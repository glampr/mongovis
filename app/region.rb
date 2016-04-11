class Region
  include Mongoid::Document

  field :area, type: String
  field :cluster_id, type: Integer
  field :category, type: String
  field :bounds, type: Hash
  field :center, type: Hash
  field :post_ids, type: Array

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
    Region.all.unset(:post_ids)
    Region.all.each do |region|
      puts region.inspect
      posts_in_region = Post.where(coordinates: {"$geoWithin" => {"$geometry" => region.bounds}}).entries
      puts "Found #{posts_in_region.length} posts".blue
      region.add_to_set(post_ids: posts_in_region.map(&:_id))
      puts "--------"
    end
  end

end
