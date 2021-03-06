require 'sinatra'
require 'json'
require 'mongo'
require 'sinatra/flash'
require 'uri'
require 'haml'
require 'active_model'

COLLECTION_NAME = 'countdowns'
DATABASE_NAME = 'db'
SECONDS_PER_MINUTE = 60
MINUTES_PER_HOUR = 60
HOURS_PER_DAY = 24
SECONDS_PER_DAY = SECONDS_PER_MINUTE * MINUTES_PER_HOUR * HOURS_PER_DAY

def get_connection
  return @db_connection if @db_connection
  if ENV["MONGOHQ_URL"]
    db = URI.parse(ENV["MONGOHQ_URL"])
    db_name = db.path.gsub(/^\//, '')
    @db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
    @db_connection.authenticate(db.user, db.password) unless (db.user.nil?)
    @db_connection
  else
    @db_connection = Mongo::Connection.new.db(DATABASE_NAME, pool_size: 5, timeout: 5)
  end
end

get '/' do
  redirect :new
end

# Display a form that lets the user create a countdown.
get '/new' do
  haml :new
end

# Create a new countdown. If the given date is invalid (ie. user entered non-numeric
# values), the to_i or DateTime methods will throw an error. For now, we just redirect
# to the 'new' page.
post '/countdown' do
  c = CountdownTarget.new(params[:date], params[:hour], params[:minute], params[:timezone], params[:description])
  if c.valid?
    time = c.to_time
    redirect :new if time < Time.new
    # Store the UTC time as a JSON string.
    id = get_connection()[COLLECTION_NAME].insert( time: time.utc.to_i, event: c.description )
    redirect "countdown/#{id}"
  else 
    redirect :new
  end
end

# Look up the given countdown in the database and return its serialized version
get '/countdown/:id' do
  doc = get_connection()[COLLECTION_NAME].find_one( _id: BSON::ObjectId(params[:id]))
  @time = Time.at(doc['time'])
  @event = doc['event']
  haml :show
end

# Look up the given countdown in the database and return its serialized version as an integer
get '/api/countdown/:id' do
  begin
    document = get_connection()[COLLECTION_NAME].find_one( _id: BSON::ObjectId(params[:id]))
    document['time'].to_json
  rescue
    nil.to_json
  end
end

class CountdownTarget
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attr_accessor :date, :year, :month, :day, :hour, :minute, :description

  SECONDS_PER_MINUTE = 60

  validates :date, :hour, :minute, :description, :presence => true
  validates :hour, :numericality => { only_integer: true, greater_than_or_equal_to: 0, less_than: 24}
  validates :minute, :numericality => { only_integer: true, greater_than_or_equal_to: 0, less_than: 60}
  validates :date, :format => { :with => /\d{2}\/\d{2}\/\d{4}/, message: 'Invalid date.' }

  def initialize (date, hour, minute, time_zone_offset_minutes, description)
    @time_zone_offset_minutes = time_zone_offset_minutes.to_i
    @date = date
    @year, @month, @day = parseDate(date)
    @hour = hour
    @minute = minute
    @description = description
  end

  # Returns a 
  def to_time
    Time.new(@year, @month, @day, @hour, @minute, 0, @time_zone_offset_minutes *  - SECONDS_PER_MINUTE)
  end

  private
  # Returns a YYYY, MM, DD from a string of format "MM/DD/YYY"
  def parseDate(date_string)
    r = /(?<month>\d{2})\/(?<day>\d{2})\/(?<year>\d{4})/.match(date_string)
    return r[:year], r[:month], r[:day]
  end

end