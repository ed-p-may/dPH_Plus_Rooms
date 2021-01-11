module BT
  
  module TFA
    # Methods for calcing and applying data to the attr-dicts...
    require File.join(__dir__, 'bt_dphPlus_defs_Visualize.rb') 
    
    def self.tag_as_TFA(_sel, factor)
      # This is for applying a 'TFA' factor to a specific face 

      _sel.each do |e|
        if e.typename == "Face"
          e.set_attribute("srfc_data_dict", "TFA%", factor)  # Set the face's attribute in the custom dictionary
          BT::Visualize.colorTFAsrfc(e)  # Color the Room's Faces using the Visulizor method
        end
      end

      _sel.clear
    end

    def self.clear_face_attrb(_sel)
      _sel.each do |e|
        if e.typename == "Face"
          puts 'Deleting from a Face...'
          e.delete_attribute("srfc_data_dict", "TFA%")
          e.material = nil
          e.back_material = nil
        elsif e.typename == "Group"
          puts 'Deleting from a Group...'
          e.entities.each do |i|
            if i.typename == "Face"
              i.delete_attribute("srfc_data_dict", "TFA%")
              i.material = nil
              i.back_material = nil
            end
          end
        elsif e.typename == "ComponentInstance"
          puts 'Deleteing from a Component Instance...'
          e.definition.entities.each do |d|
            puts 'trying....'
            if d.typename == "Face"
              d.delete_attribute("srfc_data_dict", "TFA%")
              d.material = nil
              d.back_material = nil
            end
          end
        end
      end

      _sel.clear
    end

  end #Module

end #Module BT