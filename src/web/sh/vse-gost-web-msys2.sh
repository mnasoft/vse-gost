#!/bin/bash
# Переходим в каталог пользователя
cd ~
# Останавливаем сервер баз данных PostgreSQL
"D:/home/_namatv/PRG/msys64/ucrt64/bin/pg_ctl" -D "D:/home/_namatv/PRG/msys64/var/lib/postgres/data" -l journal.log stop

# Стартуем сервер баз данных PostgreSQL
"D:/home/_namatv/PRG/msys64/ucrt64/bin/pg_ctl" -D "D:/home/_namatv/PRG/msys64/var/lib/postgres/data" -l journal.log start

# Старый вариант запуска
#sbcl --eval "(asdf:load-system :vse-gost/web)" --eval "(vse-gost/web:start-gosts)"
# Новый вариант запуска
vsegost-web.sh
