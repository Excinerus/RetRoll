local T = AceLibrary("Tablet-2.0")
local D = AceLibrary("Dewdrop-2.0")
local C = AceLibrary("Crayon-2.0")

local BC = AceLibrary("Babble-Class-2.2")
local L = AceLibrary("AceLocale-2.2"):new("retroll")
local _G = getfenv(0)

retep_standings = retep:NewModule("retep_standings", "AceDB-2.0")
local groupings = {
  "retep_groupbyclass",
  "retep_groupbyarmor",
  "retep_groupbyrole",
}
local PLATE, MAIL, LEATHER, CLOTH = 4,3,2,1
local DPS, CASTER, HEALER, TANK = 4,3,2,1
local class_to_armor = {
  PALADIN = PLATE,
  WARRIOR = PLATE,
  HUNTER = MAIL,
  SHAMAN = MAIL,
  DRUID = LEATHER,
  ROGUE = LEATHER,
  MAGE = CLOTH,
  PRIEST = CLOTH,
  WARLOCK = CLOTH,
}
local armor_text = {
  [CLOTH] = L["CLOTH"],
  [LEATHER] = L["LEATHER"],
  [MAIL] = L["MAIL"],
  [PLATE] = L["PLATE"],
}
local class_to_role = {
  PALADIN = {HEALER,DPS,TANK,CASTER},
  PRIEST = {HEALER,CASTER},
  DRUID = {HEALER,TANK,DPS,CASTER},
  SHAMAN = {HEALER,DPS,CASTER},
  MAGE = {CASTER},
  WARLOCK = {CASTER},
  ROGUE = {DPS},
  HUNTER = {DPS},
  WARRIOR = {TANK,DPS},
}
local role_text = {
  [TANK] = L["TANK"],
  [HEALER] = L["HEALER"],
  [CASTER] = L["CASTER"],
  [DPS] = L["PHYS DPS"],
}
local shooty_export = CreateFrame("Frame", "shooty_exportframe", UIParent)
shooty_export:SetWidth(250)
shooty_export:SetHeight(150)
shooty_export:SetPoint('TOP', UIParent, 'TOP', 0,-80)
shooty_export:SetFrameStrata('DIALOG')
shooty_export:Hide()
shooty_export:SetBackdrop({
  bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
  edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
  tile = true,
  tileSize = 16,
  edgeSize = 16,
  insets = {left = 5, right = 5, top = 5, bottom = 5}
  })
shooty_export:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
shooty_export:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
shooty_export.action = CreateFrame("Button","shooty_exportaction", shooty_export, "UIPanelButtonTemplate")
shooty_export.action:SetWidth(100)
shooty_export.action:SetHeight(22)
shooty_export.action:SetPoint("BOTTOM",0,-20)
shooty_export.action:SetText("Import")
shooty_export.action:Hide()
shooty_export.action:SetScript("OnClick",function() retep_standings.import() end)
shooty_export.title = shooty_export:CreateFontString(nil,"OVERLAY")
shooty_export.title:SetPoint("TOP",0,-5)
shooty_export.title:SetFont("Fonts\\ARIALN.TTF", 12)
shooty_export.title:SetWidth(200)
shooty_export.title:SetJustifyH("LEFT")
shooty_export.title:SetJustifyV("CENTER")
shooty_export.title:SetShadowOffset(1, -1)
shooty_export.edit = CreateFrame("EditBox", "shooty_exportedit", shooty_export)
shooty_export.edit:SetMultiLine(true)
shooty_export.edit:SetAutoFocus(true)
shooty_export.edit:EnableMouse(true)
shooty_export.edit:SetMaxLetters(0)
shooty_export.edit:SetHistoryLines(1)
shooty_export.edit:SetFont('Fonts\\ARIALN.ttf', 12, 'THINOUTLINE')
shooty_export.edit:SetWidth(290)
shooty_export.edit:SetHeight(190)
shooty_export.edit:SetScript("OnEscapePressed", function() 
    shooty_export.edit:SetText("")
    shooty_export:Hide() 
  end)
