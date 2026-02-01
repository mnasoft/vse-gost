#!/bin/bash
sbcl --eval "(asdf:load-system :vse-gost/web)" \
     --eval "(sb-ext:save-lisp-and-die \"vsegost-web.exe\" :executable t :compression t)"
