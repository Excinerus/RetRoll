local T = AceLibrary("Tablet-2.0")
local D = AceLibrary("Dewdrop-2.0")
local C = AceLibrary("Crayon-2.0")

local BC = AceLibrary("Babble-Class-2.2")
local L = AceLibrary("AceLocale-2.2"):new("retroll")

retep_alts = retep:NewModule("retep_alts", "AceDB-2.0")

function retep_alts:OnEnable()
  if not T:IsRegistered("retep_alts") then
    T:Register("retep_alts",
      "children", function()
        T:SetTitle(L["retroll alts"])
        self:OnTooltipUpdate()
      end,
      "showTitleWhenDetached", true,
      "showHintWhenDetached", true,
      "cantAttach", true,
      "menu", function()
        D:AddLine(
          "text", L["Refresh"],
          "tooltipText", L["Refresh window"],
          "func", function() retep_alts:Refresh() end
        )
      end      
    )
  end
  if not T:IsAttached("retep_alts") then
    T:Open("retep_alts")
  end
end

function retep_alts:OnDisable()
  T:Close("retep_alts")
end

function retep_alts:Refresh()
  T:Refresh("retep_alts")
end

function retep_alts:setHideScript()
  local i = 1
  local tablet = getglobal(string.format("Tablet20DetachedFrame%d",i))
  while (tablet) and i<100 do
    if tablet.owner ~= nil and tablet.owner == "retep_alts" then
      retep:make_escable(string.format("Tablet20DetachedFrame%d",i),"add")
      tablet:SetScript("OnHide",nil)
      tablet:SetScript("OnHide",function()
          if not T:IsAttached("retep_alts") then
            T:Attach("retep_alts")
            this:SetScript("OnHide",nil)
          end
        end)
      break
    end    
    i = i+1
    tablet = getglobal(string.format("Tablet20DetachedFrame%d",i))
  end
end

function retep_alts:Top()
  if T:IsRegistered("retep_alts") and (T.registry.retep_alts.tooltip) then
    T.registry.retep_alts.tooltip.scroll=0
  end  
end

function retep_alts:Toggle(forceShow)
  self:Top()
  if T:IsAttached("retep_alts") then
    T:Detach("retep_alts") -- show
    if (T:IsLocked("retep_alts")) then
      T:ToggleLocked("retep_alts")
    end
    self:setHideScript()
  else
    if (forceShow) then
      retep_alts:Refresh()
    else
      T:Attach("retep_alts") -- hide
    end
  end
end

function retep_alts:OnClickItem(name)
  --ChatFrame_SendTell(name)
end

function retep_alts:BuildAltsTable()
  return retep.alts
end

function retep_alts:OnTooltipUpdate()
  local cat = T:AddCategory(
      "columns", 2,
      "text",  C:Orange(L["Main"]),   "child_textR",    1, "child_textG",    1, "child_textB",    1, "child_justify",  "LEFT",
      "text2", C:Orange(L["Alts"]),  "child_text2R",   0, "child_text2G",   1, "child_text2B",   0, "child_justify2", "RIGHT"
    )
  local t = self:BuildAltsTable()
  for main, alts in pairs(t) do
    local altstring = ""
    for alt,class in pairs(alts) do
      local coloredalt = C:Colorize(BC:GetHexColor(class), alt)
      if altstring == "" then
        altstring = coloredalt
      else
        altstring = string.format("%s, %s",altstring,coloredalt)
      end
    end
    cat:AddLine(
      "text", main,
      "text2", altstring--,
      --"func", "OnClickItem", "arg1", self, "arg2", main
    )
  end
end

-- GLOBALS: retep_saychannel,retep_groupbyclass,retep_groupbyarmor,retep_groupbyrole,retep_raidonly,retep_decay,retep_minep,retep_reservechannel,retep_main,retep_progress,retep_discount,retep_log,retep_dbver,retep_looted
-- GLOBALS: retep,retep_prices,retep_standings,retep_bids,retep_loot,retep_reserves,retep_alts,retep_logs
