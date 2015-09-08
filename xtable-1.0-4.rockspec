package = "xtable"
version = "1.0-4"

source = {
  url = "https://github.com/dlaurie/xtable/archive/master.zip",
  dir = "xtable-master",
}

description = {
  summary = "Alternative table library",
  detailed = [[
    'xtable' provides generic functions for table manipulation, at a
    lower level than the standard table library.
  ]],
  homepage = "https://github.com/dlaurie/xtable",
  maintainer = "Dirk Laurie <dirk.laurie@gmail.com>",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1, < 5.4"
}

build = {
  type = "builtin",
  modules = {
    ["xtable"] = "src/xtable.lua",
    ["xtable_core"] = "src/xtable.c",
  }
}

