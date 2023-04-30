function AuctionHouseHelper.Config.InternalInitializeFrames(templateNames)
  for _, name in ipairs(templateNames) do
    CreateFrame(
      "FRAME",
      "AuctionHouseHelperConfig" .. name .. "Frame",
      SettingsPanel or InterfaceOptionsFrame,
      "AuctionHouseHelperConfig" .. name .. "FrameTemplate")
  end
end