shooty_export.edit:SetScript("OnEditFocusGained", function()
  shooty_export.edit:HighlightText()
end)
shooty_export.edit:SetScript("OnCursorChanged", function() 
  shooty_export.edit:HighlightText()
end)
shooty_export.AddSelectText = function(txt)
  shooty_export.edit:SetText(txt)
  shooty_export.edit:HighlightText()
end
shooty_export.scroll = CreateFrame("ScrollFrame", "shooty_exportscroll", shooty_export, 'UIPanelScrollFrameTemplate')
shooty_export.scroll:SetPoint('TOPLEFT', shooty_export, 'TOPLEFT', 8, -30)
shooty_export.scroll:SetPoint('BOTTOMRIGHT', shooty_export, 'BOTTOMRIGHT', -30, 8)
shooty_export.scroll:SetScrollChild(shooty_export.edit)
retep:make_escable("shooty_exportframe","add")

function retep_standings:Export()
  shooty_export.action:Hide()
  shooty_export.title:SetText(C:Gold(L["Ctrl-C to copy. Esc to close."]))
  local t = {}
  for i = 1, GetNumGuildMembers(1) do
    local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
    local ep = (retep:get_ep_v3(name,officernote) or 0) 
    local gp = (retep:get_gp_v3(name,officernote) or retep.VARS.basegp) 
    if ep > 0 then
      table.insert(t,{name,ep,gp,ep+math.min(50,gp)})
    end
  end 
  table.sort(t, function(a,b)
      return tonumber(a[4]) > tonumber(b[4])
    end)
  shooty_export:Show()
  local txt = "Name;EP;GP;PR\n"
  for i,val in ipairs(t) do
    txt = string.format("%s%s;%d;%d;%d\n",txt,val[1],val[2],val[3],val[4])
  end
  shooty_export.AddSelectText(txt)
end

function retep_standings:Import()
  if not IsGuildLeader() then return end
  shooty_export.action:Show()
  shooty_export.title:SetText(C:Red("Ctrl-V to paste data. Esc to close."))
  shooty_export.AddSelectText(L.IMPORT_WARNING)
  shooty_export:Show()
end

function retep_standings.import()
  if not IsGuildLeader() then return end
  local text = shooty_export.edit:GetText()
  local t = {}
  local found
  for line in string.gfind(text,"[^\r\n]+") do
    local name,ep,gp,pr = retep:strsplit(";",line)
    ep,gp = tonumber(ep),tonumber(gp)--,tonumber(pr)
    if (name) and (ep) and (gp) and (pr) then
      t[name]={ep,gp}
      found = true
    end
  end
  if (found) then
    local count = 0
    shooty_export.edit:SetText("")
    for i=1,GetNumGuildMembers(1) do
      local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
      local name_epgp = t[name]
      if (name_epgp) then
        count = count + 1
        --retep:debugPrint(string.format("%s {%s:%s}",name,name_epgp[1],name_epgp[2])) -- Debug
        retep:update_epgp_v3(name_epgp[1],name_epgp[2],i,name,officernote)
        t[name]=nil
      end
    end
    retep:defaultPrint(string.format(L["Imported %d members."],count))
    local report = string.format(L["Imported %d members.\n"],count)
    report = string.format(L["%s\nFailed to import:"],report)
    for name,epgp in pairs(t) do
      report = string.format("%s%s {%s:%s}\n",report,name,t[1],t[2])
    end
    shooty_export.AddSelectText(report)
  end
end

local class_cache = setmetatable({},{__index = function(t,k)
  local class
  if BC:HasReverseTranslation(k) then
    class = string.upper(BC:GetReverseTranslation(k))
  else
    class = string.upper(k)
  end
  if (class) then
    rawset(t,k,class)
    return class
  end
  return k
end})
function retep_standings:getArmorClass(class)
  class = class_cache[class]
  return class_to_armor[class] or 0
