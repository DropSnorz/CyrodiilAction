﻿

CyrodiilAction = CyrodiilAction or {}
CyrodiilAction.NotificationManager = CyrodiilAction.NotificationManager or {}
CyrodiilAction.Utils = {}


function CyrodiilAction.Utils.getKeepIcon(keepId)

	local keepType = GetKeepType(keepId)

	if keepType == KEEPTYPE_RESOURCE then

        local keepResourceType = GetKeepResourceType(keepId)
        return CyrodiilAction.defaults.icons.keep.resource[keepResourceType]
    else
        return CyrodiilAction.defaults.icons.keep[keepType]
    end

end

function CyrodiilAction.Utils.getKeepIconByBattleContext(keepId, battleContext)

	local keepType = GetKeepType(keepId)
	d("DBG "..battleContext)
	local alliance = GetKeepAlliance(keepId, battleContext)
	
	if keepType == KEEPTYPE_RESOURCE then

        local keepResourceType = GetKeepResourceType(keepId)
        return CyrodiilAction.defaults.icons.ava.keep.resource[keepResourceType][alliance]
    else
        return CyrodiilAction.defaults.icons.ava.keep[keepType][alliance]
    end
end


SLASH_COMMANDS["/notify"] = function (extra)
  
  CyrodiilAction.NotificationManager.push("New notification !")

end


