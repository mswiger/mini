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

function mini.parse(input)
  local lines = split(trim(input), "\r?\n")
  local data = {}
  local currentSection = data

  for _, line in ipairs(lines) do
    -- remove comments
    line = trim(split(line, ";")[1])

    local section = string.match(line, "^%[(%w+)%]$")
    if section then
      if not data[section] then
        data[section] = {}
      end
      currentSection = data[section]
    elseif string.match(line, "^%w+%s*=%s*.+$") then
      local kv = split(line, "=")
      local key = trim(kv[1])
      local value = trim(kv[2])

      currentSection[key] = value
    elseif #line > 0 then
      error("Invalid line: " .. line)
    end
  end

  return data
end

function mini.output(input)
  local function processSection(name, values, topLevel)
    local lines = {}

    if name then
      table.insert(lines, "[" .. name .. "]")
    end
    
    for key, value in pairs(values) do
      if type(key) ~= "string" then
        error("Invalid key '" .. key .."'. Keys must be strings.")
      end

      if type(value) == "function" then
        error("Invalid value for key '" .. key .. "'. Values cannot be functions.")
      elseif type(value) == "table" then
        if not topLevel then
          error("Invalid value for key '" .. key .. "'. Sections cannot be nested.")
        end
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
    end
  end

  local output = {}
  table.insert(output, processSection(nil, input, true))

  for key, value in pairs(sections) do
    table.insert(output, processSection(key, value, false))
  end

  return table.concat(output, "\n\n")
end

return mini
