CyrodiilAction = {}
CyrodiilAction.battles = {}
CyrodiilAction.notifications = {}
CyrodiilAction.name = "CyrodiilAction"
CyrodiilAction.isWindowClosed = false
-- Indicates if total or potential alliance points are displayed
CyrodiilAction.pointsDisplayRing = false
CyrodiilAction.debug = false

-------------------------------------
-- Called when AddOn has been successfully loaded.
-------------------------------------
function CyrodiilAction.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == CyrodiilAction.name then
    CyrodiilAction:Initialize()
  end
end


-------------------------------------
-- Bootstraps AddOn
-------------------------------------
function CyrodiilAction:Initialize()

  EVENT_MANAGER:RegisterForEvent(CyrodiilAction.name, EVENT_PLAYER_ACTIVATED, self.OnPlayerZoneChanged)

end

-------------------------------------
-- Event handler catching player zone changes.
-------------------------------------
function CyrodiilAction.OnPlayerZoneChanged(_, initial)

  local self = CyrodiilAction
  self:setupUI()

end

-------------------------------------
-- Setup AddOn UI and event bindings
-------------------------------------
function CyrodiilAction:setupUI()

  CyrodiilAction.Logger.log("zone changed")
  if IsPlayerInAvAWorld() and not self.isWindowClosed then 
    self.battleContext = BGQUERY_LOCAL
    self.playerAlliance = GetUnitAlliance("player")
    self.campaignId = GetCurrentCampaignId()
    CyrodiilActionWindowBG:SetAlpha(0.5)

    self:scanKeeps()
    self:updateScoreDisplay()

    EVENT_MANAGER:RegisterForUpdate("BattleCheckUpdate", 10000, function()
     CyrodiilAction.Logger.log("Check battles changes...")
     self:updateBattleList()
     self:updateView()
     end)

    EVENT_MANAGER:RegisterForUpdate("NotificationsUpdate", 5000, function() 
      self:processNotificationsUpdate() 
      self:updateScoreDisplay()
      end)

    EVENT_MANAGER:RegisterForUpdate("RefreshCycle", 1000, function()
      self:updateCampaignTime();
      end)

    EVENT_MANAGER:RegisterForEvent(CyrodiilAction.name, EVENT_KEEP_UNDER_ATTACK_CHANGED, self.OnKeepStatusUpdate)
    EVENT_MANAGER:RegisterForEvent(CyrodiilAction.name, EVENT_KEEP_ALLIANCE_OWNER_CHANGED , self.OnKeepOwnerChanged)
    EVENT_MANAGER:RegisterForEvent(CyrodiilAction.name, EVENT_CAMPAIGN_SCORE_DATA_CHANGED, self.OnWarScoreChanged)

    notificationAnimation, notificationAnimationTimeline = CreateSimpleAnimation(ANIMATION_TEXTURE, GetControl("NotificationTexture"))
    notificationAnimation:SetImageData(4, 8)
    notificationAnimation:SetFramerate(20)
    notificationAnimationTimeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
    notificationAnimationTimeline:PlayFromStart()

    self:updateView()
    CyrodiilActionWindow:SetHidden(false)
  else
    CyrodiilActionWindow:SetHidden(true)
    EVENT_MANAGER:UnregisterForEvent(CyrodiilAction.name, EVENT_KEEP_UNDER_ATTACK_CHANGED)
    EVENT_MANAGER:UnregisterForUpdate("BattleCheckUpdate")
    EVENT_MANAGER:UnregisterForUpdate("NotificationsUpdate")
    self.battles = {}
  end
end

-------------------------------------
-- Event handler catching keep status updates
-------------------------------------
function CyrodiilAction.OnKeepStatusUpdate(_, keepID, battlegroundContext, underAttack)
  local self = CyrodiilAction
  self.battleContext = battlegroundContext

  --Optionally hide IC district battles
  if GetKeepType(keepID) == KEEPTYPE_IMPERIAL_CITY_DISTRICT then
    return;
  end

  if underAttack then
   CyrodiilAction.Logger.log("Keep under attack.")
   self:processNewBattle(keepID)
   self:updateView()
  end
end

