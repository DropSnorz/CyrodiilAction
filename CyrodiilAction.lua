

CyrodiilAction = {} 
CyrodiilAction.name = "CyrodiilAction"

 
function CyrodiilAction:Initialize()

	EVENT_MANAGER:RegisterForEvent("event_keep", EVENT_KEEP_UNDER_ATTACK_CHANGED, self.OnKeepStatusUpdate)
  
  CyrodiilActionWindowBG:SetAlpha(0.5)
  TestLabel:SetText("Welcome in CyrodiilAction")
  CHAT_SYSTEM:AddMessage("CyrodiilAction loaded !")



end

function CyrodiilAction.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == CyrodiilAction.name then
    CyrodiilAction:Initialize()
  end
end

function CyrodiilAction.OnKeepStatusUpdate(_, keepID, battlegroundContext, underAttack)
    local self = CyrodiilAction

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

  battle = self.Battle.new(keepID)
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


function CyrodiilAction:updateView()

  self:clearView()
  for i = 0, 4 do
    if self.battles[i] ~= nil then
      local keepNameLabel = GetControl("KeepNameLabel" .. i)
      local keepTexture = GetControl("KeepTexture" .. i)
      keepNameLabel:SetText(zo_strformat(self.battles[i].keepName))
      keepTexture:SetTexture(self.battles[i]:GetKeepIcon())
      keepTexture:SetColor(CyrodiilAction.colors.white:UnpackRGBA())

    end
  end 

end

function CyrodiilAction:clearView()

  KeepNameLabel1:SetText("")
  KeepTexture1:SetTexture("")
  KeepTexture1:SetColor(CyrodiilAction.colors.invisible:UnpackRGBA())
  KeepDataLabel1:SetText("")
  KeepNameLabel2:SetText("")
  KeepDataLabel2:SetText("")
  KeepTexture2:SetTexture("")
  KeepTexture2:SetColor(CyrodiilAction.colors.invisible:UnpackRGBA())

end

EVENT_MANAGER:RegisterForEvent(CyrodiilAction.name, EVENT_ADD_ON_LOADED, CyrodiilAction.OnAddOnLoaded)