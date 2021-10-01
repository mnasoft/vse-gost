;;;; vse-gost.asd

(defsystem "vse-gost"
  :description "
@begin(section) @title(Обзор)
Проект предназначен для разбора информации о ГОСТ, размещенной на
сайте @link[uri=\"http://vsegost.com\"](vsegost.com).

Система позволяет сгенерировать:
@begin(enum)

 @item(shell-скрипт, выполняющий заполнение данными таблицы базы
данных PostgreSQL. Данная таблица содержит:

- обозначения ГОСТ-ов;

- наименования ГОСТ-ов;

- описания ГОСТ-ов;

- путь к pdf-файлам содержащим ГОСТ-ы.)

 @item(shell-скрипт, выполняющий преобразование gif-файлов,
содержащих постраничное отображение ГОСТ-ов, в pdf-файлы, содержащие
отображение ГОСТ-ов целиком.)
@end(enum)

@end(section)

@begin(section) @title(Зависимости)
Для ковертирования файлов с расширением gif в файлы с расширением pdf
используется команда @b(convert), входящая в состав пакета @b(imagemagick).

Пакет @b(imagemagick) можно установить при помощи следующей команды:

@begin[lang=shell](code)
# Установка для debian.
sudo apt install graphicsmagick-imagemagick-compat
@end(code)

@begin[lang=shell](code)
# Установка для msys2.
sudo pacman -S mingw-w64-x86_64-imagemagick
@end(code)
@end(section)

@begin(section) @title(Структура каталогов сайта vsegost.com)

Информация о ГОСТ, размещенная на сайте
@link[uri=\"http://vsegost.com\"](vsegost.com), содержится в
нескольких каталогах:

@begin(list) 
 @item(Catalog - в его подкаталогах содержатся файлы с расширением
 *.shtm, в которых присутствует информация содержащая: обозначение
 ГОСТ; наименование ГОСТ; краткое описание ГОСТ;)
 @item(Categories - в системе @c(vse-gost) не используется;)
 @item(Data - в его подкаталогах содержатся файлы с расширением *.gif,
 с отсканированными страницами ГОСТ;)
 @item(DataTN - в его подкаталогах содержатся файлы с расширением
 *.gif, с уменьшенными отсканированными страницами ГОСТ. В системе
 @c(vse-gost) не используется;)
 @item(NCategories - в системе @c(vse-gost) не используется.)
@end(list)

@end(section)

@begin(section) @title(Цели)
@begin(list)
 @item(разбор содержимого зеркалированного сайта vsegost.com и
 формирование базы данных ГОСТ;)
 @item(конвертирование gif-файлов в формат pdf;)
 @item(создание сайта, содержащего pdf ГОСТов.)
@end(list)
@end(section)

@begin(section) @title(Инструкция)
@begin(section) @title(Зеркалирование)
Перейдите в домашний каталог:
@begin[lang=shell](code)
 cd ${HOME}/Downloads
@end(code)

Собственно зеркалирование:
@begin[lang=shell](code)
 wget -m -np http://vsegost.com/
@end(code)
@end(section)

@begin(section) @title(Извлечение данных о ГОСТ)
Для извлечение данных о ГОСТ и создания файла импорта
'/home/namatv/out.txt' в PostgreSQL выполнте следующее:

@begin[lang=lisp](code)
(vse-gost:main-create-PostgreSQL-import-file vse-gost:*vsegost-Catalog*)
@end(code)

@begin(section) @title(Конвертирование gif в pdf) 

Для конвертирования gif-файлов в формат pdf неодходимо сгенерировать
shell-скрипт при помощи вызова функции:

@begin[lang=lisp](code)
 (vse-gost:main-create-bash-script-gif-pdf-convertion vse-gost:*vsegost-Data*)
@end(code)
Примечание: Примерное время выполнения функции - 5 минут.

После чего необходимо запустить shell-скрипт на выполнение.
@begin[lang=shell](code)
 sh ${HOME}/out.sh
@end(code)

@end(section)
@end(section)

@begin(section) @title(Настройка postgreSQL)

@begin[lang=shell](code)
 rsync -avzh --progress /home/namatv/public_html/2015-12-21-vsegost.com/Data/ root@192.168.0.110:/home/namatv/public_html/2015-12-21-vsegost.com/Data/
 rsync -azh --info=progress2 /home/namatv/public_html/2015-12-21-vsegost.com/Data/ root@192.168.0.110:/home/namatv/public_html/2015-12-21-vsegost.com/Data/
 rsync -avzh --progress /home/namatv/out.txt root@192.168.0.110:/home/namatv/
@end(code)
@end(section)

@begin(section) @title(Создание базы данных)

Здесь создается база данных gost на удаленом сервере mnasoft-pi для
пользователя namatv.

Переходим в запись postgres:
@begin[lang=shell](code)
 sudo su - postgres
@end(code)

Создаем роль namatv:
@begin[lang=shell](code)
 createuser -dsRP namatv
@end(code)

Создаем для владельца namatv базу gost:
@begin[lang=shell](code)
 createdb -O namatv gost
@end(code)

Входим в консоль postgresql:
@begin[lang=shell](code)
 psql -d gost -U namatv
@end(code)

Создаем таблицу gost:
@begin[lang=sql](code)
 gost=# 
 CREATE TABLE public.gost
 (
  id serial PRIMARY KEY,    -- Идентификатор записи
  designation text,         -- Обозначение Стандарта
  name text,                -- Наименование Стандарта
  description text,         -- Краткиое описание Стандарта
  local_path text,          -- Путь к документу на локальном сервере
  external_path text,       -- Путь к документу на удалённом сервере
  date date,
  status text
 )
 WITH (
   OIDS=FALSE
 );
 ALTER TABLE public.gost
  OWNER TO namatv;
 COMMENT ON COLUMN public.gost.id IS            'Идентификатор записи';
 COMMENT ON COLUMN public.gost.designation IS   'Обозначение Стандарта';
 COMMENT ON COLUMN public.gost.name IS          'Наименование Стандарта';
 COMMENT ON COLUMN public.gost.description IS   'Краткиое описание Стандарта';
 COMMENT ON COLUMN public.gost.local_path IS    'Путь к документу на локальном сервере';
 COMMENT ON COLUMN public.gost.external_path IS 'Путь к документу на удалённом сервере';
@end(code)

Импортируем содержимое таблицы gost из файла:
@begin[lang=sql](code)
gost=# 
 copy gost (local_path, designation, date, name, description, status) from '/home/namatv/out.txt';
@end(code)

или

@begin[lang=sql](code)
gost=# 
 copy gost (local_path, designation, date, name, description, status) from 'D:\PRG\msys32\home\namatv\quicklisp\local-projects\clisp\vse-gost\out.txt';
@end(code)

@begin(section) @title(Запуск Web-сервера)
Bla-Bla-Bla.
@end(section)

@end(section)
"

  :author "Nick Matvyeyev <mnasoft@gmail.com>"
  :license "GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007 or later"  
  :depends-on (#:cl-ppcre)
  :serial nil
  :components ((:module "src"
		:serial t :components ((:file "package")
                                       (:file "vse-gost")
	                               (:file "parse-shtml")
      	                               (:file "walk-dir")))))

(defsystem "vse-gost/docs"
  :description "Зависимости для сборки документации"
  :author "Nick Matvyeyev <mnasoft@gmail.com>"
  :license "GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007 or later"  
  :depends-on ("vse-gost" "codex" "mnas-package")
  :components ((:module "src/docs"
		:serial nil
                :components ((:file "docs")))))


"


"
