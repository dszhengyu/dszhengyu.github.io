#!/bin/bash

ctags -I __THROW -I "__nonnull ((1))" -I " __wur" -I "_GLIBCXX_VISIBILITY(default)" -I "__gnu_cxx" \
          --c++-kinds=+plx --fields=+iaS --extra=+q  --language-force=c++ \
          -R /usr/include/ ~/program/ ~/cabinet/src/
