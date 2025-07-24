local T = AceLibrary("Tablet-2.0")
local D = AceLibrary("Dewdrop-2.0")
local C = AceLibrary("Crayon-2.0")

local BC = AceLibrary("Babble-Class-2.2")
local L = AceLibrary("AceLocale-2.2"):new("retroll")

retep_loot = retep:NewModule("retep_loot", "AceDB-2.0")

function retep_loot:OnEnable()
  if not T:IsRegistered("retep_loot") then
    T:Register("retep_loot",
      "children", function()
        T:SetTitle(L["retroll loot info"])
        self:OnTooltipUpdate()
      end,
      "showTitleWhenDetached", true,
      "showHintWhenDetached", true,
      "cantAttach", true,
      "menu", function()
        D:AddLine(
          "text", L["Refresh"],
          "tooltipText", L["Refresh window"],
          "func", function() retep_loot:Refresh() end
        )
        D:AddLine(
          "text", L["Clear"],
          "tooltipText", L["Clear Loot."],
          "func", function() retep_looted = {} retep_loot:Refresh() end
        )        
      end      
    )
  end
  if not T:IsAttached("retep_loot") then
    T:Open("retep_loot")
  end
end

function retep_loot:OnDisable()
  T:Close("retep_loot")
end

function retep_loot:Refresh()
  T:Refresh("retep_loot")
end

function retep_loot:setHideScript()
  local i = 1
  local tablet = getglobal(string.format("Tablet20DetachedFrame%d",i))
  while (tablet) and i<100 do
    if tablet.owner ~= nil and tablet.owner == "retep_loot" then
      retep:make_escable(string.format("Tablet20DetachedFrame%d",i),"add")
      tablet:SetScript("OnHide",nil)
      tablet:SetScript("OnHide",function()
          if not T:IsAttached("retep_loot") then
            T:Attach("retep_loot")
            this:SetScript("OnHide",nil)
          end
        end)
      break
    end    
    i = i+1
    tablet = getglobal(string.format("Tablet20DetachedFrame%d",i))
  end  
end

function retep_loot:Top()
  if T:IsRegistered("retep_loot") and (T.registry.retep_loot.tooltip) then
    T.registry.retep_loot.tooltip.scroll=0
  end  
end

function retep_loot:Toggle(forceShow)
  self:Top()
  if T:IsAttached("retep_loot") then
    T:Detach("retep_loot") -- show
    if (T:IsLocked("retep_loot")) then
      T:ToggleLocked("retep_loot")
    end
    self:setHideScript()
  else
    if (forceShow) then
      retep_loot:Refresh()
    else
      T:Attach("retep_loot") -- hide
    end
  end  
end

function retep_loot:BuildLootTable()
  table.sort(retep_looted, function(a,b)
    if (a[1] ~= b[1]) then return a[1] > b[1]
    else return a[2] > b[2] end
  end)
  return retep_looted
end

function retep_loot:OnClickItem(data)

end

function retep_loot:OnTooltipUpdate()
  local cat = T:AddCategory(
      "columns", 5,
      "text",  C:Orange(L["Time"]),   "child_textR",    1, "child_textG",    1, "child_textB",    1, "child_justify",  "LEFT",
      "text2", C:Orange(L["Item"]),     "child_text2R",   1, "child_text2G",   1, "child_text2B",   0, "child_justify2", "LEFT",
      "text3", C:Orange(L["Binds"]),  "child_text3R",   0, "child_text3G",   1, "child_text3B",   0, "child_justify3", "CENTER",
      "text4", C:Orange(L["Looter"]),  "child_text4R",   0, "child_text4G",   1, "child_text4B",   0, "child_justify4", "RIGHT",
      "text5", C:Orange(L["GP Action"]),  "child_text5R",   0, "child_text5G",   1, "child_text5B",   0, "child_justify5", "RIGHT"         
    )
  local t = self:BuildLootTable()
  for i = 1, table.getn(t) do
    local timestamp,player,player_color,itemLink,bind,price,off_price,action = unpack(t[i])
    cat:AddLine(
      "text", timestamp,
      "text2", itemLink,
      "text3", bind,
      "text4", player_color,
      "text5", action--,
--      "func", "OnClickItem", "arg1", self, "arg2", t[i]
    )
  end
end

-- GLOBALS: retep_saychannel,retep_groupbyclass,retep_groupbyarmor,retep_groupbyrole,retep_raidonly,retep_decay,retep_minep,retep_reservechannel,retep_main,retep_progress,retep_discount,retep_log,retep_dbver,retep_looted
-- GLOBALS: retep,retep_prices,retep_standings,retep_bids,retep_loot,retep_reserves,retep_alts,retep_logs
