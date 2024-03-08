--[[
Fires up the addon.
]]
local function MultiTargets_initializeCore()
    -- initializes the addon data
    if not MultiTargets_Data then MultiTargets_Data = {} end

    MultiTargets = {};
    MultiTargets.__ = StormwindLibrary_v0_0_5.new()
end

-- the main event frame used to trigger core initialization
MultiTargetsInitializationFrame = CreateFrame('Frame');

-- registers the PLAYER_LOGIN event
MultiTargetsInitializationFrame:RegisterEvent('PLAYER_LOGIN');

-- fires up the MultiTargets addon when the player logs in
MultiTargetsInitializationFrame:SetScript('OnEvent',
  function(self, event, ...)

    if event == 'PLAYER_LOGIN' then
        MultiTargets_initializeCore();
    end
  end
);