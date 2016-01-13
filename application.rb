class MongoVis < Sinatra::Application
  helpers Sinatra::Cookies
  register Sinatra::MongoVis::Routes
  register Sinatra::AssetPipeline

end
