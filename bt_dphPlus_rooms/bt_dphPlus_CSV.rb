module BT
	
	module CSVexports

		#Outputs the Component Level data to a CSV file
		require 'csv'
		require File.join(__dir__, 'bt_dphPlus_filterSelForCompo.rb')

		class Room
			# Class to hold onto all the individual room data
			
			def set_defaults
				@pid ||= '----'
				@zone ||= '----'
				@floorlevel ||= '----' 
				@roomnum ||= '----'
				@roomname ||= '----'
				@vsup ||= '----'
				@veta ||= '----'
				@tfa ||= '----'
				@foorarea ||= '----'
				@tfaavg ||= '----'
				@vn50 ||= '----'
				@vv ||= '----'
				@avgheight ||= '----'
			end
			
			def initialize(params = {})  
				params.each { |key,value| instance_variable_set("@#{key}", value) }
				set_defaults
				instance_variables.each {|var| self.class.send(:attr_accessor, var.to_s.delete('@'))}
			end
				
			def to_s
				instance_variables.inject("") {|vars, var| vars += "#{var}: #{instance_variable_get(var)}; "}
			end
		end

		def self.getDataFromCompos(_ents)
			#goes through all the selected INSTANCES and DEFINITIONS and pulls out the component's data
			#takes in the selection of objects from the user, filtered to include only the DPH+ Room Components
			#returns an array of 'Room-Class' objects. One Room-Class Objet for each room object found in the _ent set.
			roomData = [] #master array to hold all room level dictionaries
			
			#filter for only DPH valid objects	
			puts '>>> Filtering out any non-DPH+ Room Compos...'
			dphRoomInstances =  BT::Filtering.filterForDPHPCompos(_ents) #propably don't need to this again? But just to be double sure its only DPH Room Compos
			
			puts '>>> Starting to pull data from the DPH+ Room Components in the model...'
			dphRoomInstances.each do |s|
				#Pull out all the relevant data from the room component in the scene and				
				#create a new Room-Class Object to hold the values for reporting later
							
				rmname = s.definition.attribute_dictionaries['dynamic_attributes']['4roomname']
				puts "-#{rmname}- is a a DPH+ object, getting the data from it...creating a room..." #for error checking	

				roomObj = Room.new(
					:pid 		=> s.persistent_id,
					:zone 		=> s.definition.attribute_dictionaries['dynamic_attributes']['1zone'],
					:floorlevel => s.definition.attribute_dictionaries['dynamic_attributes']['2flrlevel'],
					:roomnum 	=> s.definition.attribute_dictionaries['dynamic_attributes']['3roomnum'],
					:roomname 	=> s.definition.attribute_dictionaries['dynamic_attributes']['4roomname'],
					:vsup 		=> s.definition.attribute_dictionaries['dynamic_attributes']['5supplyair'],
					:veta 		=> s.definition.attribute_dictionaries['dynamic_attributes']['6extractair'], 
					# Remember, the ones above got cahnged to look at definition now. Not sure why or it thats right....
					:tfa 		=> s.definition.attribute_dictionaries['dynamic_attributes']['tfa'],
					:foorarea 	=> s.definition.attribute_dictionaries['dynamic_attributes']['flrarea'],
					:tfaavg 	=> s.definition.attribute_dictionaries['dynamic_attributes']['tfaavg'],
					:vn50 		=> s.definition.attribute_dictionaries['dynamic_attributes']['vn50'],
					:vv 		=> s.definition.attribute_dictionaries['dynamic_attributes']['vv'],
					:avgheight 	=> s.definition.attribute_dictionaries['dynamic_attributes']['avgheight'],
					:hp_ou	 	=> s.definition.attribute_dictionaries['dynamic_attributes']['8outdoorunit'],
					:hp_ahu		=> s.definition.attribute_dictionaries['dynamic_attributes']['7ahu'],
					:hrv		=> s.definition.attribute_dictionaries['dynamic_attributes']['9hrvunit']
					)
				puts '>>> Created a Room Obj successfully'
				# put the new Room Object with all the data into the master array
				roomData << roomObj
			end
			
			# returns the array of all the Room-Class Objects
			if roomData.length > 0
				return roomData
			else
				UI.messagebox('No Room Objects came through for some reason? Error in: def getDataFromCompos(_ents)', MB_OK)
			end
		end

		def self.cleanHeaderArray(_rawArray, _unitsType)
			# takes the ugly attr names and replaces with header-ready display values
			cleanArray = []
			
			# what units to display based on _unitsType  == 'IP' or 'SI'
			schema = {
				:IP => {:len => '(ft)', :area => '(ft2)', :vol => '(ft3)', :airflow => '(cfm)'},
				:SI => {:len => '(m)', :area => '(m2)', :vol => '(m3)', :airflow => '(m3/h)'}
			}
			
			_rawArray.each do |n|
				if n == "zone"
					cleanArray << "ZONE"
				elsif n == "floorlevel"
					cleanArray << "FLOOR LEVEL"
				elsif n == "roomnum"
					cleanArray << "ROOM NUMBER"
				elsif n == "roomname"
					cleanArray << "ROOM NAME"
				elsif n == "vsup"
					cleanArray << "SUPPLY AIR FLOW #{schema["#{_unitsType}".to_sym][:airflow]}"
				elsif n == "veta"
					cleanArray << "EXTRACT AIR FLOW #{schema["#{_unitsType}".to_sym][:airflow]}"
				elsif n == "tfa"
					cleanArray << "TFA #{schema["#{_unitsType}".to_sym][:area]}"
				elsif n == "foorarea"
					cleanArray << "ACTUAL NET FLOOR AREA #{schema["#{_unitsType}".to_sym][:area]}"
				elsif n == "tfaavg"
					cleanArray << "AVERAGE RM. TFA FACTOR"
				elsif n == "vn50"
					cleanArray << "Vn50 - NET INT. VOL. #{schema["#{_unitsType}".to_sym][:vol]}"
				elsif n == "vv"
					cleanArray << "Vv - VENTILATED VOL. #{schema["#{_unitsType}".to_sym][:vol]}"
				elsif n == "pid"
					cleanArray << "SKP-PID"
				elsif n == "avgheight"
					cleanArray << "CEILING HEIGHT #{schema["#{_unitsType}".to_sym][:len]}"
				elsif n == "hp_ou"
					cleanArray << "HEAT PUMP OU"
				elsif n == "hp_ahu"
					cleanArray << "HEAT PUMP AHU"
				elsif n == "hrv"
					cleanArray << "H/ERV"
				else
					cleanArray << n.to_s
				end
			end
			
			return cleanArray #flattened array with fixed header strings
		end

		def self.filterInputAndCreateRooms(_sel, _ents)
			# goes through the selection and/or scene and pulls out the relevant data
			# filters and figures out the right units to use 
			# and creates the 'Room-Class' objects for passing on later
			puts '>>> Staring def BT:CSVExports.filterInputAndCreateRooms(_sel, _ents)'
			puts ">>> #{_sel.length} Objects in Selection"
			puts ">>> #{_ents.length} Objects in Scene"

			# decide to use sel or ents
			if _sel.length > 0
				entsTopass = _sel
			else
				entsTopass = _ents
			end

			# use the filter to find only the DPH+ objs in the scene
			puts '>>> Finding the DPH+ Objects in the scene....'
			dphRoomObjs = BT::Filtering.filterForDPHPCompos(entsTopass)
			
			# decide what units to use for the display
			units = dphRoomObjs[0].definition.get_attribute('dynamic_attributes', 'dphunits')
			puts ">>> I'm going to use #{units} units for this export"	
			
			# pull out the relevant data from the ComponentInstance dynamic_attributes and create a Room Class obj
			puts '>>> Getting data from DPH+ Room Objects....'
			arrayOfRoomObjs = getDataFromCompos(dphRoomObjs) #pulls out the 'Room-Class' objects from the Sketchup scene components

			# find all the unique Zone values and put into a list
			zoneNames = []
			arrayOfRoomObjs.each do |d|
				zoneNames << d.zone
			end
			zoneNames_Unique = zoneNames.uniq  #pulls out only the unique values into a new array
			

			# Creates a set of arrays based on the Zone Name first
			# Then populates new array entries with room data in the order desired
			puts ">>> The zone names I found are: #{zoneNames_Unique}"
			puts '>>> Sorting all the Room-Objs by zone...'
			allData = []
			zoneNames_Unique.sort_by! {|a| [ a[/\d+/].to_i, a ] } # sort zone list in place
			zoneNames_Unique.each do |u|
				zoneData = []
				arrayOfRoomObjs.each do |d|
					if d.zone == u
						#roomData.map!{ |x| x.nil? ? 0:x} 					#replaces all 'nil' values with a 0
						zoneData << d
					end
				end
				allData << zoneData
			end

			# Sort each Zone's data array using the floor number, then room number...)
			puts '>>> Sorting all the Room-Objs by floor and then room number...'
			allData.each do |z|
				#z.sort_by! {|a| [ a.zone[/\d+/].to_i , a.floorlevel[/\d+/].to_i, a.roomnum[/\d+/].to_i, a.roomnum ] } #sort in place <---- old line, save in case new breaks....
				z.sort_by! {|a| [ a.floorlevel.to_s, a.roomnum.to_s ] } # sort in place (new)
			end
			
			
			# _arrayOfRoomObjs = List of all the Room-Class objects with their data embedded
			# zoneNames_Unique = List of all the unique zone names in the scene / selection for 'grouping' later on
			# units what units should be displayed? IP or SI
			return {:roomData => allData, :units => units}
		end

		def self.outputFullCSV(_sel, _ents)
			# takes in a set of 'Room-Class' objects
			# outputs a CSV to the directory designated by the User
			# outputs a cleaned and formated, sorted CSV of ALL the data for the room-class objects
			
			# get the scene's data filter and sort it....
			puts '>>> Finding the data frorm the scene...'
			data = BT::CSVexports.filterInputAndCreateRooms(_sel, _ents) #create rooms, filter and get the data
			roomObjsToOutput = data[:roomData] #<--- all the data to output in the CSV, an array of arrays (each zone is an array in the master array)
			unitsType = data[:units] #<---- the units to use in the header
			puts unitsType

			# test, if they havn't calc'd rooms yet, warn the user
			warn = false
			if unitsType == nil
				warn = true
			end
			if warn == true
				UI.messagebox("Warning: Be sure to Calculate your dPH+ Room's Data before trying to export")
			end

			# get all the unique attribute names from the room class objects
			# and put into a flattened, 'header' ready array
			puts '>>> Setting up the CSV header...'
			instVarNameArray = []
			roomObjsToOutput.each do |zone|
				zone.each do |rm|
					(instVarNameArray << rm.instance_variables).flatten!
				end
			end
			
			instVarNameArray.uniq!  # Find all the unique values in the full array of header values
			instVarNameArray.map!{ |n| n.to_s.sub!("@", "")} # remove all the @ sybmols and convery keys to strings


			#######----------------#######
			# Write the data to a CSV file
			# find the current working directory and sets it to the Desktop
			# Dir.chdir(File.dirname(__FILE__))
			# Dir.chdir(home_dir)
			# Dir.chdir(myPath)
			
			puts '>>> Outputting to CSV....'
			# get the file save location from the user
			home_dir = ENV["HOME"] || ENV["USERPROFILE"]
			myPath = File.join(home_dir, 'Desktop')
			saveFile = UI.savepanel('Test Title', myPath, 'RoomData_All.csv')
			
			# unitsType = 'IP' #<------ get from a component
			
			# writes the csv content in a particular order
			aFile = CSV.open(saveFile, 'w') do |csv|
				puts '>>> Writing header'
				csv << BT::CSVexports.cleanHeaderArray(instVarNameArray, unitsType)  #add the header row using the cleane-up header names
				roomObjsToOutput.each do |a|
					csv << [''] #adds a blank line between zones for clarity
					a.each do |rm|  #pull out the instance varables, based on the header order
						room = []
						instVarNameArray.each do |instName|
							room << rm.instance_variable_get("@#{instName}")
						end		
						csv << room #add the room data array to the csv file
					end
				end
			end
			puts ">>> File is saved: #{saveFile}" #checks the working directory
		end

		def self.outputAddVentCSV(_sel, _ents)
			# takes in a set of 'Room-Class' objects
			# outputs a CSV to the directory designated by the User
			# outputs a cleaned and formated, ordered CSV of the 'Room-Class' objs that matches
			# the 'Addnl Vent' worksheet in the PHPP
			
			# get the scene's data filter and sort it....
			puts '------>>>>> Finding the data frorm the scene....'
			data = BT::CSVexports.filterInputAndCreateRooms(_sel, _ents) #create rooms, filter and get the data
			roomObjsToOutput = data[:roomData] #<--- all the data to output in the CSV
			unitsType = data[:units] #<---- the units to use in the header
			
			# test, if they havn't calc'd rooms yet, warn the user
			warn = false
			if unitsType == nil
				warn = true
			end
			if warn == true
				UI.messagebox("Warning: Be sure to Calculate your dPH+ Room's Data before trying to export")
			end

			# setup the header in the right order / format to match the PHPP
			puts '>>> Setting up the header....'
			# what units to display based on _unitsType  == 'IP' or 'SI'
			
			schema = {
				:IP => {:len => '(ft)', :area => '(ft2)', :vol => '(ft3)', :airflow => '(cfm)'},
				:SI => {:len => '(m)', :area => '(m2)', :vol => '(m3)', :airflow => '(m3/h)'}
			}
			
			header = [
				"SKP-PID",
				"ZONE",
				"FLOOR",
				"ROOM NUM",
				"AMOUNT",
				"ROOM NAME",
				"ALLOCATION TO VENT",
				"AREA #{schema["#{unitsType}".to_sym][:area]}",
				"Vv REFERENCE HEIGHT #{schema["#{unitsType}".to_sym][:len]}",
				"V-SUP #{schema["#{unitsType}".to_sym][:airflow]}",
				"V-ETA #{schema["#{unitsType}".to_sym][:aairflow]}"
				]

			#######----------------#######
			# Write the data to a CSV file
			# find the current working directory and sets it to the Desktop
			# Dir.chdir(File.dirname(__FILE__))
			# Dir.chdir(home_dir)
			# Dir.chdir(myPath)
			puts '>>> Outputting to CSV....'
			
			# get the file save location from the user
			home_dir = ENV["HOME"] || ENV["USERPROFILE"]
			myPath = File.join(home_dir, 'Desktop')
			saveFile = UI.savepanel('Test Title', myPath, 'RoomData_AddnVent.csv')
			
			# writes the csv content in a particular order
			aFile = CSV.open(saveFile, 'w') do |csv|
				csv << header
				roomObjsToOutput.each do |zone|
					csv << [''] # adds a blank line between zones for clarity
					zone.each do |rm|
						csv << [
							rm.pid,
							rm.zone,
							rm.floorlevel,
							rm.roomnum,
							1,
							"#{rm.zone}_FL-#{rm.floorlevel}_ #{rm.roomnum}-#{rm.roomname}",
							1, 
							rm.tfa,
							(rm.vv / [1, rm.tfa.to_f].max ).round(2), #use max check cus' sometimes TFA is zero and would error
							rm.vsup,
							rm.veta
							]
					end
				end
			end
			puts ">>> File is saved: #{saveFile}" #checks the working directory
		end

	end
end