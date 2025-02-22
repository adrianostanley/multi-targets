TestClassicTargetFrameButton = BaseTestClass:new()
    -- helper method to instantiate the classic implementation
    function TestClassicTargetFrameButton:instance()
        MultiTargets.environment.getClientFlavor = function () return MultiTargets.environment.constants.CLIENT_CLASSIC end
        return MultiTargets:new('MultiTargets/TargetFrameButton')
    end

    -- @covers ClassicTargetFrameButton.__construct()
    function TestClassicTargetFrameButton:testConstructor()
        local targetFrameButton = self:instance()
        targetFrameButton:initialize()

        lu.assertNotNil(targetFrameButton)
        lu.assertNotNil(targetFrameButton.button)
        lu.assertEquals('adding', targetFrameButton.state)
    end
-- end of TestClassicTargetFrameButton