class CountdownTarget < ActiveRecord::Base
	validates_numericality_of :month
end