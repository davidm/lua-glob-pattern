--[[
 p = globtopattern(g)

 Converts glob string (g) into Lua pattern string (p).
 Always succeeds.

 Warning: This might not completely conform to POSIX or other specifications.
 Further validation should be done on syntax implemented.

 (c) 2008 D.Manura, Licensed under the same terms as Lua (MIT License).
--]]

local M = {_TYPE='module', _NAME='globtopattern', _VERSION='0.2.2008'}

function M.globtopattern(g)
  -- Some useful references:
  -- - apr_fnmatch in Apache APR.  For example,
  --   http://apr.apache.org/docs/apr/1.3/group__apr__fnmatch.html
  --   which cites POSIX 1003.2-1992, section B.6.

  local p = "^"  -- pattern being built
  local i = 0    -- index in g
  local c        -- char at index i in g.

  -- unescape glob char
  local function unescape()
    if c == '\\' then
      i = i + 1; c = g:sub(i,i)
      if c == '' then
        p = '[^]'
        return false
      end
    end
    return true
  end

  -- escape pattern char
  local function escape(c)
    return c:match("^%w$") and c or '%' .. c
  end

  -- Convert tokens at end of charset.
  local function charset_end()
    while 1 do
      if c == '' then
        p = '[^]'
        return false
      elseif c == ']' then
        p = p .. ']'
        break
      else
        if not unescape() then break end
        local c1 = c
        i = i + 1; c = g:sub(i,i)
        if c == '' then
          p = '[^]'
          return false
        elseif c == '-' then
          i = i + 1; c = g:sub(i,i)
          if c == '' then
            p = '[^]'
            return false
          elseif c == ']' then
            p = p .. escape(c1) .. '%-]'
            break
          else
            if not unescape() then break end
            p = p .. escape(c1) .. '-' .. escape(c)
          end
        elseif c == ']' then
          p = p .. escape(c1) .. ']'
          break
        else
          p = p .. escape(c1)
          i = i - 1 -- put back
        end
      end
      i = i + 1; c = g:sub(i,i)
    end
    return true
  end

  -- Convert tokens in charset.
  local function charset()
    i = i + 1; c = g:sub(i,i)
    if c == '' or c == ']' then
      p = '[^]'
      return false
    elseif c == '^' or c == '!' then
      i = i + 1; c = g:sub(i,i)
      if c == ']' then
        -- ignored
      else
        p = p .. '[^'
        if not charset_end() then return false end
      end
    else
      p = p .. '['
      if not charset_end() then return false end
    end
    return true
  end

  -- Convert tokens.
  while 1 do
    i = i + 1; c = g:sub(i,i)
    if c == '' then
      p = p .. '$'
      break
    elseif c == '?' then
      p = p .. '.'
    elseif c == '*' then
      p = p .. '.*'
    elseif c == '[' then
      if not charset() then break end
    elseif c == '\\' then
      i = i + 1; c = g:sub(i,i)
      if c == '' then
        p = p .. '\\$'
        break
      end
      p = p .. escape(c)
    else
      p = p .. escape(c)
    end
  end
  return p
end

return M

--[==[ FILE test.lua

-- tests

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
--]==]
