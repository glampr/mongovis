require 'rubygems'
require 'bundler'

Bundler.require

require './application'

require 'sinatra/asset_pipeline/task'
Sinatra::AssetPipeline::Task.define! MongoVis

run MongoVis