-------------------------------------
-- Event handler catching keep owner changes
-------------------------------------
 function CyrodiilAction.OnKeepOwnerChanged(_, keepID, battlegroundContext, owningAlliance, oldAlliance)
  local self = CyrodiilAction
  local notificationText = "|t32:32:"..CyrodiilAction.Utils.getKeepIconByBattleContext(keepID, battlegroundContext).."|t ".. zo_strformat("<<C:1>>",CyrodiilAction.Utils:shortenKeepName(GetKeepName(keepID))) .." captured ".. "|t32:32:"..CyrodiilAction.defaults.alliance[oldAlliance].pin.."|t > " .. "|t32:32:"..CyrodiilAction.defaults.alliance[owningAlliance].pin.."|t "
  local notificationType

  if self.playerAlliance == owningAlliance then
    notificationType = "success"
  else
    notificationType="danger"
  end

  local notification = {text= notificationText, type=notificationType};
  self:processNotification(notification)
end

-------------------------------------
-- Event handler catching war score updates
-------------------------------------
function CyrodiilAction.OnWarScoreChanged(eventCode)
  local self = CyrodiilAction

  local notificationText="War score updated !"
  local notification = {text= notificationText, type="info"};
  self:processNotification(notification)

  local aldmeriScore = GetCampaignAllianceScore(self.campaignId, ALLIANCE_ALDMERI_DOMINION)
  local daggerfallScore = GetCampaignAllianceScore(self.campaignId, ALLIANCE_DAGGERFALL_COVENANT)
  local ebonheartScore = GetCampaignAllianceScore(self.campaignId, ALLIANCE_EBONHEART_PACT)

  local aldmeriPotentialScore = GetCampaignAlliancePotentialScore(self.campaignId, ALLIANCE_ALDMERI_DOMINION)
  local daggerfallPotentialScore = GetCampaignAlliancePotentialScore(self.campaignId, ALLIANCE_DAGGERFALL_COVENANT)
  local ebonheartPotentialScore = GetCampaignAlliancePotentialScore(self.campaignId, ALLIANCE_EBONHEART_PACT)

  notificationText="|t32:32:"..CyrodiilAction.defaults.alliance[ALLIANCE_ALDMERI_DOMINION].pin.."|t " .. zo_strformat("<<C:1>>",GetAllianceName(ALLIANCE_ALDMERI_DOMINION)) .. ": " .. aldmeriScore .. " (+" ..aldmeriPotentialScore .. ")"
  notification = {text= notificationText, type="info"};
  self:processNotification(notification)

  notificationText="|t32:32:"..CyrodiilAction.defaults.alliance[ALLIANCE_DAGGERFALL_COVENANT].pin.."|t ".. zo_strformat("<<C:1>>",GetAllianceName(ALLIANCE_DAGGERFALL_COVENANT)) .. ": " ..  daggerfallScore .. " (+" ..daggerfallPotentialScore .. ")"
  notification = {text= notificationText, type="info"};
  self:processNotification(notification)

  notificationText="|t32:32:"..CyrodiilAction.defaults.alliance[ALLIANCE_EBONHEART_PACT].pin.."|t ".. zo_strformat("<<C:1>>",GetAllianceName(ALLIANCE_EBONHEART_PACT)) .. ": " ..  ebonheartScore .. " (+" ..ebonheartPotentialScore .. ")"
  notification = {text=notificationText, type="ifno"};
  self:processNotification(notification)

end

-------------------------------------
-- Process new incoming battle
-------------------------------------
function CyrodiilAction:processNewBattle(keepID)

  if not self:battleListContains(keepID) then
    local battle = self.Battle.new(keepID)
    table.insert(self.battles, battle)

    local notificationText = "|t32:32:" .. CyrodiilAction.Utils.getKeepIconByBattleContext(keepID, self.battleContext) .."|t New battle at  ".. zo_strformat("<<C:1>>",CyrodiilAction.Utils:shortenKeepName(GetKeepName(keepID)))
    local notificationType

    if battle:getActionType() == CyrodiilAction.ACTION_ATTACK then
      notificationType = "info"
    else
      notificationType = "danger"
    end

    notification = {text= notificationText, notificationType};
    self:processNotification(notification)
  end
