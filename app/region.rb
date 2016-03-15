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
    Region.unset(:post_ids)
    Region.all.each do |region|
      region.add_to_set(post_ids: Post.where(coordinates: {"$geoWithin" => {"$geometry" => region.bounds}}).map(&:_id))
    end
  end

end
