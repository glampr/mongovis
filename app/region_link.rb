class RegionLink
  include Mongoid::Document

  field :a_loc, type: Hash
  field :b_loc, type: Hash
  field :a_times, type: Array
  field :b_times, type: Array
  field :a_type, type: String
  field :b_type, type: String
  field :distance, type: Integer
  field :duration_sec, type: Integer
  field :line, type: Hash
  field :line_weight, type: Integer

  def start_point
    GeoRuby::SimpleFeatures::Point.from_coordinates(line["coordinates"].first)
  end

  def end_point
    GeoRuby::SimpleFeatures::Point.from_coordinates(line["coordinates"].last)
  end

  def route
    GeoRuby::SimpleFeatures::LineString.from_coordinates(line["coordinates"])
  end

end
