--[[

Cockpit Crosshair Module, required by cockpit_crosshair.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
local Menu_Index = nil
local Menu_ID = nil
local Menu_Pointer = ffi.new("const char")
--[[ Table for main menu items ]]
local Menu_Items = {
"Cockpit Crosshair",        -- 1, MENU TITLE
"Toggle Crosshair",         -- 2
"Toggle Reference Object",  -- 3
"Angle Bars On Land. Lts.", -- 4
"[Separator]",              -- 5
"Reload Settings",          -- 6
}
--[[

FUNCTIONS

]]
--[[ Menu cleanup upon script reload or session exit ]]
function Menu_CleanUp(menu_id,menu_index)
   if menu_id ~= nil then XPLM.XPLMClearAllMenuItems(menu_id) XPLM.XPLMDestroyMenu(menu_id) end
   if menu_index ~= nil then XPLM.XPLMRemoveMenuItem(XPLM.XPLMFindAircraftMenu(),Menu_Index) end
end
--[[ Menu item prefix name change ]]
function Menu_ChangeItemPrefix(menu_id,index,prefix,intable)
    --LogOutput("Plopp: "..","..index..","..prefix..","..table.concat(intable,":"))
    XPLM.XPLMSetMenuItemName(menu_id,index-2,prefix.." "..intable[index],1)
end
--[[ Menu item suffix name change ]]
function Menu_ChangeItemSuffix(menu_id,index,suffix,intable)
    --LogOutput("Plopp: "..","..index..","..prefix..","..table.concat(intable,":"))
    XPLM.XPLMSetMenuItemName(menu_id,index-2,intable[index].." "..suffix,1)
end
--[[ Menu item check status change ]]
function Menu_CheckItem(menu_id,index,state)
    index = index - 2
    local out = ffi.new("XPLMMenuCheck[1]")
    XPLM.XPLMCheckMenuItemState(menu_id,index,ffi.cast("XPLMMenuCheck *",out))
    if tonumber(out[0]) == 0 then XPLM.XPLMCheckMenuItem(menu_id,index,1) end
    if state == "Activate" and tonumber(out[0]) ~= 2 then XPLM.XPLMCheckMenuItem(menu_id,index,2)
    elseif state == "Deactivate" and tonumber(out[0]) ~= 1 then XPLM.XPLMCheckMenuItem(menu_id,index,1)
    end
end
--[[

MENU HANDLERS

]]
--[[ Main Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function Menu_Callbacks(itemref)
    for i=2,#Menu_Items do
        if itemref == Menu_Items[i] then
            if i == 2 then
                if Dref_Crosshair_In[0] == 0 then Dref_Crosshair_In[0] = 1 else Dref_Crosshair_In[0] = 0 end
            end
            if i == 3 then
                if Dref_Reference_In_Out[0] == 0 then Dref_Reference_In_Out[0] = 1 else Dref_Reference_In_Out[0] = 0 end
            end
            if i == 4 then
                if Angle_Bars_On_LandLight == 0 then Angle_Bars_On_LandLight = 1 else Angle_Bars_On_LandLight = 0 end
            end
            if i == 6 then
                Instance_Read_Settings()
            end
            Menu_Watchdog(Menu_Items,i)
        end
    end
end
--[[ Menu watchdog that is used to check an item or change its prefix ]]
function Menu_Watchdog(intable,index)
    if index == 2 then
        if Dref_Crosshair_Out[0] == 1 then Menu_CheckItem(Menu_ID,index,"Activate") else Menu_CheckItem(Menu_ID,index,"Deactivate") end
    end
    if index == 3 then
        if Dref_Reference_In_Out[0] == 1 then Menu_CheckItem(Menu_ID,index,"Activate") else Menu_CheckItem(Menu_ID,index,"Deactivate") end
    end
    if index == 4 then
        if Angle_Bars_On_LandLight == 1 then Menu_CheckItem(Menu_ID,index,"Activate") else Menu_CheckItem(Menu_ID,index,"Deactivate") end
    end
end
--[[

MENU INIT

]]
--[[ Build logic for the main menu ]]
function Menu_Build()
    local Menu_Indices = {}
    for i=2,#Menu_Items do Menu_Indices[i] = 0 end
    if XPLM ~= nil then
        Menu_Index = XPLM.XPLMAppendMenuItem(XPLM.XPLMFindAircraftMenu(),Menu_Items[1],ffi.cast("void *","None"),1)
        Menu_ID = XPLM.XPLMCreateMenu(Menu_Items[1],XPLM.XPLMFindAircraftMenu(),Menu_Index,function(inMenuRef,inItemRef) Menu_Callbacks(inItemRef) end,ffi.cast("void *",Menu_Pointer))
        for i=2,#Menu_Items do
            if Menu_Items[i] ~= "[Separator]" then
                Menu_Pointer = Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(Menu_ID,Menu_Items[i],ffi.cast("void *",Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(Menu_ID)
            end
        end
        for i=2,#Menu_Items do
            if Menu_Items[i] ~= "[Separator]" then
                Menu_Watchdog(Menu_Items,i)
            end
        end
    end
end
--[[

INITIALIZATION

]]
--[[ Initializes the debug module at every startup ]]
function Menu_Init()
    Menu_Watchdog(Menu_Items,2)
end
--[[ This is what runs from a timer ]]
function Menu_Timed()
    for i=2,#Menu_Items do Menu_Watchdog(Menu_Items,i) end
end
--[[ Unload logic for the main menu ]]
function Menu_Unload()
    Menu_CleanUp(Menu_ID,Menu_Index)
end
