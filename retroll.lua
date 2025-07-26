retep = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceHook-2.1", "AceDB-2.0", "AceDebug-2.0", "AceEvent-2.0", "AceModuleCore-2.0", "FuBarPlugin-2.0")
retep:SetModuleMixins("AceDebug-2.0")
local D = AceLibrary("Dewdrop-2.0")
local BZ = AceLibrary("Babble-Zone-2.2")
local C = AceLibrary("Crayon-2.0")
local BC = AceLibrary("Babble-Class-2.2")
local DF = AceLibrary("Deformat-2.0")
local G = AceLibrary("Gratuity-2.0")
local T = AceLibrary("Tablet-2.0")
local L = AceLibrary("AceLocale-2.2"):new("retroll")
retep.VARS = {
  basegp = 0,
  dpRollCap = 50,
  minep = 0,
  baseaward_ep = 10,
  decay = 0.9,
  max = 1000,
  timeout = 60,
  minlevel = 1,
  maxloglines = 500,
  prefix = "RRG_",
  inRaid = false,
  reservechan = "Reserves",
  reserveanswer = "^(%+)(%a*)$",
  bop = C:Red("BoP"),
  boe = C:Yellow("BoE"),
  nobind = C:White("NoBind"),
  msgp = "Mainspec GP",
  osgp = "Offspec GP",
  bankde = "Bank-D/E",
  reminder = C:Red("Unassigned"), 
  HostGuildName = "!",
  HostLeadName = "!" 
}

RetEPMSG = {
	delayedinit = false,
	dbg= true,
	prefix = "RR_",
	RequestHostInfoUpdate = "RequestHostInfoUpdate",
	RequestHostInfoUpdateTS = 0,
	HostInfoUpdate = "HostInfoUpdate",
	PugStandingUpdate = "PugStandingUpdate"

}
retep._playerName = (UnitName("player"))
local out = "|cff9664c8retroll:|r %s"
local raidStatus,lastRaidStatus
local lastUpdate = 0
local needInit,needRefresh = true
local admin,sanitizeNote
local shooty_debugchat
local running_check,running_bid
local partyUnit,raidUnit = {},{}
local hexColorQuality = {}

local options
do
  for i=1,40 do
    raidUnit[i] = "raid"..i
  end
  for i=1,4 do
    partyUnit[i] = "party"..i
  end
  for i=-1,6 do
    hexColorQuality[ITEM_QUALITY_COLORS[i].hex] = i
  end
end
local admincmd, membercmd = {type = "group", handler = retep, args = {

    show = {
      type = "execute",
      name = L["Standings"],
      desc = L["Show Standings Table."],
      func = function()
        retep_standings:Toggle()
      end,
      order = 2,
    },        
    restart = {
      type = "execute",
      name = L["Restart"],
      desc = L["Restart retroll if having startup problems."],
      func = function() 
        retep:OnEnable()
        retep:defaultPrint(L["Restarted"])
      end,
      order = 7,
    },
    roll = {
      type = "execute",
      name = "Roll",
      desc = "Roll with your EP Points",
      func = function() 
        retep:RollCommand(false,false,0)
      end,
      order = 8,
    },
    sr = {
      type = "execute",
      name = "Roll SR",
      desc = "Roll Soft Reservie with your EP Points",
      func = function() 
        retep:RollCommand(true,false,0)
      end,
      order = 9,
    },
    dsr = {
      type = "execute",
      name = "Roll Double SR",
      desc = "Roll Double Soft Reservie with your EP Points",
      func = function() 
        retep:RollCommand(true,true,0)
      end,
      order = 10,
    },
    ep = {
      type = "execute",
      name = "Check your pug EP",
      desc = "Checks your pug EP",
      func = function() 
        retep:CheckPugEP()
      end,
      order = 11,
    },
  }},
{type = "group", handler = retep, args = {
    show = {
      type = "execute",
      name = L["Standings"],
      desc = L["Show Standings Table."],
      func = function()
        retep_standings:Toggle()
      end,
      order = 1,
    },
    progress = {
      type = "execute",
      name = L["Progress"],
      desc = L["Print Progress Multiplier."],
      func = function()
        retep:defaultPrint(retep_progress)
      end,
      order = 2,
    },
    restart = {
      type = "execute",
      name = L["Restart"],
      desc = L["Restart retroll if having startup problems."],
      func = function() 
        retep:OnEnable()
        retep:defaultPrint(L["Restarted"])
      end,
      order = 4,
    },
    roll = {
      type = "execute",
      name = "Roll",
      desc = "Roll with your EP Points",
      func = function() 
        retep:RollCommand(false,false,0)
      end,
      order = 5,
    },
    sr = {
      type = "execute",
      name = "Roll SR",
      desc = "Roll Soft Reservie with your EP Points",
      func = function() 
        retep:RollCommand(true,false,0)
      end,
      order = 6,
    },
    dsr = {
      type = "execute",
      name = "Roll Double SR",
      desc = "Roll Double Soft Reservie with your EP Points",
      func = function() 
        retep:RollCommand(true,true,0)
      end,
      order = 7,
    },
    ep = {
      type = "execute",
      name = "Check your pug EP",
      desc = "Checks your pug EP",
      func = function() 
        retep:CheckPugEP()
      end,
      order = 8,
    },
  }}
retep.cmdtable = function() 
  if (admin()) then
    return admincmd
  else
    return membercmd
  end
end
retep.reserves = {}
retep.alts = {}

function retep:buildMenu()
  if not (options) then
    options = {
    type = "group",
    desc = L["retroll options"],
    handler = self,
    args = { }
    }
    options.args["ep"] = {
      type = "group",
      name = L["+EPs to Member"],
      desc = L["Account EPs for member."],
      order = 10,
      hidden = function() return not (admin()) end,
    }
    options.args["ep_raid"] = {
      type = "text",
      name = L["+EPs to Raid"],
      desc = L["Award EPs to all raid members."],
      order = 20,
      get = "suggestedAwardEP",
      set = function(v) retep:award_raid_ep(tonumber(v)) end,
      usage = "<EP>",
      hidden = function() return not (admin()) end,
      validate = function(v)
        local n = tonumber(v)
        return n and n >= 0 and n < retep.VARS.max
      end
    }
    options.args["gp"] = {
      type = "group",
      name = L["+GPs to Member"],
      desc = L["Account GPs for member."],
      order = 30,
      hidden = function() return not (admin()) end,
    }
	options.args["gp_raid"] = {
      type = "text",
      name = L["+GPs to Raid"],
      desc = L["Award GPs to all raid members."],
      order = 35,
      get = "suggestedAwardGP",
      set = function(v) retep:award_raid_gp(tonumber(v)) end,
      usage = "<GP>",
      hidden = function() return not (admin()) end,
      validate = function(v)
        local n = tonumber(v)
        return n and n >= 0 and n < retep.VARS.max
      end
    }
 
    options.args["updatePugs"] = {
      type = "execute",
      name = "Update Pug EP",
      desc = "Update Pug EP",
      order = 62,
      hidden = function() return not (admin()) end,
      func = function() retep:updateAllPugEP(false) end
    }
    options.args["alts"] = {
      type = "toggle",
      name = L["Enable Alts"],
      desc = L["Allow Alts to use Main\'s EPGP."],
      order = 63,
      hidden = function() return not (admin()) end,
      disabled = function() return not (IsGuildLeader()) end,
      get = function() return not not retep_altspool end,
      set = function(v) 
        retep_altspool = not retep_altspool
        if (IsGuildLeader()) then
          retep:shareSettings(true)
        end
      end,
    }
    options.args["alts_percent"] = {
      type = "range",
      name = L["Alts EP %"],
      desc = L["Set the % EP Alts can earn."],
      order = 66,
      hidden = function() return (not retep_altspool) or (not IsGuildLeader()) end,
      get = function() return retep_altpercent end,
      set = function(v) 
        retep_altpercent = v
        if (IsGuildLeader()) then
          retep:shareSettings(true)
        end
      end,
      min = 0.5,
      max = 1,
      step = 0.05,
      isPercent = true
    }
    options.args["set_main"] = {
      type = "text",
      name = L["Set Main"],
      desc = L["Set your Main Character for Reserve List."],
      order = 70,
      usage = "<MainChar>",
      get = function() return retep_main end,
      set = function(v) retep_main = (retep:verifyGuildMember(v)) end,
    }    
    options.args["raid_only"] = {
      type = "toggle",
      name = L["Raid Only"],
      desc = L["Only show members in raid."],
      order = 80,
      get = function() return not not retep_raidonly end,
      set = function(v) 
        retep_raidonly = not retep_raidonly
        retep:SetRefresh(true)
      end,
    }
    options.args["report_channel"] = {
      type = "text",
      name = L["Reporting channel"],
      desc = L["Channel used by reporting functions."],
      order = 95,
      hidden = function() return not (admin()) end,
      get = function() return retep_saychannel end,
      set = function(v) retep_saychannel = v end,
      validate = { "PARTY", "RAID", "GUILD", "OFFICER" },
    }    
    options.args["decay"] = {
      type = "execute",
      name = L["Decay EPGP"],
      desc = string.format(L["Decays all EPGP by %s%%"],(1-(retep_decay or retep.VARS.decay))*100),
      order = 100,
      hidden = function() return not (admin()) end,
      func = function() retep:decay_epgp_v3() end 
    }    
    options.args["set_decay"] = {
      type = "range",
      name = L["Set Decay %"],
      desc = L["Set Decay percentage (Admin only)."],
      order = 110,
      usage = "<Decay>",
      get = function() return (1.0-retep_decay) end,
      set = function(v) 
        retep_decay = (1 - v)
        options.args["decay"].desc = string.format(L["Decays all EPGP by %s%%"],(1-retep_decay)*100)
        if (IsGuildLeader()) then
          retep:shareSettings(true)
        end
      end,
      min = 0.01,
      max = 0.75,
      step = 0.01,
      bigStep = 0.05,
      isPercent = true,
      hidden = function() return not (admin()) end,    
    }

    options.args["set_min_ep_header"] = {
      type = "header",
      name = string.format(L["Minimum EP: %s"],retep_minep),
      order = 117,
      hidden = function() return admin() end,
    }
    options.args["set_min_ep"] = {
      type = "text",
      name = L["Minimum EP"],
      desc = L["Set Minimum EP"],
      usage = "<minep>",
      order = 118,
      get = function() return retep_minep end,
      set = function(v) 
        retep_minep = tonumber(v)
        retep:refreshPRTablets()
        if (IsGuildLeader()) then
          retep:shareSettings(true)
        end        
      end,
      validate = function(v) 
        local n = tonumber(v)
        return n and n >= 0 and n <= retep.VARS.max
      end,
      hidden = function() return not admin() end,
    }
    options.args["reset"] = {
     type = "execute",
     name = L["Reset EPGP"],
     desc = string.format(L["Resets everyone\'s EPGP to 0/%d (Admin only)."],retep.VARS.basegp),
     order = 120,
     hidden = function() return not (IsGuildLeader()) end,
     func = function() StaticPopup_Show("RET_EP_CONFIRM_RESET") end
    }
    options.args["resetGP"] = {
     type = "execute",
     name = L["Reset GP"],
     desc = string.format(L["Resets everyone\'s GP to 0/%d (Admin only)."],retep.VARS.basegp),
     order = 122,
     hidden = function() return not (IsGuildLeader()) end,
     func = function() StaticPopup_Show("RET_GP_CONFIRM_RESET") end
    }

  end
  if (needInit) or (needRefresh) then
    local members = retep:buildRosterTable()
    self:debugPrint(string.format(L["Scanning %d members for EP/GP data. (%s)"],table.getn(members),(retep_raidonly and "Raid" or "Full")))
    options.args["ep"].args = retep:buildClassMemberTable(members,"ep")
    options.args["gp"].args = retep:buildClassMemberTable(members,"gp")
    if (needInit) then needInit = false end
    if (needRefresh) then needRefresh = false end
  end
  return options
