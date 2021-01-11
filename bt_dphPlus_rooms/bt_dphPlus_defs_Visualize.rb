module BT
  
    module Visualize

        # Methods for coloring or styling room objects in the scene
        require File.join(__dir__, 'bt_dphPlus_filterSelForCompo.rb')

        #Colors to use for visulaizing elements
        @@colorDict = {
            1.0 => "yellow",
            0.6 => "DarkKhaki",
            0.5 => "YellowGreen",
            0.3 => "SpringGreen",
            0.0 => "#EE82EE",
            "ventSupply" => "LightSkyBlue",
            "ventExtract" => "Salmon",
            "ventMixed" => "Plum"
        }

        # Color sequence for indeterminate length styling
        # http://www.perbang.dk/rgbgradient/
        @@colorSequence = [
            '#1926FF',
            '#1682F8',
            '#13DBF2',
            '#10EBA6',
            '#2CDF0B',
            '#D1D206',
            '#CB7804',
            '#C52102',
            '#CB047F'
        ]

        # --> No fucking clue what this is doing. but needed to access the colorDict inside the def later
        # --> able to access the class variable in two ways: 'MyModule::my_variable' or 'MyModule.my_variable'
        define_singleton_method(:colorDict) do
            @@colorDict
        end

        define_singleton_method(:colorSequence) do
            @@colorSequence
        end

        def self.colorSceneBy(_sel, _ents)
            # Used to apply visual styling to the Sketchup Scene
            
            p '>>> Applying visulal styling to the Sketchup scene'
            
            # Get User Input for what to Color by
            userSays = UI.inputbox(["Parameter"], ["",""], ["TFA|Ventilation Flow|HP OU|HP AHU|H/ERV Unit|None"], "Color the scene based on...")[0]

            # Figure out if applying to the selection or the whole scene
            if _sel.length > 0 # If the user selected some rooms, apply only to those
                p '>>> Styling only the selected dPH+ Room Objects'
                dphRoomInstances =  BT::Filtering.filterForDPHPCompos(_sel)
            else # otherwise, use the entire scene
                p '>>> Styling all the dPH+ Room Objects in the scene'
                dphRoomInstances =  BT::Filtering.filterForDPHPCompos(_ents)
            end

            #First, clear out any existing materials
            BT::Visualize.clearMatsFrmSrfcs(dphRoomInstances)  

            # Style depending on the _viewBy type
            if userSays == 'TFA'
                BT::Visualize.colorRoomBy_TFA(dphRoomInstances)
            elsif userSays == 'Ventilation Flow'                
                BT::Visualize.colorRoomBy_Vent(dphRoomInstances)
            elsif userSays == 'H/ERV Unit'                
                BT::Visualize.colorRoomBy_HRV(dphRoomInstances)
            elsif userSays == 'HP OU'
                BT::Visualize.colorRoomBy_HP_OU(dphRoomInstances)
            elsif userSays == 'HP AHU'
                BT::Visualize.colorRoomBy_HP_AHU(dphRoomInstances)
            elsif userSays == 'None'
                p '>>> Removed colors from rooms and surfaces'
            end

        end

        def self.clearMatsFrmSrfcs(_ents)
            # For removing TFA materials / colors from all surfaces in dPH+ room objects only
            p '>>> Removing all Materials from Room Objects and Surfaces'

            _ents.each do |room_inst|                               # For each room, go through each surface
                room_inst.material = nil                            # Remove any materials from the room object
                room_inst.definition.entities.each do |rm_def_ent|  # For each surface, remove the materials
                    if rm_def_ent.typename == 'Face'
                        rm_def_ent.material = nil
                        rm_def_ent.back_material = nil
                    end
                end

            end
            
        end

        def self.colorTFAsrfc(_srfc)
            # Applies the color for TFA surfaces based on the Color Dict above

            if _srfc.get_attribute("srfc_data_dict", "TFA%") != nil  # Double check it has srfc_dict attributes
                # If it does have a factor, read it and apply the right color from the colorDict
                _srfc.material = BT::Visualize.colorDict[_srfc.get_attribute("srfc_data_dict", "TFA%")]
                _srfc.back_material = BT::Visualize.colorDict[_srfc.get_attribute("srfc_data_dict", "TFA%")]
            end

        end

        def self.colorRoomBy_TFA(_ents)
            # Def to find the TFA factor of a surface and color it appropriately

            _ents.each do |room_inst|                    # For each room, go through each surface
                room_inst.definition.entities.each do |rm_def_ent|  # For each surface in the room, remove any materials which are applied
                    if rm_def_ent.typename == 'Face'
                        BT::Visualize.colorTFAsrfc(rm_def_ent)      # Test the surface for factors and apply colors as appropriate
                    end
                end

            end

        end

        def self.colorRoomBy_Vent(_ents)
            # Def to color all rooms if they have ventilation supply / extract

            # For each room found...
            _ents.each do |room_inst|
                p room_inst
                vSup = room_inst.definition.get_attribute('dynamic_attributes', '5supplyair').to_f
                vEtr = room_inst.definition.get_attribute('dynamic_attributes', '6extractair').to_f
                
                p "#{room_inst.definition.get_attribute('dynamic_attributes', '4roomname')} | Vsup=#{vSup}, Vext=#{vEtr}"

                # Apply colors depending on the type of vent flow assigned
                if vSup == 0 && vEtr == 0
                    room_inst.material = nil
                elsif vSup > 0 && vEtr == 0
                    room_inst.material = BT::Visualize.colorDict["ventSupply"]
                elsif vSup == 0 && vEtr > 0
                    room_inst.material = BT::Visualize.colorDict["ventExtract"]
                elsif vSup >0 && vEtr > 0
                    room_inst.material = BT::Visualize.colorDict["ventMixed"]
                end

            end

        end
        
        def self.colorRoomBy_HP_OU(_ents)
            # For coloing rooms base on the HP-OU spec.
            p '>>> Coloring Rooms by Heat Pump Outdoor Unit (OU)'

            #Find all the OU units in the scene
            hp_ou_list = []
            _ents.each do |room_inst|
                hp_ou_list << room_inst.definition.get_attribute('dynamic_attributes', '8outdoorunit')
            end

            # Find the unique OU items used
            hp_ou_list.uniq!  # in place

            # For each unique OU, apply a color from the colorSequence
            i = 0
            hp_ou_list.each do |ou|
                hp_ou_color = BT::Visualize.colorSequence[(i % colorSequence.length)] # so that it'll cycle through the list if there are more OU's than colors
                i +=1

                _ents.each do |room_inst|
                    if room_inst.definition.get_attribute('dynamic_attributes', '8outdoorunit') == ou
                        room_inst.material = hp_ou_color
                    end

                end

            end

        end

        def self.colorRoomBy_HP_AHU(_ents)
            # For coloing rooms base on the HP-AHU spec.
            p '>>> Coloring Rooms by Heat Pump Outdoor Unit (OU)'

            #Find all the AHU units in the scene
            hp_ahu_list = []
            _ents.each do |room_inst|
                hp_ahu_list << room_inst.definition.get_attribute('dynamic_attributes', '7ahu')
            end

            # Find the unique AHU items used
            hp_ahu_list.uniq!  # in place

            # For each unique AHU, apply a color from the colorSequence
            i = 0
            hp_ahu_list.each do |ahu|
                hp_ahu_color = BT::Visualize.colorSequence[(i % colorSequence.length)] # so that it'll cycle through the list if there are more OU's than colors
                i +=1

                _ents.each do |room_inst|
                    if room_inst.definition.get_attribute('dynamic_attributes', '7ahu') == ahu
                        room_inst.material = hp_ahu_color
                    end

                end

            end

        end

        def self.colorRoomBy_HRV(_ents)
            # For coloing rooms base on the H/ERV spec.
            p '>>> Coloring Rooms by H/ERV Unit'

            # Find all the HRV units in the scene
            hrv_list = []
            _ents.each do |room_inst|
                hrv_list << room_inst.definition.get_attribute('dynamic_attributes', '9hrvunit')
            end

            # Find the unique HRV items used
            hrv_list.uniq!  # in place

            # For each unique HRV, apply a color from the colorSequence
            i = 0
            hrv_list.each do |hrv|

               hrv_color = BT::Visualize.colorSequence[(i % colorSequence.length)] # so that it'll cycle through the list if there are more OU's than colors
                i +=1
                p '>>> Using color: '+"#{hrv_color}"+' i='+"#{i}"

                _ents.each do |room_inst|
                    if room_inst.definition.get_attribute('dynamic_attributes', '9hrvunit') == hrv
                        p '>>> Found a matching Room, applying color'
                        # Style the room
                        room_inst.material = hrv_color
                    end

                end

            end

        end


    end

end