module BT

	module ConvertUnits

		# Use to  convert from SI to IP units and back as directed by the User

		def self.convert(_room, conversion, unitSystem) #takes in a room object
			#set the units display
			_room.definition.set_attribute('dynamic_attributes', 'dphunits', unitSystem)
			
			searchFor = conversion[:base]
			replaceWith = conversion[:new]
			scaleFactor = conversion[:factor]

			_room.definition.attribute_dictionaries['dynamic_attributes'].each do |key, value| 
				#'_formlabel' key is the only place where units info gets recorded in the compo attr dict
				if value.to_s.include?(searchFor)
					formLabelKeyName = "#{key}"
					attrKeyName = formLabelKeyName.split("_").to_a[1]

					#convert
					originalVal = _room.definition.get_attribute('dynamic_attributes', attrKeyName).to_f 
					newVal = originalVal * scaleFactor

					#reset the dynamic_attributes values
					_room.definition.set_attribute('dynamic_attributes', formLabelKeyName, value.sub!(searchFor, replaceWith))
					
					#only for airflow, set the instance level attr value, otherwise set the definition level attr
					if searchFor == '(cfm)' || searchFor == '(m3/h)' 
						_room.set_attribute('dynamic_attributes', attrKeyName, newVal.round(2))
						_room.definition.set_attribute('dynamic_attributes', attrKeyName, newVal.round(2))
					else
						_room.definition.set_attribute('dynamic_attributes', attrKeyName, newVal.round(2))
					end
				end
			end
		end

		def self.convertRoomObjs(_rmsArray)
			#conversion schema
			ft_meter = {:base => '(ft)', :new => '(m)', :factor =>0.3048} #linear feet to meters
			ft2_m2 = {:base => '(ft2)', :new => '(m2)', :factor =>0.092903} #square feet to square meters
			ft3_m3 = {:base => '(ft3)', :new => '(m3)', :factor =>0.0283168} #cubic feet to cubic meters
			cfm_m3h = {:base => '(cfm)', :new => '(m3/h)', :factor =>1.699010796} #cfm to m3/h airflow rate

			meter_ft = {:base => '(m)', :new => '(ft)', :factor =>3.28084} #meters to linear feet 
			m2_ft2 = {:base => '(m2)', :new => '(ft2)', :factor =>10.7639} #square meters to square feet
			m3_ft3 = {:base => '(m3)', :new => '(ft3)', :factor =>35.3147} #cubic meters to cubic feet
			m3h_cfm = {:base => '(m3/h)', :new => '(cfm)', :factor =>0.588577779} #m3/h to cfm airflow rate

			#get the desired units from the user
			userSays = UI.inputbox(["Units Type"], ["",""], ["IP|SI"], "What Units to Use?")[0]
			
			#convert units depending on user input
			if userSays == 'SI'
				_rmsArray.each do |rm|
					convert(rm, ft_meter, 'SI')
					convert(rm, ft2_m2, 'SI')
					convert(rm, ft3_m3, 'SI')
					convert(rm, cfm_m3h, 'SI')
				end
			elsif userSays == "IP"
				_rmsArray.each do |rm|
					convert(rm, meter_ft, 'IP')
					convert(rm, m2_ft2, 'IP')
					convert(rm, m3_ft3, 'IP')
					convert(rm, m3h_cfm, 'IP')
				end
			end
		end

	end

end