end

function retep:OnInitialize() -- ADDON_LOADED (1) unless LoD
  if retep_saychannel == nil then retep_saychannel = "GUILD" end
  if retep_decay == nil then retep_decay = retep.VARS.decay end
  if retep_minep == nil then retep_minep = retep.VARS.minep end
 -- if retep_progress == nil then retep_progress = "T1" end
 -- if retep_discount == nil then retep_discount = 0.25 end
  if retep_altspool == nil then retep_altspool = true end
  if retep_altpercent == nil then retep_altpercent = 1.0 end
  if retep_log == nil then retep_log = {} end
  if retep_looted == nil then retep_looted = {} end
  if retep_debug == nil then retep_debug = {} end
  if retep_pugCache == nil then retep_pugCache = {} end 
  --if retep_showRollWindow == nil then retep_showRollWindow = true end
  self:RegisterDB("retep_fubar")
  self:RegisterDefaults("char",{})
  --table.insert(retep_debug,{[date("%b/%d %H:%M:%S")]="OnInitialize"})
end

function retep:OnEnable() -- PLAYER_LOGIN (2)
  --table.insert(retep_debug,{[date("%b/%d %H:%M:%S")]="OnEnable"})
  retep._playerLevel = UnitLevel("player")
  --retep.extratip = (retep.extratip) or CreateFrame("GameTooltip","retroll_tooltip",UIParent,"GameTooltipTemplate")
  retep._versionString = GetAddOnMetadata("retroll","Version")
  retep._websiteString = GetAddOnMetadata("retroll","X-Website")
  
  if (IsInGuild()) then
    if (GetNumGuildMembers()==0) then
      GuildRoster()
    end
  end

 
  
  
 
  self:RegisterEvent("GUILD_ROSTER_UPDATE",function() 
      if (arg1) then -- member join /leave
        retep:SetRefresh(true)
      end
    end)
 
  self:RegisterEvent("CHAT_MSG_ADDON",function() 
        RetEPMSG:OnCHAT_MSG_ADDON( arg1, arg2, arg3, arg4)
    end)
  self:RegisterEvent("RAID_ROSTER_UPDATE",function()
      retep:SetRefresh(true)
	  retep:UpdateHostInfo()
     -- retep:testLootPrompt()
    end)
  self:RegisterEvent("PARTY_MEMBERS_CHANGED",function()
      retep:SetRefresh(true)
     -- retep:testLootPrompt()
    end)
  self:RegisterEvent("PLAYER_ENTERING_WORLD",function()
      retep:SetRefresh(true)
	  retep:UpdateHostInfo()
     -- retep:testLootPrompt()
    end)
  if retep._playerLevel and retep._playerLevel < MAX_PLAYER_LEVEL then
    self:RegisterEvent("PLAYER_LEVEL_UP", function()
        if (arg1) then
          retep._playerLevel = tonumber(arg1)
          if retep._playerLevel == MAX_PLAYER_LEVEL then
            retep:UnregisterEvent("PLAYER_LEVEL_UP")
          end
          if retep._playerLevel and retep._playerLevel >= retep.VARS.minlevel then
            retep:testMain()
          end
        end
      end)
  end
 -- self:RegisterEvent("CHAT_MSG_RAID","captureLootCall")
 -- self:RegisterEvent("CHAT_MSG_RAID_LEADER","captureLootCall")
 -- self:RegisterEvent("CHAT_MSG_RAID_WARNING","captureLootCall")
 -- self:RegisterEvent("CHAT_MSG_WHISPER","captureBid")
 -- self:RegisterEvent("CHAT_MSG_LOOT","captureLoot")
 -- self:RegisterEvent("TRADE_PLAYER_ITEM_CHANGED","tradeLoot")
 -- self:RegisterEvent("TRADE_ACCEPT_UPDATE","tradeLoot")

  if AceLibrary("AceEvent-2.0"):IsFullyInitialized() then
    self:AceEvent_FullyInitialized()
  else
    self:RegisterEvent("AceEvent_FullyInitialized")
  end
end

function retep:OnDisable()

--DEFAULT_CHAT_FRAME:AddMessage("retep:OnDisable()") 
  --table.insert(retep_debug,{[date("%b/%d %H:%M:%S")]="OnDisable"})
  self:UnregisterAllEvents()
end

function retep:AceEvent_FullyInitialized() -- SYNTHETIC EVENT, later than PLAYER_LOGIN, PLAYER_ENTERING_WORLD (3)
  --table.insert(retep_debug,{[date("%b/%d %H:%M:%S")]="AceEvent_FullyInitialized"})
  if self._hasInitFull then return end
  
  for i=1,NUM_CHAT_WINDOWS do
    local tab = getglobal("ChatFrame"..i.."Tab")
    local cf = getglobal("ChatFrame"..i)
    local tabName = tab:GetText()
    if tab ~= nil and (string.lower(tabName) == "debug") then
      shooty_debugchat = cf
      ChatFrame_RemoveAllMessageGroups(shooty_debugchat)
      shooty_debugchat:SetMaxLines(1024)
      break
    end
  end

  self:testMain()

  local delay = 2
  if self:IsEventRegistered("AceEvent_FullyInitialized") then
    self:UnregisterEvent("AceEvent_FullyInitialized")
    delay = 3
  end  
  if not self:IsEventScheduled("retrollChannelInit") then
    self:ScheduleEvent("retrollChannelInit",self.delayedInit,delay,self)
  end

  -- if pfUI loaded, skin the extra tooltip
 --if not IsAddOnLoaded("pfUI-addonskins") then
 --  if (pfUI) and pfUI.api and pfUI.api.CreateBackdrop and pfUI_config and pfUI_config.tooltip and pfUI_config.tooltip.alpha then
 --    pfUI.api.CreateBackdrop(retep.extratip,nil,nil,tonumber(pfUI_config.tooltip.alpha))
 --  end
 --end

  self._hasInitFull = true
end

retep._lastRosterRequest = false
function retep:OnMenuRequest()
  local now = GetTime()
  if not self._lastRosterRequest or (now - self._lastRosterRequest > 2) then
    self._lastRosterRequest = now
    self:SetRefresh(true)
    GuildRoster()
  end
  self._options = self:buildMenu()
  D:FeedAceOptionsTable(self._options)
end

 
function retep:delayedInit()
  --table.insert(retep_debug,{[date("%b/%d %H:%M:%S")]="delayedInit"})
  retep.VARS.GuildName  =""
  if (IsInGuild()) then
    retep.VARS.GuildName  = (GetGuildInfo("player"))
    if (retep.VARS.GuildName ) and retep.VARS.GuildName  ~= "" then
      retep_reservechannel = string.format("%sReserves",(string.gsub(retep.VARS.GuildName ," ",""))) 
    --  retep.VARS.GuildPugBroadCastCN  = retep:GetGuildPugChannelName(retep.VARS.GuildName)
     -- if (admin()) then JoinChannelByName(retep.VARS.GuildPugBroadCastCN) end
    end
  end
  if retep_reservechannel == nil then retep_reservechannel = retep.VARS.reservechan end  
  local reservesChannelID = tonumber((GetChannelName(retep_reservechannel)))
  if (reservesChannelID) and (reservesChannelID ~= 0) then
    self:reservesToggle(true)
  end
  -- migrate EPGP storage if needed
  
 
--  self:parseVersion(retep._versionString)
   
  local major_ver = 0 --self._version.major or 0
 -- if IsGuildLeader() and ( (retep_dbver == nil) or (major_ver > retep_dbver) ) then
 --   retep[string.format("v%dtov%d",(retep_dbver or 2),major_ver)](retep)
 -- end
 
  -- init options and comms
  self._options = self:buildMenu()
  self:RegisterChatCommand({"/shooty","/retep","/retroll","/ret"},self.cmdtable())
  function calculateBonus(input)
    local number = tonumber(input)
    if number and number >= 2 and number <= 15 then
        return number * 20
    end
    return 20  -- Return 20 for first week if input is invalid
  end
  
  self:RegisterChatCommand({"/retcsr"}, function(input)
    local bonus = calculateBonus(input)
    self:RollCommand(true, false, bonus)
  end)
  self:RegisterChatCommand({"/updatepugep"}, function() retep:updateAllPugEP(false) end)
  --self:RegisterEvent("CHAT_MSG_ADDON","addonComms")  
  -- broadcast our version
  local addonMsg = string.format("VERSION;%s;%d",retep._versionString,major_ver or 0)
  self:addonMessage(addonMsg,"GUILD")
  if (IsGuildLeader()) then
    self:shareSettings()
  end
  -- safe officer note setting when we are admin
  if (admin()) then
    if not self:IsHooked("GuildRosterSetOfficerNote") then
      self:Hook("GuildRosterSetOfficerNote")
    end
  end
  RetEPMSG.delayedinit = true
  self:defaultPrint(string.format(L["v%s Loaded."],retep._versionString))