end 


-------------------------------------
-- Scan and adds all keeps under attack
-------------------------------------
function CyrodiilAction:scanKeeps()
    --Keeps, ressources and Outposts
    for i=1,134 do
      if GetKeepUnderAttack(keepID, self.battleContext)
       and not self:battleListContains(i) then
        local battle = self.Battle.new(keepID)
        table.insert(self.battles, battle)
      end
    end
end


-------------------------------------
-- Checks if the battle list contains the given keepID
-------------------------------------
function CyrodiilAction:battleListContains(keepID)

  for i=#self.battles,1,-1 do
    local v = self.battles[i]
    if v.keepID == keepID then
      return true
    end
  end
  return false;
end


-------------------------------------
-- Update battle list
-------------------------------------
function CyrodiilAction:updateBattleList()

  for i=#self.battles,1,-1 do
    self.battles[i]:update()
    CyrodiilAction.Logger.log(GetDiffBetweenTimeStamps(GetTimeStamp(), self.battles[i].lastAttackTime))
    local battleTime = GetDiffBetweenTimeStamps(GetTimeStamp(), self.battles[i].lastAttackTime)
    if battleTime >= CyrodiilAction.defaults.timeBeforeBattleClear or 
     ( self.battles[i].keepType == KEEPTYPE_RESOURCE and battleTime >= CyrodiilAction.defaults.timeBeforeResourceBattleClear ) then
     table.remove(self.battles, i)
    end
 end

 table.sort(self.battles, function(a,b) return a.points>b.points end)

end

-------------------------------------
-- Add a new notification
-------------------------------------
function CyrodiilAction:processNotification(notificationText)

  if CyrodiilAction.NotificationManager.getSize() == 0 then
    CyrodiilAction.NotificationManager.push(notificationText)
    self:processNotificationsUpdate()
    CyrodiilAction.NotificationManager.freeze = 1

  else
    CyrodiilAction.NotificationManager.push(notificationText)
  end
end

-------------------------------------
-- Update notifications display
-------------------------------------
function CyrodiilAction:processNotificationsUpdate()

  local animation = ZO_AlphaAnimation:New(NotificationLabel)
  local notificationTexture = GetControl("NotificationTexture")
  local backgroundAnimation = ZO_AlphaAnimation:New(notificationTexture)
  backgroundAnimation:SetMinMaxAlpha(0,0.6)
  NotificationLabel:SetHidden(false)

  if CyrodiilAction.NotificationManager.isReady() then
    if CyrodiilAction.NotificationManager.getSize() ~= 0 then

      if NotificationLabel:GetAlpha() > 0.2 then
        animation:FadeOut(0, 300, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA, nil, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_SHOWN )
        backgroundAnimation:FadeOut(0, 300, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA, nil, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_SHOWN )

      end
      notification = CyrodiilAction.NotificationManager.next()
      NotificationLabel:SetText(notification.text)

      if notification.type == "danger" then
        notificationTexture:SetColor(ZO_ColorDef:New("D91E18"):UnpackRGB())
      elseif notification.type == "success" then
        notificationTexture:SetColor(ZO_ColorDef:New("00B16A"):UnpackRGB())
      else
        notificationTexture:SetColor(ZO_ColorDef:New("19B5FE"):UnpackRGB())
      end

      animation:FadeIn(0, 500, ZO_ALPHA_ANIMATION_OPTION_FORCE_ALPHA, nil, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_SHOWN )
      backgroundAnimation:FadeIn(0, 500, ZO_ALPHA_ANIMATION_OPTION_FORCE_ALPHA, nil, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_SHOWN )

    else
      animation:FadeOut(0, 500, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA, nil, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_SHOWN )
      backgroundAnimation:FadeOut(0, 500, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA, nil, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_SHOWN )

    end
  end
end

