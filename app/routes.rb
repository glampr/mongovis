module Sinatra
  module SociaLinks
    module Routes

      def self.registered(app)
        app.before do
          settings.dbclient.connect(cookies)
        end

        app.get '/' do
          erb :index, locals: {geofield: "", query: "", aggregation: "", results: []}
        end

        app.post '/' do
          geofield = params[:geofield]
          query = params[:query].strip
          aggregation = params[:aggregation].strip
          results = settings.dbclient.query(cookies[:mongo_collection], params)

          # erb :index, locals: {geofield: geofield, query: query, results: results}
          results.to_json
        end

        app.get '/region_links' do
          @categories = Region.distinct(:category)
          category = params[:category]
          @region_links = RegionLink.where("$or" => [{a_type: category}, {b_type: category}]).asc(:interval).group_by(&:interval)
          @region_links.keys.each do |interval|
            list = @region_links[interval]
            @region_links[interval] = list.partition { |rl| rl.a_type.nil? }
          end
          erb :region_links
        end

        app.get '/collection/:mongo_collection' do
          cookies[:mongo_collection] = params[:mongo_collection]
          {keys: settings.dbclient.collection_fields(params[:mongo_collection])}.to_json
        end

        app.get '/connection' do
          erb :connection
        end

        app.post '/connection' do
          cookies[:mongo_host] = params[:mongo_host]
          cookies[:mongo_db]   = params[:mongo_db]

          # not good practice, but easy hack
          cookies[:mongo_user] = params[:mongo_user]
          cookies[:mongo_pass] = params[:mongo_pass]

          redirect to('/')
        end

      end

    end
  end
end
