module BT

	module SetTFAattrDict
		
		#Calcs the TFA and adds to the DC
		
		def self.set_room_data(_sel)
			#method for calcing some important room information
			#This method finds all the tfa faces in the group and sets the room attribute data
			#for the floor area (TFA) and the volume. It gets called automatically by the 'get data' method

			_sel.each do |g|
				#for each of the selected objects....
				tfa_faces = []
				#check if its a Component and that it already has DPH+ DC attributes applied (uses '1zone' as a proxy for DPH+ obj.)
				if g.typename == "ComponentInstance" && g.definition.attribute_dictionaries['dynamic_attributes']['1zone'] != nil
					#filters for only the 'tagged' TFA surfaces in the Component Definition
					g.definition.entities.each do |e|
						if e.typename == "Face" && e.get_attribute("srfc_data_dict", "TFA%") != nil  
							tfa_faces << e
						end
					end
					
					#get the room's TFA (factored)
					roomAreas = BT::SetTFAattrDict.calc_Room_Areas(tfa_faces)
					
					roomFlrArea = roomAreas['floorArea']
					roomTFA = roomAreas['tfa']
					roomAvgTFAFactor = roomAreas['avgTFAFact']
					roomVv = roomTFA.to_f * 8.2  #8.2 ft is a constant for Resi in PH. Make this an option?
					roomVn50 = g.volume * 0.000578704  #will always be in in3 coming from Sketchup, so convert to ft3
					avgHeight = (roomVn50.to_f / roomFlrArea.to_f).to_f
					
					#Set up the component definition attribute Keys and Values
					
					#First, reset the names so the 'Component Options' panel shows the name of the room
					if g.definition.get_attribute('dynamic_attributes', '4roomname') == "----"
						puts 'keeping the default name'
					else
						puts 'changing the name'
						rmNum = g.definition.get_attribute('dynamic_attributes', '3roomnum')
						rmName = g.definition.get_attribute('dynamic_attributes', '4roomname')
						g.name ="Room_#{rmNum}-#{rmName}"
						g.set_attribute('dynamic_attributes', '_name', "Room_#{rmNum}_#{rmName}")
						#do I need to change the Definition name? I don't think so. Thise can do it though...
						#g.definition.name = "Room_#{g.definition.get_attribute('dynamic_attributes', '4roomname')}_#{g.persistent_id}"
					end
					
					g.definition.set_attribute('dynamic_attributes', '_flrarea_access', 'VIEW')
					g.definition.set_attribute('dynamic_attributes', '_flrarea_label', 'area') #Shows in 'Compo Attrbutes'
					g.definition.set_attribute('dynamic_attributes', '_flrarea_formlabel', 'Total Floor Area (ft2)') #Shows in 'Compo Options'
					g.definition.set_attribute('dynamic_attributes', '_flrarea_units', 'STRING')
					g.definition.set_attribute('dynamic_attributes', '_flrarea_formatversion', 1.0.to_f)
					g.definition.set_attribute('dynamic_attributes', '_flrarea_hasbehaviors', 1.0.to_f)
					g.definition.set_attribute('dynamic_attributes', 'flrarea', roomFlrArea.to_f.round(2))       #Actual Value
					
					g.definition.set_attribute('dynamic_attributes', '_tfa_access', 'VIEW')
					g.definition.set_attribute('dynamic_attributes', '_tfa_label', 'TFA') #Shows in 'Compo Attrbutes'
					g.definition.set_attribute('dynamic_attributes', '_tfa_formlabel', 'Room TFA (ft2)') #Shows in 'Compo Options'
					g.definition.set_attribute('dynamic_attributes', '_tfa_units', 'STRING')
					g.definition.set_attribute('dynamic_attributes', '_tfa_formatversion', 1.0.to_f)
					g.definition.set_attribute('dynamic_attributes', '_tfa_hasbehaviors', 1.0.to_f)
					g.definition.set_attribute('dynamic_attributes', 'tfa', roomTFA.to_f.round(2))       #Actual Value
					
					g.definition.set_attribute('dynamic_attributes', '_tfaavg_access', 'VIEW')
					g.definition.set_attribute('dynamic_attributes', '_tfaavg_label', 'Avg_TFA') #Shows in 'Compo Attrbutes'
					g.definition.set_attribute('dynamic_attributes', '_tfaavg_formlabel', 'Avg. TFA Factor') #Shows in 'Compo Options'
					g.definition.set_attribute('dynamic_attributes', '_tfaavg_units', 'STRING')
					g.definition.set_attribute('dynamic_attributes', '_tfaavg_formatversion', 1.0.to_f)
					g.definition.set_attribute('dynamic_attributes', '_tfaavg_hasbehaviors', 1.0.to_f)
					g.definition.set_attribute('dynamic_attributes', 'tfaavg', roomAvgTFAFactor.to_f.round(2))       #Actual Value		
						
					g.definition.set_attribute('dynamic_attributes', '_vv_access', 'VIEW')
					g.definition.set_attribute('dynamic_attributes', '_vv_label', 'Vv') #Shows in 'Compo Attrbutes'
					g.definition.set_attribute('dynamic_attributes', '_vv_formlabel', 'Vented Vol. (ft3)') #Shows in 'Compo Options'
					g.definition.set_attribute('dynamic_attributes', '_vv_units', 'STRING')
					g.definition.set_attribute('dynamic_attributes', '_vv_formatversion', 1.0.to_f)
					g.definition.set_attribute('dynamic_attributes', '_vv_hasbehaviors', 1.0.to_f)
					g.definition.set_attribute('dynamic_attributes', 'vv', roomVv.round(2))       #Actual Value

					g.definition.set_attribute('dynamic_attributes', '_vn50_access', 'VIEW')
					g.definition.set_attribute('dynamic_attributes', '_vn50_label', 'Vn50') #Shows in 'Compo Attrbutes'
					g.definition.set_attribute('dynamic_attributes', '_vn50_formlabel', 'Volume (ft3)') #Shows in 'Compo Options'
					g.definition.set_attribute('dynamic_attributes', '_vn50_units', 'STRING')
					g.definition.set_attribute('dynamic_attributes', '_vn50_formatversion', 1.0.to_f)
					g.definition.set_attribute('dynamic_attributes', '_vn50_hasbehaviors', 1.0.to_f)
					g.definition.set_attribute('dynamic_attributes', 'vn50', roomVn50.round(2))       #Actual Value

					g.definition.set_attribute('dynamic_attributes', '_avgheight_access', 'VIEW')
					g.definition.set_attribute('dynamic_attributes', '_avgheight_label', 'ceilingHeight') #Shows in 'Compo Attrbutes'
					g.definition.set_attribute('dynamic_attributes', '_avgheight_formlabel', 'Avg. Ceiling Height (ft)') #Shows in 'Compo Options'
					g.definition.set_attribute('dynamic_attributes', '_avgheight_units', 'STRING')
					g.definition.set_attribute('dynamic_attributes', '_avgheight_formatversion', 1.0.to_f)
					g.definition.set_attribute('dynamic_attributes', '_avgheight_hasbehaviors', 1.0.to_f)
					g.definition.set_attribute('dynamic_attributes', 'avgheight', avgHeight.round(2))       #Actual Value

					g.definition.set_attribute('dynamic_attributes', '_dphunits_access', 'VIEW')
					g.definition.set_attribute('dynamic_attributes', '_dphunits_label', 'dphunits') #Shows in 'Compo Attrbutes'
					g.definition.set_attribute('dynamic_attributes', '_dphunits_formlabel', 'Units (IP/SI)') #Shows in 'Compo Options'
					g.definition.set_attribute('dynamic_attributes', '_dphunits_units', 'STRING')
					g.definition.set_attribute('dynamic_attributes', '_phunits_formatversion', 1.0.to_f)
					g.definition.set_attribute('dynamic_attributes', '_dphunits_hasbehaviors', 1.0.to_f)
					g.definition.set_attribute('dynamic_attributes', 'dphunits', 'IP')     #Actual Value, set to IP on creation

					$dc_observers.get_latest_class.redraw_with_undo(g)

				else
					UI.messagebox('please select a space group', MB_OK)
				end
			end
		end	

		def self.calc_Room_Areas(_tfa_faces)
			#Finds and totals up the total face areas of all the TFA surfaces (if more than 1)
			#depedning on the various tfa Factors. Returns the total TFA of the room(s)
			
			#check to make sure there is a TFA factor applied to at least one face in the group
			faceCount = 0
			if _tfa_faces.count == 0
				UI.messagebox("ERROR: Some of the groups you have selected have no TFA surfaces tagged yet.", MB_OK)
				faceCount = 1
			else
				faceCount = _tfa_faces.count
			end

			#Finds and totals up the total face areas of all the TFA surfaces
			#and the tfa Factors and adds as attributes to the room
			total_face_area = 0
			total_tfa = 0

			for tfa_face in _tfa_faces do
				total_face_area = total_face_area + (tfa_face.area.to_f / 144).round(3)  #144 is used to convert square inches(!) to square feet
				total_tfa = total_tfa + ((tfa_face.area.to_f / 144) * tfa_face.get_attribute("srfc_data_dict", "TFA%").to_f)
			end

			#Calculate the weighted average TFA Factor for display later
			average_tfa_factor = total_tfa / total_face_area 

			return { 'tfa' => total_tfa, 'floorArea' => total_face_area, 'avgTFAFact' => average_tfa_factor }
		end

	end

end