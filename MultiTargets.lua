MultiTargets = StormwindLibrary_v1_12_0.new({
    colors = {
        primary = 'ED5859'
    },
    command = 'multitargets',
    data = 'MultiTargets_Data',
    name = 'MultiTargets',
    version = '1.5.0'
})

local events = MultiTargets.events

events:listen(events.EVENT_NAME_PLAYER_LOGIN, function()
    -- initializes the marker repository singleton
    MultiTargets.markerRepository = MultiTargets:new('MultiTargets/MarkerRepository')

    -- initializes the target frame button singleton
    MultiTargets.targetFrameButton = MultiTargets:new('MultiTargets/TargetFrameButton')
    MultiTargets.targetFrameButton:initialize()

    -- initializes the target window
    MultiTargets.targetWindow = MultiTargets
        :new('MultiTargets/TargetWindow')
        :createTargetWindowComponents()

    -- initializes the minimap button
    MultiTargets.minimapIcon = MultiTargets
        :new('MinimapIcon')
        :setIcon('Interface\\Icons\\ability_hunter_focusedaim')
        :setTooltipLines({
            MultiTargets:getVersionedNameLabel(),
            MultiTargets.output:color('Click', 'FFFFFF')..' to toggle the targets window',
            MultiTargets.output:color('Right click', 'FFFFFF')..' to print available commands',
            MultiTargets.output:color('Hold SHIFT and drag', 'FFFFFF')..' to move this icon',
        })
        :setCallbackOnLeftClick(function()
            MultiTargets.targetWindow:toggleVisibility()
        end)
        :setCallbackOnRightClick(function()
            MultiTargets.commands:printHelp()
        end)
        :create()

    --[[
    This method serves as a proxy to the loaded target list. It will call
    the method with the given name also passing the given arguments.

    The reason for this method is to avoid having to check if the target
    list is loaded before calling a method on it, otherwise it would be
    necessary to check if the target list is loaded before calling any
    method on it.

    Although the addon was designed to always have a target list loaded,
    it is possible that the target list is not loaded, so this method
    also acts as a sanity check.
    ]]
    function MultiTargets:invokeOnCurrent(methodName, ...)
        local targetList = self.currentTargetList

        if targetList then
            return targetList:invoke(methodName, ...)
        end
    end

    --[[
    Initializes the target list with the given name, loads it and sets it
    as the current target list.
    ]]
    function MultiTargets:loadTargetList(name)
        MultiTargets.currentTargetList = MultiTargets:new('MultiTargets/TargetList', name)
        MultiTargets.currentTargetList:load()
    end

    --[[
    This method will output the given message to the chat frame.

    It uses the output method from Stormwind Library, which can be easily
    replaced by another method that outputs messages to the chat frame in
    case the addon is used in another context, like a test environment.
    ]]
    function MultiTargets:out(message)
        MultiTargets.output:out(message)
    end

    -- loads the default target list
    -- in the future, this will be replaced by a saved variable that will
    -- store the last target list used by the player
    MultiTargets:loadTargetList('default')
end)
