require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'
require 'active_record'

# Helpers
require './config/environments'
require './lib/render_partial'
require './ordinal'

# Set Sinatra variables
set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :views, 'views'
set :public_folder, 'public'
set :haml, {:format => :html5} # default Haml format is :xhtml


class Participant < ActiveRecord::Base
  validates :name, :email, :year, :department, :team, :presence => true

  def as_json(options={})
    result = super
    result["participant"]["year"] = year.ordinalize.to_s
    puts result.inspect
    return result
  end
end

# Application routes
get '/' do
  haml :index, :layout => :'layouts/application'
end

# Application routes
get '/participants.json' do
  content_type :json
  Participant.all.to_json
end

post '/sign_up' do
  @participant = Participant.new({
    name: params[:name],
    email: params[:email],
    year: params[:year],
    department: params[:department],
    team: params[:team]
  })

  @signed_up = @participant.save
  haml :index, :layout => :'layouts/application'
end

get '/potential_teams.json' do
  content_type :json
  Participant.uniq.pluck(:team).to_json
end

get '/potential_departments.json' do
  content_type :json
  Participant.uniq.pluck(:department).to_json
end

get '/members_for_team.json' do
  content_type :json
  teammates = []
  if params.has_key? 'team'
    teammates = Participant.find_all_by_team(params[:team])
  end
  teammates.to_json
end

get '/about' do
  haml :about, :layout => :'layouts/page'
end
