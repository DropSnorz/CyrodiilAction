

CyrodiilAction = CyrodiilAction or {}
CyrodiilAction.NotificationManager = CyrodiilAction.NotificationManager or {}
CyrodiilAction.Utils = {}



function CyrodiilAction.Utils:shortenKeepName(str)

 return str:gsub(",..$", ""):gsub("%^.d$", "")
    --FR
        :gsub("avant.poste d[eu] ", "")
        :gsub("la bastille d[eu]s? ", "")
        :gsub("de la bastille", "")
        :gsub("fort de la ", "")
        :gsub("du château ", "")
        :gsub("du fort ", "")

end

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
	local alliance = GetKeepAlliance(keepId, battleContext)
	
	if keepType == KEEPTYPE_RESOURCE then

        local keepResourceType = GetKeepResourceType(keepId)
        return CyrodiilAction.defaults.icons.ava.keep.resource[keepResourceType][alliance]
    else
        return CyrodiilAction.defaults.icons.ava.keep[keepType][alliance]
    end
end


SLASH_COMMANDS["/notify"] = function (extra)
  
  CyrodiilAction.NotificationManager.push({text="New notification !", type="test"})

end


function CyrodiilAction.Utils.format_thousand(v)
    local s = string.format("%d", math.floor(v))
    local pos = string.len(s) % 3
    local thousandSeparator = " "
    if pos == 0 then pos = 3 end
    return string.sub(s, 1, pos)
        .. string.gsub(string.sub(s, pos+1), "(...)", thousandSeparator.."%1")
end



