#!/usr/bin/env ruby
require 'sqlite3'

# DB Name Constant
DB_NAME = "database/urwPriceCLI.db"

# Quality Table Constants
QUALITY_TABLE_NAME 		= "Quality"
QUALITY_COLUMN_TO_GET 		= "Multiplier"
QUALITY_COLUMN_TO_SEARCH 	= "Description"

# ItemPrices Table Constants
ITEMPRICES_TABLE_NAME 		= "ItemPrices"
ITEMPRICES_COLUMN_TO_GET	= "ItemPrice"
ITEMPRICES_COLUMN_TO_SEARCH	= "ItemName"

# Variable to hold Database
$db 


def loadDB()
	$db= SQLite3::Database.new (DB_NAME)
	puts "Load DB: " + DB_NAME
	puts "Version: " + ($db.get_first_value 'select SQLITE_VERSION()')
end


def setDBValues(tableName, keyValue, fieldValue )
	$db.execute ("INSERT INTO #{tableName} 
		     VALUES('#{keyValue}', #{fieldValue})")	
end


def getValueFromDB(tableToSearch, columnToGet, columnToSearch, valueToSearch)
	return $db.get_first_value( 
				  "SELECT #{columnToGet} 
				  FROM #{tableToSearch}  
				  WHERE #{columnToSearch} = ?",
				  valueToSearch)
end

def getQualityMultiplier(description)
	return getValueFromDB(QUALITY_TABLE_NAME,
			      QUALITY_COLUMN_TO_GET,
			      QUALITY_COLUMN_TO_SEARCH,
			      description)
end

def setQualityValues(description, multiplier)
	setDBValues(QUALITY_TABLE_NAME,
		    description,
		    multiplier)
end

def setItemValues(itemName, itemPrice)
	setDBValues(ITEMPRICES_TABLE_NAME,
		    itemName,
		    itemPrice)
end

def getItemValue(itemName)
	return getValueFromDB(ITEMPRICES_TABLE_NAME,
			      ITEMPRICES_COLUMN_TO_GET,
			      ITEMPRICES_COLUMN_TO_SEARCH,
			      itemName)
end


def getFullItemValue(description, itemName)
	return getQualityMultiplier(description) * getItemValue(itemName)
end


begin
	loadDB()
	puts getFullItemValue(ARGV[0], ARGV[1])
	#setItemValues(ARGV[0], ARGV[1])
rescue SQLite3::Exception => e
	puts "Exception occured"
	puts e
ensure
	$db.close if $db
end

#puts(getQualityMultiplier('poor'))
