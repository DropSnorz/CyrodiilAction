

CyrodiilAction = {} 
CyrodiilAction.name = "CyrodiilAction"

 
function CyrodiilAction:Initialize()

	EVENT_MANAGER:RegisterForEvent("event_keep", EVENT_KEEP_UNDER_ATTACK_CHANGED, self.OnKeepStatusUpdate)
  
  CyrodiilActionBG:SetAlpha(0.5)

  CHAT_SYSTEM:AddMessage("CyrodiilAction loaded !")


end

function CyrodiilAction.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == CyrodiilAction.name then
    CyrodiilAction:Initialize()
  end
end

function CyrodiilAction.OnKeepStatusUpdate(_, keepID, battlegroundContext, underAttack)
    
    --Optionally hide IC district battles
    if GetKeepType(keepID) == KEEPTYPE_IMPERIAL_CITY_DISTRICT then
            return;
    end

    if underAttack then
    	d("Keep under attack.")
    else
      d("Keep safe.")

    end
end


EVENT_MANAGER:RegisterForEvent(CyrodiilAction.name, EVENT_ADD_ON_LOADED, CyrodiilAction.OnAddOnLoaded)