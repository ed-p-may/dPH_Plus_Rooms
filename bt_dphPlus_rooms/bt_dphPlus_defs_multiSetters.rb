module BT
  
	module MultiSetters

		#Used to set multiple room objecrs with the same data since you can't do that through the Compo Options panel
		
		def self.setHRV(_sel)
			# Set the Heat Pump Outdoor Unit value
			p '>>>  Setting the HRV value for selected Rooms'
			
			# Get the ERV Unit from the User
			prompt = ['HRV: ']
			default = ['---']
			input = UI.inputbox(prompt, default , 'H/ERV Unit')
			hrv = input[0]

			_sel.each do |s|
				#filter to only work on DesignPH+ room objects
				if s.typename == "ComponentInstance" && s.definition.attribute_dictionaries['dynamic_attributes']['1zone'] != nil
					#Do the attribute setting for the definition of each selected object
					s.definition.set_attribute('dynamic_attributes', '_9hrvunit_access', 'TEXTBOX')
					s.definition.set_attribute('dynamic_attributes', '_9hrvunit_label', 'HRV_Unit') #Shows in 'Compo Attrbutes'
					s.definition.set_attribute('dynamic_attributes', '_9hrvunit_formlabel', 'H/ERV Unit') #Shows in 'Compo Options'
					s.definition.set_attribute('dynamic_attributes', '_9hrvunit_units', 'STRING')
					s.definition.set_attribute('dynamic_attributes', '_9hrvunit_formatversion', 1.0.to_f)
					s.definition.set_attribute('dynamic_attributes', '_9hrvunit_hasbehaviors', 1.0.to_f)
					s.definition.set_attribute('dynamic_attributes', '9hrvunit', hrv)       #Actual Valu
					
					#Also overwrite any user input values on the instance.
					s.set_attribute('dynamic_attributes', '9hrvunit', hrv)       #Actual Value
					$dc_observers.get_latest_class.redraw_with_undo(s)				

				else
					UI.messagebox("Select a valid dPH+ Room Object", MB_OK)
				end

			end
		
		end

		def self.setHP_OU(_sel)
			# Set the Heat Pump Outdoor Unit value
			p '>>>  Setting the HP-OU value for selected Rooms'
			
			# Get the Hea Pump PU from the User
			prompt = ['OU: ']
			default = ['---']
			input = UI.inputbox(prompt, default , 'HP Outdoor Unit (OU)')
			hp_ou = input[0]

			_sel.each do |s|
				#filter to only work on DesignPH+ room objects
				if s.typename == "ComponentInstance" && s.definition.attribute_dictionaries['dynamic_attributes']['1zone'] != nil
					#Do the attribute setting for the definition of each selected object
					s.definition.set_attribute('dynamic_attributes', '_8outdoorunit_access', 'TEXTBOX')
					s.definition.set_attribute('dynamic_attributes', '_8outdoorunit_label', 'Outdoor_Unit') #Shows in 'Compo Attrbutes'
					s.definition.set_attribute('dynamic_attributes', '_8outdoorunit_formlabel', 'HP Outdoor Unit') #Shows in 'Compo Options'
					s.definition.set_attribute('dynamic_attributes', '_8outdoorunit_units', 'STRING')
					s.definition.set_attribute('dynamic_attributes', '_8outdoorunit_formatversion', 1.0.to_f)
					s.definition.set_attribute('dynamic_attributes', '_8outdoorunit_hasbehaviors', 1.0.to_f)
					s.definition.set_attribute('dynamic_attributes', '8outdoorunit', hp_ou)       #Actual Value	
					
					#Also overwrite any user input values on the instance.
					s.set_attribute('dynamic_attributes', '8outdoorunit', hp_ou)       #Actual Value
					$dc_observers.get_latest_class.redraw_with_undo(s)				

				else
					UI.messagebox("Select a valid dPH+ Room Object", MB_OK)
				end

			end
		
		end

		def self.setHP_AHU(_sel)
			# Set the Heat Pump Indoor Unit value
			p '>>>  Setting the HP-AHU value for selected Rooms'
			
			# Get the Heaat Pump AHU from the user
			prompt = ['AHU: ']
			default = ['---']
			input = UI.inputbox(prompt, default , 'HP Indoor Unit (AHU)')
			hp_ahu = input[0]

			_sel.each do |s|
				#filter to only work on DesignPH+ room objects
				if s.typename == "ComponentInstance" && s.definition.attribute_dictionaries['dynamic_attributes']['1zone'] != nil
					#Do the attribute setting for the definition of each selected object
					s.definition.set_attribute('dynamic_attributes', '_7ahu_access', 'TEXTBOX')
					s.definition.set_attribute('dynamic_attributes', '_7ahu_label', 'AHU_Unit') #Shows in 'Compo Attrbutes'
					s.definition.set_attribute('dynamic_attributes', '_7ahu_formlabel', 'HP AHU') #Shows in 'Compo Options'
					s.definition.set_attribute('dynamic_attributes', '_7ahu_units', 'STRING')
					s.definition.set_attribute('dynamic_attributes', '_7ahu_formatversion', 1.0.to_f)
					s.definition.set_attribute('dynamic_attributes', '_7ahu_hasbehaviors', 1.0.to_f)
					s.definition.set_attribute('dynamic_attributes', '7ahu', hp_ahu)       #Actual Value

					#Also overwrite any user input values on the instance.
					s.set_attribute('dynamic_attributes', '7ahu', hp_ahu)       #Actual Value
					$dc_observers.get_latest_class.redraw_with_undo(s)				

				else
					UI.messagebox("Select a valid dPH+ Room Object", MB_OK)
				end

			end
		
		end

		def self.setFloorLevel(_sel)
			# Get the floor level from the user
			prompt = ['Floor Level: ']
			default = ['---']
			input = UI.inputbox(prompt, default , 'Floor Level')
			floorLevel = input[0]
			
			_sel.each do |s|
				#filter to only work on DesignPH+ room objects
				if s.typename == "ComponentInstance" && s.definition.attribute_dictionaries['dynamic_attributes']['1zone'] != nil
					#Do the attribute setting for the definition of each selected object
					s.definition.set_attribute('dynamic_attributes', '_2flrlevel_access', 'TEXTBOX')
					s.definition.set_attribute('dynamic_attributes', '_2flrlevel_label', 'Floor_Level') #Shows in 'Compo Attrbutes'
					s.definition.set_attribute('dynamic_attributes', '_2flrlevel_formlabel', 'Floor Level') #Shows in 'Compo Options'
					s.definition.set_attribute('dynamic_attributes', '_2flrlevel_units', 'STRING')
					s.definition.set_attribute('dynamic_attributes', '_2flrlevel_formatversion', 1.0.to_f)
					s.definition.set_attribute('dynamic_attributes', '_2flrlevel_hasbehaviors', 1.0.to_f)
					s.definition.set_attribute('dynamic_attributes', '2flrlevel', floorLevel)       #Actual Value		
					
					#Also overwrite any user input values on the instance.
					s.set_attribute('dynamic_attributes', '2flrlevel', floorLevel)       #Actual Value
					$dc_observers.get_latest_class.redraw_with_undo(s)				

				else
					UI.messagebox("Select a valid dPH+ Room Object", MB_OK)
				end

			end

		end

		def self.setZone(_sel)
			# Get the floor level from the user
			prompt = ['Zone / Unit: ']
			default = ['---']
			input = UI.inputbox(prompt, default , 'Zone / Unit')
			zone = input[0]
			
			_sel.each do |s|
				#filter to only work on DesignPH+ room objects
				if s.typename == "ComponentInstance" && s.definition.attribute_dictionaries['dynamic_attributes']['1zone'] != nil
					#Do the attribute setting for the definition of each selected object
					s.definition.set_attribute('dynamic_attributes', '_1zone_access', 'TEXTBOX')
					s.definition.set_attribute('dynamic_attributes', '_1zone_label', 'Unit_Zone') #Shows in 'Compo Attrbutes'
					s.definition.set_attribute('dynamic_attributes', '_1zone_formlabel', 'Unit / Zone') #Shows in 'Compo Options'
					s.definition.set_attribute('dynamic_attributes', '_1zone_units', 'STRING')
					s.definition.set_attribute('dynamic_attributes', '_1zone_formatversion', 1.0.to_f)
					s.definition.set_attribute('dynamic_attributes', '_1zone_hasbehaviors', 1.0.to_f)
					s.definition.set_attribute('dynamic_attributes', '1zone', zone)       #Actual Value

					#Also overwrite any user input values on the instance.
					s.set_attribute('dynamic_attributes', '1zone', zone)       #Actual Value
					$dc_observers.get_latest_class.redraw_with_undo(s)				

				else
					UI.messagebox("Select a valid dPH+ Room Object", MB_OK)
				end
			end

		end

	end

end