end


function retep:OnUpdate(elapsed)
  retep.timer.count_down = retep.timer.count_down - elapsed
  lastUpdate = lastUpdate + elapsed

  if lastUpdate > 0.5 then
    lastUpdate = 0
    retep_reserves:Refresh()
  end
end

function retep:GuildRosterSetOfficerNote(index,note,fromAddon)
  if (fromAddon) then
    self.hooks["GuildRosterSetOfficerNote"](index,note)
  else
    local name, _, _, _, _, _, _, prevnote, _, _ = GetGuildRosterInfo(index)
    local _,_,_,oldepgp,_ = string.find(prevnote or "","(.*)({%d+:%d+})(.*)")
    local _,_,_,epgp,_ = string.find(note or "","(.*)({%d+:%d+})(.*)")
    if (retep_altspool) then
      local oldmain = self:parseAlt(name,prevnote)
      local main = self:parseAlt(name,note)
      if oldmain ~= nil then
        if main == nil or main ~= oldmain then 
		 local isbnk, pugname = retep:isBank(name)
			if isbnk then
				retep:ReportPugManualEdit(pugname , epgp )
			end
          self:adminSay(string.format(L["Manually modified %s\'s note. Previous main was %s"],name,oldmain))
          self:defaultPrint(string.format(L["|cffff0000Manually modified %s\'s note. Previous main was %s|r"],name,oldmain))
        end
      end
    end    
    if oldepgp ~= nil then
      if epgp == nil or epgp ~= oldepgp then
		 local isbnk, pugname = retep:isBank(name)
			if isbnk then
				retep:ReportPugManualEdit(pugname , epgp )
			end
        self:adminSay(string.format(L["Manually modified %s\'s note. EPGP was %s"],name,oldepgp))
        self:defaultPrint(string.format(L["|cffff0000Manually modified %s\'s note. EPGP was %s|r"],name,oldepgp))
      end
    end
    local safenote = string.gsub(note,"(.*)({%d+:%d+})(.*)",sanitizeNote)
    return self.hooks["GuildRosterSetOfficerNote"](index,safenote)    
  end
end


-------------------
-- Communication
-------------------
function retep:flashFrame(frame)
  local tabFlash = getglobal(frame:GetName().."TabFlash")
  if ( not frame.isDocked or (frame == SELECTED_DOCK_FRAME) or UIFrameIsFlashing(tabFlash) ) then
    return
  end
  tabFlash:Show()
  UIFrameFlash(tabFlash, 0.25, 0.25, 60, nil, 0.5, 0.5)
end

function retep:debugPrint(msg)
  if (shooty_debugchat) then
    shooty_debugchat:AddMessage(string.format(out,msg))
    self:flashFrame(shooty_debugchat)
  else
    self:defaultPrint(msg)
  end
end

function retep:defaultPrint(msg)
  if not DEFAULT_CHAT_FRAME:IsVisible() then
    FCF_SelectDockFrame(DEFAULT_CHAT_FRAME)
  end
  DEFAULT_CHAT_FRAME:AddMessage(string.format(out,msg))
end


function retep:simpleSay(msg)
  SendChatMessage(string.format("retroll: %s",msg), retep_saychannel)
end

function retep:adminSay(msg)
  -- API is broken on Elysium
  -- local g_listen, g_speak, officer_listen, officer_speak, g_promote, g_demote, g_invite, g_remove, set_gmotd, set_publicnote, view_officernote, edit_officernote, set_guildinfo = GuildControlGetRankFlags() 
  -- if (officer_speak) then
  SendChatMessage(string.format("retroll: %s",msg),"OFFICER")
  -- end
end

function retep:widestAudience(msg)
  local channel = "SAY"
  if UnitInRaid("player") then
    if (IsRaidLeader() or IsRaidOfficer()) then
      channel = "RAID_WARNING"
    else
      channel = "RAID"
    end
  elseif UnitExists("party1") then
    channel = "PARTY"
  end
  SendChatMessage(msg, channel)
end

function retep:addonMessage(message,channel,sender)
  SendAddonMessage(self.VARS.prefix,message,channel,sender)
end

function retep:addonComms(prefix,message,channel,sender)
  if not prefix == self.VARS.prefix then return end -- we don't care for messages from other addons
  if sender == self._playerName then return end -- we don't care for messages from ourselves
  local name_g,class,rank = self:verifyGuildMember(sender,true)
  if not (name_g) then return end -- only accept messages from guild members
  local who,what,amount
  for name,epgp,change in string.gfind(message,"([^;]+);([^;]+);([^;]+)") do
    who=name
    what=epgp
    amount=tonumber(change)
  end
  if (who) and (what) and (amount) then
    local msg
    local for_main = (retep_main and (who == retep_main))
    if (who == self._playerName) or (for_main) then
      if what == "EP" then
        if amount < 0 then
          msg = string.format(L["You have received a %d EP penalty."],amount)
        else
          msg = string.format(L["You have been awarded %d EP."],amount)
        end
      elseif what == "GP" then
        msg = string.format(L["You have gained %d GP."],amount)
      end
    elseif who == "ALL" and what == "DECAY" then
      msg = string.format(L["%s%% decay to EP and GP."],amount)
    elseif who == "RAID" and what == "AWARD" then
      msg = string.format(L["%d EP awarded to Raid."],amount)
    elseif who == "RESERVES" and what == "AWARD" then
      msg = string.format(L["%d EP awarded to Reserves."],amount)
    elseif who == "VERSION" then
      local out_of_date, version_type = self:parseVersion(self._versionString,what)
      if (out_of_date) and self._newVersionNotification == nil then
        self._newVersionNotification = true -- only inform once per session
        self:defaultPrint(string.format(L["New %s version available: |cff00ff00%s|r"],version_type,what))
        self:defaultPrint(string.format(L["Visit %s to update."],self._websiteString))
      end
      if (IsGuildLeader()) then
        self:shareSettings()
      end
    elseif who == "SETTINGS" then
      for progress,discount,decay,minep,alts,altspct in string.gfind(what, "([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+)") do
        discount = tonumber(discount)
        decay = tonumber(decay)
        minep = tonumber(minep)
        alts = (alts == "true") and true or false
        altspct = tonumber(altspct)
        local settings_notice
        --if progress and progress ~= retep_progress then
        --  retep_progress = progress
        --  settings_notice = L["New raid progress"]
        --end
        --if discount and discount ~= retep_discount then
        --  retep_discount = discount
        --  if (settings_notice) then
        --    settings_notice = settings_notice..L[", offspec price %"]
        --  else
        --    settings_notice = L["New offspec price %"]
        --  end
        --end
        if minep and minep ~= retep_minep then
          retep_minep = minep
          settings_notice = L["New Minimum EP"]
          retep:refreshPRTablets()
        end
        if decay and decay ~= retep_decay then
          retep_decay = decay
          if (admin()) then
            if (settings_notice) then
              settings_notice = settings_notice..L[", decay %"]
            else
              settings_notice = L["New decay %"]
            end
          end
        end
        if alts ~= nil and alts ~= retep_altspool then
          retep_altspool = alts
          if (admin()) then
            if (settings_notice) then
              settings_notice = settings_notice..L[", alts"]
            else
              settings_notice = L["New Alts"]
            end
          end          
        end
        if altspct and altspct ~= retep_altpercent then
          retep_altpercent = altspct
          if (admin()) then
            if (settings_notice) then
              settings_notice = settings_notice..L[", alts ep %"]
            else
              settings_notice = L["New Alts EP %"]
            end
          end          
        end
        if (settings_notice) and settings_notice ~= "" then
          local sender_rank = string.format("%s(%s)",C:Colorize(BC:GetHexColor(class),sender),rank)
          settings_notice = settings_notice..string.format(L[" settings accepted from %s"],sender_rank)
          self:defaultPrint(settings_notice)
         -- self._options.args["progress_tier_header"].name = string.format(L["Progress Setting: %s"],retep_progress)
         -- self._options.args["set_discount_header"].name = string.format(L["Offspec Price: %s%%"],retep_discount*100)
          self._options.args["set_min_ep_header"].name = string.format(L["Minimum EP: %s"],retep_minep)
        end
      end
    end
    if msg and msg~="" then
      self:defaultPrint(msg)
      self:my_epgp(for_main)
    end
  end
end

function retep:shareSettings(force)
  local now = GetTime()
  if self._lastSettingsShare == nil or (now - self._lastSettingsShare > 30) or (force) then
    self._lastSettingsShare = now
    local addonMsg = string.format("SETTINGS;%s:%s:%s:%s:%s:%s;1",0,0,retep_decay,retep_minep,tostring(retep_altspool),retep_altpercent)
    self:addonMessage(addonMsg,"GUILD")
  end
end

function retep:refreshPRTablets()
  --if not T:IsAttached("retep_standings") then
  retep_standings:Refresh()
  --end
 
end

---------------------
-- EPGP Operations
---------------------


function retep:init_notes_v3(guild_index,name,officernote)
  local ep,gp = self:get_ep_v3(name,officernote), self:get_gp_v3(name,officernote)
  if not (ep and gp) then
    local initstring = string.format("{%d:%d}",0,retep.VARS.basegp)
    local newnote = string.format("%s%s",officernote,initstring)
    newnote = string.gsub(newnote,"(.*)({%d+:%d+})(.*)",sanitizeNote)
    officernote = newnote
  else
    officernote = string.gsub(officernote,"(.*)({%d+:%d+})(.*)",sanitizeNote)
  end
  GuildRosterSetOfficerNote(guild_index,officernote,true)
  return officernote
end

