local T = AceLibrary("Tablet-2.0")
local D = AceLibrary("Dewdrop-2.0")
local C = AceLibrary("Crayon-2.0")
local CP = AceLibrary("Compost-2.0")
local L = AceLibrary("AceLocale-2.2"):new("retroll")

retep_logs = retep:NewModule("retep_logs", "AceDB-2.0")
retep_logs.tmp = CP:Acquire()

function retep_logs:OnEnable()
  if not T:IsRegistered("retep_logs") then
    T:Register("retep_logs",
      "children", function()
        T:SetTitle(L["retroll logs"])
        self:OnTooltipUpdate()
      end,
      "showTitleWhenDetached", true,
      "showHintWhenDetached", true,
      "cantAttach", true,
      "menu", function()
        D:AddLine(
          "text", L["Refresh"],
          "tooltipText", L["Refresh window"],
          "func", function() retep_logs:Refresh() end
        )
        D:AddLine(
          "text", L["Clear"],
          "tooltipText", L["Clear Logs."],
          "func", function() retep_log = {} retep_logs:Refresh() end
        )
      end      
    )
  end
  if not T:IsAttached("retep_logs") then
    T:Open("retep_logs")
  end
end

function retep_logs:OnDisable()
  T:Close("retep_logs")
end

function retep_logs:Refresh()
  T:Refresh("retep_logs")
end

function retep_logs:setHideScript()
  local i = 1
  local tablet = getglobal(string.format("Tablet20DetachedFrame%d",i))
  while (tablet) and i<100 do
    if tablet.owner ~= nil and tablet.owner == "retep_logs" then
      retep:make_escable(string.format("Tablet20DetachedFrame%d",i),"add")
      tablet:SetScript("OnHide",nil)
      tablet:SetScript("OnHide",function()
          if not T:IsAttached("retep_logs") then
            T:Attach("retep_logs")
            this:SetScript("OnHide",nil)
          end
        end)
      break
    end    
    i = i+1
    tablet = getglobal(string.format("Tablet20DetachedFrame%d",i))
  end  
end

function retep_logs:Top()
  if T:IsRegistered("retep_logs") and (T.registry.retep_logs.tooltip) then
    T.registry.retep_logs.tooltip.scroll=0
  end  
end

function retep_logs:Toggle(forceShow)
  self:Top()
  if T:IsAttached("retep_logs") then
    T:Detach("retep_logs") -- show
    if (T:IsLocked("retep_logs")) then
      T:ToggleLocked("retep_logs")
    end
    self:setHideScript()
  else
    if (forceShow) then
      retep_logs:Refresh()
    else
      T:Attach("retep_logs") -- hide
    end
  end  
end

function retep_logs:reverse(arr)
  CP:Recycle(retep_logs.tmp)
  for _,val in ipairs(arr) do
    table.insert(retep_logs.tmp,val)
  end
  local i, j = 1, table.getn(retep_logs.tmp)
  while i < j do
    retep_logs.tmp[i], retep_logs.tmp[j] = retep_logs.tmp[j], retep_logs.tmp[i]
    i = i + 1
    j = j - 1
  end
  return retep_logs.tmp
end

function retep_logs:BuildLogsTable()
  -- {timestamp,line}
  return self:reverse(retep_log)
end

function retep_logs:OnTooltipUpdate()
  local cat = T:AddCategory(
      "columns", 2,
      "text",  C:Orange(L["Time"]),   "child_textR",    1, "child_textG",    1, "child_textB",    1, "child_justify",  "LEFT",
      "text2", C:Orange(L["Action"]),     "child_text2R",   1, "child_text2G",   1, "child_text2B",   1, "child_justify2", "RIGHT"
    )
  local t = retep_logs:BuildLogsTable()
  for i = 1, table.getn(t) do
    local timestamp, line = unpack(t[i])
    cat:AddLine(
      "text", C:Silver(timestamp),
      "text2", line
    )
  end  
end

-- GLOBALS: retep_saychannel,retep_groupbyclass,retep_groupbyarmor,retep_groupbyrole,retep_raidonly,retep_decay,retep_minep,retep_reservechannel,retep_main,retep_progress,retep_discount,retep_log,retep_dbver,retep_looted
-- GLOBALS: retep,retep_prices,retep_standings,retep_bids,retep_loot,retep_reserves,retep_alts,retep_logs
