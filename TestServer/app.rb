require 'yaml'
require 'json'
require 'sinatra'

def load_version
  YAML.load_file('versions.yaml')
end

def save_version(params)
  p params.to_yaml
  File.write 'versions.yaml', params.to_yaml
end

def get_version
  data = load_version

  {
    last_version: data['version'],
    update_type:  data['type']
  }
end

get '/' do
  data = load_version

  erb :index, locals: {
    version: data['version'],
    type:    data['type']
  }
end

post '/set-version' do
  save_version(params)

  redirect to('/')
end

get '/versions/ios' do
  content_type :json

  get_version.to_json
end