function retep:update_epgp_v3(ep,gp,guild_index,name,officernote,special_action)
  officernote = self:init_notes_v3(guild_index,name,officernote)
  local newnote
  if (ep) then
    ep = math.max(0,ep)
    newnote = string.gsub(officernote,"(.*{)(%d+)(:)(%d+)(}.*)",function(head,oldep,divider,oldgp,tail)
      return string.format("%s%s%s%s%s",head,ep,divider,oldgp,tail)
      end)
  end
  if (gp) then
    gp =  math.max(retep.VARS.basegp,gp)
    if (newnote) then
      newnote = string.gsub(newnote,"(.*{)(%d+)(:)(%d+)(}.*)",function(head,oldep,divider,oldgp,tail)
        return string.format("%s%s%s%s%s",head,oldep,divider,gp,tail)
        end)
    else
      newnote = string.gsub(officernote,"(.*{)(%d+)(:)(%d+)(}.*)",function(head,oldep,divider,oldgp,tail)
        return string.format("%s%s%s%s%s",head,oldep,divider,gp,tail)
        end)
    end
  end
  if (newnote) then
    GuildRosterSetOfficerNote(guild_index,newnote,true)
  end
end



function retep:update_ep_v3(getname,ep)
  for i = 1, GetNumGuildMembers(1) do
    local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
    if (name==getname) then 
      self:update_epgp_v3(ep,nil,i,name,officernote)
    end
  end  
end


function retep:update_gp_v3(getname,gp)
  for i = 1, GetNumGuildMembers(1) do
    local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
    if (name==getname) then 
      self:update_epgp_v3(nil,gp,i,name,officernote) 
    end
  end  
end


function retep:get_ep_v3(getname,officernote) -- gets ep by name or note
  if (officernote) then
    local _,_,ep = string.find(officernote,".*{(%d+):%-?%d+}.*")
    return tonumber(ep)
  end
  for i = 1, GetNumGuildMembers(1) do
    local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
    local _,_,ep = string.find(officernote,".*{(%d+):%-?%d+}.*")
    if (name==getname) then return tonumber(ep) end
  end
  return
end

function retep:get_gp_v3(getname,officernote) -- gets gp by name or officernote
  if (officernote) then
    local _,_,gp = string.find(officernote,".*{%d+:(%-?%d+)}.*")
    return tonumber(gp)
  end
  for i = 1, GetNumGuildMembers(1) do
    local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
    local _,_,gp = string.find(officernote,".*{%d+:(%-?%d+)}.*")
    if (name==getname) then return tonumber(gp) end
  end
  return
end

function retep:award_raid_ep(ep) -- awards ep to raid members in zone
  if GetNumRaidMembers()>0 then
	local award = {}
    for i = 1, GetNumRaidMembers(true) do
      local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
      if level >= retep.VARS.minlevel then
		local _,mName =  self:givename_ep(name,ep,award)
		 table.insert (award, mName)
      end
    end
    self:simpleSay(string.format(L["Giving %d ep to all raidmembers"],ep))
    self:addToLog(string.format(L["Giving %d ep to all raidmembers"],ep))    
    local addonMsg = string.format("RAID;AWARD;%s",ep)
    self:addonMessage(addonMsg,"RAID")
    self:refreshPRTablets() 
  else UIErrorsFrame:AddMessage(L["You aren't in a raid dummy"],1,0,0)end
end
function retep:award_raid_gp(gp) -- awards gp to raid members in zone
  if GetNumRaidMembers()>0 then
	local award = {}
    for i = 1, GetNumRaidMembers(true) do
      local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
      if level >= retep.VARS.minlevel then
		local _,mName =  self:givename_gp(name,gp,award)
		 table.insert (award, mName)
      end
    end
    self:simpleSay(string.format(L["Giving %d gp to all raidmembers"],gp))
    self:addToLog(string.format(L["Giving %d gp to all raidmembers"],gp))    
    local addonMsg = string.format("RAID;AWARD;%s",gp)
    self:addonMessage(addonMsg,"RAID")
    self:refreshPRTablets() 
  else UIErrorsFrame:AddMessage(L["You aren't in a raid dummy"],1,0,0)end
end

function retep:award_reserve_ep(ep) -- awards ep to reserve list
  if table.getn(retep.reserves) > 0 then
	local award = {}
    for i, reserve in ipairs(retep.reserves) do
      local name, class, rank, alt = unpack(reserve)
		local _,mName =  self:givename_ep(name,ep,award)
		 table.insert (award, mName)
    end
    self:simpleSay(string.format(L["Giving %d EP to active reserves"],ep))
    self:addToLog(string.format(L["Giving %d EP to active reserves"],ep))
    local addonMsg = string.format("RESERVES;AWARD;%s",ep)
    self:addonMessage(addonMsg,"GUILD")
    retep.reserves = {}
    reserves_blacklist = {}
    self:refreshPRTablets()
  end
end
function retep:givename_ep(getname,ep) 
	
 return retep:givename_ep(getname,ep,nil)  
end
function retep:givename_ep(getname,ep,block) -- awards ep to a single character
  if not (admin()) then return end
  local isPug, playerNameInGuild = self:isPug(getname)
  local postfix, alt = ""
  if isPug then
    -- Update EP for the level 1 character in the guild
    alt = getname
    getname = playerNameInGuild
    ep = self:num_round(retep_altpercent*ep)
    postfix = string.format(", %s\'s Pug EP Bank.",alt)
  elseif (retep_altspool) then
    local main = self:parseAlt(getname)
    if (main) then
      alt = getname
      getname = main
      ep = self:num_round(retep_altpercent*ep)
      postfix = string.format(L[", %s\'s Main."],alt)
    end
  end
  if retep:TFind(block, getname) then
		self:debugPrint(string.format("Skipping %s, already awarded.",getname)) 
		return isPug, getname 
  end
  local old =  (self:get_ep_v3(getname) or 0) 
  local newep = ep +old
  self:update_ep_v3(getname,newep) 
  self:debugPrint(string.format(L["Giving %d ep to %s%s. (Previous: %d, New: %d)"],ep,getname,postfix,old, newep))
  if ep < 0 then -- inform admins and victim of penalties
    local msg = string.format(L["%s EP Penalty to %s%s. (Previous: %d, New: %d)"],ep,getname,postfix,old, newep)
    self:adminSay(msg)
    self:addToLog(msg)
    local addonMsg = string.format("%s;%s;%s",getname,"EP",ep)
    self:addonMessage(addonMsg,"GUILD")
  end  
  return isPug, getname
end


function retep:givename_gp(getname,gp) 
 return retep:givename_gp(getname,gp,nil) 
end


function retep:TFind ( t, e) 
if not t then return nil end
    for i, item in ipairs(t) do 
		if item == e then 
			return i 
		end
    end
return nil
end

function retep:givename_gp(getname,gp,block) -- awards gp to a single character
  if not (admin()) then return end
  local isPug, playerNameInGuild = self:isPug(getname)
  local postfix, alt = ""
  if isPug then
    -- Update gp for the level 1 character in the guild
    alt = getname
    getname = playerNameInGuild
    gp = self:num_round(retep_altpercent*gp)
    postfix = string.format(", %s\'s Pug EP Bank.",alt)
  elseif (retep_altspool) then
    local main = self:parseAlt(getname)
    if (main) then
      alt = getname
      getname = main
      gp = self:num_round(retep_altpercent*gp)
      postfix = string.format(L[", %s\'s Main."],alt)
    end
  end 
	if retep:TFind (block, getname) then
		self:debugPrint(string.format("Skipping %s%s, already awarded.",getname,postfix)) 
		return isPug, getname
	end
 
  local old = (self:get_gp_v3(getname) or 0) 
  local newgp = gp + old
  self:update_gp_v3(getname,newgp) 
  self:debugPrint(string.format(L["Giving %d gp to %s%s. (Previous: %d, New: %d)"],gp,getname,postfix,old, newgp))
  if gp < 0 then -- inform admins and victim of penalties
    local msg = string.format(L["%s GP Penalty to %s%s. (Previous: %d, New: %d)"],gp,getname,postfix,old, newgp)
    self:adminSay(msg)
    self:addToLog(msg)
    local addonMsg = string.format("%s;%s;%s",getname,"GP",gp)
    self:addonMessage(addonMsg,"GUILD")
  end  
  return isPug, getname
end


function retep:decay_epgp_v3()
  if not (admin()) then return end
  for i = 1, GetNumGuildMembers(1) do
    local name,_,_,_,class,_,note,officernote,_,_ = GetGuildRosterInfo(i)
    local ep,gp = self:get_ep_v3(name,officernote), self:get_gp_v3(name,officernote)
    if (ep and gp) then
      ep = self:num_round(ep*retep_decay)
      gp = self:num_round(gp*retep_decay)
      self:update_epgp_v3(ep,gp,i,name,officernote)
    end
  end
  local msg = string.format(L["All EP and GP decayed by %s%%"],(1-retep_decay)*100)
  self:simpleSay(msg)
  if not (retep_saychannel=="OFFICER") then self:adminSay(msg) end
  local addonMsg = string.format("ALL;DECAY;%s",(1-(retep_decay or retep.VARS.decay))*100)
  self:addonMessage(addonMsg,"GUILD")
  self:addToLog(msg)
  self:refreshPRTablets() 
end


function retep:gp_reset_v3()
  if (IsGuildLeader()) then
    for i = 1, GetNumGuildMembers(1) do
      local name,_,_,_,class,_,note,officernote,_,_ = GetGuildRosterInfo(i)
      local ep,gp = self:get_ep_v3(name,officernote), self:get_gp_v3(name,officernote)
      if (ep and gp) then
        self:update_epgp_v3(0,retep.VARS.basegp,i,name,officernote)
      end
    end
    local msg = L["All EP and GP has been reset to 0/%d."]
    self:debugPrint(string.format(msg,retep.VARS.basegp))
    self:adminSay(string.format(msg,retep.VARS.basegp))
    self:addToLog(string.format(msg,retep.VARS.basegp))
  end
end

function retep:ClearGP_v3()
  if (IsGuildLeader()) then
    for i = 1, GetNumGuildMembers(1) do
      local name,_,_,_,class,_,note,officernote,_,_ = GetGuildRosterInfo(i)
      local ep,gp = self:get_ep_v3(name,officernote), self:get_gp_v3(name,officernote)
      if (ep and gp) then
        self:update_epgp_v3(ep,retep.VARS.basegp,i,name,officernote)
      end
    end
    local msg = L["All GP has been reset to %d."]
    self:debugPrint(string.format(msg,retep.VARS.basegp))
    self:adminSay(string.format(msg,retep.VARS.basegp))
    self:addToLog(string.format(msg,retep.VARS.basegp))
  end
