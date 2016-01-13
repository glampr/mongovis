class DbClient

  def initialize
  end

  def connect(opts)
    opts.reject! { |k, v| v.to_s.empty? }
    host = (opts.values_at(:mongo_host, "mongo_host") + ["127.0.0.1:27017"]).compact.first
    @db  = (opts.values_at(:mongo_db, "mongo_db") + ["tmp"]).compact.first
    user = (opts.values_at(:mongo_user, "mongo_user")).compact.first
    pass = (opts.values_at(:mongo_pass, "mongo_pass")).compact.first
    connection_options = {database: @db}
    if !user.nil? && !pass.nil?
      connection_options[:user] = user
      connection_options[:password] = pass
      connection_options[:auth_mech] = :plain
    end
    if @client.nil? || server_address != host
      @client.try(:close)
      @client = Mongo::Client.new([host], connection_options)
    end
  end

  def close

  end

  def client
    @client
  end

  def server_address
    @client.try(:cluster).try(:servers).try(:first).try(:address).to_s
  end

  def database
    @db
  end

  def collections
    @client.database.collections
  end

  def collection_fields(collection_name)
    map = %Q{
      function() {
        var serializeDoc = function(doc, separator, maxDepth) {
          var result = {};

          function isHash(v) {
            var isArray = Array.isArray(v);
            var isObject = typeof v === 'object';
            var specialObject = v instanceof Date ||
                                v instanceof ObjectId ||
                                v instanceof BinData ||
                                v instanceof NumberLong;
            return !specialObject && !isArray && isObject;
          }

          function serialize(document, parentKey, maxDepth) {
            for (var key in document) {
              // skip over inherited properties such as string, length, etch
              if (!document.hasOwnProperty(key)) {
                continue;
              }
              var value = document[key];
              // objects are skipped here and recursed into later
              // if (!isHash(value)) // Uncomment this line to remove parent keys of hash objects
                result[parentKey + key] = value;
              //it's an object, recurse...only if we haven't reached max depth
              if (isHash(value) && maxDepth > 1) {
                serialize(value, parentKey + key + separator, maxDepth - 1);
              }
            }
          }
          serialize(doc, '', maxDepth);
          return result;
        };

        serializedDoc = serializeDoc(this, '->', 10000)
        for (var key in serializedDoc) { emit(key, null); }
      }
    }

    reduce = %Q{
      function(key, values) {
        return null;
      }
    }

    keys = []
    @client.database[collection_name].find.map_reduce(map, reduce, {
      out: {inline: 1},
      raw: true
    }).each { |h| keys << h["_id"].gsub("->", ".") }
    keys
  end

  def query(collection_name, params)
    geofield = params[:geofield]
    query = JSON.parse(params[:query].to_s.strip) rescue query = nil
    results = @client.database[collection_name].find(query)
    results = results.skip(params[:skip].to_i) if !params[:skip].to_s.empty?
    results = results.limit(params[:limit].to_i) if !params[:limit].to_s.empty?
    results = results.sort(params[:sort]) if !params[:sort].to_s.empty?

    {
      type: "FeatureCollection",
      features: results.map { |r| r[geofield] } .compact.map do |g|
                  {type: "Feature", geometry: g, properties: {}}
                end
    }
  end

end
