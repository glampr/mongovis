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


# [
#   {"$unwind" : "$b_times"},
#   {"$project" : {
#     "a_loc": 1,
#     "b_loc": 1,
#     "hour": {"$hour": "$b_times"},
#     "line": 1,
#     "count": {"$literal" : 1}
#   }},
#   {"$match" : {"hour" : {"$gte" : 4, "$lt": 10}}},
#   {"$group" : {
#     "_id": "$_id",
#     "a_loc": {"$first" : "$a_loc"},
#     "b_loc": {"$first" : "$b_loc"},
#     "line": {"$first" : "$line"},
#     "line_weight": {"$sum" : "$count"}
#   }},
#   {"$match" : {"line_weight" : {"$gte" : 2}}}
# ]