end



function retep:my_epgp_announce(use_main)
  local ep,gp
  if (use_main) then
    ep,gp = (self:get_ep_v3(retep_main) or 0), (self:get_gp_v3(retep_main) or retep.VARS.basegp)
  else
    ep,gp = (self:get_ep_v3(self._playerName) or 0), (self:get_gp_v3(self._playerName) or retep.VARS.basegp)
  end
 local pr = ep + math.min( retep.VARS.dpRollCap , gp)
  local msg = string.format(L["You now have: %d EP %d GP + (%d)"], ep,gp,pr)
  self:defaultPrint(msg)
end

function retep:my_epgp(use_main)
  GuildRoster()
  self:ScheduleEvent("retrollRosterRefresh",self.my_epgp_announce,3,self,use_main)
end

---------
-- Menu
---------
retep.hasIcon = "Interface\\Icons\\INV_Misc_ArmorKit_19"
retep.title = "retroll"
retep.defaultMinimapPosition = 180
retep.defaultPosition = "RIGHT"
retep.cannotDetachTooltip = true
retep.tooltipHiddenWhenEmpty = false
retep.independentProfile = true

function retep:OnTooltipUpdate()
  local hint = L["|cffffff00Click|r to toggle Standings.%s \n|cffffff00Right-Click|r for Options."]
  if (admin()) then
    hint = string.format(hint,L[" \n|cffffff00Ctrl+Click|r to toggle Reserves. \n|cffffff00Alt+Click|r to toggle Bids. \n|cffffff00Shift+Click|r to toggle Loot. \n|cffffff00Ctrl+Alt+Click|r to toggle Alts. \n|cffffff00Ctrl+Shift+Click|r to toggle Logs."])
  else
    hint = string.format(hint,"")
  end
  T:SetHint(hint)
end

function retep:OnClick()
  local is_admin = admin()
  if (IsControlKeyDown() and IsShiftKeyDown() and is_admin) then
    retep_logs:Toggle()
  elseif (IsControlKeyDown() and IsAltKeyDown() and is_admin) then
    retep_alts:Toggle()
  elseif (IsControlKeyDown() and is_admin) then
    retep_reserves:Toggle()
  elseif (IsShiftKeyDown() and is_admin) then
   -- retep_loot:Toggle()      
  elseif (IsAltKeyDown() and is_admin) then
  --  retep_bids:Toggle()
  else
    retep_standings:Toggle()
  end
end

function retep:SetRefresh(flag)
  needRefresh = flag
  if (flag) then
    self:refreshPRTablets()
  end
end

function retep:buildRosterTable()
  local g, r = { }, { }
  local numGuildMembers = GetNumGuildMembers(1)
  if (retep_raidonly) and GetNumRaidMembers() > 0 then
    for i = 1, GetNumRaidMembers(true) do
      local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i) 
      if (name) then
        r[name] = true
      end
    end
  end
  retep.alts = {}
  for i = 1, numGuildMembers do
    local member_name,_,_,level,class,_,note,officernote,_,_ = GetGuildRosterInfo(i)
    if member_name and member_name ~= "" then
      local main, main_class, main_rank = self:parseAlt(member_name,officernote)
      local is_raid_level = tonumber(level) and level >= retep.VARS.minlevel
      if (main) then
        if ((self._playerName) and (name == self._playerName)) then
          if (not retep_main) or (retep_main and retep_main ~= main) then
            retep_main = main
            self:defaultPrint(L["Your main has been set to %s"],retep_main)
          end
        end
        main = C:Colorize(BC:GetHexColor(main_class), main)
        retep.alts[main] = retep.alts[main] or {}
        retep.alts[main][member_name] = class
      end
      if (retep_raidonly) and next(r) then
        if r[member_name] and is_raid_level then
          table.insert(g,{["name"]=member_name,["class"]=class})
        end
      else
        if is_raid_level then
          table.insert(g,{["name"]=member_name,["class"]=class})
        end
      end
    end
  end
  return g
end

function retep:buildClassMemberTable(roster,epgp)
  local desc,usage
  if epgp == "ep" then
    desc = L["Account EPs to %s."]
    usage = "<EP>"
  elseif epgp == "gp" then
    desc = L["Account GPs to %s."]
    usage = "<GP>"
  end
  local c = { }
  for i,member in ipairs(roster) do
    local class,name = member.class, member.name
    if (class) and (c[class] == nil) then
      c[class] = { }
      c[class].type = "group"
      c[class].name = C:Colorize(BC:GetHexColor(class),class)
      c[class].desc = class .. " members"
      c[class].hidden = function() return not (admin()) end
      c[class].args = { }
    end
    if (name) and (c[class].args[name] == nil) then
      c[class].args[name] = { }
      c[class].args[name].type = "text"
      c[class].args[name].name = name
      c[class].args[name].desc = string.format(desc,name)
      c[class].args[name].usage = usage
      if epgp == "ep" then
        c[class].args[name].get = "suggestedAwardEP"
        c[class].args[name].set = function(v) retep:givename_ep(name, tonumber(v)) retep:refreshPRTablets() end
      elseif epgp == "gp" then
        c[class].args[name].get = false
        c[class].args[name].set = function(v) retep:givename_gp(name, tonumber(v)) retep:refreshPRTablets() end
      end
      c[class].args[name].validate = function(v) return (type(v) == "number" or tonumber(v)) and tonumber(v) < retep.VARS.max end
    end
  end
  return c
end

---------------
-- Alts
---------------
function retep:parseAlt(name,officernote)
  if (officernote) then
    local _,_,_,main,_ = string.find(officernote or "","(.*){([%a][%a]%a*)}(.*)")
    if type(main)=="string" and (string.len(main) < 13) then
      main = self:camelCase(main)
      local g_name, g_class, g_rank, g_officernote = self:verifyGuildMember(main)
      if (g_name) then
        return g_name, g_class, g_rank, g_officernote
      else
        return nil
      end
    else
      return nil
    end
  else
    for i=1,GetNumGuildMembers(1) do
      local g_name, _, _, _, g_class, _, g_note, g_officernote, _, _ = GetGuildRosterInfo(i)
      if (name == g_name) then
        return self:parseAlt(g_name, g_officernote)
      end
    end
  end
  return nil
end


---------------
-- Reserves
---------------
function retep:reservesToggle(flag)
  local reservesChannelID = tonumber((GetChannelName(retep_reservechannel)))
  if (flag) then -- we want in
    if (reservesChannelID) and reservesChannelID ~= 0 then
      retep.reservesChannelID = reservesChannelID
      if not self:IsEventRegistered("CHAT_MSG_CHANNEL") then
        self:RegisterEvent("CHAT_MSG_CHANNEL","captureReserveChatter")
      end
      return true
    else
      self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE","reservesChannelChange")
      JoinChannelByName(retep_reservechannel)
      return
    end
  else -- we want out
    if (reservesChannelID) and reservesChannelID ~= 0 then
      self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE","reservesChannelChange")
      LeaveChannelByName(retep_reservechannel)
      return
    else
      if self:IsEventRegistered("CHAT_MSG_CHANNEL") then
        self:UnregisterEvent("CHAT_MSG_CHANNEL")
      end      
      return false
    end
  end
end

function retep:reservesChannelChange(msg,_,_,_,_,_,_,_,channel)
  if (msg) and (channel) and (channel == retep_reservechannel) then
    if msg == "YOU_JOINED" then
      retep.reservesChannelID = tonumber((GetChannelName(retep_reservechannel)))
      RemoveChatWindowChannel(DEFAULT_CHAT_FRAME:GetID(), retep_reservechannel)
      self:RegisterEvent("CHAT_MSG_CHANNEL","captureReserveChatter")
    elseif msg == "YOU_LEFT" then
      retep.reservesChannelID = nil 
      if self:IsEventRegistered("CHAT_MSG_CHANNEL") then
        self:UnregisterEvent("CHAT_MSG_CHANNEL")
      end
    end
    self:UnregisterEvent("CHAT_MSG_CHANNEL_NOTICE")
    D:Close()
  end
end

function retep:afkcheck_reserves()
  if (running_check) then return end
  if retep.reservesChannelID ~= nil and ((GetChannelName(retep.reservesChannelID)) == retep.reservesChannelID) then
    reserves_blacklist = {}
    retep.reserves = {}
    running_check = true
    retep.timer.count_down = retep.VARS.timeout
    retep.timer:Show()
    SendChatMessage(retep.VARS.reservecall,"CHANNEL",nil,retep.reservesChannelID)
    retep_reserves:Toggle(true)
  end
end

function retep:sendReserverResponce()
  if retep.reservesChannelID ~= nil then
    if (retep_main) then
      if retep_main == self._playerName then
        SendChatMessage("+","CHANNEL",nil,retep.reservesChannelID)
      else
        SendChatMessage(string.format("+%s",retep_main),"CHANNEL",nil,retep.reservesChannelID)
      end
    end
  end
end

function retep:captureReserveChatter(text, sender, _, _, _, _, _, _, channel)
  if not (channel) or not (channel == retep_reservechannel) then return end
  local reserve, reserve_class, reserve_rank, reserve_alt = nil,nil,nil,nil
  local r,_,rdy,name = string.find(text,retep.VARS.reserveanswer)
  if (r) and (running_check) then
    if (rdy) then
      if (name) and (name ~= "") then
        if (not self:inRaid(name)) then
          reserve, reserve_class, reserve_rank = self:verifyGuildMember(name)
          if reserve ~= sender then
            reserve_alt = sender
          end
        end
      else
        if (not self:inRaid(sender)) then
          reserve, reserve_class, reserve_rank = self:verifyGuildMember(sender)    
        end
      end
      if reserve and reserve_class and reserve_rank then
        if reserve_alt then
          if not reserves_blacklist[reserve_alt] then
            reserves_blacklist[reserve_alt] = true
            table.insert(retep.reserves,{reserve,reserve_class,reserve_rank,reserve_alt})
          else
            self:defaultPrint(string.format(L["|cffff0000%s|r trying to add %s to Reserves, but has already added a member. Discarding!"],reserve_alt,reserve))
          end
        else
          if not reserves_blacklist[reserve] then
            reserves_blacklist[reserve] = true
            table.insert(retep.reserves,{reserve,reserve_class,reserve_rank})
          else
            self:defaultPrint(string.format(L["|cffff0000%s|r has already been added to Reserves. Discarding!"],reserve))
          end
        end
      end
    end
    return
  end
  local q = string.find(text,L["^{retroll}Type"])
  if (q) and not (running_check) then
    if --[[(not UnitInRaid("player")) or]] (not self:inRaid(sender)) then
      StaticPopup_Show("RET_EP_RESERVE_AFKCHECK_RESPONCE")
    end
  end
