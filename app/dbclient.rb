class DbClient

  def initialize
  end

  def connect(opts)
    opts.reject! { |k, v| v.to_s.empty? }
    host = (opts.values_at(:mongo_host, "mongo_host") + ["127.0.0.1:27017"]).compact.first
    db   = (opts.values_at(:mongo_db, "mongo_db") + ["tmp"]).compact.first
    user = (opts.values_at(:mongo_user, "mongo_user")).compact.first
    pass = (opts.values_at(:mongo_pass, "mongo_pass")).compact.first
    connection_options = {database: db}
    if !user.nil? && !pass.nil?
      connection_options[:user] = user
      connection_options[:password] = pass
      connection_options[:auth_mech] = :plain
    end
    if @client.nil? || @client.cluster.servers.first.address.to_s != host
      @client = Mongo::Client.new([host], connection_options)
    end
  end

  def close

  end

end
