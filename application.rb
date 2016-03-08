require 'sinatra/base'
require 'sinatra/cookies'
require 'sinatra/asset_pipeline'
require 'mongoid'
require 'georuby'
require 'rbgraph'
require 'spacetimeid'
require './app/dbclient'
require './app/link'
require './app/post'
require './app/path'
require './app/region'
require './app/routes'


class SociaLinks < Sinatra::Application
  helpers Sinatra::Cookies
  register Sinatra::SociaLinks::Routes
  register Sinatra::AssetPipeline

  set :dbclient, DbClient.new
  Mongoid.load!('./config/mongoid.yml')
end
