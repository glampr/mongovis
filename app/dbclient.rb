class DbClient

  def initialize(opts)
    connection_options = {database: opts.fetch("mongo_db", "tmp")}
    if !opts.fetch("mongo_user", "").empty? && !opts.fetch("mongo_pass", "").empty?
      connection_options[:user] = opts.fetch["mongo_user"]
      connection_options[:pass] = opts.fetch["mongo_pass"]
      connection_options[:auth_mech] = :plain
    end
    @client = Mongo::Client.new([opts.fetch("mongo_host", "127.0.0.1:27017")], connection_options)
  end

end