-------------------------------------
-- Update score display
-------------------------------------
function CyrodiilAction:updateScoreDisplay()

    local aldmeriPoints = GetControl("AldmeriPoints");
    local daggerfallPoints = GetControl("DaggerfallPoints");
    local ebonheartPoints = GetControl("EbonheartPoints");

    local aldmeriLabelAnimation = ZO_AlphaAnimation:New(aldmeriPoints)
    local daggerfallLabelAnimation = ZO_AlphaAnimation:New(daggerfallPoints)
    local ebonheartLabelAnimation = ZO_AlphaAnimation:New(ebonheartPoints)

    aldmeriLabelAnimation:FadeIn(0, 500, ZO_ALPHA_ANIMATION_OPTION_FORCE_ALPHA, nil, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_SHOWN )
    daggerfallLabelAnimation:FadeIn(0, 500, ZO_ALPHA_ANIMATION_OPTION_FORCE_ALPHA, nil, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_SHOWN )
    ebonheartLabelAnimation:FadeIn(0, 500, ZO_ALPHA_ANIMATION_OPTION_FORCE_ALPHA, nil, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_SHOWN )


    if self.pointsDisplayRing then

      aldmeriPoints:SetText("+" .. GetCampaignAlliancePotentialScore(self.campaignId, ALLIANCE_ALDMERI_DOMINION))
      daggerfallPoints:SetText("+" ..GetCampaignAlliancePotentialScore(self.campaignId, ALLIANCE_DAGGERFALL_COVENANT))
      ebonheartPoints:SetText("+" ..GetCampaignAlliancePotentialScore(self.campaignId, ALLIANCE_EBONHEART_PACT))

      aldmeriPoints:SetColor(CyrodiilAction.defaults.alliance[ALLIANCE_ALDMERI_DOMINION].color:UnpackRGBA())
      daggerfallPoints:SetColor(CyrodiilAction.defaults.alliance[ALLIANCE_DAGGERFALL_COVENANT].color:UnpackRGBA())
      ebonheartPoints:SetColor(CyrodiilAction.defaults.alliance[ALLIANCE_EBONHEART_PACT].color:UnpackRGBA())

    else
      aldmeriPoints:SetText(CyrodiilAction.Utils.format_thousand(GetCampaignAllianceScore(self.campaignId, ALLIANCE_ALDMERI_DOMINION)))
      daggerfallPoints:SetText(CyrodiilAction.Utils.format_thousand(GetCampaignAllianceScore(self.campaignId, ALLIANCE_DAGGERFALL_COVENANT)))
      ebonheartPoints:SetText(CyrodiilAction.Utils.format_thousand(GetCampaignAllianceScore(self.campaignId, ALLIANCE_EBONHEART_PACT)))

      aldmeriPoints:SetColor(CyrodiilAction.colors.white:UnpackRGBA())
      daggerfallPoints:SetColor(CyrodiilAction.colors.white:UnpackRGBA())
      ebonheartPoints:SetColor(CyrodiilAction.colors.white:UnpackRGBA())
    end
    self.pointsDisplayRing = not self.pointsDisplayRing
  end

