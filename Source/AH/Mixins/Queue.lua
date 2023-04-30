AuctionHouseHelper.AH.QueueMixin = {}

function AuctionHouseHelper.AH.QueueMixin:Init()
  self.queue = {}
  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.AH.Events.Ready
  })
end

local function Dequeue(self)
  if #self.queue > 0 then
    AuctionHouseHelper.AH.Internals.throttling:SearchQueried()
    self.queue[1]()
    table.remove(self.queue, 1)
  end
end

function AuctionHouseHelper.AH.QueueMixin:Enqueue(func)
  table.insert(self.queue, func)

  if AuctionHouseHelper.AH.Internals.throttling:IsReady() then
    Dequeue(self)
  end
end

function AuctionHouseHelper.AH.QueueMixin:Remove(func)
  local index = tIndexOf(self.queue, func)
  if index ~= nil then
    table.remove(self.queue, index)
  end
end

function AuctionHouseHelper.AH.QueueMixin:ReceiveEvent(event)
  Dequeue(self)
end
