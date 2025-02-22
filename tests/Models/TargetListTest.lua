TestTargetList = BaseTestClass:new()
    -- @covers TargetList:add()
    function TestTargetList:testAdd()
        local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')
        targetList.refreshState = function (self, action)
            targetList.actionArg = action
            targetList.refreshStateInvoked = true
        end

        lu.assertIsNil(targetList.actionArg)
        lu.assertIsNil(targetList.refreshStateInvoked)

        local addedMessage = 'test-new-target added to the target list'
        local alreadyAddedMessage = 'test-new-target is already in the target list'

        lu.assertIsFalse(MultiTargets.output:printed(addedMessage))
        lu.assertIsFalse(MultiTargets.output:printed(alreadyAddedMessage))

        -- will try two times to test if add() won't add duplicate names
        targetList:add('test-new-target')
        lu.assertIsTrue(MultiTargets.output:printed(addedMessage))
        lu.assertIsFalse(MultiTargets.output:printed(alreadyAddedMessage))
        targetList:add('test-new-target')
        lu.assertIsTrue(MultiTargets.output:printed(alreadyAddedMessage))

        local expectedTargets = MultiTargets:new('MultiTargets/Target', 'test-new-target')

        lu.assertEquals({expectedTargets}, targetList.targets)
        lu.assertEquals('add', targetList.actionArg)
        lu.assertIsTrue(targetList.refreshStateInvoked)
    end

    -- @covers TargetList:add()
    -- @covers TargetList:remove()
    function TestTargetList:testAddAndRemoveWithInvalidName()
        local function execution(method, name)
            -- @TODO: Remove this once every test resets the MultiTargets
            -- instance, even for test with providers <2024.04.09>
            MultiTargets.output.history = {}

            local message = 'Invalid target name'

            local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')
    
            lu.assertIsFalse(MultiTargets.output:printed(message))
    
            targetList[method](name)
            
            lu.assertTrue(MultiTargets.output:printed(message))
        end

        execution('add', nil)
        execution('add', '')
        execution('add', ' ')
        execution('remove', nil)
        execution('remove', '')
        execution('remove', ' ')
    end

    -- @covers TargetList:addTargetted()
    function TestTargetList:testAddTargetted()
        local function execution(targettedName, shouldInvokeAdd)
            local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')
            targetList.addInvoked = false
            targetList.add = function () targetList.addInvoked = true end

            MultiTargets.target = {
                getName = function () return targettedName end
            }

            targetList:addTargetted()

            lu.assertEquals(shouldInvokeAdd, targetList.addInvoked)
        end

        execution('test-target-1', true)
        execution(nil, false)
    end

    -- @covers TargetList:canBeInvoked()
    function TestTargetList:testCanBeInvoked()
        local function execution(methodName, targetListCanBeUpdated, shouldBeAbleToInvoke)
            local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')
            targetList.canBeUpdated = function () return targetListCanBeUpdated end

            local canBeInvoked = targetList:canBeInvoked(methodName)

            lu.assertEquals(shouldBeAbleToInvoke, canBeInvoked)
        end

        -- target list can be updated, so any method can be invoked
        execution('testMethod', true, true)

        -- target list can't be updated, so only safe methods can be invoked
        execution('testMethod', false, false)

        -- target list can't be updated, but method is safe
        execution('maybeMark', false, true)
    end

    -- @covers TargetList:canBeUpdated()
    function TestTargetList:testCanBeUpdated()
        local function execution(playerInCombat, expectedResult)
            MultiTargets.currentPlayer.inCombat = playerInCombat

            local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')

            lu.assertEquals(expectedResult, targetList:canBeUpdated())
        end

        -- player is in combat, so it can't be updated
        execution(true, false)

        -- player is not in combat, so it can be updated
        execution(false, true)
    end

    -- @covers TargetList:clear()
    function TestTargetList:testClear()
        local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')
        targetList.save = function () targetList.saveInvoked = true end
        targetList.targets = {MultiTargets:new('MultiTargets/Target', 'test-new-target')}
        targetList.current = 1

        lu.assertIsNil(targetList.saveInvoked)

        targetList:clear()

        lu.assertEquals({}, targetList.targets)
        lu.assertEquals(0, targetList.current)
        lu.assertIsTrue(targetList.saveInvoked)
        lu.assertTrue(MultiTargets.output:printed('Target list cleared successfully'))
    end

    -- @covers TargetList:currentIsValid()
    function TestTargetList:testCurrentIsValid()
        local execution = function (targets, current, expectedResult)
            local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')

            targetList.targets = targets
            targetList.current = current
        
            lu.assertEquals(expectedResult, targetList:currentIsValid())
        end

        execution({}, 0, false)
        execution({'t-1'}, 0, false)
        execution({'t-1'}, 1, true)
        execution({'t-1'}, 2, false)
        execution({'t-1', 't-2'}, 2, true)
        execution({'t-1', 't-2'}, 3, false)
    end

    -- @covers TargetList:has()
    function TestTargetList:testHas()
        local targetA = MultiTargets:new('MultiTargets/Target', 'test-target-1')
        local targetB = MultiTargets:new('MultiTargets/Target', 'test-target-2')
        local targetC = MultiTargets:new('MultiTargets/Target', 'test-target-3')

        local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')
        targetList.targets = {targetA, targetB}

        lu.assertIsTrue(targetList:has('test-target-1'))
        lu.assertIsTrue(targetList:has(targetA))

        lu.assertIsFalse(targetList:has('test-target-3'))
        lu.assertIsFalse(targetList:has(targetC))
    end

    -- @covers TargetList.__construct()
    function TestTargetList:testInstantiation()
        local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')

        lu.assertNotIsNil(targetList)
        lu.assertEquals('default', targetList.listName)
        lu.assertEquals({}, targetList.targets)
    end

    -- @covers TargetList.invoke()
    function TestTargetList:testInvoke()
        local function execution(methodCanBeInvoked, expectedOutput)
            local targetList = MultiTargets:new('MultiTargets/TargetList', 'test-list-name')
            targetList.canBeInvoked = function () return methodCanBeInvoked end

            -- an instance method to fully test the invoke call
            function targetList:testMethod(arg1) return self.listName..' - '..arg1 end

            local output = targetList:invoke('testMethod', 'test-arg')

            lu.assertEquals(expectedOutput, output)
        end

        -- target list can be updated, so the method is invoked
        execution(true, 'test-list-name - test-arg')

        -- target list can't be updated, so the method is not invoked
        execution(false, nil)
    end

    -- @covers TargetList.isCurrent()
    function TestTargetList:testIsCurrent()
        local function execution(targetList, currentIndex, targetToCheck, expectedResult)
            targetList.current = currentIndex

            lu.assertEquals(expectedResult, targetList:isCurrent(targetToCheck))
        end

        local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')

        -- with no targets, it should return false
        execution(targetList, 0, '', false)

        targetList:add('test-target-1')

        -- with a target, but invalid index, it should return false
        execution(targetList, 0, 'test-target-1', false)

        targetList:add('test-target-2')

        -- with multiple targets, but target is not the current, it should return false
        execution(targetList, 1, 'test-target-2', false)

        -- with multiple targets, and target is the current, it should return true
        execution(targetList, 2, 'test-target-2', true)

        -- with multiple targets, and target is an instance
        execution(targetList, 2, MultiTargets:new('MultiTargets/Target', 'test-target-2'), true)
    end

    -- @covers TargetList:isEmpty()
    function TestTargetList:testIsEmpty()
        local execution = function (targets, expectedResult)
            local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')
        
            targetList.targets = targets
        
            lu.assertEquals(expectedResult, targetList:isEmpty())
        end

        execution({}, true)
        execution({'t-1'}, false)
    end

    -- @covers TargetList:load()
    function TestTargetList:testLoad()
        local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')

        targetList.maybeInitializeData = function () targetList.invokedMaybeInitializeData = true end
        targetList.loadTargets = function () targetList.invokedLoadTargets = true end
        targetList.loadCurrentIndex = function () targetList.invokedLoadCurrentIndex = true end
        targetList.refreshState = function (self, action)
            targetList.actionArg = action
            targetList.invokedRefreshState = true
        end

        lu.assertIsNil(targetList.actionArg)
        lu.assertIsNil(targetList.invokedMaybeInitializeData)
        lu.assertIsNil(targetList.invokedLoadTargets)
        lu.assertIsNil(targetList.invokedLoadCurrentIndex)
        lu.assertIsNil(targetList.invokedRefreshState)

        targetList:load()

        lu.assertEquals('load', targetList.actionArg)
        lu.assertIsTrue(targetList.invokedMaybeInitializeData)
        lu.assertIsTrue(targetList.invokedLoadTargets)
        lu.assertIsTrue(targetList.invokedLoadCurrentIndex)
        lu.assertIsTrue(targetList.invokedRefreshState)
    end

    -- @covers TargetList:loadCurrentIndex()
    function TestTargetList:testLoadCurrentIndex()
        MultiTargets:playerConfig({['lists.default.current'] = 2})

        local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')

        lu.assertEquals(0, targetList.current)

        targetList:loadCurrentIndex()

        lu.assertEquals(2, targetList.current)
    end

    -- @covers TargetList:loadTargets()
    function TestTargetList:testLoadTargets()
        MultiTargets:playerConfig({['lists.default.targets'] = {
            'test-target-1',
            'test-target-2',
            'test-target-3',
        }})

        local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')

        lu.assertEquals(0, #targetList.targets)

        targetList:loadTargets()

        local targets = targetList.targets

        lu.assertEquals({
            MultiTargets:new('MultiTargets/Target', 'test-target-1'),
            MultiTargets:new('MultiTargets/Target', 'test-target-2'),
            MultiTargets:new('MultiTargets/Target', 'test-target-3'),
        }, targets)
    end

    -- @covers TargetList:maybeInitializeData()
    function TestTargetList:testMaybeInitializeData()
        local targetList = MultiTargets:new('MultiTargets/TargetList', 'test-target-list')

        lu.assertIsNil(MultiTargets:playerConfig(targetList.targetsDataKey))
        lu.assertIsNil(MultiTargets:playerConfig(targetList.currentDataKey))

        targetList:maybeInitializeData()

        lu.assertEquals({}, MultiTargets:playerConfig(targetList.targetsDataKey))
        lu.assertEquals(0, MultiTargets:playerConfig(targetList.currentDataKey))
    end

    -- @covers TargetList:maybeMark()
    function TestTargetList:testMaybeMark()
        local target1 = MultiTargets:new('MultiTargets/Target', 'test-target-1')
        local target2 = MultiTargets:new('MultiTargets/Target', 'test-target-2')
        local target3 = MultiTargets:new('MultiTargets/Target', 'test-target-3')

        target1.maybeMark = function () target1.invokedMaybeMark = true return false end
        target2.maybeMark = function () target2.invokedMaybeMark = true return true end
        target3.maybeMark = function () target3.invokedMaybeMark = true return false end

        local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')

        targetList.targets = {target1, target2, target3}

        lu.assertIsNil(target1.invokedMaybeMark)
        lu.assertIsNil(target2.invokedMaybeMark)
        lu.assertIsNil(target3.invokedMaybeMark)

        targetList:maybeMark()

        lu.assertIsTrue(target1.invokedMaybeMark)
        lu.assertIsTrue(target2.invokedMaybeMark)
        lu.assertIsNil(target3.invokedMaybeMark)
    end

    -- @covers TargetList:print()
    function TestTargetList:testPrint()
        local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')
        
        targetList:print()

        lu.assertTrue(MultiTargets.output:printed('There are no targets in the target list'))
        
        local targetA = MultiTargets:new('MultiTargets/Target', 'test-target-a')
        local targetB = MultiTargets:new('MultiTargets/Target', 'test-target-b')

        targetList.targets = {targetA, targetB}

        targetList:print()

        lu.assertTrue(MultiTargets.output:printed('Target #1 - ' .. targetA:getPrintableString()))
        lu.assertTrue(MultiTargets.output:printed('Target #2 - ' .. targetB:getPrintableString()))
    end

    -- @covers TargetList:refreshState()
    function TestTargetList:testRefreshState()
        local sanitizeCurrentInvoked = false
        local sanitizeMarksInvoked = false
        local saveInvoked = false
        local updateMacroWithCurrentTargetInvoked = false

        local eventActionArg = nil
        local eventBroadcasted = nil
        local eventTargetListInstance = nil

        MultiTargets.events.notify = function (self, event, targetList, action)
            eventBroadcasted = event
            eventTargetListInstance = targetList
            eventActionArg = action
        end

        local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')

        targetList.sanitizeCurrent = function () sanitizeCurrentInvoked = true end
        targetList.sanitizeMarks = function () sanitizeMarksInvoked = true end
        targetList.save = function () saveInvoked = true end
        targetList.updateMacroWithCurrentTarget = function () updateMacroWithCurrentTargetInvoked = true end

        targetList:refreshState('test-action')

        lu.assertIsTrue(sanitizeCurrentInvoked)
        lu.assertIsTrue(sanitizeMarksInvoked)
        lu.assertIsTrue(saveInvoked)
        lu.assertIsTrue(updateMacroWithCurrentTargetInvoked)

        lu.assertEquals('TARGET_LIST_REFRESHED', eventBroadcasted)
        lu.assertEquals(targetList, eventTargetListInstance)
        lu.assertEquals('test-action', eventActionArg)
    end

    -- @covers TargetList:remove()
    function TestTargetList:testRemove()
        local function execution(targets, name, expectedTargets, expectedOutput)
            -- @TODO: Remove this once every test resets the MultiTargets instance <2024.04.09>
            MultiTargets.output.history = {}

            local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')
            targetList.targets = targets
            targetList.refreshState = function (self, action)
                targetList.actionArg = action
                targetList.refreshStateInvoked = true
            end

            targetList:remove(name)

            lu.assertEquals(expectedTargets, targetList.targets)
            lu.assertEquals('remove', targetList.actionArg)
            lu.assertIsTrue(targetList.refreshStateInvoked)
            lu.assertTrue(MultiTargets.output:printed(expectedOutput))
        end

        local targetA = MultiTargets:new('MultiTargets/Target', 'test-target-a')
        local targetB = MultiTargets:new('MultiTargets/Target', 'test-target-b')

        execution({}, 'test-target-1', {}, 'test-target-1 is not in the target list')
        execution({targetA}, 'test-target-a', {}, 'test-target-a removed from the target list')
        execution({targetA}, 'test-target-b', {targetA}, 'test-target-b is not in the target list')
        execution({targetA, targetB}, 'test-target-a', {targetB}, 'test-target-a removed from the target list')
    end

    -- @covers TargetList:removeTargetted()
    function TestTargetList:testRemoveTargetted()
        local function execution(targettedName, shouldInvokeRemove)
            local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')
            targetList.removeInvoked = false
            targetList.remove = function () targetList.removeInvoked = true end

            MultiTargets.target = {
                getName = function () return targettedName end
            }

            targetList:removeTargetted()

            lu.assertEquals(shouldInvokeRemove, targetList.removeInvoked)
        end

        execution('test-target-1', true)
        execution(nil, false)
    end

    -- @covers TargetList:rotate()
    function TestTargetList:testRotate()
        local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')

        targetList.refreshState = function (self, action)
            targetList.actionArg = action
            targetList.refreshStateInvoked = true
        end

        targetList.current = 5

        targetList:rotate()

        lu.assertEquals(6, targetList.current)
        lu.assertEquals('rotate', targetList.actionArg)
        lu.assertIsTrue(targetList.refreshStateInvoked)
    end

    -- @covers TargetList:sanitizeCurrent()
    function TestTargetList:testSanitizeCurrent()
        local function execution(isEmpty, currentIsValid, current, expectedCurrent)
            local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')
        
            targetList.isEmpty = function () return isEmpty end
            targetList.currentIsValid = function () return currentIsValid end
            targetList.current = current
        
            targetList:sanitizeCurrent()
        
            lu.assertEquals(expectedCurrent, targetList.current)
        end

        -- isEmpty, so current must be zero
        execution(true, true, 1, 0)

        -- current is valid, so current must be not changed
        execution(false, true, 1, 1)

        -- is not empty and current is not valid, so it resets
        execution(false, false, 2, 1)
    end

    -- @covers TargetList:sanitizeMarks()
    function TestTargetList:testSanitizeMarks()
        local targetA = MultiTargets:new('MultiTargets/Target', 'test-target-1')
        local targetB = MultiTargets:new('MultiTargets/Target', 'test-target-2')
        local targetC = MultiTargets:new('MultiTargets/Target', 'test-target-3')

        local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')
        targetList.targets = {targetA, targetB, targetC}

        targetList:sanitizeMarks()

        lu.assertEquals(MultiTargets.raidMarkers.skull, targetA.raidMarker)
        lu.assertEquals(MultiTargets.raidMarkers.x, targetB.raidMarker)
        lu.assertEquals(MultiTargets.raidMarkers.square, targetC.raidMarker)
    end

    -- @covers TargetList:save()
    function TestTargetList:testSave()
        local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')

        local targetA = MultiTargets:new('MultiTargets/Target', 'test-target-a')
        local targetB = MultiTargets:new('MultiTargets/Target', 'test-target-b')

        targetList.targets = {targetA, targetB}
        targetList.current = 2

        targetList:save()

        lu.assertEquals({'test-target-a', 'test-target-b'}, MultiTargets:playerConfig(targetList.targetsDataKey))
        lu.assertEquals(2, MultiTargets:playerConfig(targetList.currentDataKey))
    end

    --[[
    @covers TargetList:updateMacroWithCurrentTarget()
    ]]
    function TestTargetList:testUpdateMacroWithCurrentTarget()
        local targetA = MultiTargets:new('MultiTargets/Target', 'test-target-1')
        local targetB = MultiTargets:new('MultiTargets/Target', 'test-target-1')

        targetA.updateMacro = function () targetA.invoked = true end
        targetB.updateMacro = function () targetB.invoked = true end

        local targetList = MultiTargets:new('MultiTargets/TargetList', 'default')
        targetList.targets = {targetA, targetB}
        targetList.updateMacroWithDefault = function () targetList.updateMacroWithDefaultInvoked = true end

        lu.assertIsNil(targetList.updateMacroWithDefaultInvoked)

        targetList:updateMacroWithCurrentTarget()

        lu.assertIsTrue(targetList.updateMacroWithDefaultInvoked)

        lu.assertIsNil(targetA.invoked)
        lu.assertIsNil(targetB.invoked)

        targetList.current = 1

        targetList:updateMacroWithCurrentTarget()

        lu.assertIsTrue(targetA.invoked)
        lu.assertIsNil(targetB.invoked)

        targetList.current = 2

        targetList:updateMacroWithCurrentTarget()

        lu.assertIsTrue(targetB.invoked)
    end

    -- @covers TargetList:updateMacroWithDefault()
    function TestTargetList:testUpdateMacroWithDefault()
        local macro = {
            updateMacro = function (self, macroBody)
                self.updateMacroInvoked = true
                self.macroBody = macroBody
            end
        }

        local targetList = MultiTargets:new('MultiTargets/TargetList', 'test-name')

        function MultiTargets:new(className)
            if className == 'MultiTargets/Macro' then
                return macro
            end
        end

        targetList:updateMacroWithDefault()

        lu.assertIsTrue(macro.updateMacroInvoked)
        lu.assertEquals("/run MultiTargets:out('There are no names in the target list')", macro.macroBody)
    end
-- end of TestTargetList