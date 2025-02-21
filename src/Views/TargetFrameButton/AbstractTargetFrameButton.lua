--[[
The AbstractTargetFrameButton class is responsible for creating and managing
the button that will be attached to the player's target frame, which is that
small frame that appears when the player targets a unit in the game (another
player, an enemy, a friendly NPC, etc).

The button may assume two states: adding and removing, based on the current
target existence in the target list. When the player targets a unit that is
not in the target list, the button will be in the adding state, and when the
player targets a unit that is in the target list, the button will be in the
removing state.

As an event listener, the button may update its state when the player changes
the target list, regardless of the change source.
]]
local AbstractTargetFrameButton = {}
    AbstractTargetFrameButton.__index = AbstractTargetFrameButton
    MultiTargets:addAbstractClass('MultiTargets/AbstractTargetFrameButton', AbstractTargetFrameButton)

    --[[
    AbstractTargetFrameButton constructor.
    ]]
    function AbstractTargetFrameButton.__construct()
        return setmetatable({}, AbstractTargetFrameButton)
    end

    --[[
    Creates the button that will be added to the player's target frame.

    @codeCoverageIgnore this method is already tested in the constructor
                        test, so it is not necessary to test it again,
                        unless there's a good mock expectation structure
                        in the future
    ]]
    function AbstractTargetFrameButton:createButton()
        self.button = CreateFrame('Button', 'TargetFrameButton', TargetFrame, 'UIPanelButtonTemplate')
        self.button:SetSize(110, 25)

        -- concrete classes should implement this method to return the
        -- proper offsets for the button in the target frame
        local ofsx, ofsy = self:getOffset()

        self.button:SetPoint('TOPLEFT', TargetFrame, 'TOPLEFT', ofsx, ofsy)
        self.button:SetScript('OnClick', function ()
            self:onButtonClick()
        end)

        self.button.Left:Hide()
        self.button.Middle:Hide()
        self.button.Right:Hide()

        self.buttonText = self.button:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        self.buttonText:SetPoint('LEFT', self.button, 'LEFT', 7, 0)
        self.buttonText:SetJustifyH('LEFT')
        self.buttonText:SetTextColor(1, 1, 1)

        self.button:SetFontString(self.buttonText)

        local htex = self.button:CreateTexture()
        htex:SetColorTexture(1, 1, 1, 0.025)
        self.button:SetHighlightTexture(htex)
    end

    --[[
    Gets the button offset from the target frame.

    This method is used to position the button in the target frame and it's
    abstract due to the different offsets that the button may have in the
    World of Warcraft clients.
    ]]
    function AbstractTargetFrameButton:getOffset()
        error('This is an abstract method and should be implemented by this class inheritances')
    end

    --[[
    Initializes the class dependencies.

    This method was originally part of the constructor execution, but since
    the target frame button became an abstract class, it was moved to a
    separate method to be called by the inheritances as constructor override
    is not entirely supported by the Stormwind Library class factory
    structure.
    ]]
    function AbstractTargetFrameButton:initialize()
        self:createButton()
        self:observeRelevantEvents()
        self:turnAddState()
    end

    --[[
    Determines if the button is in the adding state.

    @treturn boolean
    ]]
    function AbstractTargetFrameButton:isAdding()
        return self.state == 'adding'
    end

    --[[
    Determines if the button is in the removing state.

    @treturn boolean
    ]]
    function AbstractTargetFrameButton:isRemoving()
        return self.state == 'removing'
    end

    --[[
    Observes all the relevant events that can change the button state.

    Examples of relevant events are the player target changes and the combat
    status changing from entering or leaving combat.
    ]]
    function AbstractTargetFrameButton:observeRelevantEvents()
        local callback = function() self:updateState() end

        MultiTargets.events:listen('PLAYER_ENTERED_COMBAT', callback)
        MultiTargets.events:listen('PLAYER_LEFT_COMBAT', callback)
        MultiTargets.events:listen('TARGET_LIST_REFRESHED', callback)
        MultiTargets.events:listen('PLAYER_TARGET', callback)
        MultiTargets.events:listen('PLAYER_TARGET_CHANGED', callback)        
    end

    --[[
    Callback for the button's click event.
    ]]
    function AbstractTargetFrameButton:onButtonClick()
        if self:isAdding() then
            MultiTargets:invokeOnCurrent('addTargetted')
        else
            -- this is the only other state, so we don't need to check
            -- if it's removing, however, we could add a check here
            -- if we add more states in the future
            MultiTargets:invokeOnCurrent('removeTargetted')
        end

        self:updateState()
    end

    --[[
    Updates the button's state to adding.
    ]]
    function AbstractTargetFrameButton:turnAddState()
        self.button:SetText('+ add target')
        self.state = 'adding'
    end

    --[[
    Updates the button's state to removing.
    ]]
    function AbstractTargetFrameButton:turnRemoveState()
        self.button:SetText('- remove target')
        self.state = 'removing'
    end

    --[[
    Updates the button's state based on the current target.
    
    If the current target is in the target list, the button will be in the
    removing state, otherwise, it will be in the adding state.
    ]]
    function AbstractTargetFrameButton:updateState()
        self:updateVisibility()

        local targetName = MultiTargets.target:getName()

        if not targetName then return end

        if MultiTargets.currentTargetList:has(targetName) then
            self:turnRemoveState()
            return
        end

        self:turnAddState()
    end

    --[[
    Updates the button's visibility based on the criteria to determine if
    the button should be shown or hidden.
    ]]
    function AbstractTargetFrameButton:updateVisibility()
        if MultiTargets.currentPlayer.inCombat then
            self.button:Hide()
            return
        end

        self.button:Show()
    end
-- end of AbstractTargetFrameButton