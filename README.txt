LUA MODULE

  globtopattern v$(_VERSION) - converts file glob string to Lua pattern string.

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

  https://github.com/davidm/lua-glob-pattern

DOWNLOAD/INSTALL

  To install using LuaRocks:
  
    luarocks install lua-glob-pattern

  Otherwise, download <https://github.com/davidm/lua-glob-pattern>.
  
  You may simply copy globtopattern.lua into your LUA_PATH.
  
  Otherwise:
  
    make test
    make install  (or make install-local)  -- to install into LuaRocks
    make remove  (or make remove-local)  -- to remove from LuaRocks
   
REFERENCES/FOOTNOTES
 
   [1] http://en.wikipedia.org/wiki/Glob_%28programming%29
   [2] http://lua-users.org/wiki/FileGlob
   [3] http://apr.apache.org/docs/apr/1.3/group__apr__fnmatch.html
       Apache APR fnmatch, based on POSIX 1003.2-1992, section B.6
   [4] http://blogs.msdn.com/oldnewthing/archive/2007/12/17/6785519.aspx
       Wildcards in Windows/MSDOS.
       Windows globs are often implemented by calling the FindFileFirst /
       FindFileNext Win32 API calls.  The glob function implemented by Windows
       FindFileFirst/FindFileNext API calls can be especially counterintuitive
       and should sometimes be avoided (e.g. *.txt may match both 1.txt and
       1.txt~). So, wrapping these API calls in a Lua extension DLL may not
       be the most desirable approach.
 
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

