expose("mini API", function ()
  _G.mini = require("mini")

  it("can be imported", function ()
    assert.are.equal(type(mini), "table")
    assert.are.equal(type(mini.parse), "function")
    assert.are.equal(type(mini.output), "function")
    assert.are_not.equal(mini, nil)
  end)
end)

describe("mini", function ()
  describe("parse", function ()
    it("parses valid INI into a table", function ()
      local ini = [[
        ; configuration for graphics
        [graphics]
        width = 1024     ; width of the window
        height = 768     ; height of the window
        vsync = true

        [input]
        left = key:left button:dpleft
        right = key:right button:dpright
      ]]

      assert.are_same({
        graphics = {
          width = "1024",
          height = "768",
          vsync = "true",
        },
        input = {
          left = "key:left button:dpleft",
          right = "key:right button:dpright",
        },
      }, mini.parse(ini))
    end)

    it("raises an error when value definition has no section", function ()
      local ini = [[
        x = 1

        [general]
        override = false
      ]]

      assert.has_error(
        function() mini.parse(ini) end,
        "Error: 'x' has no section."
      )
    end)

    it("raises an error with invalid section definition", function ()
      local ini = [[
        [general
        override = false
      ]]

      assert.has_error(
        function() mini.parse(ini) end,
        "Invalid line: [general"
      )
    end)

    it("raises an error with invalid value definition", function ()
      local ini = [[
        [general]
        override
      ]]

      assert.has_error(
        function() mini.parse(ini) end,
        "Invalid line: override"
      )
    end)
  end)

  describe("output", function ()
    it("outputs INI from valid table", function ()
      local config = {
        graphics = {
          width = "1024",
          height = "768",
          vsync = "true",
        },
        input = {
          left = "key:left button:dpleft",
          right = "key:right button:dpright",
        },
      }

      local output =
        "[graphics]\n" ..
        "height = 768\n" ..
        "vsync = true\n" ..
        "width = 1024\n\n" ..
        "[input]\n" ..
        "left = key:left button:dpleft\n" ..
        "right = key:right button:dpright"

      assert.are.equal(output, mini.output(config))
    end)

    it("raises an error for invalid section value", function ()
      local config = {
        section = "value",
      }
      assert.has_error(
        function() mini.output(config) end,
        "Invalid value for section 'section'. Section values must be tables."
      )
    end)

    it("raises an error when key is not string", function ()
      local config = {
        section = {
          [1] = "value",
        }
      }
      assert.has_error(
        function() mini.output(config) end,
        "Invalid key '1'. Keys must be strings."
      )
    end)

    it("raises an error when value is defined as function", function ()
      local config = {
        section = {
          key = function() end
        }
      }
      assert.has_error(
        function() mini.output(config) end,
        "Invalid value for key 'key'. Values cannot be functions."
      )
    end)

    it("raises an error when value is defined as a table", function ()
      local config = {
        section = {
          key = {}
        }
      }
      assert.has_error(
        function() mini.output(config) end,
        "Invalid value for key 'key'. Sections cannot be nested."
      )
    end)
  end)
end)
