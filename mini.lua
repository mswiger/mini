--[[
Copyright (c) 2026 Michael Swiger

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

local mini = {}

local function split(str, sep)
  local vals = {}
  for val in string.gmatch(str, "([^" .. sep .. "]+)") do
    table.insert(vals, val)
  end
  return vals
end

local function trim(str)
  return string.match(str, "^%s*(.-)%s*$")
end

local function sortKeys(tbl)
  local keys = {}

  for key, _ in pairs(tbl) do
    table.insert(keys, key)
  end

  table.sort(keys)

  return keys
end

--- @alias IniTable { [string]: { [string]: any } }

--- Parse a string representing an INI configuration into a Lua table.
--- @param input string a string that represents an INI configuration
--- @return IniTable # a Lua table representing the parsed configuration
function mini.parse(input)
  local lines = split(trim(input), "\r?\n")
  local data = {}
  local currentSection = nil

  for _, line in ipairs(lines) do
    -- remove comments
    line = trim(line:gsub(";.*", ""))

    local section = string.match(line, "^%[(%w+)%]$")
    if section then
      if not data[section] then
        data[section] = {}
      end
      currentSection = section
    elseif string.match(line, "^%w+%s*=%s*.+$") then
      local kv = split(line, "=")
      local key = trim(kv[1])
      local value = trim(kv[2])

      if not currentSection then
        error("Error: '" .. key .. "' has no section.")
      end


      data[currentSection][key] = value
    elseif #line > 0 then
      error("Invalid line: " .. line)
    end
  end

  return data
end

--- Output a string that represents an INI configuration from the given Lua table
--- @param input IniTable a Lua table that represents an INI configuration
--- @return string # a string that represents the given INI configuration
function mini.output(input)
  local function processSection(name, values)
    local lines = {}

    if name then
      table.insert(lines, "[" .. name .. "]")
    end

    local sortedKeys = sortKeys(values)

    for _, key in ipairs(sortedKeys) do
      if type(key) ~= "string" then
        error("Invalid key '" .. key .."'. Keys must be strings.")
      end

      local value = values[key]

      if type(value) == "function" then
        error("Invalid value for key '" .. key .. "'. Values cannot be functions.")
      elseif type(value) == "table" then
        error("Invalid value for key '" .. key .. "'. Sections cannot be nested.")
      else
        table.insert(lines, key .. " = " .. value)
      end
    end

    return table.concat(lines, "\n")
  end

  local sections = {}
  for key, value in pairs(input) do
    if type(value) == "table" then
      sections[key] = value
    else
      error("Invalid value for section '" .. key .. "'. Section values must be tables.")
    end
  end

  local sortedKeys = sortKeys(sections)
  local output = {}

  for _, key in ipairs(sortedKeys) do
    table.insert(output, processSection(key, sections[key]))
  end

  return table.concat(output, "\n\n")
end

return mini
