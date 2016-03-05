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
  field :distance, type: Integer
  field :duration_sec, type: Integer
  field :weight, type: Integer

end

class PostLink < Link

end

class RegionLink < Link

end
