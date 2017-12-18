Проект vse-gost

Предназначен для:
1. Генерации скрипта, выполняющего заполнение данными таблицы
базы данных PostgreSQL, которая содержит, обозначения ГОСТов,
наименования ГОСТов, описания ГОСТов и данные о расположении
pdf-файлов, содержащих ГОСТы
2. Генерации скрипта, выполняющего преобразование gif-файлов,
содержащих постраничное отображение ГОСТов, в pdf-файлы,
содержащих отображение гостов целиком.

ИНСТРУКЦИЯ
==========

1. Переход в рабочий каталог для зеркалирования (bash)
cd ~/Downloads

2. Зеркалирование (bash)
wget -m -np http://vsegost.com/

3. Настройка postgreSQL
3. Для создания файла импорта '/home/namatv/out.txt' в PostgreSQL выполнте следующее:
(vse-gost:main-create-PostgreSQL-import-file vse-gost:*vsegost-Catalog*)

4. Для создания файла скрипта, преобразующего gif-файлы каждого каталога в  файл gost.pdf.
(vse-gost:main-create-bash-script-gif-pdf-convertion vse-gost:*vsegost-Data*)

Примечание: Примерное время выполнения сценария 5 минут.

rsync -avzh --progress /home/namatv/public_html/2015-12-21-vsegost.com/Data/ root@192.168.0.110:/home/namatv/public_html/2015-12-21-vsegost.com/Data/

rsync -azh --info=progress2 /home/namatv/public_html/2015-12-21-vsegost.com/Data/ root@192.168.0.110:/home/namatv/public_html/2015-12-21-vsegost.com/Data/

rsync -avzh --progress /home/namatv/out.txt root@192.168.0.110:/home/namatv/

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

5. Создание базы данных gost на удаленом сервере mnasoft-pi для пользователя namatv

5.1 Переходим в запись postgres
namatv@mnasoft-pi:~$ sudo su - postgres

5.2 Создаем роль namatv
postgres@mnasoft-pi:~$ createuser -dsRP namatv

5.3 Создаем для владельца namatv базу gost
namatv@mnasoft-pi:~$ createdb -O namatv gost

5.4 Входим в консоль postgresql
namatv@mnasoft-pi:~$ psql -d gost -U namatv

5.5 Создаем таблицу gost
gost=# 
CREATE TABLE public.gost
(
  id serial PRIMARY KEY,                                        -- Идентификатор записи
  designation text,                                             -- Обозначение Стандарта.
  name text,                                                    -- Наименование Стандарта.
  description text,                                             -- Краткиое описание Стандарта
  local_path text,                                              -- Путь к документу на локальном сервере.
  external_path text,                                           -- Путь к документу на удалённом сервере.
  date date,
  status text
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.gost
  OWNER TO namatv;
COMMENT ON COLUMN public.gost.id IS            'Идентификатор записи.';
COMMENT ON COLUMN public.gost.designation IS   'Обозначение Стандарта';
COMMENT ON COLUMN public.gost.name IS          'Наименование Стандарта';
COMMENT ON COLUMN public.gost.description IS   'Краткиое описание Стандарта';
COMMENT ON COLUMN public.gost.local_path IS    'Путь к документу на локальном сервере.';
COMMENT ON COLUMN public.gost.external_path IS 'Путь к документу на удалённом сервере.';

5.6 Импортируем содержимое таблицы gost из файла:
gost=# 
copy gost (local_path, designation, date, name, description, status) from '/home/namatv/out.txt';

6. Запуск веб на удаленном сервере
