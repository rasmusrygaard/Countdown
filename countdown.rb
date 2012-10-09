require "sinatra"
require 'json'
require 'mongo'
require 'sinatra/flash'
require 'uri'
require "haml"

COLLECTION_NAME = 'countdowns'
DATABASE_NAME = 'db'
SECONDS_PER_MINUTE = 60
MINUTES_PER_HOUR = 60
HOURS_PER_DAY = 24
SECONDS_PER_DAY = SECONDS_PER_MINUTE * MINUTES_PER_HOUR * HOURS_PER_DAY

def get_connection
  return @db_connection if @db_connection
  if ENV["MONGOHQ_URL"]
    db = URI.parse(ENV[MONGOHQ_URL])
    db_name = db.path.gsub(/^\//, '')
    @db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
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
  validCountdown = true
  matches = /(?<day>\d+)\/(?<month>\d+)\/(?<year>\d+)/.match(params[:date])
  if matches.nil?
    setError('date', params[:date])
    validCountdown = false
  end
  timeMatch = /\d\d?/
  hour = timeMatch.match(params[:hour])
  if hour.nil? || hour[0].to_i >= 24
    setError('hour', params[:hour]) 
    validCountdown = false
  end
  minute = timeMatch.match(params[:minute])
  if minute.nil? || minute[0].to_i >= 60
    setError('minute', params[:minute]) 
    validCountdown = false
  end
  if !validCountdown
    redirect :new
  else
    time_zone_offset_minutes = params[:timezone].to_i
    date = Time.new(
        matches[:year].to_i,
        matches[:day].to_i,
        matches[:month].to_i,
        hour[0].to_i,
        minute[0].to_i,
        0,
        -time_zone_offset_minutes * SECONDS_PER_MINUTE
      ).utc.to_json
    # Store the UTC date as a JSON string.
    id = get_connection()[COLLECTION_NAME].insert( date: date.to_s, description: params[:description] )
    redirect "countdown/#{id}"
  end
end

# Look up the given countdown in the database and return its serialized version
get '/countdown/:id' do
  doc = get_connection()[COLLECTION_NAME].find_one( _id: BSON::ObjectId(params[:id]))
  @date = Time.parse(doc['date'])
  @event = doc['description']
  haml :show
end

# Look up the given countdown in the database and return its serialized version
get '/api/countdown/:id' do
  begin
    document = get_connection()[COLLECTION_NAME].find_one( _id: BSON::ObjectId(params[:id]))
    document['date'].to_json
  rescue
    nil.to_json
  end
end

def setError(name, value)
  flash[:error] = "Invalid #{name}: #{value}"
end