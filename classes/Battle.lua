
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
    self.keepName = GetKeepName(keepID)
    self.keepType = GetKeepType(keepID)

    self.owner = GetKeepAlliance(self.keepID, CyrodiilAction.battleContext)

    self.siege = {}
    self:update()

    return self
end

function CyrodiilAction.Battle:update()

    self.owner = GetKeepAlliance(self.keepID, CyrodiilAction.battleContext)

    self.siege[ALLIANCE_ALDMERI_DOMINION] = GetNumSieges(self.keepID, CyrodiilAction.battleContext, ALLIANCE_ALDMERI_DOMINION)
    self.siege[ALLIANCE_DAGGERFALL_COVENANT] = GetNumSieges(self.keepID, CyrodiilAction.battleContext, ALLIANCE_DAGGERFALL_COVENANT)
    self.siege[ALLIANCE_EBONHEART_PACT] = GetNumSieges(self.keepID, CyrodiilAction.battleContext, ALLIANCE_EBONHEART_PACT)

end


function CyrodiilAction.Battle:createView()

    view = CreateControlFromVirtual("BattleLine", CyrodiilActionWindow, "BattleLine", self.KeepID)
    view:SetText(self.KeepName)
end


function CyrodiilAction.Battle:GetKeepIcon()

    if self.keepType == KEEPTYPE_RESOURCE then

        local keepResourceType = GetKeepResourceType(self.keepID)
        return CyrodiilAction.defaults.icons.keep.resource[keepResourceType]
    else
        return CyrodiilAction.defaults.icons.keep[self.keepType]
    end
end



