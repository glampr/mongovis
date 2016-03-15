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
