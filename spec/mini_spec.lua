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

      local output, error = mini.parse(ini)

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
      }, output)

      assert.is_nil(error)
    end)

    it("returns an error when value definition has no section", function ()
      local ini = [[
        x = 1

        [general]
        override = false
      ]]

      local output, error = mini.parse(ini)
      assert.are.equal(nil, output)
      assert.are.equal("Error: 'x' has no section.", error)
    end)

    it("raises an error with invalid section definition", function ()
      local ini = [[
        [general
        override = false
      ]]

      local output, error = mini.parse(ini)
      assert.are.equal(nil, output)
      assert.are.equal("Invalid line: [general", error)
    end)

    it("raises an error with invalid value definition", function ()
      local ini = [[
        [general]
        override
      ]]

      local output, error = mini.parse(ini)
      assert.are.equal(nil, output)
      assert.are.equal("Invalid line: override", error)
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

      local expected =
        "[graphics]\n" ..
        "height = 768\n" ..
        "vsync = true\n" ..
        "width = 1024\n\n" ..
        "[input]\n" ..
        "left = key:left button:dpleft\n" ..
        "right = key:right button:dpright"

      local output, error = mini.output(config)
      assert.are.equal(expected, output)
      assert.is_nil(error)
    end)

    it("raises an error for invalid section value", function ()
      local config = {
        section = "value",
      }

      local output, error = mini.output(config)
      assert.are.equal(nil, output)
      assert.are.equal("Invalid value for section 'section'. Section values must be tables.", error)
    end)

    it("raises an error when key is not string", function ()
      local config = {
        section = {
          [1] = "value",
        }
      }

      local output, error = mini.output(config)
      assert.are.equal(nil, output)
      assert.are.equal("Invalid key '1'. Keys must be strings.", error)
    end)

    it("raises an error when value is defined as function", function ()
      local config = {
        section = {
          key = function() end
        }
      }

      local output, error = mini.output(config)
      assert.are.equal(nil, output)
      assert.are.equal("Invalid value for key 'key'. Values cannot be functions.", error)
    end)

    it("raises an error when value is defined as a table", function ()
      local config = {
        section = {
          key = {}
        }
      }

      local output, error = mini.output(config)
      assert.are.equal(nil, output)
      assert.are.equal("Invalid value for key 'key'. Sections cannot be nested.", error)
    end)
  end)
end)
