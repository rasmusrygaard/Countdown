require "sinatra"
require 'mongo'
require 'json'
require 'sinatra/flash'

enable :sessions

class Countdown < Sinatra::Base

  COLLECTION_NAME = 'countdowns'
  DATABASE_NAME = 'db'
  SECONDS_PER_MINUTE = 60
  MINUTES_PER_HOUR = 60
  HOURS_PER_DAY = 24
  SECONDS_PER_DAY = SECONDS_PER_MINUTE * MINUTES_PER_HOUR * HOURS_PER_DAY

  db = Mongo::Connection.new.db(DATABASE_NAME, pool_size: 5, timeout: 5)

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
      time_zone_offset = params[:timezone].to_i
      date = DateTime.new(
          matches[:year].to_i,
          matches[:day].to_i,
          matches[:month].to_i,
          hour[0].to_i + time_zone_offset / MINUTES_PER_HOUR,
          minute[0].to_i + time_zone_offset % MINUTES_PER_HOUR
        ).to_json
      id = db[COLLECTION_NAME].insert( date: date.to_s )
      redirect "countdown/#{id}"
    end
  end

  # Look up the given countdown in the database and return its serialized version
  get '/countdown/:id' do
    @date = DateTime.parse(db[COLLECTION_NAME].find_one( _id: BSON::ObjectId(params[:id]))['date'])
    haml :show
  end

  # Look up the given countdown in the database and return its serialized version
  get '/api/countdown/:id' do
    begin
      document = db[COLLECTION_NAME].find_one( _id: BSON::ObjectId(params[:id]))
      document['date'].to_json
    rescue
      nil.to_json
    end
  end

  def setError(name, value)
    flash[:error] = "Invalid #{name}: #{value}"
  end

  # Return the days, hours, minutes, and seconds until the given time
  def remainder(time)
    seconds = ((time - DateTime.now) * SECONDS_PER_DAY).to_i
    return 0, 0, 0, 0 if seconds < 0
    # Do not mod yet to simplify calculations
    minutes = seconds / SECONDS_PER_MINUTE
    hours = minutes / MINUTES_PER_HOUR
    days = hours / HOURS_PER_DAY
    puts minutes
    # Mod all values
    return days, hours % HOURS_PER_DAY, minutes % MINUTES_PER_HOUR, seconds % SECONDS_PER_MINUTE
  end
end