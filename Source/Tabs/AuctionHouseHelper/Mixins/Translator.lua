AuctionHouseHelperTranslatorMixin = {}

function AuctionHouseHelperTranslatorMixin:OnLoad()
  self.FlagTexture:SetTexture(self.textureLocation)
  self.TranslatorsText:SetText(self.translators)
end
