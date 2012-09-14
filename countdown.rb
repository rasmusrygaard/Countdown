require 'rubygems'
require 'sinatra'
require	'mongo'
require 'json'

COLLECTION_NAME = 'countdowns'
DATABASE_NAME = 'db'

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
		date = DateTime.new(
				params[:year].to_i, 
				params[:month].to_i, 
				params[:day].to_i, 
				params[:hour].to_i, 
				params[:minute].to_i
			).to_json
		id = db[COLLECTION_NAME].insert( date: date.to_s )
		redirect "countdown/#{id}"
	rescue ArgumentError => e
		redirect :new
	end
end

# Look up the given countdown in the database and return its serialized version
get '/countdown/:id' do
	db[COLLECTION_NAME].find_one( _id: BSON::ObjectId(params[:id]))['date']
end