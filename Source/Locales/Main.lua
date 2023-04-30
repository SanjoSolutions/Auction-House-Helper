local currentLocale = {}

local function FixMissingTranslations(incomplete, locale)
  if locale == "enUS" then
    return
  end

  local enUS = AUCTION_HOUSE_HELPER_LOCALES["enUS"]()
  for key, val in pairs(enUS) do
    if incomplete[key] == nil then
      incomplete[key] = val
    end
  end
end

local function AddNewLines(full)
  for key, val in pairs(full) do
    full[key] = string.gsub(full[key], "\\n", "\n")
  end
end

if AUCTION_HOUSE_HELPER_LOCALES_OVERRIDE ~= nil then
  currentLocale = AUCTION_HOUSE_HELPER_LOCALES_OVERRIDE()

  FixMissingTranslations(currentLocale, "OVERRIDE")
elseif AUCTION_HOUSE_HELPER_LOCALES[GetLocale()] ~= nil then
  currentLocale = AUCTION_HOUSE_HELPER_LOCALES[GetLocale()]()

  FixMissingTranslations(currentLocale, GetLocale())
else
  currentLocale = AUCTION_HOUSE_HELPER_LOCALES["enUS"]()
end

AddNewLines(currentLocale)

-- Export constants into the global scope (for XML frames to use)
for key, value in pairs(currentLocale) do
  _G["AUCTION_HOUSE_HELPER_L_"..key] = value
end

function AuctionHouseHelper.Locales.Apply(s, ...)
  if currentLocale[s] ~= nil then
    return string.format(currentLocale[s], ...)
  else
    error("Unknown/missing locale string '" .. s .. "'")
  end
end
