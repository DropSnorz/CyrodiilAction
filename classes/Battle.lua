
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

    self.siege = {}
    self:createView()

    return self
end


function CyrodiilAction.Battle:createView()

    view = CreateControlFromVirtual("BattleLine", CyrodiilActionWindow, "BattleLine", self.KeepID)
end




