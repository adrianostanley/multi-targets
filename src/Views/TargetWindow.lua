--[[--
Class description.
]]
local TargetWindow = {}
    TargetWindow.__index = TargetWindow
    -- TargetWindow inherits from Window
    setmetatable(TargetWindow, MultiTargets.__:getClass('Window'))

    --[[--
    TargetWindow constructor.
    ]]
    function TargetWindow.__construct()
        local self = setmetatable({}, TargetWindow)

        -- @TODO: Remove the contentChildren initialization once the library
        --        is able to ignore nil values when setting the content
        --        children <2024.04.26>
        self.contentChildren = {}
        self.id = 'targets-window'

        -- @TODO: Remove the first position call once the library is able to
        --        set the default values inside the initial position method
        --        <2024.04.26>
        self:setFirstPosition({point = 'CENTER', relativePoint = 'CENTER', xOfs = 0, yOfs = 0})
        self:setFirstSize({width = 250, height = 400})
        self:setFirstVisibility(true)
        self:setTitle('MultiTargets')

        self:observeTargetListRefreshings()

        return self
    end

    --[[--
    Handles the target list refresh event.
    ]]
    function TargetWindow:handleTargetListRefreshEvent(targetList)
        -- @TODO: Implement this method <2024.04.26>
    end

    --[[--
    Registers the window instance to listen to target list refreshings.

    This is important to update the window when the target list is updated
    with new targets or when targets are removed.
    ]]
    function TargetWindow:observeTargetListRefreshings()
        MultiTargets.__.events:listen('TARGET_LIST_REFRESHED', function(targetList)
            self:handleTargetListRefreshEvent(targetList)
        end)
    end
-- end of TargetWindow

-- allows this class to be instantiated
MultiTargets.__:addClass('MultiTargetsTargetWindow', TargetWindow)