module BT

	module Filtering

		def self.filterForDPHPCompos(_entsArray)
			#filters the entire passed entity set for only DPH valid objects
			#takes in a set (anything with an .each method) of entities (Sketchup::Entities, Sketchup::Selection, etc)
			#(Sketchup.active_model.entities = all the entities in the scene)
			#returns an array of all the DPH+ objects (Sketchup::ComponentInstance objects)
			
			puts '>>> Starting BT::filterForDPHPCompo(_entsArray)'

			roomClassObjs = []
			
			_entsArray.each do |e|
				#Is it a Component?
				if e.typename == 'ComponentInstance' 
					#Is it a Dynamic Component?
					if e.definition.attribute_dictionaries['dynamic_attributes'] != nil
						#if its a valid DPH+ object with TFA information
						if e.definition.attribute_dictionaries['dynamic_attributes']['1zone'] != nil  #uses zone param as proxy for DPH Obj
							#Pull out all the relevant data from the room component in the scene and				
							#create a new Room-Class Object to hold the values for reporting later
							roomClassObjs << e
						end
					end
				end
			end
			
			if roomClassObjs.length > 0
				puts '>>> I found at least 1 dph+ room object. Returning all the roomClasObjects' 
				return roomClassObjs
			else
				UI.messagebox('No Valid dPH+ Objects Found.', MB_OK)
				abort('no DHP objects found')
			end
		end

		def self.findUniq(_ents, _attrKey)
			listOfAll = []
			_ents.each do |e|
				listOfAll << e.definition.get_attribute('dynamic_attributes', _attrKey)
			end

			return listOfAll.uniq!
		end

		def self.addMatchestoSel(_ents, _attrKey, _attrValToSearchFor)
			# Selects dPH+ Rooms that match the search criteria

			# Clear any existing selection
			Sketchup.active_model.selection.clear
			
			_ents.each do |e|
				if e.definition.get_attribute('dynamic_attributes', _attrKey) == _attrValToSearchFor
					# Add to the current Selection if so
					Sketchup.active_model.selection.add(e)
				end
			end
		end

		def self.selectBy(_ents)
			
			# Work only on the dPH+ Objects
			dphRoomInstances =  BT::Filtering.filterForDPHPCompos(_ents)

			# Ask the User what to select by
			userSays = UI.inputbox(["Parameter"], ["",""], ["Zone|Floor Level|HP OU|HP AHU|H/ERV Unit"], "Select dPH+ Rooms by...")[0]
			
			# Select the Rooms based on User Input from above
			if userSays == 'Zone'
				# Find uniq values
				listOfKeys = BT::Filtering.findUniq(dphRoomInstances, '1zone')
				txtForUI = listOfKeys.join("|")
				userSays_SearchFor = UI.inputbox(["Zone:"], ["",""], ["#{txtForUI}"], "Select Rooms in Zone...")[0]
				BT::Filtering.addMatchestoSel(dphRoomInstances, '1zone', userSays_SearchFor.to_s)

			elsif userSays == 'Floor Level'
				listOfKeys = BT::Filtering.findUniq(dphRoomInstances, '2flrlevel')
				txtForUI = listOfKeys.join("|")
				userSays_SearchFor = UI.inputbox(["Floor:"], ["",""], ["#{txtForUI}"], "Select Rooms on Floor...")[0]
				BT::Filtering.addMatchestoSel(dphRoomInstances, '2flrlevel', userSays_SearchFor.to_s)

			elsif userSays == 'HP OU'
				listOfKeys = BT::Filtering.findUniq(dphRoomInstances, '8outdoorunit')
				txtForUI = listOfKeys.join("|")
				userSays_SearchFor = UI.inputbox(["Floor:"], ["",""], ["#{txtForUI}"], "Select Rooms assigned to HP-OU...")[0]
				BT::Filtering.addMatchestoSel(dphRoomInstances, '8outdoorunit', userSays_SearchFor.to_s)

			elsif userSays == 'HP AHU'
				listOfKeys = BT::Filtering.findUniq(dphRoomInstances, '7ahu')
				txtForUI = listOfKeys.join("|")
				userSays_SearchFor = UI.inputbox(["Floor:"], ["",""], ["#{txtForUI}"], "Select Rooms assigned to HP-AHU...")[0]
				BT::Filtering.addMatchestoSel(dphRoomInstances, '7ahu', userSays_SearchFor.to_s)

			elsif userSays == 'H/ERV Unit'
				listOfKeys = BT::Filtering.findUniq(dphRoomInstances, '9hrvunit')
				txtForUI = listOfKeys.join("|")
				userSays_SearchFor = UI.inputbox(["HRV:"], ["",""], ["#{txtForUI}"], "Select Rooms assigned to H/ERV...")[0]
				BT::Filtering.addMatchestoSel(dphRoomInstances, '9hrvunit', userSays_SearchFor.to_s)

			end

		end

	end

end