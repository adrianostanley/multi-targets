TestCommands = {}
    -- @covers src/Commands/AddCurrentTargetCommand.lua
    -- @covers src/Commands/ClearTargetListCommand.lua
    function TestCommands:testCommandsWereAdded()
        local operations = MultiTargets.__.commands.operations

        local arr = MultiTargets.__.arr
        lu.assertNotIsNil(arr:get(operations, 'add'))
        lu.assertNotIsNil(arr:get(operations, 'addt'))
        lu.assertNotIsNil(arr:get(operations, 'clear'))
        lu.assertNotIsNil(arr:get(operations, 'print'))
        lu.assertNotIsNil(arr:get(operations, 'removet'))
    end
-- end of TestCommands