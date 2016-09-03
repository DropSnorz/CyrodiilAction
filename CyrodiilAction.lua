

CyrodiilAction = {} 
CyrodiilAction.name = "CyrodiilAction"

 
function CyrodiilAction:Initialize()

	EVENT_MANAGER:RegisterForEvent("event_keep", EVENT_KEEP_UNDER_ATTACK_CHANGED, self.OnKeepStatusUpdate)
  self.battleContext = BGQUERY_LOCAL
  CyrodiilActionWindowBG:SetAlpha(0.5)

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
      self:ProcessNewBattle(keepID)
    else
      d("Keep safe.")
      self:ProcessEndBattle(keepID)
    end

end

CyrodiilAction.battles = {}
function CyrodiilAction:ProcessNewBattle(keepID)

  local battle = self.Battle.new(keepID)
  table.insert(self.battles, battle)
  self:updateView()

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

      --Main keeps
    for i=3,20 do
      self:checkAdd(i)

    end

    --Outposts
    for i=132,134 do
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


function CyrodiilAction:updateView()

  self:clearView()

  if table.getn(self.battles) == 0 then 
    TitleLabel:SetHidden(false)
  else
    for i = 0, 2 do
      if self.battles[i] ~= nil then
        local step = i
        local keepNameLabel = GetControl("KeepNameLabel" ..step)
        local keepAttackTexture = GetControl("KeepAttackTexture" .. step)
        local keepTexture = GetControl("KeepTexture" .. step)
        local keepDataLabel = GetControl("KeepDataLabel" .. step)

        keepNameLabel:SetText(zo_strformat(self.battles[i].keepName))
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


end

EVENT_MANAGER:RegisterForEvent(CyrodiilAction.name, EVENT_ADD_ON_LOADED, CyrodiilAction.OnAddOnLoaded)