

CyrodiilAction = CyrodiilAction or {}
CyrodiilAction.NotificationManager = {}
CyrodiilAction.NotificationManager.notifications = {}

notifications = CyrodiilAction.NotificationManager.notifications
CyrodiilAction.NotificationManager.freeze = 0


function CyrodiilAction.NotificationManager.push(notification)

  table.insert(notifications, notification)

end

function CyrodiilAction.NotificationManager.next()

  -- TODO check empty list
  local notification = notifications[1]
  table.remove(notifications, 1)
  return notification
end

function CyrodiilAction.NotificationManager.isReady()

  if CyrodiilAction.NotificationManager.freeze == 0 then
    return true
  else 
    CyrodiilAction.NotificationManager.freeze  = CyrodiilAction.NotificationManager.freeze  - 1
    return false
  end
  end

function CyrodiilAction.NotificationManager.getSize()

  return #notifications

end
