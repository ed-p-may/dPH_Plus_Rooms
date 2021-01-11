require 'sketchup.rb'
require File.join(__dir__, 'bt_dphPlus_defs_TFA.rb')
require File.join(__dir__, 'bt_dphPlus_defs_CreateCompo.rb')
require File.join(__dir__, 'bt_dphPlus_defs_SetTFAAttrDict.rb')
require File.join(__dir__, 'bt_dphPlus_defs_multiSetters.rb')
require File.join(__dir__, 'bt_dphPlus_defs_quickView.rb')
require File.join(__dir__, 'bt_dphPlus_CSV.rb')
require File.join(__dir__, 'bt_dphPlus_defs_ClearAll.rb')
require File.join(__dir__, 'bt_dphPlus_defs_Visualize.rb')
require File.join(__dir__, 'bt_dphPlus_filterSelForCompo.rb')
require File.join(__dir__, 'bt_dphPlus_convertUnits.rb')

mod = Sketchup.active_model
ents = mod.entities
sel = mod.selection
mats = mod.materials

######---------------------########
##### UI and toolbar Stuff ########
######---------------------########
#Set up all the Commands...
cmd_createDPHPlusRoom = UI::Command.new("Create a New dPH+ Room(s)")         { BT::CreateCompo.createDPHPlusCompo(sel)  }
cmd_calcRoomData = UI::Command.new("Calc Room(s) Data")                      { BT::SetTFAattrDict.set_room_data(sel)    }
cmd_setRoomZone = UI::Command.new("Set Room(s): Zone / Unit")                { BT::MultiSetters.setZone(sel)            }
cmd_setRoomFlrLvl = UI::Command.new("Set Room(s): Floor Level")              { BT::MultiSetters.setFloorLevel(sel)      }
cmd_setHPOU = UI::Command.new("Set Room(s): Heat Pump Outdoor Unit (OU)")    { BT::MultiSetters.setHP_OU(sel)           }
cmd_setHPAHU = UI::Command.new("Set Room(s): Heat Pump Indoor Unit (AHU)")   { BT::MultiSetters.setHP_AHU(sel)          }
cmd_setHRV = UI::Command.new("Set Room(s): HRV Unit")                        { BT::MultiSetters.setHRV(sel)             }
cmd_clearAll = UI::Command.new('Remove dPH+ Attributes From Selected')       { BT::ClearAll.clearAll_verify(sel)        }

cmd_to_set_tfa100 = UI::Command.new("Set as TFA-100")                 { BT::TFA.tag_as_TFA(sel, 1.0)  }
cmd_to_set_tfa60 = UI::Command.new("Set as TFA-60")                   { BT::TFA.tag_as_TFA(sel, 0.6)  }
cmd_to_set_tfa50 = UI::Command.new("Set as TFA-50")                   { BT::TFA.tag_as_TFA(sel, 0.5)  }
cmd_to_set_tfa30 = UI::Command.new("Set as TFA-30")                   { BT::TFA.tag_as_TFA(sel, 0.3)  }
cmd_to_set_tfa0 = UI::Command.new("Set as TFA-0")                     { BT::TFA.tag_as_TFA(sel, 0.0)  }
cmd_to_clr_tfa_attr = UI::Command.new("Clear TFA Attrb. From Srfc")   { BT::TFA.clear_face_attrb(sel) }

cmd_quickData = UI::Command.new("Output: Room Data Quick View")     { BT::Quickview.quickView(sel)                           }
cmd_outputALL = UI::Command.new("Output: All Room Data")            { BT::CSVexports.outputFullCSV(sel, ents)                }
cmd_outputAdVnt = UI::Command.new("Output: Room Data for PHPP Addn'l Vent") { BT::CSVexports.outputAddVentCSV(sel, ents)     }
cmd_convertUnits = UI::Command.new("Set SI / IP Units")             { BT::ConvertUnits.convertRoomObjs(BT::Filtering.filterForDPHPCompos(sel))  }

cmd_vis_colorBy = UI::Command.new("Color the Scene By...")          { BT::Visualize.colorSceneBy(sel, ents) }
cmd_filter_selBy = UI::Command.new("Select dPH+ Rooms By...")       { BT::Filtering.selectBy(ents)          }

#####--------------------########
#Set up and add the commands to the main (top) toolbar dropdowns
new_menu = UI.menu("Window").add_submenu("dPH+ Rooms") #puts commands into 'Window' next to the real DesignPH

new_menu.add_item(cmd_createDPHPlusRoom)
new_menu.add_item(cmd_calcRoomData)

