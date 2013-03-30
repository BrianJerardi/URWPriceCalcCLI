# The program takes command line paramters and manages items
# for the game urw
#
# Author::	Brian Jerardi

require "rubygems"
require "active_record"
require "active_support"

# This module contains all functions and classes for the urwp program
module URWPriceCalc

	module_function

	# Destroy all data in the database
	def destroy
		Models::Quality.destroy_all
		Models::ItemPrice.destroy_all
		Models::Inventory_Item.destroy_all
	end

	# Add a Quality to the db
	#
	# Takes:
	# * description - The description of the quality (ex: poor)
	# * multiplier - The multiplier associated with the quality (ex: 0.5)
	def addQuality(description, multiplier)
		puts "Adding: #{description} #{multiplier}"
		Models::Quality.create(
			:description => description,
			:multiplier => multiplier)
	end

	# Show all Qualities in the database
	def showQualities
		Models::Quality.find(:all).map(&:to_s)
	end

	# Add an Item with it's price to the database
	#
	# Takes:
	# * itemName - The name of the item (ex; spear)
	# * itemPrice - The price of the item (ex: 344)
	def addItemPrice(itemName, itemPrice)
		puts "Adding: #{itemName} #{itemPrice}"
		Models::ItemPrice.create(
			:name => itemName,
			:price => itemPrice)
	end

	# Show all Item Prices int he database
	def showItemPrices
		Models::ItemPrice.find(:all).map(&:to_s)
	end

	# Add an invetory item to the database
	#
	# Takes:
	# * itemQuality - The quality of the item (ex: poor)
	# * itemName - The name of the item (ex: spear)
	def addInventory(itemQuality, itemName)
		puts "Adding: #{itemQuality} #{itemName}"
		Models::Inventory_Item.create(
			:quality_id => Models::Quality.find_by_description(itemQuality).id,
			:itemPrice_id => Models::ItemPrice.find_by_name(itemName).id)	
	end

	# Show all the Inventory Items
	def showInventory
		items = Models::Inventory_Item.find(:all, 
						    :group => "quality_id,itemPrice_id"
						   ).map(&:to_s)
	#	counts = Models::Inventory_Item.count(:all,
	#					      :group => "quality_id,itemPrice_id")
	end		

	# Process the command line arguments
	#
	# Takes:
	# * cmd - an array of command line arguments (ex: i)
	def process_command(cmd)
		args = Array(cmd)
		command = args.shift
		case(command)
		when "setup_db"
			URWPriceCalc::Models.generate_schema
		when "+q"
			addQuality(args[0], args[1]) rescue unreqCommand
		when "+p"
			addItemPrice(args[0], args[1]) rescue unreqCommand
		when "+i"
			addInventory(args[0], args[1]) rescue unreqCommand
		when "q"
			puts showQualities
		when "p"
			puts showItemPrices
		when "i"
			puts showInventory
		when "destroy"
			destroy
		else
			unreqCommand
		end
	end

	# Displays "Unrecognized command"
	def unreqCommand
		puts "Unrecognized command"
	end

	# Connect the the database
	def connect(dbfile="data/urwPriceCalc.db")
		ActiveRecord::Base.establish_connection(
			:adapter => "sqlite3",
			:database => dbfile
		)
	end

	# Module containg the Data Models
	module Models

		# Class for a Quality Model
		class Quality < ActiveRecord::Base
			
			# To string method for a Quality Model
			#
			# Ex:
			# 6. poor	0.5
			def to_s
				"#{id}. #{description} \t #{multiplier}"
			end

		end

		# Class for an ItemPrice Model
		class ItemPrice < ActiveRecord::Base
		
			# To string method for an ItemPrice Model
			#
			# Ex:
			# 1. spear	344	
			def to_s
				"#{id}. #{name} \t #{price}"
			end
		end

		# Class for an Invetory_Item Model
		class Inventory_Item < ActiveRecord::Base
			belongs_to :quality
			belongs_to :itemPrice

			# Gets the true price of the item by multipling the
			# price by the multiplier
			#
			# Sample:
			# a poor spear
			# * multiplier: 	0.5
			# * price:	344
			# * returns:	172
			def truePrice
				quality.multiplier*itemPrice.price
			end
			
			# To string method for an Inventory_Item Model
			#
			# Ex:
			# 1. poor	spear	
			def to_s
				"#{id}. #{quality.description} #{itemPrice.name}: \t" + 
				truePrice.to_s
			end
		end

		module_function

		# Generates the database schema
		def generate_schema
			ActiveRecord::Schema.define do
				create_table :qualities do |t|
					t.column :description, :string
					t.column :multiplier, :double
				end

				create_table :item_prices do |t|
					t.column :name, :string
					t.column :price, :double
				end

				create_table :inventory_items do |t|
					t.column :quality_id, :integer
					t.column :itemPrice_id, :integer
				end
			end
		end
	end
end
