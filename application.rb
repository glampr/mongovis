require 'sinatra/base'
require 'sinatra/cookies'
require 'sinatra/asset_pipeline'
require './app/dbclient'
require './app/routes'


class MongoVis < Sinatra::Application
  helpers Sinatra::Cookies
  register Sinatra::MongoVis::Routes
  register Sinatra::AssetPipeline

  set :dbclient, DbClient.new
end
