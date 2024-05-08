--[[

Cockpit Crosshair Module, required by cockpit_crosshair.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

Credit to XPJavelin (SGES) and laurenzo (SGS) for some code inspiration.

]]
--[[

VARIABLES

]]
local Inst_Container                                      -- Placeholder for instance array, was "AttachObj_Inst"
local Inst_DrefArray                                      -- Placeholder for instance dataref array, was "AttachObj_DrefArray"
local Inst_DrefAddr = ffi.new("const char**")             -- Arbitrary to store addr of dataref array (source: https://forums.x-plane.org/index.php?/files/file/53433-follow-me-car/), was "AttachObj_DrefAddr"
local Inst_Reference                                      -- Instance reference, was "AttachObj_InstRefs"
local Inst_WorldNew = {x=0,y=0,z=0}                       -- Was "AttachObj_WorldNew"
local Inst_DrawInfo = ffi.new("XPLMDrawInfo_t[?]",1)      -- Creates an information array depending on the length of the input table, was "AttachObj_DrawInfo"
local Inst_DrawInfoAddr = ffi.new("const XPLMDrawInfo_t*")-- Arbitrary to store address of drawinfo, was "AttachObj_DrawInfoAddr"
local Inst_DrawFloat = ffi.new("float[1]")                -- Some float value, was "AttachObj_DrawFloat"
local Inst_DrawFloatAddr = ffi.new("const float*")        -- Arbitrary to store addr of float value, was "AttachObj_DrawFloatAddr"
-- Probes are unused! (At the moment...)
local ProbeInfo = ffi.new("XPLMProbeInfo_t[?]",1)         -- Creates an information array depending on the length of the input table
local ProbeInfoAddr = ffi.new("XPLMProbeInfo_t*")         -- Arbitrary to store terrain probe address
local ProbeType = ffi.new("int[1]")                       -- Defines terrain probe type
local ProbeRef = ffi.new("XPLMProbeRef")                  -- Terrrain probe reference
local ProbeX = ffi.new("double[1]")                       -- Probe result output for OpenGL (local) x coordinate
local ProbeY = ffi.new("double[1]")                       -- Probe result output for OpenGL (local) y coordinate
local ProbeZ = ffi.new("double[1]")                       -- Probe result output for OpenGL (local) z coordinate
local ProbeContainer = {x=0,y=0,z=0}                      -- Container with x,y,z coordinates of terrain probe result
--[[

DATAREFS

]]
simDR_pos_local_x = find_dataref("sim/flightmodel/position/local_x") -- OpenGL Y
simDR_pos_local_y = find_dataref("sim/flightmodel/position/local_y") -- OpenGL Y
simDR_pos_local_z = find_dataref("sim/flightmodel/position/local_z") -- OpenGL Z
simDR_pos_the = find_dataref("sim/flightmodel/position/theta") -- Pitch
simDR_pos_phi = find_dataref("sim/flightmodel/position/phi") -- Roll
simDR_pos_psi = find_dataref("sim/flightmodel/position/psi") -- Yaw

--[[

FUNCTIONS

]]
--[[ HELPER: Splits a line at the designated delimiter, returns a table ]]
function SplitString(input,delim)
    local output = {}
    --PrintToConsole("Line splitting in: "..input)
    for i in string.gmatch(input,delim) do table.insert(output,i) end
    --PrintToConsole("Line splitting out: "..table.concat(output,",",1,#output))
    return output
end
local filename = "settings.cfg"
--[[ SETTINGS FILE: Read ]]
function Instance_Read_Settings()
    local file = io.open(Folder_Path.."/"..filename, "r") -- Check if file exists
    if file then
        print("Cockpit Crosshair: Started reading of "..filename)
        local i=0
        for line in file:lines() do
            if string.match(line,"^[^#]") then -- Only catch lines that are not starting with a "#"
                local splitvalues = SplitString(line,"([^,]+)") -- Split line at commas
                --print(table.concat(splitvalues,";"))
                -- AUTO ENABLE
                if splitvalues[1] == "AUTO_ENABLE" then -- Look for this string
                    if #splitvalues == 2 then
                        if tonumber(splitvalues[2]) ~= nil then
                            Dref_Crosshair_AutoEnableIAS = tonumber(splitvalues[2])
                        else
                            print("Cockpit Crosshair: ERROR! Value "..j.." in the AUTO_ENABLE line of "..filename.." is not a number!")
                        end
                    else
                        print("Cockpit Crosshair: ERROR! Malformed AUTO_ENABLE line in "..filename..", 2 items required!")
                    end
                    print("Cockpit Crosshair: AUTO_ENABLE initial value: "..Dref_Crosshair_AutoEnableIAS)
                end
                -- MAX SPEED FOR ANGLE BARS
                if splitvalues[1] == "ANGLE_BARS_MAX_SPD" then -- Look for this string
                    if #splitvalues == 2 then
                        if tonumber(splitvalues[2]) ~= nil then
                            Dref_Crosshair_AngleBarsIAS = tonumber(splitvalues[2])
                        else
                            print("Cockpit Crosshair: ERROR! Value "..j.." in the ANGLE_BARS_MAX_SPD line of "..filename.." is not a number!")
                        end
                    else
                        print("Cockpit Crosshair: ERROR! Malformed ANGLE_BARS_MAX_SPD line in "..filename..", 2 items required!")
                    end
                    print("Cockpit Crosshair: ANGLE_BARS_MAX_SPD initial value: "..Dref_Crosshair_AngleBarsIAS)
                end
                -- ANGLE BAR ON LAND LIGHT
                if splitvalues[1] == "ANGLE_BARS_ON_LAND_LIGHT" then -- Look for this string
                    if #splitvalues == 2 then
                        if tonumber(splitvalues[2]) ~= nil then
                            Angle_Bars_On_LandLight = tonumber(splitvalues[2])
                        else
                            print("Cockpit Crosshair: ERROR! Value "..j.." in the ANGLE_BARS_ON_LAND_LIGHT line of "..filename.." is not a number!")
                        end
                    else
                        print("Cockpit Crosshair: ERROR! Malformed ANGLE_BARS_ON_LAND_LIGHT line in "..filename..", 2 items required!")
                    end
                    print("Cockpit Crosshair: ANGLE_BARS_ON_LAND_LIGHT initial value: "..Angle_Bars_On_LandLight)
                end
                -- INTERIOR ONLY
                if splitvalues[1] == "INTERIOR_ONLY" then -- Look for this string
                    if #splitvalues == 2 then
                        if tonumber(splitvalues[2]) ~= nil then
                            Interior_Only = tonumber(splitvalues[2])
                        else
                            print("Cockpit Crosshair: ERROR! Value "..j.." in the INTERIOR_ONLY line of "..filename.." is not a number!")
                        end
                    else
                        print("Cockpit Crosshair: ERROR! Malformed INTERIOR_ONLY line in "..filename..", 2 items required!")
                    end
                    print("Cockpit Crosshair: INTERIOR_ONLY initial value: "..Interior_Only)
                end
                -- REFERENCE
                if splitvalues[1] == "REFERENCE" then -- Look for this string
                    if #splitvalues == 5 then
                        for j=2,5 do
                            if tonumber(splitvalues[j]) ~= nil then
                                Dref_Reference_In_Out[j-2] = tonumber(splitvalues[j])
                            else
                                print("Cockpit Crosshair: ERROR! Value "..j.." in the REFERENCE line of "..filename.." is not a number!")
                            end
                        end
                    else
                        print("Cockpit Crosshair: ERROR! Malformed REFERENCE line in "..filename..", 5 items required!")
                    end
                    print("Cockpit Crosshair: Reference object initial values: "..Dref_Reference_In_Out[0]..","..Dref_Reference_In_Out[1]..","..Dref_Reference_In_Out[2]..","..Dref_Reference_In_Out[3])
                end
                -- CROSSHAIR
                if splitvalues[1] == "CROSSHAIR" then -- Look for this string
                    if #splitvalues == 8 then
                        for j=2,8 do
                            if tonumber(splitvalues[j]) ~= nil then
                                Dref_Crosshair_In[j-2] = tonumber(splitvalues[j])
                            else
                                print("Cockpit Crosshair: ERROR! Value "..j.." in the CROSSHAIR line of "..filename.." is not a number!")
                            end
                        end
                    else
                        print("Cockpit Crosshair: ERROR! Malformed CROSSHAIR line in "..filename..", 8 items required!")
                    end
                    print("Cockpit Crosshair: Crosshair object initial values: "..Dref_Crosshair_In[0]..","..Dref_Crosshair_In[1]..","..Dref_Crosshair_In[2]..","..Dref_Crosshair_In[3]..","..Dref_Crosshair_In[4]..","..Dref_Crosshair_In[5]..","..Dref_Crosshair_In[6]..","..Dref_Crosshair_In[7])
                end
                -- ANGLE BARS
                if splitvalues[1] == "ANGLE_BARS" then -- Look for this string
                    if #splitvalues == 5 then
                        for j=2,5 do
                            if tonumber(splitvalues[j]) ~= nil then
                                Dref_Angle_Bars_In[j-2] = tonumber(splitvalues[j])
                            else
                                print("Cockpit Crosshair: ERROR! Value "..j.." in the ANGLE_BARS line of "..filename.." is not a number!")
                            end
                        end
                    else
                        print("Cockpit Crosshair: ERROR! Malformed ANGLE_BARS line in "..filename..", 5 items required!")
                    end
                    print("Cockpit Crosshair: Reference object initial values: "..Dref_Angle_Bars_In[0]..","..Dref_Angle_Bars_In[1]..","..Dref_Angle_Bars_In[2]..","..Dref_Angle_Bars_In[3])
                end
                i=i+1 -- Checksum for successfully parsed lines
            end
        end
        file:close()
        if i ~= nil and i > 0 then print("Cockpit Crosshair: "..filename.." parsed!") else print("Cockpit Crosshair: "..filename.." read error!") end
    else
        print("Cockpit Crosshair: "..filename.." not found!")
    end
end


--[[ OBJECT INSTANCE: Delays the drawing of objects ]]
function Instance_Delayed()
    --AttachObj_AllowDrawing = 1
end

--[[ OBJECT INSTANCE: Initialize ]]
function Instance_Create()
    if Inst_Container == nil then
        Inst_Container = ffi.new("XPLMInstanceRef[?]",1)   -- Create an instance array of length 1
        Inst_DrefArray = ffi.new("const char*[?]",3)  -- Create a dataref array with a length of 2
        Inst_DrefArray[0] = "cockpit_crosshair/reference_point"
        Inst_DrefArray[1] = "cockpit_crosshair/crosshair"
        Inst_DrefArray[2] = NULL -- Terminate array with null value to satisfy https://developer.x-plane.com/sdk/XPLMCreateInstance/
        Inst_DrefAddr = Inst_DrefArray           -- Write array to arbitrary
        Inst_Reference = ffi.new("XPLMObjectRef")
        XPLM.XPLMLoadObjectAsync(Folder_Path.."/resources/Cockpit_Crosshair.obj",function(inObject, inRefcon) Inst_Container[0] = XPLM.XPLMCreateInstance(inObject,Inst_DrefAddr) Inst_Reference = inObject end, inRefcon)
    end
    run_after_time(Instance_Delayed,0.25) -- Delay initial drawing a bit
end

--[[ OBJECT INSTANCE: Unload by destroying its instance and unloading the OBJ files ]]
function Instance_Obj_Unload()
    if Inst_Container ~= nil and Inst_Reference ~= nil then
        Inst_DrawInfo[0].x = 0
        Inst_DrawInfo[0].y = 0
        Inst_DrawInfo[0].z = 0
        Inst_DrawInfo[0].pitch = 0
        Inst_DrawInfo[0].heading = 0
        Inst_DrawInfo[0].roll = 0
        XPLM.XPLMDestroyInstance(Inst_Container[0])
        Inst_Container[0] = nil
        XPLM.XPLMUnloadObject(Inst_Reference)
        Inst_Reference = nil
        if Inst_Container[0] == nil --[[ and Inst_Reference == nil ]] then print("Cockpit Crosshair: Unloaded object.") end
    end
end

--[[ OBJECT INSTANCE: Transforms aircraft coordinates into local GL coordinates. Source: Austin Meyer himself. :) ]]
function Instance_AcftToWorld(x_acft,y_acft,z_acft,in_phi_deg,in_psi_deg,in_the_deg)
        local phi_rad = math.rad(in_phi_deg) -- Convert to radians
        local psi_rad = math.rad(in_psi_deg)
        local the_rad = math.rad(in_the_deg)
        local x_phi = (x_acft * math.cos(phi_rad)) + (y_acft * math.sin(phi_rad))
        local y_phi = (y_acft * math.cos(phi_rad)) - (x_acft * math.sin(phi_rad))
        local z_the = (z_acft * math.cos(the_rad)) + (y_phi * math.sin(the_rad))
        local out_x = (x_phi * math.cos(psi_rad)) - (z_the * math.sin(psi_rad))
        local out_y = (y_phi * math.cos(the_rad)) - (z_acft * math.sin(the_rad))
        local out_z = (z_the * math.cos(psi_rad)) + (x_phi * math.sin(psi_rad))
        return out_x,out_y,out_z
end

--[[ OBJECT INSTANCE: Updates the position when airplane-attached ]]
function Instance_Update_Pos()
    if Inst_Reference ~= nil then
        --Inst_WorldNew.x,Inst_WorldNew.y,Inst_WorldNew.z = Instance_AcftToWorld(AttachObj_Container[index][4],AttachObj_Container[index][5],AttachObj_Container[index][6],simDR_pos_phi,simDR_pos_psi,simDR_pos_the)
        Inst_DrawInfo[0].x = simDR_pos_local_x --+ Inst_WorldNew.x
        Inst_DrawInfo[0].y = simDR_pos_local_y --+ Inst_WorldNew.y
        Inst_DrawInfo[0].z = simDR_pos_local_z --+ Inst_WorldNew.z
        Inst_DrawInfo[0].pitch = simDR_pos_the --+ AttachObj_Container[index][7]
        Inst_DrawInfo[0].heading = simDR_pos_psi --+ AttachObj_Container[index][8]
        Inst_DrawInfo[0].roll = simDR_pos_phi --+ AttachObj_Container[index][9]
        Inst_DrawInfoAddr = Inst_DrawInfo
        Inst_DrawFloat[0] = 0
        Inst_DrawFloatAddr = Inst_DrawFloat
        XPLM.XPLMInstanceSetPosition(Inst_Container[0],Inst_DrawInfoAddr,Inst_DrawFloatAddr)
    end
end
--[[ OBJECT INSTANCE: Updates the position of all ground objects in a list of instance refs ]]
function Instance_Show_Gnd()
    --AttachObj_Shift.Dist = math.sqrt(((AttachObj_Container[index][4])^2)+((AttachObj_Container[index][6])^2)) -- Calculate distance from aircraft
    --AttachObj_Shift.Hdg = math.fmod((math.deg(math.atan2(AttachObj_Container[index][4],AttachObj_Container[index][6]))+360),360) -- Shift for heading
    --AttachObj_Shift.X = simDR_pos_local_x - math.sin(math.rad(simDR_pos_psi - AttachObj_Shift.Hdg)) * AttachObj_Shift.Dist
    --AttachObj_Shift.Z = simDR_pos_local_z - math.cos(math.rad(simDR_pos_psi - AttachObj_Shift.Hdg)) * AttachObj_Shift.Dist * -1
    --Probe_Update(AttachObj_Shift.X,simDR_pos_local_y,AttachObj_Shift.Z) -- Probes the ground below the object's position
    --Inst_DrawInfo[0].x = AttachObj_Shift.X -- Terrain X is local Z?
    --Inst_DrawInfo[0].y = ProbeContainer.y + AttachObj_Container[index][5]
    --Inst_DrawInfo[0].z = AttachObj_Shift.Z -- Terrain Z is local X?
    --Inst_DrawInfo[0].pitch = AttachObj_Container[index][7]
    --Inst_DrawInfo[0].heading = simDR_pos_psi + AttachObj_Container[index][8]
    --Inst_DrawInfo[0].roll = AttachObj_Container[index][9]
    --Inst_DrawInfoAddr = Inst_DrawInfo
    --Inst_DrawFloat[0] = 0
    --Inst_DrawFloatAddr = Inst_DrawFloat
    --XPLM.XPLMInstanceSetPosition(Inst_Container[0],Inst_DrawInfoAddr,Inst_DrawFloatAddr)
end
--[[ OBJECT INSTANCE: Hides an object by moving it to 0,0,0 ]]
function AttachObject_Hide()
    Inst_DrawInfo[0].x = 0
    Inst_DrawInfo[0].y = -1000
    Inst_DrawInfo[0].z = 0
    Inst_DrawInfo[0].pitch = 0
    Inst_DrawInfo[0].heading = 0
    Inst_DrawInfo[0].roll = 0
    AttachObj_DrawInfoAddr = Inst_DrawInfo
    Inst_DrawFloat[0] = 0
    Inst_DrawFloatAddr = Inst_DrawFloat
    XPLM.XPLMInstanceSetPosition(Inst_Container[0],AttachObj_DrawInfoAddr,Inst_DrawFloatAddr)
end
--[[ TERRAIN PROBE: Create ]]
function Probe_Create()
    ProbeInfo[0].structSize = ffi.sizeof(ProbeInfo[0])
    ProbeInfoAddr = ProbeInfo
    ProbeType[1] = 0
    ProbeRef = XPLM.XPLMCreateProbe(ProbeType[1])
end
--[[ TERRAIN PROBE: Probes the unterlying terrain ]]
function Probe_Update(in_x,in_y,in_z)
    ProbeX[0] = in_x
    ProbeY[0] = in_y
    ProbeZ[0] = in_z
    XPLM.XPLMProbeTerrainXYZ(ProbeRef,ProbeX[0],ProbeY[0],ProbeZ[0],ProbeInfoAddr)
    ProbeInfo = ProbeInfoAddr
    ProbeContainer.x = ProbeInfo[0].locationX
    ProbeContainer.y = ProbeInfo[0].locationY
    ProbeContainer.z = ProbeInfo[0].locationZ
end
--[[

INITIALIZATION

]]
--[[ Common start items ]]
function Instancing_Start()
    Instance_Read_Settings()
    -- Maybe later...
    --    Probe_Create()
    --    Probe_Update(simDR_pos_local_x,simDR_pos_local_y,simDR_pos_local_z)
    Instance_Create()
end