end

------------
-- Logging
------------
function retep:addToLog(line,skipTime)
  local over = table.getn(retep_log)-retep.VARS.maxloglines+1
  if over > 0 then
    for i=1,over do
      table.remove(retep_log,1)
    end
  end
  local timestamp
  if (skipTime) then
    timestamp = ""
  else
    timestamp = date("%b/%d %H:%M:%S")
  end
  table.insert(retep_log,{timestamp,line})
end

------------
-- Utility 
------------
function retep:num_round(i)
  return math.floor(i+0.5)
end

function retep:strsplit(delimiter, subject)
  local delimiter, fields = delimiter or ":", {}
  local pattern = string.format("([^%s]+)", delimiter)
  string.gsub(subject, pattern, function(c) fields[table.getn(fields)+1] = c end)
  return unpack(fields)
end

function retep:strsplitT(delimiter, subject)
 local tbl = {retep:strsplit(delimiter, subject)}
 return tbl
end

 function retep:verifyGuildMember(name,silent)
	retep:verifyGuildMember(name,silent,false)
 end
function retep:verifyGuildMember(name,silent,ignorelevel)
  for i=1,GetNumGuildMembers(1) do
    local g_name, g_rank, g_rankIndex, g_level, g_class, g_zone, g_note, g_officernote, g_online = GetGuildRosterInfo(i)
    if (string.lower(name) == string.lower(g_name)) and (ignorelevel or tonumber(g_level) >= retep.VARS.minlevel) then 
    -- == MAX_PLAYER_LEVEL]]
      return g_name, g_class, g_rank, g_officernote
    end
  end
  if (name) and name ~= "" and not (silent) then
    self:defaultPrint(string.format(L["%s not found in the guild or not max level!"],name))
  end
  return
end

function retep:inRaid(name)
  for i=1,GetNumRaidMembers() do
    if name == (UnitName(raidUnit[i])) then
      return true
    end
  end
  return false
end

function retep:lootMaster()
  local method, lootmasterID = GetLootMethod()
  if method == "master" and lootmasterID == 0 then
    return true
  else
    return false
  end
end

function retep:testMain()
  if (retep_main == nil) or (retep_main == "") then
    if (IsInGuild()) then
      StaticPopup_Show("RET_EP_SET_MAIN")
    end
  end
end

function retep:make_escable(framename,operation)
  local found
  for i,f in ipairs(UISpecialFrames) do
    if f==framename then
      found = i
    end
  end
  if not found and operation=="add" then
    table.insert(UISpecialFrames,framename)
  elseif found and operation=="remove" then
    table.remove(UISpecialFrames,found)
  end
end

local raidZones = {[L["Molten Core"]]="T1",[L["Onyxia\'s Lair"]]="T1.5",[L["Blackwing Lair"]]="T2",[L["Ahn\'Qiraj"]]="T2.5",[L["Naxxramas"]]="T3"}
local zone_multipliers = {
  ["T3"] =   {["T3"]=1,["T2.5"]=0.75,["T2"]=0.5,["T1.5"]=0.25,["T1"]=0.25},
  ["T2.5"] = {["T3"]=1,["T2.5"]=1,   ["T2"]=0.7,["T1.5"]=0.4, ["T1"]=0.4},
  ["T2"] =   {["T3"]=1,["T2.5"]=1,   ["T2"]=1,  ["T1.5"]=0.5, ["T1"]=0.5},
  ["T1"] =   {["T3"]=1,["T2.5"]=1,   ["T2"]=1,  ["T1.5"]=1,   ["T1"]=1}
}
function retep:suggestedAwardEP()

return retep.VARS.baseaward_ep
-- local currentTier, zoneEN, zoneLoc, checkTier, multiplier
-- local inInstance, instanceType = IsInInstance()
-- if (inInstance == nil) or (instanceType ~= nil and instanceType == "none") then
--   currentTier = "T1.5"   
-- end
-- if (inInstance) and (instanceType == "raid") then
--   zoneLoc = GetRealZoneText()
--   if (BZ:HasReverseTranslation(zoneLoc)) then
--     zoneEN = BZ:GetReverseTranslation(zoneLoc)
--     checkTier = raidZones[zoneEN]
--     if (checkTier) then
--       currentTier = checkTier
--     end
--   end
-- end
-- if not currentTier then 
--   return retep.VARS.baseaward_ep
-- else
--   multiplier = zone_multipliers[retep_progress][currentTier]
-- end
-- if (multiplier) then
--   return multiplier*retep.VARS.baseaward_ep
-- else
--   return retep.VARS.baseaward_ep
-- end
end
function retep:suggestedAwardGP()

return retep.VARS.baseaward_ep
-- local currentTier, zoneEN, zoneLoc, checkTier, multiplier
-- local inInstance, instanceType = IsInInstance()
-- if (inInstance == nil) or (instanceType ~= nil and instanceType == "none") then
--   currentTier = "T1.5"   
-- end
-- if (inInstance) and (instanceType == "raid") then
--   zoneLoc = GetRealZoneText()
--   if (BZ:HasReverseTranslation(zoneLoc)) then
--     zoneEN = BZ:GetReverseTranslation(zoneLoc)
--     checkTier = raidZones[zoneEN]
--     if (checkTier) then
--       currentTier = checkTier
--     end
--   end
-- end
-- if not currentTier then 
--   return retep.VARS.baseaward_ep
-- else
--   multiplier = zone_multipliers[retep_progress][currentTier]
-- end
-- if (multiplier) then
--   return multiplier*retep.VARS.baseaward_ep
-- else
--   return retep.VARS.baseaward_ep
-- end
end
function retep:parseVersion(version,otherVersion)
	if   version then  
  if not retep._version then
      retep._version = {  
		major = 0,
		minor = 0,
		patch = 0
	}
  
  end
  for major,minor,patch in string.gfind(version,"(%d+)[^%d]?(%d*)[^%d]?(%d*)") do
    retep._version.major = tonumber(major)
    retep._version.minor = tonumber(minor)
    retep._version.patch = tonumber(patch)
  end
  end
  if (otherVersion) then
    if not retep._otherversion then retep._otherversion = {} end
    for major,minor,patch in string.gfind(otherVersion,"(%d+)[^%d]?(%d*)[^%d]?(%d*)") do
      retep._otherversion.major = tonumber(major)
      retep._otherversion.minor = tonumber(minor)
      retep._otherversion.patch = tonumber(patch)      
    end
    if (retep._otherversion.major ~= nil and retep._version ~= nil and retep._version.major ~= nil) then
      if (retep._otherversion.major < retep._version.major) then -- we are newer
        return
      elseif (retep._otherversion.major > retep._version.major) then -- they are newer
        return true, "major"        
      else -- tied on major, go minor
        if (retep._otherversion.minor ~= nil and retep._version.minor ~= nil) then
          if (retep._otherversion.minor < retep._version.minor) then -- we are newer
            return
          elseif (retep._otherversion.minor > retep._version.minor) then -- they are newer
            return true, "minor"
          else -- tied on minor, go patch
            if (retep._otherversion.patch ~= nil and retep._version.patch ~= nil) then
              if (retep._otherversion.patch < retep._version.patch) then -- we are newer
                return
              elseif (retep._otherversion.patch > retep._version.patch) then -- they are newwer
                return true, "patch"
              end
            elseif (retep._otherversion.patch ~= nil and retep._version.patch == nil) then -- they are newer
              return true, "patch"
            end
          end    
        elseif (retep._otherversion.minor ~= nil and retep._version.minor == nil) then -- they are newer
          return true, "minor"
        end
      end
    end
  end
 
end

function retep:camelCase(word)
  return string.gsub(word,"(%a)([%w_']*)",function(head,tail) 
    return string.format("%s%s",string.upper(head),string.lower(tail)) 
    end)
end

admin = function()
  return (CanEditOfficerNote() --[[and CanEditPublicNote()]])
end

sanitizeNote = function(prefix,epgp,postfix)
  -- reserve 12 chars for the epgp pattern {xxxxx:yyyy} max public/officernote = 31
  local remainder = string.format("%s%s",prefix,postfix)
  local clip = math.min(31-12,string.len(remainder))
  local prepend = string.sub(remainder,1,clip)
  return string.format("%s%s",prepend,epgp)
end

-------------
-- Dialogs
-------------

