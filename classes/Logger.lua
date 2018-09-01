CyrodiilAction = CyrodiilAction or {}
CyrodiilAction.Logger = {}


function CyrodiilAction.Logger.log(message)
  if CyrodiilAction.debug then
    d(message)
  end
end