end

function retep_standings:getRolesClass(roster)
  local roster_num = table.getn(roster)
  for i=1,roster_num do
    local player = roster[i]
    local name, lclass, armor_class, ep, gp, pr = unpack(player)
    local class = class_cache[lclass]
    local roles = class_to_role[class]
    if not (roles) then
      player[3]=0
    else
      for i,role in ipairs(roles) do
        if i==1 then
          player[3]=role
        else
          table.insert(roster,{player[1],player[2],role,player[4],player[5],player[6]})
        end
      end      
    end
  end
  return roster
end 

function retep_standings:OnEnable()
  if not T:IsRegistered("retep_standings") then
    T:Register("retep_standings",
      "children", function()
        T:SetTitle(L["retroll standings"])
        self:OnTooltipUpdate()
      end,
  		"showTitleWhenDetached", true,
  		"showHintWhenDetached", true,
  		"cantAttach", true,
  		"menu", function()
        D:AddLine(
          "text", L["Raid Only"],
          "tooltipText", L["Only show members in raid."],
          "checked", retep_raidonly,
          "func", function() retep_standings:ToggleRaidOnly() end
        )      
        D:AddLine(
          "text", L["Group by class"],
          "tooltipText", L["Group members by class."],
          "checked", retep_groupbyclass,
          "func", function() retep_standings:ToggleGroupBy("retep_groupbyclass") end
        )
        D:AddLine(
          "text", L["Group by armor"],
          "tooltipText", L["Group members by armor."],
          "checked", retep_groupbyarmor,
          "func", function() retep_standings:ToggleGroupBy("retep_groupbyarmor") end
        )
        D:AddLine(
          "text", L["Group by roles"],
          "tooltipText", L["Group members by roles."],
          "checked", retep_groupbyrole,
          "func", function() retep_standings:ToggleGroupBy("retep_groupbyrole") end
        )
        D:AddLine(
          "text", L["Refresh"],
          "tooltipText", L["Refresh window"],
          "func", function() retep_standings:Refresh() end
        )
        D:AddLine(
          "text", L["Export"],
          "tooltipText", L["Export standings to csv."],
          "func", function() retep_standings:Export() end
        )
        if IsGuildLeader() then
          D:AddLine(
          "text", L["Import"],
          "tooltipText", L["Import standings from csv."],
          "func", function() retep_standings:Import() end
        )
        end
  		end
    )
  end
  if not T:IsAttached("retep_standings") then
    T:Open("retep_standings")
  end
end

function retep_standings:OnDisable()
  T:Close("retep_standings")
end

function retep_standings:Refresh()
  T:Refresh("retep_standings")
end

function retep_standings:setHideScript()
  local i = 1
  local tablet = getglobal(string.format("Tablet20DetachedFrame%d",i))
  while (tablet) and i<100 do
    if tablet.owner ~= nil and tablet.owner == "retep_standings" then
      retep:make_escable(string.format("Tablet20DetachedFrame%d",i),"add")
      tablet:SetScript("OnHide",nil)
      tablet:SetScript("OnHide",function()
          if not T:IsAttached("retep_standings") then
            T:Attach("retep_standings")
            this:SetScript("OnHide",nil)
          end
        end)
      break
    end    
    i = i+1
    tablet = getglobal(string.format("Tablet20DetachedFrame%d",i))
  end  
end

function retep_standings:Top()
  if T:IsRegistered("retep_standings") and (T.registry.retep_standings.tooltip) then
    T.registry.retep_standings.tooltip.scroll=0
  end  
end

