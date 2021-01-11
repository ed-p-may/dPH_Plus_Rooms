module BT

	module CreateCompo

		#These defs create the new component and set up the basic 
		#parameter set for each one selected

		require File.join(__dir__, 'bt_dphPlus_defs_ClearAll.rb')

		def self.createDPHPlusCompo(_sel)
			#Used to take some selection (faces, groups) and make them into compoments
			groupsArray = []
			faceArray = []
			compoArray= []

			#First, separate out the groups, components and the faces in the selection
			_sel.each do |e|
				if e.typename == "Group"
					groupsArray << e
				elsif e.typename == "ComponentInstance"
					compoArray << e
				elsif e.typename == "Face" 
					faceArray << e
				end
			end
		
			#if there are any loose faces, make a group from them and 
			#put into the groups array
			if faceArray.length > 0
				newGroup = Sketchup.active_model.active_entities.add_group(faceArray) #create a group from the raw faces
				groupsArray << newGroup
			end 

			#create components from all the groups and add to the component array
			if groupsArray.length > 0
				">>> Creating components from groups"
				groupsArray.each do |g|
					compoArray << g.to_component
				end
			end
			
			#puts 'component Array includes: ' + groupsArray.to_s
			puts ">>> Component Array includes: #{compoArray.to_s}"
			
			#filter out (or not) the already DPH+ room objects
			#see if it is already a DPH+ object?
			alert1 = false
			compoArray.each do |c|
				puts '>>> Checking to see if its already a dPH+ room...'
				if c.definition.attribute_dictionaries != nil
					if c.definition.attribute_dictionaries['dynamic_attributes'] != nil
						if c.definition.attribute_dictionaries['dynamic_attributes']['1zone'] != nil
							puts '>>> This is already a dPH+ Object.'
							alert1 = true
						else
							p '>>> This is not already a dPH+ Room.'
						end
					end
				end
			end

			if alert1 == true  # gets set to true easrlier if there is DPH+ room in the selection
				answer = UI.messagebox("Do you want to re-use (keep) the existing dPH+ Room object data? (usualy: Yes)", MB_YESNOCANCEL)
				#6 == YES, 7 == NO, 2 == CANCEL
				if answer == 7 #7==NO
					# Delete all existing data from all selected Components
					'>>> removing all the existing data from Rooms'
					compoArray.each do |c|
						BT::ClearAll.clearAttrDict_Rooms(c)
					end

					# Ask about TFA surfaces too
					answerTFA = UI.messagebox("Do you want to re-use (keep) the existing TFA Surfaces?", MB_YESNOCANCEL)
					if answerTFA == 7 #7==No
						p '>>> Removing all the existing TFA Surfaces in the Component'
						compoArray.each do |c|
							BT::ClearAll.clearAttrDict_TFA(c)
						end
					elsif answerTFA == 6 #6==Yes
						p '>>> Keeping all the existing TFA Surfaces in the Component'
					elsif answerTFA == 2 #2==Cancel
						abort('Operation Canceled. Room Data was already deleted though!')
					end

				elsif answer == 6 #6 == YES
					# pass through the entire component set without any modification
					'>>> Keeping all the existing data'
				elsif answer == 2 #2 == CANCEL=
					abort("Operation Canceled") # Stops the script
				end
			end
			
			# Pass each of the component objects to the component setter-upper one at a time
			if compoArray.length > 0
				compoArray.each do |c|
					puts '>>> Passing the component object along for setup...'
					BT::CreateCompo.setDPHPlusCompoAttr(c)
				end
			else
				UI.messagebox('Please pass in either a Component, a Group or a set of faces for this to work correctly', MB_OK)
			end
		end

		def self.getExistingAttrVal(_compo, _attrKey)
			# Used to check if there is existing data, returns default if not
			p '>>> Checking for any existing Attribute: '+"'#{_attrKey}'"+' to re-use...'

			default = '----'

			if _compo.definition.get_attribute('dynamic_attributes', _attrKey) != nil
				return _compo.definition.get_attribute('dynamic_attributes', _attrKey)
			else
				return default
			end

		end

		def self.setDPHPlusCompoAttr(_component)
			# sets up the initial parameters for the 'room' object component instance
			if _component.typename == 'ComponentInstance' #double check that its a component
				instance = _component

				puts '>>> Setting up a new dPH+ Room Component...'
				#Set up the component definition attribute standard set of Keys and Values
				#Remember: Key naming rules = NO caps, NO underscores...

				# Pull out an existing data from an existing component
				p 'Pulling any existing data....'
				attrVal_zone = BT::CreateCompo.getExistingAttrVal(instance, '1zone')
				attrVal_floorLevel = BT::CreateCompo.getExistingAttrVal(instance, '2flrlevel') 
				attrVal_roonNum = BT::CreateCompo.getExistingAttrVal(instance, '3roomnum') 
				attrVal_roomName = BT::CreateCompo.getExistingAttrVal(instance, '4roomname') 
				attrVal_supplyAir= BT::CreateCompo.getExistingAttrVal(instance, '5supplyair') 
				attrVal_extractAir = BT::CreateCompo.getExistingAttrVal(instance, '6extractair') 
				attrVal_AHU = BT::CreateCompo.getExistingAttrVal(instance, '7ahu') # For heat pumps
				attrVal_OU = BT::CreateCompo.getExistingAttrVal(instance, '8outdoorunit')  # For heat pumps
				attrVal_HRV = BT::CreateCompo.getExistingAttrVal(instance, '9hrvunit')  # For H/ERVS

				# Clear out any existing attr dict values or keys
				p '>>> Removing all the old Component Attribute keys and Values'
				BT::ClearAll.clearAttrDict_Rooms(_component) #<---- removes all the existing data

				# Set up the Attr Dict keys and values
				p '>>> Setting up the new Component Attribute Keys and Values and building a new Room Component'
				instance.definition.name = "Room_"  #component name gets incemented automatically
				
				instance.definition.set_attribute('dynamic_attributes', '_1zone_access', 'TEXTBOX')
				instance.definition.set_attribute('dynamic_attributes', '_1zone_label', 'Unit_Zone') #Shows in 'Compo Attrbutes'
				instance.definition.set_attribute('dynamic_attributes', '_1zone_formlabel', 'Unit / Zone') #Shows in 'Compo Options'
				instance.definition.set_attribute('dynamic_attributes', '_1zone_units', 'STRING')
				instance.definition.set_attribute('dynamic_attributes', '_1zone_formatversion', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '_1zone_hasbehaviors', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '1zone', attrVal_zone)       #Actual Value
				
				instance.definition.set_attribute('dynamic_attributes', '_2flrlevel_access', 'TEXTBOX')
				instance.definition.set_attribute('dynamic_attributes', '_2flrlevel_label', 'Floor_Level') #Shows in 'Compo Attrbutes'
				instance.definition.set_attribute('dynamic_attributes', '_2flrlevel_formlabel', 'Floor Level') #Shows in 'Compo Options'
				instance.definition.set_attribute('dynamic_attributes', '_2flrlevel_units', 'STRING')
				instance.definition.set_attribute('dynamic_attributes', '_2flrlevel_formatversion', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '_2flrlevel_hasbehaviors', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '2flrlevel', attrVal_floorLevel)       #Actual Value

				instance.definition.set_attribute('dynamic_attributes', '_3roomnum_access', 'TEXTBOX')
				instance.definition.set_attribute('dynamic_attributes', '_3roomnum_label', 'Room_Num') #Shows in 'Compo Attrbutes'
				instance.definition.set_attribute('dynamic_attributes', '_3roomnum_formlabel', 'Room Number') #Shows in 'Compo Options'
				instance.definition.set_attribute('dynamic_attributes', '_3roomnum_units', 'STRING')
				instance.definition.set_attribute('dynamic_attributes', '_3roomnum_formatversion', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '_3roomnum_hasbehaviors', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '3roomnum', attrVal_roonNum)       #Actual Value

				instance.definition.set_attribute('dynamic_attributes', '_4roomname_access', 'TEXTBOX')
				instance.definition.set_attribute('dynamic_attributes', '_4roomname_label', 'Room_Name') #Shows in 'Compo Attrbutes'
				instance.definition.set_attribute('dynamic_attributes', '_4roomname_formlabel', 'Room Name') #Shows in 'Compo Options'
				instance.definition.set_attribute('dynamic_attributes', '_4roomname_units', 'STRING')
				instance.definition.set_attribute('dynamic_attributes', '_4roomname_formatversion', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '_4roomname_hasbehaviors', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '4roomname', attrVal_roomName)       #Actual Value

				instance.definition.set_attribute('dynamic_attributes', '_5supplyair_access', 'TEXTBOX')
				instance.definition.set_attribute('dynamic_attributes', '_5supplyair_label', 'Supply_Air') #Shows in 'Compo Attrbutes'
				instance.definition.set_attribute('dynamic_attributes', '_5supplyair_formlabel', 'Room Supply Air (cfm)') #Shows in 'Compo Options'
				instance.definition.set_attribute('dynamic_attributes', '_5supplyair_units', 'STRING')
				instance.definition.set_attribute('dynamic_attributes', '_5supplyair_formatversion', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '_5supplyair_hasbehaviors', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '5supplyair', attrVal_supplyAir)       #Actual Value

				instance.definition.set_attribute('dynamic_attributes', '_6extractair_access', 'TEXTBOX')
				instance.definition.set_attribute('dynamic_attributes', '_6extractair_label', 'Extract_Air') #Shows in 'Compo Attrbutes'
				instance.definition.set_attribute('dynamic_attributes', '_6extractair_formlabel', 'Room Extract Air (cfm)') #Shows in 'Compo Options'
				instance.definition.set_attribute('dynamic_attributes', '_6extractair_units', 'STRING')
				instance.definition.set_attribute('dynamic_attributes', '_6extractair_formatversion', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '_6extractair_hasbehaviors', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '6extractair', attrVal_extractAir)       #Actual Value

				instance.definition.set_attribute('dynamic_attributes', '_7ahu_access', 'TEXTBOX')
				instance.definition.set_attribute('dynamic_attributes', '_7ahu_label', 'AHU_Unit') #Shows in 'Compo Attrbutes'
				instance.definition.set_attribute('dynamic_attributes', '_7ahu_formlabel', 'HP AHU') #Shows in 'Compo Options'
				instance.definition.set_attribute('dynamic_attributes', '_7ahu_units', 'STRING')
				instance.definition.set_attribute('dynamic_attributes', '_7ahu_formatversion', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '_7ahu_hasbehaviors', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '7ahu', attrVal_AHU)       #Actual Value

				instance.definition.set_attribute('dynamic_attributes', '_8outdoorunit_access', 'TEXTBOX')
				instance.definition.set_attribute('dynamic_attributes', '_8outdoorunit_label', 'Outdoor_Unit') #Shows in 'Compo Attrbutes'
				instance.definition.set_attribute('dynamic_attributes', '_8outdoorunit_formlabel', 'HP Outdoor Unit') #Shows in 'Compo Options'
				instance.definition.set_attribute('dynamic_attributes', '_8outdoorunit_units', 'STRING')
				instance.definition.set_attribute('dynamic_attributes', '_8outdoorunit_formatversion', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '_8outdoorunit_hasbehaviors', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '8outdoorunit', attrVal_OU)       #Actual Value

				instance.definition.set_attribute('dynamic_attributes', '_9hrvunit_access', 'TEXTBOX')
				instance.definition.set_attribute('dynamic_attributes', '_9hrvunit_label', 'HRV_Unit') #Shows in 'Compo Attrbutes'
				instance.definition.set_attribute('dynamic_attributes', '_9hrvunit_formlabel', 'H/ERV Unit') #Shows in 'Compo Options'
				instance.definition.set_attribute('dynamic_attributes', '_9hrvunit_units', 'STRING')
				instance.definition.set_attribute('dynamic_attributes', '_9hrvunit_formatversion', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '_9hrvunit_hasbehaviors', 1.0.to_f)
				instance.definition.set_attribute('dynamic_attributes', '9hrvunit', attrVal_HRV)       #Actual Valu

				$dc_observers.get_latest_class.redraw_with_undo(instance)
			else
				UI.messagebox('You must pass in a Component Object for this to work correctly', MB_OK)
			end
		end

	end

end