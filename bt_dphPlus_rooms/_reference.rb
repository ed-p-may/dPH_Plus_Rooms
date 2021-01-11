#Reference:
#https://forums.sketchup.com/t/ruby-how-to-make-face-into-component/46667/3
#https://sketchucation.com/forums/viewtopic.php?f=180&t=1877
#https://forums.sketchup.com/t/how-to-create-a-component-with-existing-entities-in-a-component-by-ruby/18546/5
#https://forums.sketchup.com/t/how-to-access-the-attributes-for-the-dynamic-component/12287/8
#https://forums.sketchup.com/t/manage-different-access-to-dynamic-attributes-in-ruby/62204/2


# Save these, the code for user access....
#s.set_attribute ‘dynamic_attributes’, ‘_attribut_access’, 'NONE’
#s.set_attribute ‘dynamic_attributes’, ‘_attribut_access’ ,'VIEW’
#s.set_attribute ‘dynamic_attributes’, ‘_attribut_access’, ‘LIST’
#s.set_attribute ‘dynamic_attributes’, ‘_attribut_access’, ‘TEXTBOX’

=begin
#Reference code from somebody else....
#Add a new definition to the model
#If the name already exists, it'll add a suffix automatically.
new_comp_def = Sketchup.active_model.definitions.add("space") ; 

#For now, creates some random geometry. Would want it to accept the selected geometry
#eventually. 
points = Array.new ; 
points[0] = ORIGIN ; # "ORIGIN" is a SU provided constant 
points[1] = [100, 0 , 0] ; 
points[2] = [100, 100, 0] ; 
points[3] = [0 , 100, 0] ; 

newface = new_comp_def.entities.add_face(points) ;
newface.reverse! if newface.normal.z < 0 ;
newface.pushpull(100) ;


newface = new_comp_def.entities.add_face(edgeArray) ;

#Now, insert the Cube component. 
#add_instance takes a 'transform' so use IDENTITY since "It is referenced by a global constant, #defined by the SketchUp Ruby API, during startup. So it is always available, in any scope." 

Sketchup.active_model.active_entities.add_instance(new_comp_def, IDENTITY) ; 


### Create a non-visible attribute that makes a simple calculation.
  mod = Sketchup.active_model
  sel = mod.selection
  sel.grep(Sketchup::ComponentInstance).each do |s|
    s.set_attribute "dynamic_attributes","calculated", "0"
    s.set_attribute "dynamic_attributes", "_calculated_access","NONE"
    s.set_attribute "dynamic_attributes","_calculated_formula", "100/2"
    $dc_observers.get_latest_class.redraw_with_undo(s)
  end

  ### Create a visible attribute that can not be modified by the user.
  mod = Sketchup.active_model
  sel = mod.selection
  sel.grep(Sketchup::ComponentInstance).each do |s|
    s.set_attribute "dynamic_attributes","a00title", "COMPONENT OPTIONS"
    s.set_attribute "dynamic_attributes", "_a00title_access","VIEW"
    s.set_attribute "dynamic_attributes","_a00title_formlabel","-" 
    $dc_observers.get_latest_class.redraw_with_undo(s)
  end
  
  ### Create a dynamic attribute "LenX" modifiable by the user.
  mod = Sketchup.active_model
  sel = mod.selection
  sel.grep(Sketchup::ComponentInstance).each do |s|
    current_width = s.get_attribute "dynamic_attributes","lenx" 
    s.set_attribute "dynamic_attributes","lenx", current_width
    s.set_attribute "dynamic_attributes","_lenx_formula", current_width
    s.set_attribute "dynamic_attributes","_lenx_units", "CENTIMETERS"
    s.set_attribute "dynamic_attributes", "_lenx_access","TEXTBOX"
    s.set_attribute "dynamic_attributes","_lenx_formlabel","Length" 
    $dc_observers.get_latest_class.redraw_with_undo(s)
  end     
  
  ### Create an attribute as a list and apply the color chosen by the user to the material attribute.
  mod = Sketchup.active_model
  sel = mod.selection
  sel.grep(Sketchup::ComponentInstance).each do |s|
    s.set_attribute "dynamic_attributes","choice_colors","RED"
    s.set_attribute "dynamic_attributes","_choice_colors_units", "STRING"
    s.set_attribute "dynamic_attributes", "_choice_colors_access","LIST"
    s.set_attribute "dynamic_attributes","_choice_colors_formlabel","Test 4 Liste" 
    s.set_attribute "dynamic_attributes","_choice_colors_options", "Option 1 - RED=red&Option 2 - BLUE=blue"
    
    s.set_attribute "dynamic_attributes","material","RED"
    s.set_attribute "dynamic_attributes","_material_formula", "choice_colors"
    $dc_observers.get_latest_class.redraw_with_undo(s)
  end

=end
