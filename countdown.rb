require 'rubygems'
require 'sinatra'
require	'mongo'
require 'json'

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
	begin
		time_zone_offset = params[:timezone].to_i
		date = DateTime.new(
				params[:year].to_i, 
				params[:month].to_i, 
				params[:day].to_i, 
				params[:hour].to_i + time_zone_offset / MINUTES_PER_HOUR, 
				params[:minute].to_i + time_zone_offset % MINUTES_PER_HOUR
			).to_json
		id = db[COLLECTION_NAME].insert( date: date.to_s )
		redirect "countdown/#{id}"
	rescue ArgumentError => e
		redirect :new
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