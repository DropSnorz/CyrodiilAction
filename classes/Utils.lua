

CyrodiilAction = CyrodiilAction or {}
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

