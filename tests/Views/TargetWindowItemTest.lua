TestTargetWindowItem = BaseTestClass:new()
    -- @covers TargetWindowItem:__construct()
    function TestTargetWindowItem:testConstruct()
        local instance = MultiTargets.__:new('MultiTargetsTargetWindowItem')

        lu.assertNotNil(instance)
    end

    -- @covers TargetWindowItem:create()
    function TestTargetWindowItem:testCreate()
        local instance = MultiTargets.__:new('MultiTargetsTargetWindowItem')

        instance.createFrame = function() instance.createFrameInvoked = true end

        local result = instance:create()

        lu.assertIsTrue(instance.createFrameInvoked)
        lu.assertEquals(result, instance)
    end

    -- @covers TargetWindowItem:createFrame()
    function TestTargetWindowItem:testCreateFrame()
        local instance = MultiTargets.__:new('MultiTargetsTargetWindowItem')

        instance.createRaidMarker = function() instance.createRaidMarkerInvoked = true end
        instance.createLabel = function() instance.createLabelInvoked = true end
        instance.createRemoveButton = function() instance.createRemoveButtonInvoked = true end

        local result = instance:createFrame()

        lu.assertEquals(instance.frame, result)

        lu.assertEquals(result.backdrop, {
            bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
            edgeFile = '',
            edgeSize = 4,
            insets = {left = 5, right = 1, top = 1, bottom = 1},
        })
        lu.assertEquals(result.backdropColor, {0, 0, 0, .2})
        lu.assertEquals(result.height, 30)
        lu.assertIsTrue(result.hideInvoked)

        lu.assertIsTrue(instance.createRaidMarkerInvoked)
        lu.assertIsTrue(instance.createLabelInvoked)
        lu.assertIsTrue(instance.createRemoveButtonInvoked)
    end

    -- @covers TargetWindowItem:createLabel()
    function TestTargetWindowItem:testCreateLabel()
        local instance = MultiTargets.__:new('MultiTargetsTargetWindowItem')

        instance.frame = CreateFrame()

        local result = instance:createLabel()

        lu.assertEquals(instance.label, result)
        lu.assertEquals(result.fontFamily, 'Fonts\\ARIALN.ttf')
        lu.assertEquals(result.fontSize, 14)
        lu.assertEquals(result.text, '')
        lu.assertEquals(result.points, {
            LEFT = {
                relativeFrame = instance.raidMarker,
                relativePoint = 'LEFT',
                xOfs = 20,
                yOfs = 0,
            },
        })
    end

    -- @covers TargetWindowItem:createRaidMarker()
    function TestTargetWindowItem:testCreateRaidMarker()
        local target = MultiTargets.__:new('MultiTargetsTarget', '')
        target.raidMarker.getPrintableString = function() return 'test-raid-marker' end

        local instance = MultiTargets.__:new('MultiTargetsTargetWindowItem', target)

        instance.frame = CreateFrame()

        local result = instance:createRaidMarker()

        lu.assertEquals(instance.raidMarker, result)
        lu.assertEquals(result.fontFamily, 'Fonts\\ARIALN.ttf')
        lu.assertEquals(result.fontSize, 14)
        lu.assertEquals(result.points, {
            LEFT = {
                relativeFrame = instance.frame,
                relativePoint = 'LEFT',
                xOfs = 10,
                yOfs = 0,
            },
        })
        lu.assertEquals(result.text, 'test-raid-marker')
    end

    -- @covers TargetWindowItem:createRemoveButton()
    function TestTargetWindowItem:testCreateRemoveButton()
        local instance = MultiTargets.__:new('MultiTargetsTargetWindowItem')

        instance.frame = CreateFrame()

        local result = instance:createRemoveButton()

        lu.assertEquals(instance.removeButton, result)
        lu.assertEquals(result.points, {
            RIGHT = {
                relativeFrame = instance.frame,
                relativePoint = 'RIGHT',
                xOfs = -5,
                yOfs = 0,
            },
        })
        lu.assertNotIsNil(result.scripts['OnClick'])
        lu.assertEquals(result.text, 'Remove')
        lu.assertEquals(result.width, 60)
    end

    -- @covers TargetWindowItem:onRemoveClick()
    function TestTargetWindowItem:testOnRemoveClick()
        local target = MultiTargets.__:new('MultiTargetsTarget', 'test-target')
        
        ---@diagnostic disable-next-line: duplicate-set-field
        function MultiTargets:invokeOnCurrent(operation, targetName)
            self.operationArg = operation
            self.targetNameArg = targetName
        end

        local instance = MultiTargets.__:new('MultiTargetsTargetWindowItem', target)

        instance:onRemoveClick()

        lu.assertEquals(MultiTargets.operationArg, 'remove')
        lu.assertEquals(MultiTargets.targetNameArg, 'test-target')
    end
-- end of TestTargetWindowItem