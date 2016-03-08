class Link
  include Mongoid::Document

  field :username, type: String
  field :a_id, type: Integer
  field :b_id, type: Integer
  field :a_loc, type: Hash
  field :b_loc, type: Hash
  field :line, type: Hash
  field :a_time, type: Time
  field :b_time, type: Time
  field :a_type, type: String
  field :b_type, type: String
  field :distance, type: Integer
  field :duration_sec, type: Integer
  field :weight, type: Integer

  def start_point
    GeoRuby::SimpleFeatures::Point.from_coordinates(a_loc["coordinates"])
  end

  def end_point
    GeoRuby::SimpleFeatures::Point.from_coordinates(b_loc["coordinates"])
  end

  def route
    GeoRuby::SimpleFeatures::LineString.from_coordinates(line["coordinates"])
  end

end

class PostLink < Link

  def self.originating_from(category)
    for_category(:out)
  end

  def self.leading_to(category)
    for_category(:in)
  end

  def self.for_category(category, in_out_or_both = :in)
    all_post_ids = Region.where(category: category).pluck(:post_ids).flatten
    case in_out_or_both
    when :in then self.in(b_id: all_post_ids)
    when :out then self.in(a_id: all_post_ids)
    when :both then self.in(a_id: all_post_ids, b_id: all_post_ids)
    end
  end

  def self.hybrid_grid(category, in_out_or_both = :in, max_level = 2, max_nodes = 10)
    regions = Region.where(category: category).not.with_size(post_ids: 0).entries
    region_per_post = {}
    regions.each { |r| r.post_ids.each { |pi| region_per_post[pi] = r }}
    graph = Rbgraph::DirectedGraph.new
    links = for_category(category, in_out_or_both)

    links.each do |link|
      start_node = nil
      end_node = nil
      case in_out_or_both

      # Incoming links for the 'category', i.e. links that end inside regions of this category
      when :in
        start_region = region_per_post[link.a_id]
        if start_region.nil?
          point = SpaceTimeId.new(link.a_loc["coordinates"])
          start_node = {id: point.xy_id_str, data: {txy: point}}
        else
          start_node = {id: start_region.center["coordinates"].join("_") }
        end
        end_region = region_per_post[link.b_id]
        end_node = {id: end_region.center["coordinates"].join("_") }
      # Outgoing links for the 'category', i.e. links that begin from regions of this category
      when :out

      when :both

      end

      graph.add_edge!(start_node, end_node, 1, in_out_or_both, {
        t: [link.a_time, link.b_time]
      }) unless start_node[:id] == end_node[:id] # prevents self connecting edges
    end
    aggregate_graph(graph, max_level, max_nodes)
    output_edges(graph, category)
    graph
  end

  def self.aggregate_graph(graph, max_level, max_nodes)
    (1..max_level).each do |level|
      candidate_nodes = graph.nodes.values.select{ |node| node.data[:txy].try(:level) == level - 1 }
      nodes_per_cubicle = candidate_nodes.group_by { |node| node.data[:txy].xy_parent.id }
      nodes_per_cubicle.each do |parent_id, node_list|
        if node_list.length < max_nodes
          parent = SpaceTimeId.new(parent_id, level: level)
          # do not aggregate if there are nodes of more than one level down within the parent
          next if parent.xy_descendants.any? do |pn|
            graph.nodes[pn.id] && graph.nodes[pn.id].data[:txy].level == pn.level - 1
          end
          parent_node = graph.merge_nodes!(node_list.map(&:id), parent.id, {txy: parent})
          # remove node if it contained only self connecting edges
          graph.remove_node!(parent_node) if parent_node.edges.empty?
        end
      end
    end
  end

  def self.output_edges(graph, category)
    graph.edges.values.each do |edge|
      p1 = {"type" => "Point", "coordinates" => edge.node1.id.split("_").map(&:to_f)}
      p2 = {"type" => "Point", "coordinates" => edge.node2.id.split("_").map(&:to_f)}
      lc = [p1["coordinates"], p2["coordinates"]]
      link = RegionLink.new(
        id: lc.flatten.join("_"),
        a_loc: p1,
        b_loc: p2,
        line: {"type" => "LineString", "coordinates" => lc},
        a_type: (edge.node1.data[:txy].nil? ? category : nil),
        b_type: (edge.node2.data[:txy].nil? ? category : nil),
        weight: edge.weight
      )
      link.distance = link.start_point.spherical_distance(link.end_point)
      link.upsert
    end
  end

end

class RegionLink < Link

end