StaticPopupDialogs["RET_EP_SET_MAIN"] = {
  text = L["Set your main to be able to participate in Reserve List EPGP Checks."],
  button1 = TEXT(ACCEPT),
  button2 = TEXT(CANCEL),
  hasEditBox = 1,
  maxLetters = 12,
  OnAccept = function()
    local editBox = getglobal(this:GetParent():GetName().."EditBox")
    local name = retep:camelCase(editBox:GetText())
    retep_main = retep:verifyGuildMember(name)
  end,
  OnShow = function()
    getglobal(this:GetName().."EditBox"):SetText(retep_main or "")
    getglobal(this:GetName().."EditBox"):SetFocus()
  end,
  OnHide = function()
    if ( ChatFrameEditBox:IsVisible() ) then
      ChatFrameEditBox:SetFocus()
    end
    getglobal(this:GetName().."EditBox"):SetText("")
  end,
  EditBoxOnEnterPressed = function()
    local editBox = getglobal(this:GetParent():GetName().."EditBox")
    retep_main = retep:verifyGuildMember(editBox:GetText())
    this:GetParent():Hide()
  end,
  EditBoxOnEscapePressed = function()
    this:GetParent():Hide()
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1  
}
StaticPopupDialogs["RET_EP_RESERVE_AFKCHECK_RESPONCE"] = {
  text = " ",
  button1 = TEXT(YES),
  button2 = TEXT(NO),
  OnShow = function()
    this._timeout = retep.VARS.timeout-1
  end,
  OnUpdate = function(elapsed,dialog)
    this._timeout = this._timeout - elapsed
    getglobal(dialog:GetName().."Text"):SetText(string.format(L["Reserves AFKCheck. Are you available? |cff00ff00%0d|rsec."],this._timeout))
    if (this._timeout<=0) then
      this._timeout = 0
      dialog:Hide()
    end
  end,
  OnAccept = function()
    this._timeout = 0
    retep:sendReserverResponce()
  end,
  timeout = 0,--retep.VARS.timeout,
  exclusive = 1,
  showAlert = 1,
  whileDead = 1,
  hideOnEscape = 1  
}
StaticPopupDialogs["RET_EP_CONFIRM_RESET"] = {
  text = L["|cffff0000Are you sure you want to Reset ALL EPGP?|r"],
  button1 = TEXT(OKAY),
  button2 = TEXT(CANCEL),
  OnAccept = function()
    retep:gp_reset_v3()
  end,
  timeout = 0,
  whileDead = 1,
  exclusive = 1,
  showAlert = 1,
  hideOnEscape = 1
}
StaticPopupDialogs["RET_GP_CONFIRM_RESET"] = {
  text = L["|cffff0000Are you sure you want to Reset ALL GP?|r"],
  button1 = TEXT(OKAY),
  button2 = TEXT(CANCEL),
  OnAccept = function()
    retep:ClearGP_v3()
  end,
  timeout = 0,
  whileDead = 1,
  exclusive = 1,
  showAlert = 1,
  hideOnEscape = 1
}


function retep:EasyMenu_Initialize(level, menuList)
  for i, info in ipairs(menuList) do
    if (info.text) then
      info.index = i
      UIDropDownMenu_AddButton( info, level )
    end
  end
end
function retep:EasyMenu(menuList, menuFrame, anchor, x, y, displayMode, level)
  if ( displayMode == "MENU" ) then
    menuFrame.displayMode = displayMode
  end
  UIDropDownMenu_Initialize(menuFrame, function() retep:EasyMenu_Initialize(level, menuList) end, displayMode, level)
  ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y)
end

function retep:RollCommand(isSRRoll,isDSRRoll,bonus)
  local playerName = UnitName("player")
  local ep = 0 
  local gp = 0
  local desc = ""  
  local hostG= retep:GetGuildName()
	if (IsPugInHostedRaid()) then
		hostG = retep.VARS.HostGuildName
		local key = retep:GetGuildKey(retep.VARS.HostGuildName)
		if retep_pugCache[key] and retep_pugCache[key][playerName] then
		-- Player is a Pug, use stored EP
			ep = retep_pugCache[key][playerName][1] 
			
			
			gp = retep_pugCache[key][playerName][2]
			local inguildn = retep_pugCache[key][playerName][3] or ""
			desc = string.format("PUG(%s)",inguildn)
		else
			ep = 0
			gp = 0
			desc = "Unregistered PUG"
		end
	  -- Check if the player is an alt
	elseif retep_altspool then
		local main = self:parseAlt(playerName)
		if main then
		  -- If the player is an alt, use the main's EP
		  ep = self:get_ep_v3(main) or 0
		  gp = self:get_gp_v3(main) or 0
		  desc = "Alt of "..main
		else
		  -- If not an alt, use the player's own EP
		  ep = self:get_ep_v3(playerName) or 0
		  gp = self:get_gp_v3(playerName) or 0
		  desc = "Main"
		end
	else
		-- If alt pooling is not enabled, just use the player's EP
		ep = self:get_ep_v3(playerName) or 0
		gp = self:get_gp_v3(playerName) or 0
		desc = "Main"
	end
  
  -- Calculate the roll range based on whether it's an SR roll or not
  local cappedGP =    math.min(retep.VARS.dpRollCap,gp)
  local minRoll, maxRoll
  if isSRRoll then
    minRoll = 101 + ep + cappedGP
    maxRoll = 200 + ep  + cappedGP
    if isDSRRoll then
      minRoll = 101 + ep + 20  + cappedGP
      maxRoll = 200 + ep + 20 + cappedGP
    end
  else
    minRoll = 1 + ep + cappedGP
    maxRoll = 100 + ep + cappedGP
  end
  minRoll = minRoll + bonus
  maxRoll = maxRoll + bonus

  RandomRoll(minRoll, maxRoll)
  
  -- Prepare the announcement message
  local bonusText = " as "..desc.." of "..hostG
  local message = string.format("I rolled %d - %d with %d EP +%d GP (%d)%s", minRoll, maxRoll, ep ,cappedGP, gp,  bonusText)

  if(isSRRoll) then
    message = string.format("I rolled SR %d - %d with %d EP +%d GP (%d)%s", minRoll, maxRoll, ep ,cappedGP, gp, bonusText)
  end
  if(isDSRRoll) then
    message = string.format("I rolled Double SR %d - %d with %d EP +%d GP (%d)%s", minRoll, maxRoll, ep ,cappedGP, gp, bonusText)
  end

  if bonus > 0 then
    local weeks = math.floor(bonus / 20)
    bonusText = string.format(" +%d for %d weeks", bonus, weeks)..bonusText
    message = string.format("I rolled Cumulative SR %d - %d with %d EP +%d(%dGP)%s", minRoll, maxRoll, ep ,cappedGP, gp, bonusText)
  end
  -- Determine the chat channel
  local chatType = UnitInRaid("player") and "RAID" or "SAY"
  
  -- Send the message
  SendChatMessage(message, chatType)
end
function retep:isPug(name)
  for i = 1, GetNumGuildMembers(1) do
    local guildMemberName, _, _, _, _, _, _, officerNote = GetGuildRosterInfo(i)
 
    if officerNote and officerNote ~= '' then
      local _,_,pugName = string.find(officerNote, "{pug:([^}]+)}")
        if pugName == name then
          return true, guildMemberName 
        end
    end
  end
  return false
end
function retep:isBank(name)
  for i = 1, GetNumGuildMembers(1) do
    local guildMemberName, _, _, _, _, _, _, officerNote = GetGuildRosterInfo(i)
	
	if guildMemberName == name then
		if officerNote and officerNote ~= '' then
		  local _,_,pugName = string.find(officerNote, "{pug:([^}]+)}")
			if pugName then
			  return true,   pugName
			end
		end
	end
 
  end
  return false
end

function retep:CheckPugEP()
  local playerName = UnitName("player")
  local foundEP = false
  
  for guildName, guildData in pairs(retep_pugCache) do
    if guildData[playerName] then
      self:defaultPrint(string.format("Your EP for %s: %d , %d", guildName, guildData[playerName][1],guildData[playerName][2]))
      foundEP = true
    end
  end
  
  if not foundEP then
    self:defaultPrint("No EP found for " .. playerName .. " in any guild")
  end
end
function retep:getAllPugs()
  local pugs = {}
  for i = 1, GetNumGuildMembers(1) do
    local guildMemberName, _, _, guildMemberLevel, _, _, _, officerNote = GetGuildRosterInfo(i)
    if officerNote and officerNote ~= '' then
      local _, _, pugName = string.find(officerNote, "{pug:([^}]+)}")
      if pugName then
        pugs[guildMemberName] = pugName
      end
    end
  end
  return pugs
end
function retep:updateAllPugEP( force )
  if not admin() and not force then
    self:defaultPrint("You don't have permission to perform this action.")
    return
  end
  local pugs = self:getAllPugs()
  local count = 0

  local packet={}
  local pi = 0
  for guildMemberName, pugName in pairs(pugs) do
	if retep:inRaid(pugName) then
		local ep = self:get_ep_v3(guildMemberName) or 0
		local gp = self:get_gp_v3(guildMemberName) or 0
		table.insert(packet,pugName..":"..guildMemberName..":"..ep..":"..gp)
		pi = pi + 1
		
		if pi >= 4 then
			self:sendPugEpUpdatePacket(packet)
			packet={}
			pi = 0
		end
		--self:sendPugEpUpdate(pugName, ep)
		count = count + 1
	end
  end
	if pi >0 then
		self:sendPugEpUpdatePacket(packet)
		packet={}
		pi = 0
	end
  self:defaultPrint(string.format("Updated EP for %d Pug player(s)", count))
end


function retep:getPugName(name)
  for i = 1, GetNumGuildMembers(1) do
      local guildMemberName, _, _, _, _, _, _, officerNote = GetGuildRosterInfo(i)
      if guildMemberName == name then
          local _, _, pugName = string.find(officerNote or "", "{pug:([^}]+)}")
          return pugName
      end
  end
  return nil
end 

 

function retep:UpdateHostInfo()
 
	
	local ownGuild =(GetGuildInfo("player"))
	local playerName = UnitName("player")
	local isInGuild = (guildName) and guildName ~= ""
	if (GetNumRaidMembers() > 0 ) then -- we entered a raid or raid updated

        if not inRaid then 
            inRaid = true
        end
		local _ ,raidlead = retep:GetRaidLeader()
		if (retep.VARS.HostLeadName ~= raidlead ) then --raid leadership changed or new raid
			
			if retep.VARS.HostLeadName ~= "!" then
			--leadership changed
			
				if raidlead == playerName then
					RetEPMSG:DBGMSG("Leadership assigned to you, Sending host info")
					retep.VARS.HostGuildName =  ownGuild 
					retep.VARS.HostLeadName = playerName
					retep:SendHostInfoUpdate(nil)
				else
					RetEPMSG:DBGMSG("Leadership changed, requesting host info")
					retep.VARS.HostGuildName = "!"
					retep.VARS.HostLeadName ="!"
					retep:RequestHostInfo()
				end

			else
			
				if raidlead == UnitName("player") then
					RetEPMSG:DBGMSG("Raid Created, Sending host info")
					retep.VARS.HostGuildName =  ownGuild 
					retep.VARS.HostLeadName = playerName
					retep:SendHostInfoUpdate(nil)

				else
					RetEPMSG:DBGMSG("Joined Raid, requesting host info")
					retep:RequestHostInfo()
				end
				
				
			end
		end
  
	else -- we left raid
    if inRaid then
		RetEPMSG:DBGMSG("Leaving Raid")
        inRaid = false
    end
		retep.VARS.HostGuildName = "!"
		retep.VARS.HostLeadName ="!"
	end 

 
