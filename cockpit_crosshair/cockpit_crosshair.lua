--[[

Cockpit Crosshair

A device that

Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

MODULES

]]
ffi = require("ffi") -- LuaJIT FFI module
dofile("core_ffi.lua") -- Handles X-Plane SDK stuff in Lua's Foreign Function Interface
dofile("core_instancing.lua") -- Handles X-Plane object instancing
dofile("core_menu.lua") -- The menu
--[[

VARIABLES

]]
Folder_Path = "" -- Stores the path to the cockpit_crosshair folder; KEEP EMPTY!
Angle_Bars_On_LandLight = 0 -- Angle bars tied to landing light?
Interior_Only = 0 -- Hide crosshair in exterior view?
--[[

DATAREFS

]]
simDR_elec_landlights = find_dataref("sim/cockpit/electrical/landing_lights_on")
simDR_pos_alpha = find_dataref("sim/flightmodel/position/alpha") -- Alpha (pitch rel. to flight path)
simDR_pos_beta = find_dataref("sim/flightmodel/position/beta") -- Beta (Yaw rel. to flight path)
simDR_pos_vpath = find_dataref("sim/flightmodel2/position/vpath")
simDR_pos_hpath = find_dataref("sim/flightmodel2/position/hpath")
simDR_pos_ias = find_dataref("sim/flightmodel/position/indicated_airspeed")
simDR_pos_head_x = find_dataref("sim/graphics/view/pilots_head_x") -- Head position lateral
simDR_pos_head_y = find_dataref("sim/graphics/view/pilots_head_y") -- Head position vertical
simDR_pos_head_z = find_dataref("sim/graphics/view/pilots_head_z") -- Head position horizontal
simDR_view_external = find_dataref("sim/graphics/view/view_is_external") -- Used to determine if view is interior or exterior
--[[

CUSTOM DATAREFS

]]
function fake_handler() end -- Required to make a custom dataref writable
Dref_Reference_In_Out = create_dataref("cockpit_crosshair/reference_point","array[4]",fake_handler) -- Visible,X,Y,Z
Dref_Crosshair_In = create_dataref("cockpit_crosshair/crosshair_in","array[7]",fake_handler)       -- Visible,Rot_X,Rot_Y,Rot_Z,X,Y,Z
Dref_Crosshair_Out = create_dataref("cockpit_crosshair/crosshair_out","array[7]")       -- Visible,Rot_X,Rot_Y,Rot_Z,X,Y,Z
Dref_Angle_Bars_In = create_dataref("cockpit_crosshair/angle_bars_in","array[4]",fake_handler) -- Visible, bar 1 angle in degrees,  bar 2 angle in degrees, bar 3 angle in degrees
Dref_Angle_Bars_Out = create_dataref("cockpit_crosshair/angle_bars_out","array[4]") -- Visible, bar 1 angle in degrees,  bar 2 angle in degrees, bar 3 angle in degrees
Dref_Crosshair_AutoEnableIAS = create_dataref("cockpit_crosshair/auto_enable_ias","number",fake_handler)       -- Velocity in knots
Dref_Crosshair_AngleBarsIAS = create_dataref("cockpit_crosshair/angle_bars_ias","number",fake_handler)       -- Velocity in knots
--[[

FUNCTIONS

]]
--[[ Callback for the custom command to toggle the cross ]]
function Callback_Crosshair_Toggle(phase,duration)
    if phase == 0 then -- 0 = command begin, 1 = command continue, 2 = command end
        if Dref_Crosshair_In[0] == 0 then Dref_Crosshair_In[0] = 1 else Dref_Crosshair_In[0] = 0 end
    end
end
--[[ Callback for the custom command to toggle the cross ]]
function Callback_Reference_Toggle(phase,duration)
    if phase == 0 then -- 0 = command begin, 1 = command continue, 2 = command end
        if Dref_Reference_In_Out[0] == 0 then Dref_Reference_In_Out[0] = 1 else Dref_Reference_In_Out[0] = 0 end
    end
end
--[[ Callback for the custom command to reload the offset file ]]
function Callback_Settings_Reload(phase,duration)
    if phase == 0 then -- 0 = command begin, 1 = command continue, 2 = command end
        Instance_Read_Settings()
    end