function retep_standings:Toggle(forceShow)
  self:Top()
  if T:IsAttached("retep_standings") then -- hidden
    T:Detach("retep_standings") -- show
    if (T:IsLocked("retep_standings")) then
      T:ToggleLocked("retep_standings")
    end
    self:setHideScript()
  else
    if (forceShow) then
      retep_standings:Refresh()
    else
      T:Attach("retep_standings") -- hide
    end
  end  
end

function retep_standings:ToggleGroupBy(setting)
  for _,value in ipairs(groupings) do
    if value ~= setting then
      _G[value] = false
    end
  end
  _G[setting] = not _G[setting]
  self:Top()
  self:Refresh()
end

function retep_standings:ToggleRaidOnly()
  retep_raidonly = not retep_raidonly
  self:Top()
  retep:SetRefresh(true)
end

local pr_sorter_standings = function(a,b)
  if retep_minep > 0 then
    local a_over = a[4]-retep_minep >= 0
    local b_over = b[4]-retep_minep >= 0
    if a_over and b_over or (not a_over and not b_over) then
      if a[6] ~= b[6] then
        return tonumber(a[6]) > tonumber(b[6])
      else
        return tonumber(a[4]) > tonumber(b[4])
      end
    elseif a_over and (not b_over) then
      return true
    elseif b_over and (not a_over) then
      return false
    end
  else
    if a[6] ~= b[6] then
      return tonumber(a[6]) > tonumber(b[6])
    else
      return tonumber(a[4]) > tonumber(b[4])
    end
  end
end
-- Builds a standings table with record:
-- name, class, armor_class, roles, EP, GP, PR
-- and sorted by PR
function retep_standings:BuildStandingsTable()
  local t = { }
  local r = { }
  if (retep_raidonly) and GetNumRaidMembers() > 0 then
    for i = 1, GetNumRaidMembers(true) do
      local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i) 
      r[name] = true
    end
  end
  retep.alts = {}
  for i = 1, GetNumGuildMembers(1) do
    local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
    local ep = (retep:get_ep_v3(name,officernote) or 0) 
    local gp = (retep:get_gp_v3(name,officernote) or retep.VARS.basegp)
    local main, main_class, main_rank = retep:parseAlt(name,officernote)
    
    -- Check if the player is a pug
    local pugName = retep:getPugName(name)
    local displayName = pugName and string.format("%s (%s)", pugName, name) or name

    if (main) then
      if ((retep._playerName) and (name == retep._playerName)) then
        if (not retep_main) or (retep_main and retep_main ~= main) then
          retep_main = main
          retep:defaultPrint(L["Your main has been set to %s"],retep_main)
        end
      end
      main = C:Colorize(BC:GetHexColor(main_class), main)
      retep.alts[main] = retep.alts[main] or {}
      retep.alts[main][name] = class
    end
    local armor_class = self:getArmorClass(class)
    if ep > 0 then
      if (retep_raidonly) and next(r) then
        if r[name] then
          table.insert(t,{displayName,class,armor_class,ep,gp,(ep+ math.min(retep.VARS.dpRollCap,gp)),name})
        end
      else
        table.insert(t,{displayName,class,armor_class,ep,gp,(ep+ math.min(retep.VARS.dpRollCap,gp)),name})
      end
    end
  end
  if (retep_groupbyclass) then
    table.sort(t, function(a,b)
      if (a[2] ~= b[2]) then return a[2] > b[2]
      else return pr_sorter_standings(a,b) end
    end)
  elseif (retep_groupbyarmor) then
    table.sort(t, function(a,b)
      if (a[3] ~= b[3]) then return a[3] > b[3]
      else return pr_sorter_standings(a,b) end
    end)
  elseif (retep_groupbyrole) then
    t = self:getRolesClass(t) -- we are subbing role into armor_class to avoid extra table creation
    table.sort(t, function(a,b)
    if (a[3] ~= b[3]) then return a[3] > b[3]
      else return pr_sorter_standings(a,b) end
    end)   
  else
    table.sort(t, pr_sorter_standings)
  end
  return t
