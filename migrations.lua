local L = AceLibrary("AceLocale-2.2"):new("retroll")
function retep:v2tov3()
  local count = 0
  for i = 1, GetNumGuildMembers(1) do
    local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
    local epv2 = retep:get_ep_v2(name,note)
    local gpv2 = retep:get_gp_v2(name,officernote)
    local epv3 = retep:get_ep_v3(name,officernote)
    local gpv3 = retep:get_gp_v3(name,officernote)
    if (epv3 and gpv3) then
      -- do nothing, we've migrated already
    elseif (epv2 and gpv2) and (epv2 > 0 and gpv2 >= retep.VARS.basegp) then
      count = count + 1
      -- self:defaultPrint(string.format("epv2:%s,gpv2:%s,i:%s,n:%s,o:%s",epv2,gpv2,i,name,officernote))
      retep:update_epgp_v3(epv2,gpv2,i,name,officernote)
    end
  end
  self:defaultPrint(string.format(L["Updated %d members to v3 storage."],count))
  retep_dbver = 3
end

-- GLOBALS: retep_saychannel,retep_groupbyclass,retep_groupbyarmor,retep_groupbyrole,retep_raidonly,retep_decay,retep_minep,retep_reservechannel,retep_main,retep_progress,retep_discount,retep_log,retep_dbver,retep_looted
-- GLOBALS: retep,retep_prices,retep_standings,retep_bids,retep_loot,retep_reserves,retep_alts,retep_logs
