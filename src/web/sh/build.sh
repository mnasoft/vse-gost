#!/bin/bash
sbcl --eval "(ql:quickload :vse-gost/web)" \
     --eval "(sb-ext:save-lisp-and-die \"vsegost-web.exe\" :executable t :compression t)"