end


function retep_standings:OnTooltipUpdate()
  local cat = T:AddCategory(
      "columns", 4,
      "text",  C:Orange(L["Name"]),   "child_textR",    1, "child_textG",    1, "child_textB",    1, "child_justify",  "LEFT",
      "text2", C:Orange(L["Primary"]),     "child_text2R",   1, "child_text2G",   1, "child_text2B",   1, "child_justify2", "RIGHT",
      "text3", C:Orange(L["Auxiliary"]),     "child_text3R",   1, "child_text3G",   1, "child_text3B",   1, "child_justify3", "RIGHT",
      "text4", C:Orange(L["Roll"]),     "child_text4R",   1, "child_text4G",   1, "child_text4B",   0, "child_justify4", "RIGHT"
    )
  local t = self:BuildStandingsTable()
  local separator
  for i = 1, table.getn(t) do
    local displayName, class, armor_class, ep, gp, pr, originalName = unpack(t[i])
    if (retep_groupbyarmor) or (retep_groupbyrole) then
      if not (separator) then
        if (retep_groupbyarmor) then
          separator = armor_text[armor_class]
        elseif (retep_groupbyrole) then
          separator = role_text[armor_class]
        end
        if (separator) then
          cat:AddLine(
            "text", C:Green(separator),
            "text2", "",
            "text3", "",
            "text4", ""
          )
        end
      else
        local last_separator = separator
        if (retep_groupbyarmor) then
          separator = armor_text[armor_class]
        elseif (retep_groupbyrole) then
          separator = role_text[armor_class]
        end
        if (separator) and (separator ~= last_separator) then
          cat:AddLine(
            "text", C:Green(separator),
            "text2", "",
            "text3", "",
            "text4", ""
          )          
        end
      end
    end
	
	local egp = math.min( gp , retep.VARS.dpRollCap )
	local hf = retep.VARS.dpRollCap/2
	local blue = 0
	local green =  math.max(egp, retep.VARS.dpRollCap/4)/retep.VARS.dpRollCap *255
	local red =  (1-( math.max(math.min(egp,retep.VARS.dpRollCap )-hf,0)/hf))  *255  
	
	if (gp<0 ) then blue = 0 red = 255 green = 0 end
    local text = C:Colorize(BC:GetHexColor(class), displayName)
    local text2, text4
    if retep_minep > 0 and ep < retep_minep then
      text2 = C:Red(string.format("%.4g", ep))
      text4 = C:Red(string.format("%.4g", pr))
    else
      text2 = string.format("%.4g", ep)
      text4 =   string.format("%s (%s)",  pr,   C:Colorize( string.format("%02x%02x%02x", red,green,0 ) , egp)    ) 
    end
	
 
	

	if (gp > retep.VARS.dpRollCap ) then blue = 255 red = 128 green = 128 end
	
    local text3 =  C:Colorize( string.format("%02x%02x%02x", red,green,blue ) , gp)  
    if ((retep._playerName) and retep._playerName == originalName) or ((retep_main) and retep_main == originalName) then
      text = string.format("(*)%s",text)
      --local pr_decay = retep:capcalc(ep,gp)
      --if pr_decay < 0 then
      --  text4 = string.format("%s(|cffff0000%.4g|r)",text4,pr_decay)
      --end
    end
    cat:AddLine(
      "text", text,
      "text2", text2,
      "text3", text3,
      "text4", text4
    )
  end
end

-- GLOBALS: retep_saychannel,retep_groupbyclass,retep_groupbyarmor,retep_groupbyrole,retep_raidonly,retep_decay,retep_minep,retep_reservechannel,retep_main,retep_progress,retep_discount,retep_log,retep_dbver,retep_looted
-- GLOBALS: retep,retep_prices,retep_standings,retep_bids,retep_loot,retep_reserves,retep_alts,retep_logs
