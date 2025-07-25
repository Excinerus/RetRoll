local L = AceLibrary("AceLocale-2.2"):new("retroll")

L:RegisterTranslations("enUS", function() return {
  --["Term"] = true, -- Example
  -- common
  ["Refresh"] = true,
  ["Refresh window"] = true,
  ["Clear"] = true,
  ["Name"] = true,
  ["Raid Only"] = true,
  ["Only show members in raid."] = true,
  ["Restarted"] = true,
  ["Progress"] = true,
  ["Print Progress Multiplier."] = true,
  ["Offspec"] = true,
  ["Print Offspec Price."] = true,
  ["Progress Setting: %s"] = true,
  ["Offspec Price: %s%%"] = true,
  ["Minimum EP: %s"] = true,
  ["Minimum EP"] = true,
  ["Set Minimum EP"] = true,
  -- bids
  ["retroll bids"] = true,
  ["Winning Mainspec Bid: %s (%.03f PR)"] = true,
  ["Winning Offspec Bid: %s (%.03f PR)"] = true,
  -- logs
  ["retroll logs"] = true,
  ["Clear Logs."] = true,
  ["Time"] = true,
  ["Action"] = true,
  -- loot
  ["retroll loot info"] = true,
  ["Clear Loot."] = true,
  ["Item"] = true,
  ["Binds"] = true,
  ["Looter"] = true,
  ["GP Action"] = true,
  -- migrations
  ["Updated %d members to v3 storage."] = true,
  -- reserves
  ["retroll reserves"] = true,
  ["Countdown"] = true,
  ["Rank"] = true,
  ["OnAlt"] = true,
  -- standings
  ["Ctrl-C to copy. Esc to close."] = true,
  ["Ctrl-V to paste data. Esc to close."] = true,
  ["Imported %d members."] = true,
  ["Imported %d members.\n"] = true,
  ["%s\nFailed to import:"] = true,
  ["retroll standings"] = true,
  ["Group by class"] = true,
  ["Group members by class."] = true,
  ["Export"] = true,
  ["Export standings to csv."] = true,
  ["Import"] = true,
  ["Import standings from csv."] = true,
  ["ep"] = true,
  ["gp"] = true,
  ["pr"] = true,
  ["Standing"] = true,
  ["Primary"] = true,
  ["Auxiliary"] = true,
  ["Roll"] = true,
  IMPORT_WARNING = [[Warning: 
Import overwrites all existing EPGP values.

Paste all the csv data here replacing this text, 
then hit Import.
Results will print here when done.]],
  ["Group by armor"] = true,
  ["Group members by armor."] = true,
  ["Group by roles"] = true,
  ["Group members by roles."] = true,
  ["CLOTH"] = true,
  ["LEATHER"] = true,
  ["MAIL"] = true,
  ["PLATE"] = true,
  ["TANK"] = true,
  ["HEALER"] = true,
  ["CASTER"] = true,
  ["PHYS DPS"] = true,
  -- retroll
  ["{retroll}Type \"+\" if on main, or \"+<YourMainName>\" (without quotes) if on alt within %dsec."] = true,
  ["|cffFF3333|Hshootybid:1:$ML|h[Mainspec/NEED]|h|r"] = true,
  ["|cff009900|Hshootybid:2:$ML|h[Offspec/GREED]|h|r"] = true,
  ["Bids"] = true,
  ["Show Bids Table."] = true,
  ["ClearLoot"] = true,  
  ["Clear Loot Table."] = true,
  ["ClearLogs"] = true,  
  ["Clear Logs Table."] = true,
  ["Standings"] = true,  
  ["Show Standings Table."] = true,
  ["Restart"] = true,  
  ["Restart retroll if having startup problems."] = true,
  ["Standings"] = true,  
  ["Show Standings Table."] = true,
  ["v%s Loaded."] = true,  
  ["Alt Click/RClick/MClick"] = true,
  ["Call for: MS/OS/Both"] = true,  
  ["gp:|cff32cd32%d|r gp_os:|cff20b2aa%d|r"] = true,
  ["pr:|cffff0000%.02f|r(%.02f) pr_os:|cffff0000%.02f|r(%.02f)"] = true,  
  ["|cffff0000Finished|r"] = true,
  ["|cff00ff00%02d|r|cffffffffsec|r"] = true,  
  ["Manually modified %s\'s note. EPGP was %s"] = true,
  ["|cffff0000Manually modified %s\'s note. EPGP was %s|r"] = true,
  ["Whisper %s a + for %s (mainspec)"] = true,
  ["Whisper %s a - for %s (offspec)"] = true,
  ["Whisper %s a + or - for %s (mainspec or offspec)"] = true,
  ["Click $MS or $OS for %s"] = true,
  ["or $OS "] = true,
  ["$MS or "] = true,
  ["You have received a %d EP penalty."] = true,
  ["You have been awarded %d EP."] = true,
  ["You have gained %d GP."] = true,
  ["%s%% decay to EP and GP."] = true,
  ["%d EP awarded to Raid."] = true,
  ["%d EP awarded to Reserves."] = true,
  ["New %s version available: |cff00ff00%s|r"] = true,
  ["Visit %s to update."] = true,
  ["New raid progress"] = true,
  [", offspec price %"] = true,
  ["New offspec price %"] = true,
  [", decay %"] = true,
  ["New decay %"] = true,
  [" settings accepted from %s"] = true,
  ["Giving %d ep to all raidmembers"] = true,
  ["Giving %d gp to all raidmembers"] = true,
  ["You aren't in a raid dummy"] = true,
  ["Giving %d ep to active reserves"] = true,
  ["Giving %d ep to %s%s. (Previous: %d, New: %d)"] = true,
  ["Giving %d gp to active reserves"] = true,
  ["Giving %d gp to %s%s. (Previous: %d, New: %d)"] = true,
  ["%s EP Penalty to %s%s. (Previous: %d, New: %d)"] = true,
  ["%s GP Penalty to %s%s. (Previous: %d, New: %d)"] = true,  
  ["%s\'s officernote is broken:%q"] = true,
  ["All EP and GP decayed by %d%%"] = true,
  ["All EP and GP decayed by %s%%"] = true,
  ["All GP has been reset to %d."] = true,
  ["All EP and GP has been reset to 0/%d."] = true,
  ["You now have: %d EP %d GP + (%d)"] = true,
  ["Close to EPGP Cap. Next Decay will change your |cffff7f00PR|r by |cffff0000%.4g|r."] = true,
  ["|cffffff00Click|r to toggle Standings.%s \n|cffffff00Right-Click|r for Options."] = true,
  [" \n|cffffff00Ctrl+Click|r to toggle Reserves. \n|cffffff00Alt+Click|r to toggle Bids. \n|cffffff00Shift+Click|r to toggle Loot. \n|cffffff00Ctrl+Alt+Click|r to toggle Alts. \n|cffffff00Ctrl+Shift+Click|r to toggle Logs."] = true,
  ["Account EPs to %s."] = true,
  ["Account GPs to %s."] = true,
  ["retroll options"] = true,
  ["+EPs to Member"] = true,
  ["Account EPs for member."] = true,
  ["+EPs to Raid"] = true,
  ["+GPs to Raid"] = true,
  ["Award EPs to all raid members."] = true,
  ["Award GPs to all raid members."] = true,
  ["+GPs to Member"] = true,
  ["Account GPs for member."] = true,
  ["+EPs to Reserves"] = true,
  ["Award EPs to all active Reserves."] = true,
  ["Enable Reserves"] = true,
  ["Participate in Standby Raiders List.\n|cffff0000Requires Main Character Name.|r"] = true,
  ["AFK Check Reserves"] = true,
  ["AFK Check Reserves List"] = true,
  ["Set Main"] = true,
  ["Set your Main Character for Reserve List."] = true,
  ["Raid Progress"] = true,
  ["Highest Tier the Guild is raiding.\nUsed to adjust GP Prices.\nUsed for suggested EP awards."] = true,
  ["4.Naxxramas"] = true,
  ["3.Temple of Ahn\'Qiraj"] = true,
  ["2.Blackwing Lair"] = true,
  ["1.Molten Core"] = true,
  ["Reporting channel"] = true,
  ["Channel used by reporting functions."] = true,
  ["Decay EPGP"] = true,
  ["Decays all EPGP by %s%%"] = true,
  ["Set Decay %"] = true,
  ["Set Decay percentage (Admin only)."] = true,
  ["Offspec Price %"] = true,
  ["Set Offspec Items GP Percent."] = true,
  ["Reset EPGP"] = true,
  ["Reset GP"] = true,
  ["Resets everyone\'s EPGP to 0/%d (Admin only)."] = true,
  ["Resets everyone\'s GP to 0/%d (Admin only)."] = true,
  ["Scanning %d members for EP/GP data. (%s)"] = true,
  ["|cffff0000%s|r trying to add %s to Reserves, but has already added a member. Discarding!"] = true,
  ["|cffff0000%s|r has already been added to Reserves. Discarding!"] = true,
  ["^{retroll}Type"] = true,
  ["Clearing old Bids"] = true,
  ["%s not found in the guild or not max level!"] = true,
  ["Molten Core"] = true,
  ["Onyxia\'s Lair"] = true,
  ["Blackwing Lair"] = true,
  ["Ahn\'Qiraj"] = true,
  ["Naxxramas"] = true,
  ["There are %d loot drops stored. It is recommended to clear loot info before a new raid. Do you want to clear it now?"] = true,
  ["Show me"] = true,
  ["Logs cleared"] = true,
  ["Loot info cleared"] = true,
  ["Loot info can be cleared at any time from the Tablet context menu or '/shooty clearloot' command"] = true,
  ["Set your main to be able to participate in Reserve List EPGP Checks."] = true,  
  ["Reserves AFKCheck. Are you available? |cff00ff00%0d|rsec."] = true,
  ["|cffff0000Are you sure you want to Reset ALL EPGP?|r"] = true,
  ["|cffff0000Are you sure you want to Reset ALL GP?|r"] = true,
  ["Add MainSpec GP"] = true,
  ["Add OffSpec GP"] = true,
  ["Bank or D/E"] = true,
  ["%s looted %s. What do you want to do?"] = true,
  ["GP Actions"] = true,
  ["Remind me Later"] = true,
  ["Need MasterLooter to perform Bid Calls!"] = true,
  ["retroll alts"] = true,
  ["Enable Alts"] = true,
  ["Main"] = true,
  ["Alt"] = true,
  ["Allow Alts to use Main\'s EPGP."] = true,
  ["Alts EP %"] = true,
  ["Set the % EP Alts can earn."] = true,
  [", alts"] = true,
  ["New Alts"] = true,
  [", alts ep %"] = true,
  ["New Alts EP %"] = true,
  ["Manually modified %s\'s note. Previous main was %s"] = true,
  ["|cffff0000Manually modified %s\'s note. Previous main was %s|r"] = true,
  [", %s\'s Main."] = true,
  ["Your main has been set to %s"] = true,
  ["Alts"] = true,
  ["New Minimum EP"] = true,
} end)

