class Region
  include Mongoid::Document

  field :area, type: String
  field :cluster_id, type: Integer
  field :category, type: String
  field :bounds, type: Hash
  field :center, type: Hash
  field :post_ids, type: Array
  field :space_ids, type: Array
  field :next_regions, type: Array
  field :prev_regions, type: Array

  def geo_polygon
    GeoRuby::SimpleFeatures::Polygon.from_coordinates(bounds["coordinates"])
  end

  # mongoimport --host 127.0.0.1 --database test --collection regions --jsonArray --file import.json
  def self.import
    Region.with(database: "test").all.each do |r|
      b = JSON.parse(r["bounds"])
      c = JSON.parse(r["center"])
      Region.create(r.as_document.merge(bounds: b, center: c))
    end
  end

  def self.populate_post_ids
    Region.unset(:post_ids)
    Region.all.each do |region|
      region.add_to_set(post_ids: Post.where(coordinates: {"$geoWithin" => {"$geometry" => region.bounds}}).map(&:_id))
    end
  end

  def self.connect!
    Region.all.unset(:next_regions)
    Region.all.unset(:prev_regions)
    RegionLink.delete_all
    regions = Region.not.with_size(post_ids: 0).entries
    regions.each do |region|
      # # next regions
      outgoing_links = Link.in(a_id: region.post_ids)
      outgoing_links_other_rids = outgoing_links.map(&:b_id).flatten
      next_regions = regions.select { |r| !(outgoing_links_other_rids & r.post_ids).blank? }
      # region.add_to_set(next_regions: next_regions.map(&:id))

      regions_per_link = {}
      outgoing_links.each do |link|
        regions_per_link[link] = next_regions.select { |r| r.post_ids.include?(link.b_id) }
      end
      regions_per_link.each do |link, link_regions|
        link_regions.each do |link_region|
          RegionLink.new({
            id: "#{region.id}_#{link_region.id}_#{link.id}",
            username: link.username,
            a_id: region.id,
            b_id: link_region.id,
            a_loc: region.center,
            b_loc: link_region.center,
            line: {type: "LineString", coordinates: [region.center["coordinates"], link_region.center["coordinates"]]},
            a_time: link.a_time,
            b_time: link.b_time,
            a_type: region.category,
            b_type: link_region.category,
            distance: link.distance,
            duration_sec: link.duration_sec
          }).upsert
        end
      end

      # # prev regions
      # incoming_links = Link.in(b_id: region.post_ids)
      # prev_regions = Region.in(post_ids: incoming_links.map(&:b_id).flatten)
      # region.add_to_set(prev_regions: prev_regions.map(&:id))
    end
  end

end
