--[[ FILE README.txt

LUA MODULE

  globtopattern v$(_VERSION) - convert file glob string to Lua pattern string.

SYNOPSIS
  
  local globtopattern = require 'globtopattern'.globtopattern
  local pat = globtopattern '[a-z]??.htm*' --> ^[a-z]..%.htm.*$
  assert(('a01.html'):match(pat))

DESCRIPTION

  This module converts a file glob expression [1,2] into a Lua pattern, which
  can then be used in Lua's pattern matching function.
  File globs are a common means to match file names.  Roughly in concept,
  ignoring differences in syntax, globs are a subset of Lua patterns which
  are a subset of regular expressions. However, globs sometimes have some
  obscure rules and corner cases (see below) depending on chosen syntax. [3-4]

API  
 
  p = globtopattern(g)

    Converts glob string `g` into Lua pattern string `p`.
    Always succeeds.

  Warning: This might not completely conform to POSIX or other specifications.
  Further validation should be done on syntax implemented.

DEPENDENCIES

  None (other than Lua 5.1 or 5.2).
  
HOME PAGE

  https://raw.github.com/gist/1408288

DOWNLOAD/INSTALL

  If using LuaRocks:
    luarocks install lua-globtopattern

  Otherwise, download <https://raw.github.com/gist/1408288/globtopattern.lua>.
  Alternately, if using git:
    git clone git://gist.github.com/1408288.git lua-globtopattern
    cd lua-globtopattern
  Optionally unpack and install in LuaRocks:
    Download <https://raw.github.com/gist/1422205/sourceunpack.lua>.
    lua sourceunpack.lua globtopattern.lua
    cd out && luarocks make *.rockspec
   
REFERENCES/FOOTNOTES
 
   [1] http://en.wikipedia.org/wiki/Glob_%28programming%29
   [2] http://lua-users.org/wiki/FileGlob
   [3] http://apr.apache.org/docs/apr/1.3/group__apr__fnmatch.html
       Apache APR fnmatch, based on POSIX 1003.2-1992, section B.6
   [4] http://blogs.msdn.com/oldnewthing/archive/2007/12/17/6785519.aspx
       Wildcards in Windows/MSDOS.
       Windows globs are often implemented by calling the FindFileFirst/FindFileNext
       Win32 API calls.  The glob function implemented by Windows
       FindFileFirst/FindFileNext API calls can be especially counterintuitive and
       should sometimes be avoided (e.g. *.txt may match both 1.txt and 1.txt~).
       So, wrapping these API calls in a Lua extension DLL may not be the most desirable
       approach.
 
LICENSE

  (c) 2008-2011 David Manura.  Licensed under the same terms as Lua (MIT).

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  (end license)

--]]---------------------------------------------------------------------

local M = {_TYPE='module', _NAME='globtopattern', _VERSION='0.2.20120103'}

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

--[[ FILE lua-globtopattern-$(_VERSION)-1.rockspec

package = 'lua-globtopattern'
version = '$(_VERSION)-1'
source = {
  url = 'https://raw.github.com/gist/1408288/$(GITID)/globtopattern.lua',
  --url = 'https://raw.github.com/gist/1408288/globtopattern.lua', -- latest raw
  --url = 'https://gist.github.com/gists/1408288/download', -- latest archive
  md5 = '$(MD5)'
}
description = {
  summary = 'Convert glob to Lua string pattern',
  detailed =
    'Convert glob to Lua string pattern.',
  license = 'MIT/X11',
  homepage = 'https://gist.github.com/1408288',
  maintainer = 'David Manura'
}
dependencies = {
  'lua >= 5.1' -- including 5.2
}
build = {
  type = 'builtin',
  modules = {
    ['globtopattern'] = 'globtopattern.lua'
  }
}
--]]---------------------------------------------------------------------


--[==[ FILE test.lua

-- test.lua - tests of globtopattern

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
--]==]