end

function retep:GetGuildName()
	local guildName, _, _ = GetGuildInfo("player")
	return guildName
end


function IsPugInHostedRaid()
	local GuildName = retep:GetGuildName()
	
	--DEFAULT_CHAT_FRAME:AddMessage("GuildName "..GuildName.." retep.VARS.HostGuildName " .. retep.VARS.HostGuildName  )
	
	return GuildName =="" or retep.VARS.HostGuildName ~="!" and retep.VARS.HostGuildName ~= GuildName
end
 
function retep:GetRaidLeader()
for i = 1, GetNumRaidMembers() do
	local name, rank, _, _, _, _, _, online  = GetRaidRosterInfo(i);
	if (rank == 2) then return i,name,online end
end
	return ""
end

function retep:GetRaidLeadGuild() 
	local guildName = nil
    local index,name,online = retep:GetRaidLeader()
	
	if UnitExists("raid"..index) then
		 
	  local guildName, _, _ = GetGuildInfo("raid"..index)
		 
	  if guildName then
			if (guildName == "") then return "!" end
		 return guildName
	  else
		 return "!!"
	  end
	else
	  return "!!"
	end

end
 
function retep:GetGuildKey(g) 
	return (string.gsub(g ," ",""))
end
 

local lastHostInfoDispatch = 0
local HostInfoRequestsSinceLastDispatch = 0

function retep:SendHostInfoUpdate( member , epgp)

	local GuildName = retep:GetGuildName()
	if GuildName == nil or GuildName == "" then DEFAULT_CHAT_FRAME:AddMessage("SendHostInfoUpdate : not in guild") return end
	 
	-- is raid a guild raid
	local GuildRules = true
	-- is the sender a pug
	
	local prio = "BULK"
	local message = string.format("%s:%s",GuildName,tostring(GuildRules))
	if (member) then
		local isPug,inGuildName =  retep:isPug(member)
	
		if isPug then
			local ep,gp
			if epgp then
 
				_,_, ep,gp = string.find(epgp, "{(%d+):(%d+)}")
 
				DEFAULT_CHAT_FRAME:AddMessage(string.format("epgp %s  %d %d", epgp,  ep,gp)) 
			else
				ep = self:get_ep_v3(inGuildName)  
				gp = self:get_gp_v3(inGuildName)  
			end
			prio = "ALERT"
			message = message ..":"..string.format("%s:%s:%d:%d",member,inGuildName,ep,gp)
		else
			if retep:verifyGuildMember(member,true,true) then
			
			else
				message = message ..":"..string.format("%s:%s:%d:%d",member,"!!",0,0)
			end
		end
	end
	retep:SendMessage(RetEPMSG.HostInfoUpdate,message,prio) 
end


function retep:Status()
DEFAULT_CHAT_FRAME:AddMessage("Host LeadName " .. retep.VARS.HostLeadName )
DEFAULT_CHAT_FRAME:AddMessage("Host GuildName " .. retep.VARS.HostGuildName ) 
end

function retep:ParseHostInfo(  sender , text )

	RetEPMSG:DBGMSG("Parsing HostInfo:"..text)
	local GuildName = retep:GetGuildName()
	local fields = retep:strsplitT(':', text)
	retep.VARS.HostLeadName = sender or "!"
	local HostGuildName = fields[1]
	if HostGuildName then
		local oldHost = retep.VARS.HostGuildName 
		retep.VARS.HostGuildName =  fields[1] 
		
		if oldHost~=retep.VARS.HostGuildName then
			self:defaultPrint(string.format("This Raid is hosted by %s.", HostGuildName))
		end
		if HostGuildName == GuildName then
			-- enable guildrules
		else
		--is message targetting us
			local TargetMember = fields[3]
				if TargetMember == UnitName("player") then
					-- pug
					local PugReg = fields[4]
					
					if PugReg and PugReg ~= "!!"  then
						-- registered

						local ep = tonumber(fields[5]) or 0
						local gp = tonumber(fields[6]) or 0
						-- update ep/gp cache
						local key = retep:GetGuildKey(retep.VARS.HostGuildName)
						if not retep_pugCache[key] then
							retep_pugCache[key] = {}
						end
						retep_pugCache[key][fields[3]] = {ep,gp,PugReg}
						self:defaultPrint(string.format("Updated EP/GP for %s as %s in guild %s: %d : %d",  TargetMember, PugReg, HostGuildName, ep,gp))
					else
						-- announce unregistered
						self:defaultPrint(string.format("You don't have standing bank character in %s, contact one of their officers for that", HostGuildName))
					end
				end
		end
	else
		return
	end
	-- update guild ep cache
end
function retep:RequestHostInfo() 
	if GetTime()-RetEPMSG.RequestHostInfoUpdateTS > 5 then
		RetEPMSG.RequestHostInfoUpdateTS = GetTime()
		retep:SendMessage(RetEPMSG.RequestHostInfoUpdate,"RequestHostInfoUpdate","ALERT")
	end
end 


function retep:sendPugEpUpdatePacket(packet)
	
	

	local updateline = string.format("%s{", retep:GetGuildName())
	for i, ep in ipairs(packet) do
		updateline = updateline .. ep
		if (i<table.getn(packet)) then 
			updateline = updateline .. ","
		end
		
		
	end
	
		updateline = updateline .. "}"
	RetEPMSG:DBGMSG("Sending a packet")
	retep:SendMessage(RetEPMSG.PugStandingUpdate,updateline,"BULK")
end

function retep:parsePugEpUpdatePacket(message)

	
 local playerName = UnitName("player") 
 local _, _, guildName , packet = string.find(message,"([^{]+){([^}]+)}")
  local segs = retep:strsplitT(',', packet)
  
  for i, seg in pairs(segs) do
  
	local _, _, name,inGuildName, ep, gp = string.find(seg, "(%S+):(%S+):(%d+):(%d+)")

	if playerName == name then
	 if playerName and inGuildName and ep and gp then
		
      if guildName then
		local key = retep:GetGuildKey(guildName)
        if retep_pugCache == nil then 
            retep_pugCache = {}
        end
        if  retep_pugCache[key] == nil then
          retep_pugCache[key] = {}
        end
        retep_pugCache[key][playerName] = {ep,gp}

        self:defaultPrint(string.format("Updated EP/GP for %s in guild %s as %s: %d : %d", playerName, guildName,inGuildName, ep,gp))
        end
      else
        self:defaultPrint("Could not parse guild name from broadcast "  )
      end

	end
 
  end
end


function retep:ReportIfPugs()
	local GuildName = retep:GetGuildName()
	if (GuildName and  GuildName == retep.VARS.HostGuildName and retep:inRaid(pug)) then
		retep:SendHostInfoUpdate( pug)
	end
end

function retep:ReportPugManualEdit(pug , epgp)
	local GuildName = retep:GetGuildName()
	if (pug and epgp and GuildName and  GuildName == retep.VARS.HostGuildName and retep:inRaid(pug)) then
		retep:SendHostInfoUpdate( pug, epgp)
	end
end

function retep:SendMessage(subject, msg , prio)
	prio = prio or "BULK"
	RetEPMSG:DBGMSG("--SendingAddonMSG["..subject.."]:"..msg , true) 
    if GetNumRaidMembers() == 0 then
       -- SendAddonMessage(RetEPMSG.prefix..subject, msg, "PARTY", UnitName("player"));
		ChatThrottleLib:SendAddonMessage(prio, RetEPMSG.prefix..subject, msg, "PARTY")
    else
		ChatThrottleLib:SendAddonMessage(prio, RetEPMSG.prefix..subject, msg, "RAID")
    end
end
function RetEPMSG:DBGMSG(msg)
		RetEPMSG:DBGMSG(msg, false)
end
function RetEPMSG:DBGMSG(msg, red)
	if RetEPMSG.dbg then 
		if red then
			DEFAULT_CHAT_FRAME:AddMessage( msg ,0.5,0.5,0.8 )   
		else
			DEFAULT_CHAT_FRAME:AddMessage( msg ,0.9,0.5,0.5 ) 
		end
	end
end


function RetEPMSG:OnCHAT_MSG_ADDON( prefix, text, channel, sender)
		
	
	if ( RetEPMSG.delayedinit) then  retep:addonComms(prefix,text,channel,sender) end
	 
		if (channel == "RAID" or channel == "PARTY") then
		
		if (  string.find( prefix, RetEPMSG.prefix) ) then  
			
			
				if ( sender == UnitName("player")) then 
					--RetEPMSG:DBGMSG("sent a message" )   
					return 
				end
				--RetEPMSG:DBGMSG("Recieved a message" )  
				
				local _ ,raidlead = retep:GetRaidLeader()
				if (UnitName("player")==raidlead) then
				--	RetEPMSG:DBGMSG("as reaidleader" )  
					if ( string.find( prefix, RetEPMSG.RequestHostInfoUpdate) and  retep:inRaid(sender)) then
						RetEPMSG:DBGMSG("Recieved a RequestHostInfoUpdate from " .. sender ) 
						 retep:SendHostInfoUpdate(sender)
					end
				else
					--RetEPMSG:DBGMSG("as member" )  
					
					if (sender == raidlead) then
					RetEPMSG:DBGMSG("from raid leader: " .. sender )  
						if ( string.find( prefix, RetEPMSG.HostInfoUpdate)) then
							RetEPMSG:DBGMSG("Recieved a HostInfoUpdate from " .. sender ) 
							retep:ParseHostInfo( sender, text ) 
						end
						if ( string.find( prefix,RetEPMSG.PugStandingUpdate)) then
							RetEPMSG:DBGMSG("Recieved a PugStandingUpdate from " .. sender ) 
							retep:parsePugEpUpdatePacket( text )
						end
					end
				end 
				
			end
		end
end









-- GLOBALS: retep_saychannel,retep_groupbyclass,retep_groupbyarmor,retep_groupbyrole,retep_raidonly,retep_decay,retep_minep,retep_reservechannel,retep_main,retep_progress,retep_discount,retep_altspool,retep_altpercent,retep_log,retep_dbver,retep_looted,retep_debug,retep_fubar,retep_showRollWindow
-- GLOBALS: retep,retep_prices,retep_standings,retep_bids,retep_loot,retep_reserves,retep_alts,retep_logs,retep_pugCache