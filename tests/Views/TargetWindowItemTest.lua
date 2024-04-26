TestTargetWindowItem = BaseTestClass:new()
    -- @covers TargetWindowItem:__construct()
    function TestTargetWindowItem:testConstruct()
        local target = MultiTargets.__:new('MultiTargetsTarget', 'test-target')

        local instance = MultiTargets.__:new('MultiTargetsTargetWindowItem', target)

        lu.assertNotNil(instance)
        lu.assertEquals(instance.target, target)
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

        lu.assertIsTrue(instance.createRaidMarkerInvoked)
        lu.assertIsTrue(instance.createLabelInvoked)
        lu.assertIsTrue(instance.createRemoveButtonInvoked)
    end

    -- @covers TargetWindowItem:createLabel()
    function TestTargetWindowItem:testCreateLabel()
        local target = MultiTargets.__:new('MultiTargetsTarget', 'test-target')

        local instance = MultiTargets.__:new('MultiTargetsTargetWindowItem', target)

        instance.frame = CreateFrame()

        local result = instance:createLabel()

        lu.assertEquals(instance.label, result)
        lu.assertEquals(result.fontFamily, 'Fonts\\ARIALN.ttf')
        lu.assertEquals(result.fontSize, 14)
        lu.assertEquals(result.text, 'test-target')
        lu.assertEquals(result.points, {
            LEFT = {
                relativeFrame = instance.raidMarker,
                relativePoint = 'LEFT',
                xOfs = 20,
                yOfs = 0,
            },
        })
    end
-- end of TestTargetWindowItem