# Mini
Mini is a tiny INI parser written in Lua.

## API and Usage
Mini provides two functions for working with INI files:

1. `mini.parse` - Parses a string that represents an INI configuration into a Lua table that represents that same configuration. The output table contains one string key per section present in the INI file, which in turn maps to another table of key-value pairs for the values listed under the respective section.
2. `mini.output` - Outputs a string representation of an INI configuration from the given Lua table. The given Lua table must be structed as a list of sections where each section is a set of key-value pairs. In order to maintain consistency of results, sections will be output in alphabetical order, and key-value pairs output in alphabetical order based on the key.

## Examples

### mini.parse
```lua
local mini = require("mini")

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

local config = mini.parse(ini)

-- value of config is now:
{
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
```

### mini.output
```lua
local mini = require("mini")

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

local output = mini.output(config)
print(output)
```
```
[graphics]
height = 768
vsync = true
width = 1024

[input]
left = key:left button:dpleft
right = key:right button:dpright
```
