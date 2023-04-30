function AuctionHouseHelper.Utilities.SetStacksText(entry)
  if entry.numStacks == 1 then
    entry.availablePretty = AUCTION_HOUSE_HELPER_L_X_STACK_OF_X:format(entry.numStacks, entry.stackSize)
  else
    entry.availablePretty = AUCTION_HOUSE_HELPER_L_X_STACKS_OF_X:format(entry.numStacks, entry.stackSize)
  end
end