new_menu.add_separator
new_menu.add_item(cmd_setRoomZone)
new_menu.add_item(cmd_setRoomFlrLvl)
new_menu.add_item(cmd_setHPOU)
new_menu.add_item(cmd_setHPAHU)
new_menu.add_item(cmd_setHRV)
new_menu.add_item(cmd_clearAll)

new_menu.add_separator
new_menu.add_item(cmd_vis_colorBy)
new_menu.add_item(cmd_filter_selBy)

new_menu.add_separator
new_menu.add_item(cmd_quickData)
new_menu.add_item(cmd_outputALL)
new_menu.add_item(cmd_outputAdVnt)
new_menu.add_item(cmd_convertUnits)

#####--------------------########
#Set up and add the commands to right click menu
UI.add_context_menu_handler do |context_menu|
  context_menu.add_separator

  context_menu.add_item("Create a New dPH+ Room(s)") { BT::CreateCompo.createDPHPlusCompo(sel) }
  
  submenu1 = context_menu.add_submenu('dPH+ Room Data')
  submenu1.add_item('Calc dPH+ Room(s) Data')  { BT::SetTFAattrDict.set_room_data(sel) }
  submenu1.add_separator

  submenu1.add_item('Set Room(s): Zone / Unit') { BT::MultiSetters.setZone(sel)         }
  submenu1.add_item('Set Room(s): Floor Level') { BT::MultiSetters.setFloorLevel(sel)   } 
  submenu1.add_item('Set Room(s): HP OU')       { BT::MultiSetters.setHP_OU(sel)        }
  submenu1.add_item('Set Room(s): HP AHU')      { BT::MultiSetters.setHP_AHU(sel)       }
  submenu1.add_item('Set Room(s): H/ERV')       { BT::MultiSetters.setHRV(sel)          }
  submenu1.add_separator

  submenu1.add_item('Remove DPH Attributes From Selected') { BT::ClearAll.clearAll_verify(sel)  }

  submenu2 = context_menu.add_submenu('dPH+ TFA')
  submenu2.add_item('Set TFA-100')        { BT::TFA.tag_as_TFA(sel, 1.0)  }
  submenu2.add_item('Set TFA-60')         { BT::TFA.tag_as_TFA(sel, 0.6)  }
  submenu2.add_item('Set TFA-50')         { BT::TFA.tag_as_TFA(sel, 0.5)  }
  submenu2.add_item('Set TFA-30')         { BT::TFA.tag_as_TFA(sel, 0.3)  }
  submenu2.add_item('Set TFA-0')          { BT::TFA.tag_as_TFA(sel, 0.0)  }
  submenu2.add_item('Clear TFA Attrb.')   { BT::TFA.clear_face_attrb(sel) }

end

#####--------------------########
#Creats the floating toolbar to access the set-TFA-factor commands
tfa_toolbar = UI::Toolbar.new "dPH+ TFA"
toolbar_image_path = File.join(__dir__, "Images")

cmd_to_set_tfa100.tooltip = "Set Face to 100% TFA"
cmd_to_set_tfa100.large_icon = File.join(__dir__, "Images", "tfa_100_24px.png")
tfa_toolbar.add_item(cmd_to_set_tfa100)

cmd_to_set_tfa60.tooltip = "Set Face to 60% TFA"
cmd_to_set_tfa60.large_icon = File.join(__dir__, "Images", "tfa_60_24px.png")
tfa_toolbar.add_item(cmd_to_set_tfa60)

cmd_to_set_tfa50.tooltip = "Set Face to 50% TFA"
cmd_to_set_tfa50.large_icon = File.join(__dir__, "Images", "tfa_50_24px.png")
tfa_toolbar.add_item(cmd_to_set_tfa50)

cmd_to_set_tfa30.tooltip = "Set Face to 30% TFA"
cmd_to_set_tfa30.large_icon = File.join(__dir__, "Images", "tfa_30_24px.png")
tfa_toolbar.add_item(cmd_to_set_tfa30)

cmd_to_set_tfa0.tooltip = "Set Face to 0% TFA"
cmd_to_set_tfa0.large_icon = File.join(__dir__, "Images", "tfa_0_24px.png")
tfa_toolbar.add_item(cmd_to_set_tfa0)

cmd_to_clr_tfa_attr.tooltip = "Clear Face TFA Data"
cmd_to_clr_tfa_attr.large_icon = File.join(__dir__, "Images", "tfa_clear_24px.png")
tfa_toolbar.add_item(cmd_to_clr_tfa_attr)

#tfa_toolbar.show  #Should make this 'remember' last visible state somehow/someday....
