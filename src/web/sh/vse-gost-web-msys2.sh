#!/bin/bash

"D:\home\_namatv\PRG\msys64\ucrt64\bin\pg_ctl" -D "D:\home\_namatv\PRG\msys64\var\lib\postgres\data" -l journal.log stop

"D:\home\_namatv\PRG\msys64\ucrt64\bin\pg_ctl" -D "D:\home\_namatv\PRG\msys64\var\lib\postgres\data" -l journal.log start

sbcl --eval "(asdf:load-system :vse-gost/web)" --eval "(vse-gost/web:start-gosts)"
