require 'rubygems'
require 'bundler'

Bundler.require

require 'sinatra/base'
require 'sinatra/cookies'
require 'sinatra/asset_pipeline'
require './app/dbclient'
require './app/routes'
require './application'

require 'sinatra/asset_pipeline/task'
Sinatra::AssetPipeline::Task.define! MongoVis

run MongoVis