L:RegisterTranslations("zhCN", function() return {
  --["Term"] = "术语", -- Example
  -- common
  ["Refresh"] = "刷新",
  ["Refresh window"] = "刷新窗口",
  ["Clear"] = "清除",
  ["Name"] = "名字",
  ["Raid Only"] = "只显示团队",
  ["Only show members in raid."] = "只显示在团队里的成员.",  
  -- bids
  ["retroll bids"] = "retroll 竞拍",
  ["Winning Mainspec Bid: %s (%.03f PR)"] = "副天赋竞标获胜: %s (%.03f PR)",
  ["Winning Offspec Bid: %s (%.03f PR)"] = "副天赋竞标获胜: %s (%.03f PR)",
  -- logs
  ["retroll logs"] = "retroll 日志",
  ["Clear Logs."] = "清除日志.",
  ["Time"] = "时间",
  ["Action"] = "行为",
  -- loot
  ["retroll loot info"] = "retroll 拾取信息",
  ["Clear Loot."] = "清除拾取.",
  ["Item"] = "物品",
  ["Binds"] = "竞拍",
  ["Looter"] = "拾取人",
  ["GP Action"] = "GP 行为",  
  -- migrations
  ["Updated %d members to v3 storage."] = "更新 %d 成员到v3存储区.",
  -- reserves
  ["retroll reserves"] = "retroll 替补成员",
  ["Countdown"] = "倒计时",
  ["Rank"] = "Rank",
  ["OnAlt"] = "OnAlt",
     -- standings
  ["Ctrl-C to copy. Esc to close."] = "Ctrl-C 复制. Esc 退出.",
  ["Ctrl-V to paste data. Esc to close."] = "Ctrl-V 粘贴数据. Esc 退出.",
  ["Imported %d members."] = "导入 %d 成员.",
  ["Imported %d members.\n"] = "导入 %d 成员.\n",  
  ["%s\nFailed to import:"] = "%s\n未能导入:",
  ["retroll standings"] = "retroll 名单列表",
  ["Group by class"] = "职业分组",
  ["Group members by class."] = "按职业分组.",
  ["Export"] = "导出",
  ["Export standings to csv."] = "导出排名到CSV文本.",
  ["Import"] = "导入",
  ["Import standings from csv."] = "从CSV文本里导入数据.",
  ["ep"] = "ep(贡献点)",
  ["gp"] = "gp(装备点)",
  ["pr"] = "pr(优先)",
  IMPORT_WARNING = [[警告: 
导入会覆盖所有现有的EPGP值.

粘贴这里的所有CSV数据替换文本, 
然后再导入.
完成后打印结果.]],
  ["Group by armor"] = "Group by armor",
  ["Group members by armor."] = "Group members by armor.",
  ["Group by roles"] = "Group by roles",
  ["Group members by roles."] = "Group members by roles.",
  ["CLOTH"] = "CLOTH",
  ["LEATHER"] = "LEATHER",
  ["MAIL"] = "MAIL",
  ["PLATE"] = "PLATE",
  ["TANK"] = "TANK",
  ["HEALER"] = "HEALER",
  ["CASTER"] = "CASTER",
  ["PHYS DPS"] = "PHYS DPS",
  -- retroll
  ["{retroll}Type \"+\" if on main, or \"+<YourMainName>\" (without quotes) if on alt within %dsec."] = "{retroll}使用 \"+\" 如果你在大号上, 或者 \"+<YourMainName>\" (没有引号) 如果在小号 %d秒.",
  ["|cffFF3333|Hshootybid:1:$ML|h[Mainspec/NEED]|h|r"] = "|cffFF3333|Hshootybid:1:$ML|h[主天赋/需求]|h|r",
  ["|cff009900|Hshootybid:2:$ML|h[Offspec/GREED]|h|r"] = "|cff009900|Hshootybid:2:$ML|h[副天赋/贪婪]|h|r",
  ["Bids"] = "竞标",
  ["Show Bids Table."] = "显示竞标表.",
  ["ClearLoot"] = "清除拾取",  
  ["Clear Loot Table."] = "清除拾取表.",
  ["ClearLogs"] = "清除日志",  
  ["Clear Logs Table."] = "清除日志表.",
  ["Standings"] = "排名",  
  ["Show Standings Table."] = "显示排名表.",
  ["Restart"] = "重新开始",  
  ["Restart retroll if having startup problems."] = "重新开始 retroll，如果有启动问题.",
  ["Standings"] = "排名",  
  ["Show Standings Table."] = "显示排名表.",
  ["v%s Loaded."] = "v%s 加载.",  
  ["Alt Click/RClick/MClick"] = "Alt+左键/右键/中键",
  ["Call for: MS/OS/Both"] = "要求: MS/OS/Both",  
  ["gp:|cff32cd32%d|r gp_os:|cff20b2aa%d|r"] = "gp:|cff32cd32%d|r 副天赋gp:|cff20b2aa%d|r",
  ["pr:|cffff0000%.02f|r(%.02f) pr_os:|cffff0000%.02f|r(%.02f)"] = "pr:|cffff0000%.02f|r(%.02f) 副天赋pr:|cffff0000%.02f|r(%.02f)",  
  ["|cffff0000Finished|r"] = "|cffff0000完成|r",
  ["|cff00ff00%02d|r|cffffffffsec|r"] = "|cff00ff00%02d|r|cffffffff秒|r",  
  ["Manually modified %s\'s note. EPGP was %s"] = "手动修改 %s\'s 记录. EPGP 是 %s",
  ["|cffff0000Manually modified %s\'s note. EPGP was %s|r"] = "|cffff0000手动修改 %s\'s 记录. EPGP 是 %s|r",
  ["Whisper %s a + for %s (mainspec)"] = "私聊 %s + 为 %s (主天赋)",
  ["Whisper %s a - for %s (offspec)"] = "私聊 %s - 为 %s (副天赋)",
  ["Whisper %s a + or - for %s (mainspec or offspec)"] = "私聊 %s + 或 - 为 %s (主天赋或副天赋)",
  ["Click $MS or $OS for %s"] = "Click $MS 或 $OS for %s",
  ["or $OS "] = "或 $OS ",
  ["$MS or "] = "$MS 或 ",
  ["You have received a %d EP penalty."] = "你已经收到了 %d EP 处罚.",
  ["You have been awarded %d EP."] = "你被授予 %d EP.",
  ["You have gained %d GP."] = "你得到了 %d GP.",
  ["%s%% decay to EP and GP."] = "%s%% 递减EP和GP.",
  ["%d EP awarded to Raid."] = "%d EP 授予团队.",
  ["%d EP awarded to Reserves."] = "%d EP 授予替补队员.",
  ["New %s version available: |cff00ff00%s|r"] = "新的 %s 版本可用: |cff00ff00%s|r",
  ["Visit %s to update."] = "访问 %s 升级.",
  ["New raid progress"] = "新的RAID进度",
  [", offspec price %"] = ", 副天赋价格 %",
  ["New offspec price %"] = "新的副天赋价格 %",
  [", decay %"] = ", 递减 %",
  ["New decay %"] = "新的递减 %",
  [" settings accepted from %s"] = " 设置接受从 %s",
  ["Giving %d ep to all raidmembers"] = "给予 %d ep 到所有团员",
  ["Giving %d gp to all raidmembers"] = "给予 %d gp 到所有团员",
  ["You aren't in a raid dummy"] = "你不在一个团队",
  ["Giving %d ep to active reserves"] = "给予 %d ep 在线的替补队员",
  ["Giving %d ep to %s%s. (Previous: %d, New: %d)"] = "给予 %d ep 给 %s (以前: %d, 新: %d)",
  ["Giving %d gp to active reserves"] = "给予 %d gp 在线的替补队员",
  ["Giving %d gp to %s%s. (Previous: %d, New: %d)"] = "给予 %d gp 给 %s (以前: %d, 新: %d)", 
  ["%s EP Penalty to %s%s. (Previous: %d, New: %d)"] = "%s EP 惩罚 %s. (以前: %d, 新: %d)",
  ["%s GP Penalty to %s%s. (Previous: %d, New: %d)"] = "%s GP 惩罚 %s. (以前: %d, 新: %d)",
  ["Awarding %d GP to %s%s. (Previous: %d, New: %d)"] = "奖励 %d GP 给 %s. (以前: %d, 新: %d)",
  ["%s\'s officernote is broken:%q"] = "%s\'s 官员备注无法执行:%q",
  ["All EP and GP decayed by %d%%"] = "所有EP和GP递减 %d%%",
  ["All EP and GP decayed by %s%%"] = "所有EP和GP递减 %s%%",
  ["All GP has been reset to %d."] = "所有GP已重置为 %d.",
  ["All EP and GP has been reset to 0/%d."] = "所有EP和GP已重置为 0/%d.",
  ["You now have: %d EP %d GP + (%d)"] = "你现在有: %d EP %d GP + (%d) ",
  ["Close to EPGP Cap. Next Decay will change your |cffff7f00PR|r by |cffff0000%.4g|r."] = "下次递减会改变你的 |cffff7f00PR|r 从 |cffff0000%.4g|r.",
  ["|cffffff00Click|r to toggle Standings.%s \n|cffffff00Right-Click|r for Options."] = "|cffffff00点击|r 切换名单.%s \n|cffffff00右键|r 设置.",
  [" \n|cffffff00Ctrl+Click|r to toggle Reserves. \n|cffffff00Alt+Click|r to toggle Bids. \n|cffffff00Shift+Click|r to toggle Loot. \n|cffffff00Ctrl+Alt+Click|r to toggle Alts. \n|cffffff00Ctrl+Shift+Click|r to toggle Logs."] = " \n|cffffff00Ctrl+点击|r 切换到替补队员. \n|cffffff00Alt+点击|r 切换到竞拍. \n|cffffff00Shift+点击|r 切换到拾取. \n|cffffff00Ctrl+Shift+点击|r 切换到日志.", -- needs update
  ["Account EPs to %s."] = "记账 EP 到 %s.",
  ["Account GPs to %s."] = "记账 GP 到 %s.",
  ["retroll options"] = "retroll 设置",
  ["+EPs to Member"] = "+EP给成员",
  ["Account EPs for member."] = "记账 EP 给成员.",
  ["+EPs to Raid"] = "+EP给团队",
  ["+GPs to Raid"] = "+GP给团队",
  ["Award EPs to all raid members."] = "奖励 EP 给所有团队成员.",
  ["Award GPs to all raid members."] = "奖励 GP 给所有团队成员.",
  ["+GPs to Member"] = "+GP给成员",
  ["Account GPs for member."] = "记账 GP给成员.",
  ["+EPs to Reserves"] = "+EP给替补队员",
  ["Award EPs to all active Reserves."] = "奖励EP给所有在线的替补队员.",
  ["Enable Reserves"] = "激活替补成员",
  ["Participate in Standby Raiders List.\n|cffff0000Requires Main Character Name.|r"] = "参与在备用团队列表.\n|cffff0000要求大号名字.|r",
  ["AFK Check Reserves"] = "替补队员AFK检查",
  ["AFK Check Reserves List"] = "检查AFK的替补成员",
  ["Set Main"] = "设置大号",
  ["Set your Main Character for Reserve List."] = "设置你的大号人物为替补成员列表.",
  ["Raid Progress"] = "公会raid进度",
  ["Highest Tier the Guild is raiding.\nUsed to adjust GP Prices.\nUsed for suggested EP awards."] = "设置公会的最高raid进度.\n用于调整GP价格.\n用于自动调整推荐EP奖励值.",
  ["4.Naxxramas"] = "4.纳克萨玛斯",
  ["3.Temple of Ahn\'Qiraj"] = "3.安其拉神殿",
  ["2.Blackwing Lair"] = "2.黑翼之巢",
  ["1.Molten Core"] = "1.熔火之心",
  ["Reporting channel"] = "报告频道",
  ["Channel used by reporting functions."] = "报告功能使用的频道.",
  ["Decay EPGP"] = "递减 EPGP",
  ["Decays all EPGP by %s%%"] = "递减所有 EPGP 从 %s%%",
  ["Set Decay %"] = "设置递减 %",
  ["Set Decay percentage (Admin only)."] = "设置递减百分比 (只能管理员).",
  ["Offspec Price %"] = "副天赋价值 %",
  ["Set Offspec Items GP Percent."] = "设置副天赋物品 GP 百分比.",
  ["Reset EPGP"] = "重置 EPGP",
  ["Reset GP"] = "重置 GP",
  ["Resets everyone\'s EPGP to 0/%d (Admin only)."] = "重置所有人的 EPGP 到 0/%d (只能管理员).",
  ["Resets everyone\'s GP to 0/%d (Admin only)."] = "重置所有人的 EPGP 到 0/%d (只能管理员).",
  ["Scanning %d members for EP/GP data. (%s)"] = "扫描 %d 成员 EP/GP 数据. (%s)",
  ["|cffff0000%s|r trying to add %s to Reserves, but has already added a member. Discarding!"] = "|cffff0000%s|r 试图添加 %s 给替补成员, 但已经增加了一个成员。",
  ["|cffff0000%s|r has already been added to Reserves. Discarding!"] = "|cffff0000%s|r 已经添加到替补成员.",
  ["^{retroll}Type"] = "^{retroll}使用",
  ["Clearing old Bids"] = "结算之前的竞拍",
  ["%s not found in the guild or not max level!"] = "%s 没有在公会中找到或不是最高级别！",
  ["Molten Core"] = "熔火之心",
  ["Onyxia\'s Lair"] = "奥妮克希亚的巢穴",
  ["Blackwing Lair"] = "黑翼之巢",
  ["Ahn\'Qiraj"] = "安其拉",
  ["Naxxramas"] = "纳克萨玛斯",
  ["There are %d loot drops stored. It is recommended to clear loot info before a new raid. Do you want to clear it now?"] = "这个 %d 掉落是个战利品. 建议在新的RAID之前清除拾取物信息. 你现在想清除它吗？",
  ["Show me"] = "秀出來",
  ["Loot info cleared"] = "战利品信息清除",
  ["Loot info can be cleared at any time from the Tablet context menu or '/shooty clearloot' command"] = "拾取信息可以随时从小地图上下文菜单中清除，或者用 '/shooty clearloot' 命令",
  ["Set your main to be able to participate in Reserve List EPGP Checks."] = "设定你的主要人物到参与替补成员EPGP检查清单.",  
  ["Reserves AFKCheck. Are you available? |cff00ff00%0d|rsec."] = "替补成员AFK检查. 你在吗? |cff00ff00%0d|r秒.",
  ["|cffff0000Are you sure you want to Reset ALL EPGP?|r"] = "|cffff0000您确定要重置全部 EPGP?|r",
  ["|cffff0000Are you sure you want to Reset ALL GP?|r"] = "|cffff0000您确定要重置全部 GP?|r",
  ["Add MainSpec GP"] = "添加主天赋 GP",
  ["Add OffSpec GP"] = "添加副天赋 GP",
  ["Bank or D/E"] = "公会银行或分解师",
  ["%s looted %s. What do you want to do?"] = "%s 拾取了 %s. 你想做什么？",
  ["GP Actions"] = "GP 操作",
  ["Remind me Later"] = "以后提醒我",
  ["Need MasterLooter to perform Bid Calls!"] = "Need MasterLooter to perform Bid Calls!",
  ["retroll alts"] = "retroll 小号",
  ["Enable Alts"] = "启用小号",
  ["Main"] = "大号",
  ["Alt"] = "小号",
  ["Allow Alts to use Main\'s EPGP."] = "允许小号使用大号的 EPGP.",
  ["Alts EP %"] = "小号 EP %",
  ["Set the % EP Alts can earn."] = "设置 % EP 小号可以赚取.",
  [", alts"] = ", 小号",
  ["New Alts"] = "新小号",
  [", alts ep %"] = ", 小号 ep %",
  ["New Alts EP %"] = "新小号 EP %",
  ["Manually modified %s\'s note. Previous main was %s"] = "手动调整 %s 的备注. 以前的大号是 %s",
  ["|cffff0000Manually modified %s\'s note. Previous main was %s|r"] = "|cffff0000手动调整 %s 的备注. 以前的大号是 %s|r",
  [", %s\'s Main."] = ", %s 的大号.",
  ["Your main has been set to %s"] = "你的大号设置为 %s",
  ["Alts"] = "小号",
  ["Logs cleared"] = "清除日志",
  ["Restarted"] = "重新启动",
  ["Progress"] = "进度",
  ["Print Progress Multiplier."] = "打印进度调整器.",
  ["Offspec"] = "副天赋",
  ["Print Offspec Price."] = "打印副天赋价格.",
  ["Progress Setting: %s"] = "进度设置: %s",
  ["Offspec Price: %s%%"] = "副天赋价格: %s%%",
  ["Minimum EP: %s"] = "最小值 EP: %s",
  ["Minimum EP"] = "最小值 EP",
  ["Set Minimum EP"] = "设置最小值 EP",
  ["New Minimum EP"] = "新最小值 EP",
} end)
