CyrodiilAction = CyrodiilAction or {} 
CyrodiilAction.Battle = {}
CyrodiilAction.Battle.__index = CyrodiilAction.Battle
CyrodiilAction.Battle.type = "Battle"



----------------------------------------------
-- Creation
----------------------------------------------
function CyrodiilAction.Battle.new(keepID)
  local self = setmetatable({}, CyrodiilAction.Battle)
  self.startBattle = GetTimeStamp()
  self.endBattle = nil
  self.keepID = keepID
  self.keepName = CyrodiilAction.Utils:shortenKeepName(GetKeepName(keepID))
  self.keepType = GetKeepType(keepID)
  self.lastAttackTime = GetTimeStamp()
  self.siege = {}
  -- Number of point relative to battle size
  self.points = 0
  self:update()

  return self
end

-------------------------------------
-- Update battle attributes
-------------------------------------
function CyrodiilAction.Battle:update()

  self.owner = GetKeepAlliance(self.keepID, CyrodiilAction.battleContext)
  self.isKeepUnderAttack = GetKeepUnderAttack(self.keepID, CyrodiilAction.battleContext)
  self.siege[ALLIANCE_ALDMERI_DOMINION] = GetNumSieges(self.keepID, CyrodiilAction.battleContext, ALLIANCE_ALDMERI_DOMINION)
  self.siege[ALLIANCE_DAGGERFALL_COVENANT] = GetNumSieges(self.keepID, CyrodiilAction.battleContext, ALLIANCE_DAGGERFALL_COVENANT)
  self.siege[ALLIANCE_EBONHEART_PACT] = GetNumSieges(self.keepID, CyrodiilAction.battleContext, ALLIANCE_EBONHEART_PACT)

  if self.isKeepUnderAttack or self.siege[ALLIANCE_ALDMERI_DOMINION] > 0 or self.siege[ALLIANCE_DAGGERFALL_COVENANT] > 0 or self.siege[ALLIANCE_EBONHEART_PACT] > 0 then
    self.lastAttackTime = GetTimeStamp()
  end

  self.points = self.siege[ALLIANCE_ALDMERI_DOMINION] + self.siege[ALLIANCE_DAGGERFALL_COVENANT] + self.siege[ALLIANCE_EBONHEART_PACT]
  -- battles involving real keeps are bigger then the others.
  if self.keepType == KEEPTYPE_KEEP then
    self.points = self.points + 10
  end
end


function CyrodiilAction.Battle:createView()
  view = CreateControlFromVirtual("BattleLine", CyrodiilActionWindow, "BattleLine", self.KeepID)
  view:SetText(self.KeepName)
end

-------------------------------------
-- Returns keep icon for this battle instance
-------------------------------------
function CyrodiilAction.Battle:getKeepIcon()

  if self.keepType == KEEPTYPE_RESOURCE then
    local keepResourceType = GetKeepResourceType(self.keepID)
    return CyrodiilAction.defaults.icons.keep.resource[keepResourceType]
  else
    return CyrodiilAction.defaults.icons.keep[self.keepType]
  end
end

-------------------------------------
-- Returns keep action based on player action
-- CyrodiilAction.ACTION_DEFEND or CyrodiilAction.ACTION_ATTACK
-------------------------------------
function CyrodiilAction.Battle:getActionType()

  if self.keepType == KEEPTYPE_RESOURCE then
    local parentKeepID = GetParentKeep(self.keepID)
    local parentKeepOwner = GetKeepAlliance(parentKeepID, CyrodiilAction.battleContext)

    if parentKeepOwner == CyrodiilAction.playerAlliance then 
      return CyrodiilAction.ACTION_DEFEND
    else
      return CyrodiilAction.ACTION_ATTACK
    end

  else
    if self.owner == CyrodiilAction.playerAlliance then 
      return CyrodiilAction.ACTION_DEFEND
    else
      return CyrodiilAction.ACTION_ATTACK
    end
  end
end
