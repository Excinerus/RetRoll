local T = AceLibrary("Tablet-2.0")
local D = AceLibrary("Dewdrop-2.0")
local C = AceLibrary("Crayon-2.0")

local BC = AceLibrary("Babble-Class-2.2")
local L = AceLibrary("AceLocale-2.2"):new("retroll")

retep_reserves = retep:NewModule("retep_reserves", "AceDB-2.0")

function retep_reserves:OnEnable()
  if not T:IsRegistered("retep_reserves") then
    T:Register("retep_reserves",
      "children", function()
        T:SetTitle(L["retroll reserves"])
        self:OnTooltipUpdate()
      end,
      "showTitleWhenDetached", true,
      "showHintWhenDetached", true,
      "cantAttach", true,
      "menu", function()
        D:AddLine(
          "text", L["Refresh"],
          "tooltipText", L["Refresh window"],
          "func", function() retep_reserves:Refresh() end
        )
      end      
    )
  end
  if not T:IsAttached("retep_reserves") then
    T:Open("retep_reserves")
  end
end

function retep_reserves:OnDisable()
  T:Close("retep_reserves")
end

function retep_reserves:Refresh()
  T:Refresh("retep_reserves")
end

function retep_reserves:setHideScript()
  local i = 1
  local tablet = getglobal(string.format("Tablet20DetachedFrame%d",i))
  while (tablet) and i<100 do
    if tablet.owner ~= nil and tablet.owner == "retep_reserves" then
      retep:make_escable(string.format("Tablet20DetachedFrame%d",i),"add")
      tablet:SetScript("OnHide",nil)
      tablet:SetScript("OnHide",function()
          if not T:IsAttached("retep_reserves") then
            T:Attach("retep_reserves")
            this:SetScript("OnHide",nil)
          end
        end)
      break
    end    
    i = i+1
    tablet = getglobal(string.format("Tablet20DetachedFrame%d",i))
  end  
end

function retep_reserves:Top()
  if T:IsRegistered("retep_reserves") and (T.registry.retep_reserves.tooltip) then
    T.registry.retep_reserves.tooltip.scroll=0
  end  
end

function retep_reserves:Toggle(forceShow)
  self:Top()
  if T:IsAttached("retep_reserves") then
    T:Detach("retep_reserves") -- show
    if (T:IsLocked("retep_reserves")) then
      T:ToggleLocked("retep_reserves")
    end
    self:setHideScript()
  else
    if (forceShow) then
      retep_reserves:Refresh()
    else
      T:Attach("retep_reserves") -- hide
    end
  end  
end

function retep_reserves:OnClickItem(name)
  ChatFrame_SendTell(name)
end

function retep_reserves:BuildReservesTable()
  --{name,class,rank,alt}
  table.sort(retep.reserves, function(a,b)
    if (a[2] ~= b[2]) then return a[2] > b[2]
    else return a[1] > b[1] end
  end)
  return retep.reserves
end

function retep_reserves:OnTooltipUpdate()
  local cdcat = T:AddCategory(
      "columns", 2
    )
  cdcat:AddLine(
      "text", C:Orange(L["Countdown"]),
      "text2", retep.timer.cd_text
    )
  local cat = T:AddCategory(
      "columns", 3,
      "text",  C:Orange(L["Name"]),   "child_textR",    1, "child_textG",    1, "child_textB",    1, "child_justify",  "LEFT",
      "text2", C:Orange(L["Rank"]),     "child_text2R",   1, "child_text2G",   1, "child_text2B",   0, "child_justify2", "RIGHT",
      "text3", C:Orange(L["OnAlt"]),  "child_text3R",   0, "child_text3G",   1, "child_text3B",   0, "child_justify3", "RIGHT"
    )
  local t = self:BuildReservesTable()
  for i = 1, table.getn(t) do
    local name, class, rank, alt = unpack(t[i])
    cat:AddLine(
      "text", C:Colorize(BC:GetHexColor(class), name),
      "text2", rank,
      "text3", alt or "",
      "func", "OnClickItem", "arg1", self, "arg2", alt or name
    )
  end
end

-- GLOBALS: retep_saychannel,retep_groupbyclass,retep_groupbyarmor,retep_groupbyrole,retep_raidonly,retep_decay,retep_minep,retep_reservechannel,retep_main,retep_progress,retep_discount,retep_log,retep_dbver,retep_looted
-- GLOBALS: retep,retep_prices,retep_standings,retep_bids,retep_loot,retep_reserves,retep_alts,retep_logs
