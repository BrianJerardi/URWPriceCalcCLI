require "rubygems"
require "active_record"
require "active_support"

module URWPriceCalc

	module_function

	def destroy
		Models::Quality.destroy_all
		Models::ItemPrice.destroy_all
	end

	def addQuality(description, multiplier)
		puts "Adding: #{description} #{multiplier}"
		Models::Quality.create(
			:description => description,
			:multiplier => multiplier)
	end

	def showQualities
		Models::Quality.find(:all).map(&:to_s)
	end

	def addItemPrice(itemName, itemPrice)
		puts "Adding: #{itemName} #{itemPrice}"
		Models::ItemPrice.create(
			:name => itemName,
			:price => itemPrice)
	end

	def showItemPrices
		Models::ItemPrice.find(:all).map(&:to_s)
	end

	def addInventory(itemQuality, itemName)
		puts "Adding: #{itemQuality} #{itemName}"
		puts Models::Quality.find_by_description(itemQuality).id
		puts Models::ItemPrice.find_by_name(itemName).id
		Models::Inventory_Item.create(
			:quality_id => Models::Quality.find_by_description(itemQuality).id,
			:itemPrice_id => Models::ItemPrice.find_by_name(itemName).id)	
	end

	def showInventory
		"Showing Inventory PLACEHOLDER" 
		Models::Inventory_Item.find(:all).map(&:to_s)
	end		

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

	def unreqCommand
		puts "Unrecognized command"
	end

	def connect(dbfile="data/urwPriceCalc.db")
		ActiveRecord::Base.establish_connection(
			:adapter => "sqlite3",
			:database => dbfile
		)
	end

	module Models
		class Quality < ActiveRecord::Base
			def to_s
				"#{id}. #{description} \t #{multiplier}"
			end

		end

		class ItemPrice < ActiveRecord::Base
			def to_s
				"#{id}. #{name} \t #{price}"
			end
		end

		class Inventory_Item < ActiveRecord::Base
			belongs_to :quality
			belongs_to :itemPrice
			def truePrice
				quality.multiplier*itemPrice.price
			end
				
			def to_s
				"#{id}. #{quality.description} #{itemPrice.name}: \t" + 
				truePrice.to_s
			end
		end

		module_function

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
