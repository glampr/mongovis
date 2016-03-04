class Path
  include Mongoid::Document

  field :username, type: String
  field :length, type: Integer
  field :times, type: Array
  field :route, type: Hash     # GeoJSON LineString
  field :post_ids, type: Array

  def self.to_links(criteria)
    PostLink.collection.drop
    links = []
    criteria.each do |path|
      path.length.times do |i|
        link = PostLink.new
        link.id = "#{path.id}_#{i}"
        link.username = path.username
        link.a_id = path.post_ids[i]
        link.b_id = path.post_ids[i + 1]
        link.a_loc = {type: "Point", coordinates: path.route["coordinates"][i]}
        link.b_loc = {type: "Point", coordinates: path.route["coordinates"][i + 1]}
        link.a_time = Time.at path.times[i]
        link.b_time = Time.at path.times[i + 1]
        orgn = GeoRuby::SimpleFeatures::Point.from_coordinates(link[:a_loc][:coordinates])
        dest = GeoRuby::SimpleFeatures::Point.from_coordinates(link[:b_loc][:coordinates])
        link.distance = orgn.spherical_distance(dest)
        link.duration_sec = path.times[i + 1] - path.times[i]
        links << link.as_document
      end
    end
    PostLink.collection.insert_many(links)
  end

end
