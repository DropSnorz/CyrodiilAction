

CyrodiilAction = {} 
CyrodiilAction.name = "CyrodiilAction"

 
function CyrodiilAction:Initialize()



	EVENT_MANAGER:RegisterForEvent("event_keep", EVENT_KEEP_UNDER_ATTACK_CHANGED, self.OnKeepStatusUpdate)
  self.battleContext = BGQUERY_LOCAL
  self.playerAlliance = GetUnitAlliance("player")
  CyrodiilActionWindowBG:SetAlpha(0.5)

  EVENT_MANAGER:RegisterForUpdate("BattleCheck", 10000, function()
       d("Check battles changes...")
       self:processBattle()
       self:updateView()
  end)

  self:scanKeeps()
  self:updateView()


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

    else
      --d("Keep safe.")
      --self:ProcessEndBattle(keepID)
    end

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
    if GetDiffBetweenTimeStamps(GetTimeStamp(), self.battles[i].lastAttackTime) >= CyrodiilAction.defaults.timeBeforeBattleClear then
     table.remove(self.battles, i)
    end
  end

  table.sort(self.battles, function(a,b) return a.points>b.points end)

end


function CyrodiilAction:updateView()

  self:clearView()

  if table.getn(self.battles) == 0 then 
    TitleLabel:SetHidden(false)
  else
    for i = 0, 4 do
      if self.battles[i] ~= nil then
        local step = i
        local actionTypeLabel = GetControl("ActionType"..i)
        local keepNameLabel = GetControl("KeepNameLabel" ..step)
        local keepAttackTexture = GetControl("KeepAttackTexture" .. step)
        local keepTexture = GetControl("KeepTexture" .. step)
        local keepDataLabel = GetControl("KeepDataLabel" .. step)

        if self.battles[i]:getActionType() == CyrodiilAction.ACTION_ATTACK then
          actionTypeLabel:SetText("A")
        else
          actionTypeLabel:SetText("D")
        end

        keepNameLabel:SetText(zo_strformat("<<C:1>>",self.battles[i].keepName))
        keepAttackTexture:SetHidden(not self.battles[i].isKeepUnderAttack)
        keepAttackTexture:SetColor(CyrodiilAction.defaults.alliance[ALLIANCE_ALDMERI_DOMINION].color:UnpackRGBA())

        keepTexture:SetTexture(self.battles[i]:GetKeepIcon())
        keepTexture:SetColor(CyrodiilAction.defaults.alliance[self.battles[i].owner].color:UnpackRGBA())

        keepDataLabel:SetText(self.battles[i].siege[ALLIANCE_DAGGERFALL_COVENANT].. " "..self.battles[i].siege[ALLIANCE_ALDMERI_DOMINION].." " ..self.battles[i].siege[ALLIANCE_EBONHEART_PACT])
      end
    end 
  end
end

function CyrodiilAction:clearView()

  --TODO : refacto
  TitleLabel:SetHidden(true)
  KeepNameLabel1:SetText("")
  KeepTexture1:SetTexture("")
  KeepTexture1:SetColor(CyrodiilAction.colors.invisible:UnpackRGBA())
  KeepAttackTexture1:SetHidden(true)
  KeepDataLabel1:SetText("")
  KeepNameLabel2:SetText("")
  KeepDataLabel2:SetText("")
  KeepTexture2:SetTexture("")
  KeepTexture2:SetColor(CyrodiilAction.colors.invisible:UnpackRGBA())
  KeepAttackTexture2:SetHidden(true)

  KeepNameLabel3:SetText("")
  KeepTexture3:SetTexture("")
  KeepTexture3:SetColor(CyrodiilAction.colors.invisible:UnpackRGBA())
  KeepAttackTexture3:SetHidden(true)
  KeepDataLabel3:SetText("")

  KeepNameLabel4:SetText("")
  KeepTexture4:SetTexture("")
  KeepTexture4:SetColor(CyrodiilAction.colors.invisible:UnpackRGBA())
  KeepAttackTexture4:SetHidden(true)
  KeepDataLabel4:SetText("")
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