module Sinatra
  module MongoVis
    module Routes

      def self.registered(app)
        app.before do
          @dbclient = DbClient.new(cookies)
        end

        app.get '/' do
          erb :index
        end

        app.get '/connection' do
          erb :connection
        end

        app.post '/connection' do
          cookies[:mongo_host] = params[:mongo_host]
          cookies[:mongo_user] = params[:mongo_user]
          cookies[:mongo_pass] = params[:mongo_pass]
          cookies[:mongo_db]   = params[:mongo_db]
          redirect to('/connection')
        end
      end

    end
  end
end
