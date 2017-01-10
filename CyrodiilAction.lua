

CyrodiilAction = {} 
CyrodiilAction.notifications = {}
CyrodiilAction.name = "CyrodiilAction"
CyrodiilAction.isWindowClosed = false

 
function CyrodiilAction:Initialize()


  --CyrodiilAction:setupUI()

  EVENT_MANAGER:RegisterForEvent(CyrodiilAction.name, EVENT_PLAYER_ACTIVATED, self.OnPlayerZoneChanged)


end


function CyrodiilAction.OnPlayerZoneChanged(_, initial)

    local self = CyrodiilAction
    self:setupUI()

end


function CyrodiilAction:setupUI()

    d("zone changed")
  if IsPlayerInAvAWorld() and not self.isWindowClosed then 
    EVENT_MANAGER:RegisterForEvent(CyrodiilAction.name, EVENT_KEEP_UNDER_ATTACK_CHANGED, self.OnKeepStatusUpdate)
    self.battleContext = BGQUERY_LOCAL
    self.playerAlliance = GetUnitAlliance("player")
    CyrodiilActionWindowBG:SetAlpha(0.5)

    EVENT_MANAGER:RegisterForUpdate("BattleCheckUpdate", 10000, function()
         d("Check battles changes...")
         self:processBattle()
         self:updateView()
    end)

    EVENT_MANAGER:RegisterForUpdate("NotificationsUpdate", 5000, function() 
      self:processNotificationsUpdate() end)

    self:scanKeeps()
    self:updateView()
    CyrodiilActionWindow:SetHidden(false)
  else
    CyrodiilActionWindow:SetHidden(true)
    EVENT_MANAGER:UnregisterForEvent("YourAddonName", EVENT_KEEP_UNDER_ATTACK_CHANGED)
    EVENT_MANAGER:UnregisterForUpdate("BattleCheckUpdate")
    EVENT_MANAGER:UnregisterForUpdate("NotificationsUpdate")
    self.battles = {}
  end
end

function CyrodiilAction.CloseWindow()

  self = CyrodiilAction
  self.isWindowClosed = true
  self:setupUI()

end


function CyrodiilAction.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == CyrodiilAction.name then
    CyrodiilAction:Initialize()
  end
end

function CyrodiilAction.OnKeepStatusUpdate(_, keepID, battlegroundContext, underAttack)
    local self = CyrodiilAction
    self.battleContext = battlegroundContext

    --Optionally hide IC district battles
    if GetKeepType(keepID) == KEEPTYPE_IMPERIAL_CITY_DISTRICT then
            return;
    end

    if underAttack then
    	d("Keep under attack.")
      self:processNewBattle(keepID)
      self:updateView()
    end

end

function CyrodiilAction.OnKeepOwnerChanged(_, keepID, battlegroundContext, owningAlliance, oldAlliance)
  return;

end

CyrodiilAction.battles = {}
function CyrodiilAction:processNewBattle(keepID)

  local isKeepInBattles = false
  for i=#self.battles,1,-1 do
   local v = self.battles[i]
   if v.keepID == keepID then
     isKeepInBattles = true
   end
end

if not isKeepInBattles then
  local battle = self.Battle.new(keepID)
  table.insert(self.battles, battle)


  local notificationText = "New battle at |t32:32:" .. battle:GetKeepIcon() .."|t  ".. zo_strformat("<<C:1>>",GetKeepName(keepID))
  self:processNotification(notificationText)

end

end 

function CyrodiilAction:ProcessEndBattle(keepID)
 
for i=#self.battles,1,-1 do
   local v = self.battles[i]
   if v.keepID == keepID then
     table.remove(self.battles, i)
     self:updateView()
   end
end
end


function CyrodiilAction:scanKeeps()

    --Keeps, ressources and Outposts
    for i=1,134 do
        self:checkAdd(i)
    end

end

function CyrodiilAction:checkAdd(keepID)

  --TODO check if Keep in self.battles
  --TODO count siege
  if GetKeepUnderAttack(keepID, self.battleContext) then
    local battle = self.Battle.new(keepID)
    table.insert(self.battles, battle)
  end
end

function CyrodiilAction:processBattle()

  for i=#self.battles,1,-1 do
    self.battles[i]:update()

    d(GetDiffBetweenTimeStamps(GetTimeStamp(), self.battles[i].lastAttackTime))
    local battleTime = GetDiffBetweenTimeStamps(GetTimeStamp(), self.battles[i].lastAttackTime)

    if battleTime >= CyrodiilAction.defaults.timeBeforeBattleClear or 
     ( self.battles[i].keepType == KEEPTYPE_RESOURCE and battleTime >= CyrodiilAction.defaults.timeBeforeResourceBattleClear ) then
     table.remove(self.battles, i)
    end
  end

  table.sort(self.battles, function(a,b) return a.points>b.points end)

end

function CyrodiilAction:processNotification(notificationText)

  if CyrodiilAction.NotificationManager.getSize() == 0 then

    CyrodiilAction.NotificationManager.push(notificationText)
    self:processNotificationsUpdate()

    CyrodiilAction.NotificationManager.freeze = 1

  else

    CyrodiilAction.NotificationManager.push(notificationText)

  end
end



function CyrodiilAction:processNotificationsUpdate()

  if CyrodiilAction.NotificationManager.getSize() ~= 0 then

    if CyrodiilAction.NotificationManager.isReady() then

      notification = CyrodiilAction.NotificationManager.next()
      NotificationLabel:SetText(notification)
      NotificationLabel:SetHidden(false)
    end

  else

    NotificationLabel:SetHidden(true)

  end
end


function CyrodiilAction:updateView()

  d("TEST NM" .. CyrodiilAction.NotificationManager.getSize())
   -- TODO refacto
  self:clearView()

  if table.getn(self.battles) == 0 then 
    TitleLabel:SetHidden(false)
  else
    for i = 0, 4 do
      if self.battles[i] ~= nil then
        local step = i
        local actionTypeTexture = GetControl("ActionType"..i)
        local keepNameLabel = GetControl("KeepNameLabel" ..step)
        local keepAttackTexture = GetControl("KeepAttackTexture" .. step)
        local keepTexture = GetControl("KeepTexture" .. step)
        local keepDataSiegeAD = GetControl("KeepSiegeAD" .. step)
        local keepDataSiegeDC = GetControl("KeepSiegeDC" .. step)
        local keepDataSiegeEP = GetControl("KeepSiegeEP" .. step)


        if self.battles[i]:getActionType() == CyrodiilAction.ACTION_ATTACK then
          actionTypeTexture:SetTexture(CyrodiilAction.defaults.icons.actionAttack)
        else
          actionTypeTexture:SetTexture(CyrodiilAction.defaults.icons.actionDefend)

        end
        actionTypeTexture:SetHidden(false)

        keepNameLabel:SetText(zo_strformat("<<C:1>>",self.battles[i].keepName))
        keepAttackTexture:SetHidden(not self.battles[i].isKeepUnderAttack)
        keepAttackTexture:SetColor(CyrodiilAction.defaults.alliance[ALLIANCE_ALDMERI_DOMINION].color:UnpackRGBA())

        keepTexture:SetTexture(self.battles[i]:GetKeepIcon())
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

EVENT_MANAGER:RegisterForEvent(CyrodiilAction.name, EVENT_ADD_ON_LOADED, CyrodiilAction.OnAddOnLoaded)


    -- When the event fires, call this function & pass it keepId (given to you by the event) --
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