#!/bin/bash

ctags -I __THROW -I "__nonnull ((1))" --c++-kinds=+p --fields=+iaS --extra=+q -R /usr/include/ ~/program/ 
