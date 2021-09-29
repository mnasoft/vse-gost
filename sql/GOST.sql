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
