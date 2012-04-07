-- test.lua - tests of globtopattern

-- 'findbin' -- https://github.com/davidm/lua-find-bin
package.preload.findbin = function()
  local M = {_TYPE='module', _NAME='findbin', _VERSION='0.1.1.20120406'}
  local script = arg and arg[0] or ''
  local bin = script:gsub('[/\\]?[^/\\]+$', '') -- remove file name
  if bin == '' then bin = '.' end
  M.bin = bin
  setmetatable(M, {__call = function(_, relpath) return bin .. relpath end})
  return M
end
package.path = require 'findbin' '/lua/?.lua;' .. package.path

local globtopattern = require 'globtopattern'.globtopattern

-- text only
local p = globtopattern("")
assert(p == '^$')
local p = globtopattern("abc")
assert(p == '^abc$')
-- escaping in pattern
local p = globtopattern("ab#/.")
assert(p == '^ab%#%/%.$')
-- escaping in glob
local p = globtopattern("\\\\\\ab\\c\\")
assert(p == '^%\\abc\\$')

-- basic * and ?
local p = globtopattern("abc.*")
assert(p == '^abc%..*$')
assert(("abc.txt"):match(p))
assert(("abc."):match(p))
assert(not("abc"):match(p))
local p = globtopattern("??.txt")
assert(p == '^..%.txt$')

-- character sets
-- trivial
local p = globtopattern("a[]")
assert(p == '[^]')
local p = globtopattern("a[^]b")
assert(p == '^ab$')
local p = globtopattern("a[!]b")
assert(p == '^ab$')
-- normal
local p = globtopattern("a[a][b]z")
assert(p == '^a[a][b]z$')
local p = globtopattern("a[a-f]z")
assert(p == '^a[a-f]z$')
local p = globtopattern("a[a-f0-9]z")
assert(p == '^a[a-f0-9]z$')
local p = globtopattern("a[a-f0-]z")
assert(p == '^a[a-f0%-]z$')  --correct?
local p = globtopattern("a[!a-f]z")
assert(p == '^a[^a-f]z$')
local p = globtopattern("a[^a-f]z")
assert(p == '^a[^a-f]z$')
local p = globtopattern("a[\\!\\^\\-z\\]]z")
assert(p == '^a[%!%^%-z%]]z$')
local p = globtopattern("a[\\a-\\f]z")
assert(p == '^a[a-f]z$')
-- broken char sets - never match
local p = globtopattern("a[")
assert(p == '[^]')
local p = globtopattern("a[a-")
assert(p == '[^]')
local p = globtopattern("a[a-b")
assert(p == '[^]')
local p = globtopattern("a[!")
assert(p == '[^]')
local p = globtopattern("a[!a")
assert(p == '[^]')
local p = globtopattern("a[!a-")
assert(p == '[^]')
local p = globtopattern("a[!a-b")
assert(p == '[^]')
local p = globtopattern("a[!a-b\\]")
assert(p == '[^]')

print 'DONE'