end
--[[ This stuff runs in the timer below ]]
function Run_In_Timer()
    Menu_Timed() -- See core_menu.lua
    -- Check if restriction is on and if view is exterior and if yes, hide crosshair
    if Interior_Only == 1 and simDR_view_external == 1 then
        Dref_Crosshair_In[0] = 0 -- Crosshair is not visible
    else
        Dref_Crosshair_In[0] = 1 -- Crosshair is visible
    end
    -- Control crosshair visbility
    if Dref_Crosshair_In[0] == 1 then -- Check if crosshair visibility is desired
        if simDR_pos_ias < Dref_Crosshair_AutoEnableIAS then
            Dref_Crosshair_Out[0] = 1 -- Crosshair is visible
        else
            Dref_Crosshair_Out[0] = 0 -- Crosshair is not visible
        end
    else
        Dref_Crosshair_Out[0] = 0 -- Crosshair is not visible
    end
    -- Control angle bar visibility
    if Dref_Angle_Bars_In[0] == 1 then -- Check if angle bar visibility is desired
        if Angle_Bars_On_LandLight == 1 then
            if simDR_elec_landlights == 1 then
                Dref_Angle_Bars_Out[0] = 1 -- Angle bars are visible
            else
                Dref_Angle_Bars_Out[0] = 0 -- Angle bars are visible
            end
        elseif simDR_pos_ias < Dref_Crosshair_AngleBarsIAS then
            Dref_Angle_Bars_Out[0] = 1 -- Angle bars are visible
        else
            Dref_Angle_Bars_Out[0] = 0 -- Angle bars are not visible
        end
    else
        Dref_Angle_Bars_Out[0] = 0 -- Angle bars are not visible
    end
end
--[[

CUSTOM COMMMAND

]]
create_command("cockpit_crosshair/toggle_crosshair","Cockpit Crosshair: Toggle",Callback_Crosshair_Toggle)
create_command("cockpit_crosshair/toggle_reference","Cockpit Crosshair: Toggle Ref. Point",Callback_Reference_Toggle)
create_command("cockpit_crosshair/reload_settings","Cockpit Crosshair: Reload Settings",Callback_Settings_Reload)

--[[

X-PLANE CALLBACKS

]]
--[[ This runs at flight start ]]
function flight_start()
    Folder_Path = Get_Folder() -- See core_ffi.lua; ALWAYS THE FIRST ITEM!
    --print("Cockpit Crosshair path: "..Folder_Path)
    FFI_CheckInit() -- See core_ffi.lua
    Instancing_Start() -- See core_instancing.lua
    Menu_Init() -- See core_menu.lua
    Menu_Build() -- See core_menu.lua
    run_at_interval(Run_In_Timer,1) -- Run every second
end
--[[ This runs each frame ]]
function after_physics()
    Instance_Update_Pos()
    Dref_Crosshair_Out[1] = simDR_pos_vpath - simDR_pos_the -- Rot_X for the crosshair
    Dref_Crosshair_Out[2] = Dref_Crosshair_In[2]    -- Rot_Y
    Dref_Crosshair_Out[3] = simDR_pos_beta -- Rot_Z for flight path
    Dref_Crosshair_Out[4] = Dref_Crosshair_In[4] + simDR_pos_head_x   -- X
    Dref_Crosshair_Out[5] = Dref_Crosshair_In[5] + simDR_pos_head_z   -- Y
    Dref_Crosshair_Out[6] = Dref_Crosshair_In[6] + simDR_pos_head_y   -- Z

    Dref_Angle_Bars_Out[1] = Dref_Angle_Bars_In[1] - simDR_pos_the -- Rot_X for angle bar 1
    Dref_Angle_Bars_Out[2] = Dref_Angle_Bars_In[2] - simDR_pos_the -- Rot_X for angle bar 2
    Dref_Angle_Bars_Out[3] = Dref_Angle_Bars_In[3] - simDR_pos_the -- Rot_X for angle bar 3
end
--[[ This runs when the aircraft is unloaded ]]
function aircraft_unload()
    Menu_Unload() -- See core_menu.lua
    Instance_Obj_Unload() -- See core_instancing.lua
end
