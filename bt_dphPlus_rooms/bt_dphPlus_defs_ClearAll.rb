module BT

	module ClearAll
		#Used to totally remove all the DPH+ attribute_dictionaries from the selected faces, entities and definitions.
		#Lets you start over without having to explode the objects and rebuild.

		def self.clearAttrDict_TFA(_ent)
			# Removes all existing atttribute dictionary information from any surfaces

			if _ent.class == Sketchup::ComponentInstance
				p '>>> It is a Component'
				if _ent.attribute_dictionaries != nil
					p '>>> It does have an attribute dictionary'

					_ent.definition.entities.each do |e| # Go through all the entities in the Compo
						if e.attribute_dictionaries != nil
							p '>>> found dictionaries applied to the surfaces'

							# Remove any 'srfc_data_dict' info from all the entities
							if e.attribute_dictionaries['srfc_data_dict'] != nil
								p ">>> Deleting all the 'srfc_data_dict' data..."
								e.attribute_dictionaries.delete('srfc_data_dict')
							end

							# Remove the old 'room_data_dict' incase its still lingering around...
							if e.attribute_dictionaries['room_data_dict'] != nil
								puts ">>> Deleting all the 'room_data_dict' data..."
								e.attribute_dictionaries.delete('room_data_dict')
							end

							# Remove any surface coloration from the TFA factors
							if e.typename == "Face"
								p '>>> Removing all materials from the surfaces in the component'
								e.material = nil
								e.back_material = nil
							end
						end
					end	
				else
					p '>>> Did not find any surfaces with Attribute Dictionaries'
				end
			else
				p '>>> Did not find any Components in the selected objects?'
			end

		end

		def self.clearAttrDict_Rooms(_ent)

			if _ent.class == Sketchup::ComponentInstance
				if _ent.attribute_dictionaries != nil

					#remove the old 'room_data_dict' incase its still lingering around...
					_ent.definition.entities.each do |e|
						if e.attribute_dictionaries != nil && e.attribute_dictionaries['room_data_dict'] != nil
							puts '>>> Deleting all the old data...'
							e.attribute_dictionaries.delete('room_data_dict')
						end
					end					

					if _ent.attribute_dictionaries['room_data_dict'] != nil
						_ent.attribute_dictionaries.delete('room_data_dict')
					end

					if _ent.definition.attribute_dictionaries['room_data_dict'] != nil
						_ent.definition.attribute_dictionaries.delete('room_data_dict')
					end

					#remove the definition level 'dynamic_attrributes' dict
					if _ent.definition.attribute_dictionaries['dynamic_attributes'] != nil
						_ent.definition.attribute_dictionaries.delete('dynamic_attributes')
					end

					#remove the instance level 'dynamic_attrributes' dict
					if _ent.attribute_dictionaries['dynamic_attributes'] != nil
						_ent.attribute_dictionaries.delete('dynamic_attributes')
					end	

				end

			end

		end

		def self.clearAll_verify(_sel)
			# Just adds a user verify warning before running the clearAll def above
			goAhead = UI.messagebox("About to delete all dPH+ info from the selected objects. Are you sure? (this may take a minute)", MB_YESNOCANCEL)

			if goAhead == 6  #6 is 'yes'
				_sel.each do |e|
					clearAttrDict_Rooms(e)
					clearAttrDict_TFA(e)
				end
			else
				abort('user canceled')
			end
		end

	end
end