-------------------------------------
-- Update battle display
-------------------------------------
function CyrodiilAction:updateView()

   -- TODO: avoid clearing entire UI beofre fill it.
  self:clearView()

  if table.getn(self.battles) == 0 then 
    TitleLabel:SetHidden(false)
  else
    for i = 0, 4 do
      if self.battles[i] ~= nil then
        local actionTypeTexture = GetControl("ActionType"..i)
        local keepNameLabel = GetControl("KeepNameLabel" ..i)
        local keepAttackTexture = GetControl("KeepAttackTexture" .. i)
        local keepTexture = GetControl("KeepTexture" .. i)
        local keepDataSiegeAD = GetControl("KeepSiegeAD" .. i)
        local keepDataSiegeDC = GetControl("KeepSiegeDC" .. i)
        local keepDataSiegeEP = GetControl("KeepSiegeEP" .. i)

        if self.battles[i]:getActionType() == CyrodiilAction.ACTION_ATTACK then
          actionTypeTexture:SetTexture(CyrodiilAction.defaults.icons.actionAttack)
        else
          actionTypeTexture:SetTexture(CyrodiilAction.defaults.icons.actionDefend)
        end

        actionTypeTexture:SetHidden(false)

        keepNameLabel:SetText(zo_strformat("<<C:1>>",self.battles[i].keepName))
        keepAttackTexture:SetHidden(not self.battles[i].isKeepUnderAttack)
        keepAttackTexture:SetColor(CyrodiilAction.defaults.alliance[ALLIANCE_ALDMERI_DOMINION].color:UnpackRGBA())

        keepTexture:SetTexture(self.battles[i]:getKeepIcon())
        keepTexture:SetColor(CyrodiilAction.defaults.alliance[self.battles[i].owner].color:UnpackRGBA())

        keepDataSiegeAD:SetText(self.battles[i].siege[ALLIANCE_ALDMERI_DOMINION])
        keepDataSiegeAD:SetColor(CyrodiilAction.defaults.alliance[ALLIANCE_ALDMERI_DOMINION].color:UnpackRGBA())
        keepDataSiegeDC:SetText(self.battles[i].siege[ALLIANCE_DAGGERFALL_COVENANT])
        keepDataSiegeDC:SetColor(CyrodiilAction.defaults.alliance[ALLIANCE_DAGGERFALL_COVENANT].color:UnpackRGBA())
        keepDataSiegeEP:SetText(self.battles[i].siege[ALLIANCE_EBONHEART_PACT])
        keepDataSiegeEP:SetColor(CyrodiilAction.defaults.alliance[ALLIANCE_EBONHEART_PACT].color:UnpackRGBA())
      end
    end
  end
end

-------------------------------------
-- Update campign time display display
-------------------------------------
function CyrodiilAction:updateCampaignTime()
  local campaignTime = GetControl("CampaignTime");
  local time = CyrodiilAction.Utils.format_time(GetSecondsUntilCampaignScoreReevaluation(self.campaignId));
  campaignTime:SetText(time)
end


-------------------------------------
-- Clear AddOn view
-------------------------------------
function CyrodiilAction:clearView()

  TitleLabel:SetHidden(true)
  for i = 1, 4 do
    local actionTypeTexture = GetControl("ActionType"..i)
    local keepNameLabel = GetControl("KeepNameLabel" ..i)
    local keepAttackTexture = GetControl("KeepAttackTexture" .. i)
    local keepTexture = GetControl("KeepTexture" .. i)
    local keepDataSiegeAD = GetControl("KeepSiegeAD" .. i)
    local keepDataSiegeDC = GetControl("KeepSiegeDC" .. i)
    local keepDataSiegeEP = GetControl("KeepSiegeEP" .. i)

    actionTypeTexture:SetHidden(true)
    keepNameLabel:SetText("")
    keepAttackTexture:SetHidden(true)
    keepTexture:SetColor(CyrodiilAction.colors.invisible:UnpackRGBA())
    keepDataSiegeAD:SetText("")
    keepDataSiegeDC:SetText("")
    keepDataSiegeEP:SetText("")
  end
end

-------------------------------------
-- Cose UI
-------------------------------------
function CyrodiilAction.CloseWindow()
  self = CyrodiilAction
  self.isWindowClosed = true
  self:setupUI()
end

-------------------------------------
-- Returns the resource parent keep
-------------------------------------
function GetParentKeep(_keepId) 
  local iKeepResourceType = GetKeepResourceType(_keepId) 
    -- If the resourceType is none then I'm guessing that makes it the main (parent) keep? --
    -- so do this to check if its a main (parent) keep under attack --
  if iKeepResourceType ==  RESOURCETYPE_NONE then
    return _keepId
  end

-- Otherwise it is a resource keep so we need to find out which main (parent) --
-- keep it belongs too --

  local iNumKeeps = GetNumKeeps()

  for i = 1, iNumKeeps do
    local parentKeepId = GetKeepKeysByIndex(i)
    local resourceKeepId = GetResourceKeepForKeep(parentKeepId, iKeepResourceType)
      -- GetResourceKeepForKeep(integer parentKeepId, integer resourceType)
      --     Returns: integer keepId 

    if resourceKeepId == _keepId then
      return parentKeepId
    end
  end
end

EVENT_MANAGER:RegisterForEvent(CyrodiilAction.name, EVENT_ADD_ON_LOADED, CyrodiilAction.OnAddOnLoaded)
