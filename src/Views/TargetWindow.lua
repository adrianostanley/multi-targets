--[[
The TargetWindowItem class is a component that contains all the constrols
for players to manage the loaded target list.

It uses the Stormwind Library Window class as a base to create the window
and shows the target list in a scrollable list as well as with the target
controls that are available in the TargetWindowItem class.

Due to how World of Warcraft API handles garbage collection, the
instantiated items won't be removed from this component when the target list
decreses in size. They'll actually be hidden and reused when new targets are
added to the list. That requires some extra logic to handle the recycling
of old items and the rendering of the target list, but it's a good trade-off
considering that the number of targets in the list would be recriated for
every target rotation and if players spam the rotation button, that would
drastically increase the number of orphan frames.

@see TargetWindow.maybeAllocateItems()
]]
local TargetWindow = {}
    TargetWindow.__index = TargetWindow
    -- TargetWindow inherits from Window
    setmetatable(TargetWindow, MultiTargets.__:getClass('Window'))

    --[[
    TargetWindow constructor.
    ]]
    function TargetWindow.__construct()
        local self = setmetatable({}, TargetWindow)

        -- @TODO: Remove the contentChildren initialization once the library
        --        is able to ignore nil values when setting the content
        --        children <2024.04.26>
        self.contentChildren = {}
        self.emptyTargetListMessage = self:createEmptyTargetListMessage()
        self.id = 'targets-window'
        self.items = {}
        self.targetList = nil

        -- @TODO: Remove the first position call once the library is able to
        --        set the default values inside the initial position method
        --        <2024.04.26>
        self:setFirstPosition({point = 'CENTER', relativePoint = 'CENTER', xOfs = 0, yOfs = 0})
        self:setFirstSize({width = 250, height = 400})
        self:setFirstVisibility(true)
        self:setPersistStateByPlayer(true)
        self:setTitle('MultiTargets')

        self:observeTargetListRefreshings()

        return self
    end

    --[[
    Creates a visual message to be displayed when the target list is empty.

    @treturn Frame The frame instance that contains the message
    ]]
    function TargetWindow:createEmptyTargetListMessage()
        local frame = CreateFrame('Frame', nil, nil, 'BackdropTemplate')

        frame:SetBackdrop({
            bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
            edgeFile = '',
            edgeSize = 4,
            insets = {left = 5, right = 1, top = 1, bottom = 1},
        })
        frame:SetBackdropColor(0, 0, 0, .2)
        frame:SetHeight(50)

        local text = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        text:SetPoint('TOP', frame, 'TOP', 0, 0)
        text:SetText('There are no names in the target list. Please, add some targets and use the rotation macro to start the rotation.')
        text:SetFont('Fonts\\ARIALN.ttf', 14)

        return frame
    end

    --[[
    Handles the target list refresh event.
    ]]
    function TargetWindow:handleTargetListRefreshEvent(targetList, action)
        self:setTargetList(targetList)

        if action == 'add' then
            self:setVisibility(true)
        end
    end

    --[[
    Allocates the items that will be used to render the target list.

    The allocation in this context means creating the items that will be
    used to render targets in the window. When the target list size is
    greater than the number of items, the missing items are created and
    added to the items list.

    Please, refer to this class documentation to understand why the items
    are not removed when the target list size decreases.

    If the number of allocated items is equal or greater than the target
    list size, this method does nothing.
    ]]
    function TargetWindow:maybeAllocateItems()
        local missingItems = #self.targetList.targets - #self.items

        for i = 1, missingItems do
            self.items[#self.items + 1] = MultiTargets.__
                :new('MultiTargetsTargetWindowItem')
                :create()
        end

        self:setContent(MultiTargets.__.arr:pluck(self.items, 'frame'))
    end

    --[[
    May show the empty target list message if the target list is empty.
    ]]
    function TargetWindow:maybeShowEmptyTargetListMessage()
        if self.targetList:isEmpty() then
            self:setContent({self.emptyTargetListMessage})
            self.emptyTargetListMessage:Show()
            return
        end

        self.emptyTargetListMessage:Hide()
    end

    --[[
    Registers the window instance to listen to target list refreshings.

    This is important to update the window when the target list is updated
    with new targets or when targets are removed.
    ]]
    function TargetWindow:observeTargetListRefreshings()
        MultiTargets.__.events:listen('TARGET_LIST_REFRESHED', function(targetList, action)
            self:handleTargetListRefreshEvent(targetList, action)
        end)
    end

    --[[
    Renders the target list in the window.

    This method only iterates over the items and sets the target instance
    to be represented by each item. Considering that each item will be
    hidden if a null target is set, there's no need to control their
    visibility here.
    ]]
    function TargetWindow:renderTargetList()
        MultiTargets.__.arr:each(self.items, function(item, i)
            item:setTarget(self.targetList.targets[i])
        end)
    end

    --[[
    Sets the target list to be rendered in the window.

    @tparam table targetList The target list instance to be set and
                             reflect in the window
    ]]
    function TargetWindow:setTargetList(targetList)
        self.targetList = targetList
        self:maybeAllocateItems()
        self:maybeShowEmptyTargetListMessage()
        self:renderTargetList()
    end
-- end of TargetWindow

-- allows this class to be instantiated
MultiTargets.__:addClass('MultiTargetsTargetWindow', TargetWindow)