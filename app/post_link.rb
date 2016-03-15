class PostLink
  include Mongoid::Document

  field :username, type: String
  field :a_id, type: Integer
  field :b_id, type: Integer
  field :a_loc, type: Hash
  field :b_loc, type: Hash
  field :line, type: Hash
  field :a_time, type: Time
  field :b_time, type: Time
  field :a_types, type: Array
  field :b_types, type: Array
  field :distance, type: Integer
  field :duration_sec, type: Integer

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

  def start_point
    GeoRuby::SimpleFeatures::Point.from_coordinates(a_loc["coordinates"])
  end

  def end_point
    GeoRuby::SimpleFeatures::Point.from_coordinates(b_loc["coordinates"])
  end

  def route
    GeoRuby::SimpleFeatures::LineString.from_coordinates(line["coordinates"])
  end

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

  def self.assign_categories
    categories = Region.distinct(:category)
    categories.each do |category|
      all_post_ids = Region.where(category: category).distinct(:post_ids)
      self.in(a_id: all_post_ids).add_to_set(a_types: category)
      self.in(b_id: all_post_ids).add_to_set(b_types: category)
    end
  end

  def self.hybrid_grid(category, in_out_or_both = :in, max_level = 2, max_nodes = 10)
    regions = Region.where(category: category).not.with_size(post_ids: 0).entries
    region_per_post = {}
    regions.each { |r| r.post_ids.each { |pi| region_per_post[pi] = r }}
    graph = Rbgraph::DirectedGraph.new

    links = case in_out_or_both
    # Incoming links for the 'category', i.e. links that end inside regions of this category
    when :in
      RegionLink.where(b_type: category).delete_all
      where(b_types: category)
    # Outgoing links for the 'category', i.e. links that begin from regions of this category
    when :out
      RegionLink.where(a_type: category).delete_all
      where(a_types: category)
    when :both
      RegionLink.where(a_type: category).delete_all
      RegionLink.where(b_type: category).delete_all
      where(a_types: category, b_types: category)
    end

    links.each do |link|
      start_node = nil
      end_node = nil
      case in_out_or_both

      # Incoming links for the 'category', i.e. links that end inside regions of this category
      when :in
        start_region = region_per_post[link.a_id]
        if start_region.nil?
          point = LinkSpaceTimeId.new(link.a_loc["coordinates"])
          start_node = {id: point.xy_id_str, data: {txy: point}}
        else
          start_node = {id: start_region.center["coordinates"].join("_"), data: {r: start_region} }
        end
        end_region = region_per_post[link.b_id]
        end_node = {id: end_region.center["coordinates"].join("_"), data: {r: end_region} }
      # Outgoing links for the 'category', i.e. links that begin from regions of this category
      when :out

      when :both

      end

      graph.add_edge!(start_node, end_node, 1, in_out_or_both, {
        t: [[link.a_time, link.b_time]]
      }) do |graph, existing_edge, new_edge|
        existing_edge.data[:t] << [link.a_time, link.b_time]
        existing_edge.weight += new_edge.weight
      end unless start_node[:id] == end_node[:id] # prevents self connecting edges
    end

    aggregate_graph(graph, max_level, max_nodes)
    output_edges(graph, category, in_out_or_both)
    graph
  end

  def self.aggregate_graph(graph, max_level, max_nodes)
    return if max_level < 1
    (1..max_level).each do |level|
      candidate_nodes = graph.nodes.values.select{ |node| node.data[:txy].try(:level) == level - 1 }
      nodes_per_cubicle = candidate_nodes.group_by { |node| node.data[:txy].xy_parent.id }
      nodes_per_cubicle.each do |parent_id, node_list|
        if node_list.length < max_nodes
          parent = LinkSpaceTimeId.new(parent_id, level: level)
          # do not aggregate if there are nodes of more than one level down within the parent
          next if parent.xy_descendants.any? do |pn|
            graph.nodes[pn.id] && graph.nodes[pn.id].data[:txy].level == pn.level - 1
          end
          parent_node = graph.merge_nodes!(node_list.map(&:id), parent.id, {txy: parent}) do |graph, existing_edge, new_edge|
            existing_edge.data[:t] += new_edge.data[:t]
            existing_edge.weight += new_edge.weight
          end
          if node_list.length == 1
            parent_node.data[:single_node] = node_list.first
          end
          # remove node if it contained only self connecting edges
          graph.remove_node!(parent_node) if parent_node.edges.empty?
        end
      end
    end
    false_parents = graph.nodes.values.select { |n| !n.data[:single_node].nil? } .each do |fp|
      fp.id = fp.data[:single_node].id
      fp.data = fp.data[:single_node].data
    end
  end

  def self.output_edges(graph, category, in_out_or_both = :in)
    graph.edges.values.each do |edge|
      a_loc = nil; b_loc = nil; a_ctr = nil; b_ctr = nil;
      if edge.node1.data[:r].nil?
        a_loc = {"type" => "LineString", "coordinates" => edge.node1.data[:txy].xy_boundary, "properties" => {"level" => edge.node1.data[:txy].level}}
        a_ctr = edge.node1.data[:txy].xy_id_2d_center
      else
        a_loc = edge.node1.data[:r].bounds
        a_ctr = edge.node1.data[:r].center["coordinates"]
      end
      if edge.node2.data[:r].nil?
        b_loc = {"type" => "LineString", "coordinates" => edge.node2.data[:txy].xy_boundary, "properties" => {"level" => edge.node2.data[:txy].level}}
        b_ctr = edge.node2.data[:txy].xy_id_2d_center
      else
        b_loc = edge.node2.data[:r].bounds
        b_ctr = edge.node2.data[:r].center["coordinates"]
      end

      link = RegionLink.new(
        id: [a_ctr, b_ctr].flatten.join("_"),
        a_loc: a_loc,
        b_loc: b_loc,
        a_times: edge.data[:t].map(&:first),
        b_times: edge.data[:t].map(&:last),
        line: {"type" => "LineString", "coordinates" => [a_ctr, b_ctr]},
        a_type: (in_out_or_both != :in ? category : nil),
        b_type: (in_out_or_both != :out ? category : nil),
        line_weight: edge.weight
      )
      link.distance = link.start_point.spherical_distance(link.end_point)
      link.upsert
    end
  end

end

class LinkSpaceTimeId < SpaceTimeId

  self.default_options = {
    xy_base_step: 0.01,    # 0.01 degrees
    xy_expansion: 5,       # expands into a 5x5 grid recursively
    ts_steps:     [3600],  # [600, 1800, 3600, 21600, 86400] [10min, 0.5h, 1h, 6h, 1day]
    ts_expansion: 2,       # expands 2 times each interval
    decimals: 2
  }

end
