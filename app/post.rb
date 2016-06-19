class Post
  include Mongoid::Document

  field :user_id, type: Integer
  field :user_screen_name, type: String
  field :text, type: String
  field :image, type: String
  field :posted_at, type: Time
  field :timestamp, type: Integer
  field :coordinates, type: Hash

  # mongoimport --host 127.0.0.1 --database test --collection posts --jsonArray --file import.json
  def self.import(connection_options)
    RawPost.store_in(connection_options)
    RawPost.all.in_batches(:id, 10000).each do |records|
      documents = []
      records.each do |r|
        document = {}
        document[:_id] = r["_id"] || r["id"]
        document[:user_id] = r["user"]["_id"] || r["user"]["id"]
        document[:user_screen_name] = r["user"]["screen_name"]
        document[:text] = r["text"]
        document[:posted_at] = Time.parse(r["timestamp_ms"] / 1000)
        document[:timestamp] = r["timestamp_ms"] / 1000
        document[:coordinates] = r["coordinates"]
        documents << document
      end
      BulkWriter.upsert_all(documents, Post.collection)
    end
  end

  def self.to_paths(criteria)
    Path.collection.drop
    criteria = criteria.ne(coordinates: nil)
    aggregation = collection.find.aggregate([
      {:$match => criteria.selector},
      {:$sort  => {timestamp: 1}},
      {:$group => {
        :_id       => "$user_id",
        :username  => {"$first" => "$user_screen_name"},
        :length    => {"$sum"   => 1},
        :times     => {"$push"  => "$timestamp"},
        :locations => {"$push"  => "$coordinates.coordinates"},
        :post_ids  => {"$push"  => "$_id"}
      }},
      {:$project => {
        :username  => "$username",
        :length    => {"$subtract" => ["$length", 1]},
        :times     => "$times",
        :route     => {"type" => {"$literal" => "LineString"}, "coordinates" => "$locations"},
        :post_ids  => "$post_ids"
      }},
      {:$match => {length: {"$gt" => 0}}},
      {:$out   => "paths"},
    ])
    aggregation = aggregation.allow_disk_use(true)
    aggregation.entries
  end

end


class RawPost
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
end
