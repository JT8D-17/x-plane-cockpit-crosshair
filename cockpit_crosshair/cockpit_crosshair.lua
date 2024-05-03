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
Force_Mode = 0 -- Crosshair mode force 0=Auto,1=Angle,2=Cruise
Active_Mode = 0 -- Controls the active crosshair mode
Active_Mode_Old = 0 -- For detecting changes in crosshair mode
--[[

DATAREFS

]]
simDR_Alt_AGL = find_dataref("sim/flightmodel/position/y_agl")
simDR_pos_alpha = find_dataref("sim/flightmodel/position/alpha") -- Alpha (pitch rel. to flight path)
simDR_pos_beta = find_dataref("sim/flightmodel/position/beta") -- Beta (Yaw rel. to flight path)
simDR_pos_vpath = find_dataref("sim/flightmodel2/position/vpath")
simDR_pos_hpath = find_dataref("sim/flightmodel2/position/hpath")
simDR_pos_theta = find_dataref("sim/flightmodel/position/theta")
simDR_pos_ias = find_dataref("sim/flightmodel/position/indicated_airspeed")
--[[

CUSTOM DATAREFS

]]
function fake_handler() end -- Required to make a custom dataref writable
Dref_Reference_Object = create_dataref("cockpit_crosshair/reference_point","array[4]",fake_handler) -- Visible,X,Y,Z
Dref_Crosshair_Object = create_dataref("cockpit_crosshair/crosshair","array[7]")       -- Visible,Rot_X,Rot_Y,Rot_Z,X,Y,Z
Dref_Crosshair_Offsets = create_dataref("cockpit_crosshair/crosshair_offsets","array[7]",fake_handler)       -- Visible,Rot_X,Rot_Y,Rot_Z,X,Y,Z
Dref_Crosshair_AutoEnableIAS = create_dataref("cockpit_crosshair/auto_enable_ias","number",fake_handler)       -- Velocity in knots
Dref_Crosshair_AngleModeIAS = create_dataref("cockpit_crosshair/angle_mode_ias","number",fake_handler)       -- Velocity in knots
Dref_Crosshair_Mode = create_dataref("cockpit_crosshair/mode","number",fake_handler)       -- Crosshair mode 0=Auto, 1=Angle, 2=Flight Path
--[[

FUNCTIONS

]]
--[[ Callback for the custom command to toggle the cross ]]
function Callback_Crosshair_Toggle(phase,duration)
    if phase == 0 then -- 0 = command begin, 1 = command continue, 2 = command end
        if Dref_Crosshair_Offsets[0] == 0 then Dref_Crosshair_Offsets[0] = 1 else Dref_Crosshair_Offsets[0] = 0 end
    end
end
--[[ Callback for the custom command to toggle the cross ]]
function Callback_Reference_Toggle(phase,duration)
    if phase == 0 then -- 0 = command begin, 1 = command continue, 2 = command end
        if Dref_Reference_Object[0] == 0 then Dref_Reference_Object[0] = 1 else Dref_Reference_Object[0] = 0 end
    end
end
--[[ Callback for the custom command to reload the offset file ]]
function Callback_Settings_Reload(phase,duration)
    if phase == 0 then -- 0 = command begin, 1 = command continue, 2 = command end
        Instance_Read_Settings()
    end
end
--[[ Callback to cycle crosshair mode ]]
function Callback_Cycle_Mode(phase,duration)
    if phase == 0 then -- 0 = command begin, 1 = command continue, 2 = command end
        Force_Mode = Force_Mode + 1
        if Force_Mode > 2 then Force_Mode = 0 end
    end
end
--[[ This stuff runs in the timer below ]]
function Run_In_Timer()
    Menu_Timed() -- See core_menu.lua
    -- Control crosshair visbility
    if simDR_pos_ias < Dref_Crosshair_AutoEnableIAS and Dref_Crosshair_Offsets[0] == 1 then
        Dref_Crosshair_Object[0] = 1    -- Visibility
    else
        Dref_Crosshair_Object[0] = 0
    end
    -- Swiches crosshair modes
    if simDR_pos_ias <= Dref_Crosshair_AngleModeIAS then
        if Force_Mode == 2 then
            Dref_Crosshair_Mode = 2
        else
            Dref_Crosshair_Mode = 1
        end
    else
        if Force_Mode == 1 then
            Dref_Crosshair_Mode = 1
        else
            Dref_Crosshair_Mode = 2
        end
    end
    -- Prints message regarding new crosshair mode
    if Dref_Crosshair_Mode ~= Active_Mode_Old then
        if Dref_Crosshair_Mode == 1 then
            if Force_Mode == 0 then
                print("Cockpit Crosshair: Angle Mode (Auto-Switched)")
            else
                print("Cockpit Crosshair: Angle Mode (Forced)")
            end
        end
        if Dref_Crosshair_Mode == 2 then
            if Force_Mode == 0 then
                print("Cockpit Crosshair: Flight Path Mode (Auto-Switched)")
            else
                print("Cockpit Crosshair: Flight Path Mode (Forced)")
            end
        end
        Active_Mode_Old = Dref_Crosshair_Mode
    end
end
--[[

CUSTOM COMMMAND

]]
create_command("cockpit_crosshair/toggle_crosshair","Cockpit Crosshair: Toggle",Callback_Crosshair_Toggle)
create_command("cockpit_crosshair/toggle_reference","Cockpit Crosshair: Toggle Ref. Point",Callback_Reference_Toggle)
create_command("cockpit_crosshair/reload_settings","Cockpit Crosshair: Reload Settings",Callback_Settings_Reload)
create_command("cockpit_crosshair/cycle_mode","Cockpit Crosshair: Cycle Mode",Callback_Cycle_Mode)
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
    -- Angle mode
    if Dref_Crosshair_Mode == 1 then
        Dref_Crosshair_Object[1] = Dref_Crosshair_Offsets[1] - simDR_pos_theta -- Rot_X for angle
        Dref_Crosshair_Object[3] = Dref_Crosshair_Offsets[3] + simDR_pos_beta -- Rot_Z for angle
    end
    -- Flight Path mode
    if Dref_Crosshair_Mode == 2 then
        Dref_Crosshair_Object[1] = simDR_pos_vpath - simDR_pos_theta -- Rot_X for flight path
        Dref_Crosshair_Object[3] = simDR_pos_beta -- Rot_Z for flight path
    end
    Dref_Crosshair_Object[2] = Dref_Crosshair_Offsets[2]    -- Rot_Y
    Dref_Crosshair_Object[4] = Dref_Crosshair_Offsets[4]    -- X
    Dref_Crosshair_Object[5] = Dref_Crosshair_Offsets[5]    -- Y
    Dref_Crosshair_Object[6] = Dref_Crosshair_Offsets[6]    -- Z
end
--[[ This runs when the aircraft is unloaded ]]
function aircraft_unload()
    Menu_Unload() -- See core_menu.lua
    Instance_Obj_Unload() -- See core_instancing.lua
end
