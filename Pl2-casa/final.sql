BEGIN;
\pset pager off


CREATE TABLE IF NOT EXISTS public."auxiliar_personal"
(  
nombre text NOT NULL,   
anio_nacimiento integer,
anio_muerte integer
);

CREATE TABLE IF NOT EXISTS public."auxiliar_directores"
(
nombre_director text NOT NULL,
anioestreno integer,
titulo text,
ano_nacimiento_director text, -- quitar los /N para limpiar los datos
ano_fallecimiento_director text 
);
\copy auxiliar_directores(anioestreno,titulo,nombre_director,ano_nacimiento_director,ano_fallecimiento_director) from './csv/directores_peliculas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER false, ENCODING 'UTF8');
--SELECT * FROM public.auxiliar_directores;


CREATE TABLE IF NOT EXISTS public."auxiliar_actores"
(
nombre_actor text NOT NULL,
anioestreno_pelicula integer,
titulo_pelicula text,
ano_nacimiento_actor text, -- quitar los /N para limpiar los datos
ano_fallecimiento_actor text,
nombre_personaje text
);
\copy auxiliar_actores(anioestreno_pelicula,titulo_pelicula,nombre_actor,ano_nacimiento_actor,ano_fallecimiento_actor,nombre_personaje) from './csv/actores_peliculas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER false, ENCODING 'UTF8');
--SELECT * FROM public.auxiliar_actores;

CREATE TABLE IF NOT EXISTS public."auxiliar_guionistas"(
nombre_guionista text,
anioestreno_pelicula integer,
titulo_pelicula text,
ano_nacimiento_guionista text, -- quitar los /N para limpiar los datos
ano_fallecimiento_guionista text 
);
\copy auxiliar_guionistas(anioestreno_pelicula,titulo_pelicula,nombre_guionista,ano_nacimiento_guionista,ano_fallecimiento_guionista) from './csv/guionistas_peliculas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER false, ENCODING 'UTF8');
--SELECT * FROM public.guionistas1;


CREATE TABLE IF NOT EXISTS public."Personal"
(
    nombre text NOT NULL,
    anio_nacimiento integer,
    anio_muerte integer,
    CONSTRAINT "Personal_pk" PRIMARY KEY (nombre)
);

-- FORMA PASO A PASO, dejar comentada, se hace con el comando UNION mas abajo
-- Union de directores
--INSERT INTO public."auxiliar_personal" (nombre, anio_nacimiento, anio_muerte)
--SELECT DISTINCT nombre_director, CAST(NULLIF(ano_nacimiento_director, '\N') AS INTEGER), CAST(NULLIF(ano_fallecimiento_director, '\N') AS INTEGER)
--FROM public."auxiliar_directores";

-- Union de actores
--INSERT INTO public."auxiliar_personal" (nombre, anio_nacimiento, anio_muerte)
--SELECT DISTINCT nombre_actor, CAST(NULLIF(ano_nacimiento_actor, '\N') AS INTEGER), CAST(NULLIF(ano_fallecimiento_actor, '\N') AS INTEGER)
--FROM public."auxiliar_actores";

-- Union de guionistas
--INSERT INTO public."auxiliar_personal" (nombre, anio_nacimiento, anio_muerte)
--SELECT DISTINCT nombre_guionista, CAST(NULLIF(ano_nacimiento_guionista, '\N') AS INTEGER), CAST(NULLIF(ano_fallecimiento_guionista, '\N') AS INTEGER)
--FROM public."auxiliar_guionistas";

-- Usando el commando UNION

INSERT INTO public."auxiliar_personal" (nombre, anio_nacimiento, anio_muerte)
SELECT 
 nombre_director AS nombre,
 CAST(NULLIF(ano_nacimiento_director, '\N') AS INTEGER) AS anio_nacimiento,
 CAST(NULLIF(ano_fallecimiento_director, '\N') AS INTEGER) AS anio_muerte
FROM public."auxiliar_directores"
UNION
SELECT nombre_actor, CAST(NULLIF(ano_nacimiento_actor, '\N') AS INTEGER), CAST(NULLIF(ano_fallecimiento_actor, '\N') AS INTEGER)
FROM public."auxiliar_actores"
UNION
SELECT nombre_guionista, CAST(NULLIF(ano_nacimiento_guionista, '\N') AS INTEGER), CAST(NULLIF(ano_fallecimiento_guionista, '\N') AS INTEGER)
FROM public."auxiliar_guionistas";
-- Insertamos en la tabla personal

INSERT INTO public."Personal" (nombre, anio_nacimiento, anio_muerte)
SELECT DISTINCT nombre, anio_nacimiento, anio_muerte 
FROM public."auxiliar_personal";

--sacamos 20 Personal aleaorio
--SELECT * FROM public."Personal" ORDER BY random() LIMIT 20;




CREATE TABLE IF NOT EXISTS public."Actores"
(
    "nombre_Personal" text  NOT NULL,
    CONSTRAINT "Actores_pk" PRIMARY KEY ("nombre_Personal"),
    CONSTRAINT fk_nombre_personal FOREIGN KEY ("nombre_Personal")
        REFERENCES public."Personal" (nombre) MATCH SIMPLE
        
);

--insetarmos en la tabla de actores desde la tabla auxiliar_actores
INSERT INTO public."Actores" ("nombre_Personal")
SELECT DISTINCT nombre_actor
FROM public."auxiliar_actores";
--sacamos 20 actores aleaorio
--SELECT * FROM public."Actores" ORDER BY random() LIMIT 20;


CREATE TABLE IF NOT EXISTS public."Directores"
(
    "nombre_Personal" text NOT NULL,
    CONSTRAINT "Directores_pk" PRIMARY KEY ("nombre_Personal"),
    CONSTRAINT "fk_Personal" FOREIGN KEY ("nombre_Personal")
        REFERENCES public."Personal" (nombre) MATCH SIMPLE
       
);

--insetarmos en la tabla de directores desde la tabla auxiliar_directores
INSERT INTO public."Directores" ("nombre_Personal")
SELECT DISTINCT nombre_director
FROM public."auxiliar_directores";
--sacamos 20 directores aleaorio
--SELECT * FROM public."Directores" ORDER BY random() LIMIT 20;


CREATE TABLE IF NOT EXISTS public."Guionistas"
(
    "nombre_Personal" text NOT NULL,
    CONSTRAINT "Guionista_pk" PRIMARY KEY ("nombre_Personal"),
    CONSTRAINT "fk_Personal" FOREIGN KEY ("nombre_Personal")
        REFERENCES public."Personal" (nombre) MATCH SIMPLE
       
);

--insetarmos en la tabla de guionistas desde la tabla auxiliar_guionistas
INSERT INTO public."Guionistas" ("nombre_Personal")
SELECT DISTINCT nombre_guionista
FROM public."auxiliar_guionistas";
--sacamos 20 guionistas aleaorio
--SELECT * FROM public."Guionistas" ORDER BY random() LIMIT 20;


CREATE TABLE IF NOT EXISTS public."auxiliar_peliculas"
(
    anio integer NOT NULL,
    titulo text  NOT NULL,
    idioma text ,
    duracion text,
    calificacion text,
    nombre_personal_directores text,
    genero text
);
\copy auxiliar_peliculas(anio,titulo,genero,idioma,duracion,calificacion) from './csv/peliculas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER false, ENCODING 'UTF8');




CREATE TABLE IF NOT EXISTS public."Peliculas"
(
    anio integer NOT NULL,
    titulo text  NOT NULL,
    idioma text ,
    duracion integer,
    calificacion text,
    nombre_personal_directores text,
    genero text,
    CONSTRAINT "Peliculas_pk" PRIMARY KEY (anio, titulo),
    CONSTRAINT "fk_Directores" FOREIGN KEY (nombre_personal_directores)
        REFERENCES public."Directores" ("nombre_Personal") MATCH SIMPLE
        
);
INSERT INTO "Peliculas" (anio, titulo, idioma, duracion, calificacion, nombre_personal_directores, genero)
SELECT 
    anio, 
    titulo, 
    NULLIF(idioma, '') AS idioma, 
    CAST(NULLIF(SUBSTRING(duracion FROM '[0-9]+'), '') AS INTEGER) AS duracion, 
    NULLIF(calificacion, 'NULL') AS calificacion, 
    nombre_personal_directores, 
    NULLIF(genero, '') AS genero
FROM public."auxiliar_peliculas";
-- '[0-9]+' es una expresión regular que significa "cualquier número de 0 a 9, y el + significa que puede haber más de uno"
-- probar 20 peliculas aleatorias
--SELECT * FROM public."Peliculas" ORDER BY random() LIMIT 20;
-- salen las peliculas sin director, se hace el join mas abajo




-- unir director con su pelicula
UPDATE public."Peliculas" AS p                 -- tabla a actualizar , alias p
SET nombre_personal_directores = ad.nombre_director   -- columna a actualizar , valor a actualizar
FROM public."auxiliar_directores" AS ad            -- tabla auxiliar , alias ad
WHERE p.titulo = ad.titulo;                     -- condición de unión


--SELECT * FROM public."Peliculas";
-- el csv tiene varios directores para cada pelicula aunque el enunciado dice que solo hay uno por pelicula?
-- encuentra director para la segunda mitad de los datos.
--SELECT * FROM public."Peliculas" WHERE nombre_personal_directores IS NOT NULL;



CREATE TABLE IF NOT EXISTS public."auxiliar_actuan"
(
    nombre_personal_actores text,
    anio_peliculas integer,
    titulo_peliculas text,
    nombre_personaje text,
    anio_nacimiento_actor text,
    ano_fallecimiento_actor text
);
--copiamos los datos del csv a la tabla auxiliar_actuan
\copy auxiliar_actuan(anio_peliculas,titulo_peliculas,nombre_personal_actores,anio_nacimiento_actor,ano_fallecimiento_actor,nombre_personaje) from './csv/actores_peliculas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER false, ENCODING 'UTF8');

CREATE TABLE IF NOT EXISTS public."Actuan"
(
    "nombre_Personal_Actores" text NOT NULL,
    "anio_Peliculas" integer NOT NULL,
    "titulo_Peliculas" text NOT NULL,
    CONSTRAINT "Actuan_pk" PRIMARY KEY ("nombre_Personal_Actores", "anio_Peliculas", "titulo_Peliculas"),
    CONSTRAINT "fk_Actores" FOREIGN KEY ("nombre_Personal_Actores")
        REFERENCES public."Actores" ("nombre_Personal") MATCH SIMPLE,
    CONSTRAINT "fk_Peliculas" FOREIGN KEY ("titulo_Peliculas", "anio_Peliculas")
        REFERENCES public."Peliculas" (titulo, anio) MATCH SIMPLE
       
);
-- insertamos desde la tabla auxilixar_actuan
INSERT INTO public."Actuan" ("nombre_Personal_Actores", "anio_Peliculas", "titulo_Peliculas")
SELECT DISTINCT
 nombre_personal_actores,
 CAST(anio_peliculas AS INTEGER) AS anio_peliculas,
 titulo_peliculas
FROM public."auxiliar_actuan";
-- selecionamos 20 actuan aleatorios
--SELECT * FROM public."Actuan" ORDER BY random() LIMIT 20;

--1984	They're Playing with Fire	Howard Avedis	1927	2017

CREATE TABLE IF NOT EXISTS public."auxiliar_guionizan"
(
    nombre_personal_guionistas text,
    anio_peliculas integer,
    titulo_peliculas text,
    anio_nacimiento_guionista text,
    anio_fallecimiento_guionista text
);
\copy auxiliar_guionizan(anio_peliculas,titulo_peliculas,nombre_personal_guionistas,anio_nacimiento_guionista,anio_fallecimiento_guionista) from './csv/guionistas_peliculas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER false, ENCODING 'UTF8');
CREATE TABLE IF NOT EXISTS public."Guionizan"
(
    "anio_Peliculas" integer NOT NULL,
    "titulo_Peliculas" text NOT NULL,
    "nombre_Personal_Guionistas" text NOT NULL,
    CONSTRAINT guionizan_pk PRIMARY KEY ("anio_Peliculas", "titulo_Peliculas", "nombre_Personal_Guionistas"),
    CONSTRAINT "fk_Guionizan" FOREIGN KEY ("nombre_Personal_Guionistas")
        REFERENCES public."Guionistas" ("nombre_Personal") MATCH SIMPLE,
    CONSTRAINT fk_peliculas FOREIGN KEY ("anio_Peliculas", "titulo_Peliculas")
        REFERENCES public."Peliculas" (anio, titulo) MATCH SIMPLE
       
);

INSERT INTO public."Guionizan" ("anio_Peliculas", "titulo_Peliculas", "nombre_Personal_Guionistas")
SELECT 
 anio_peliculas,
 
 titulo_peliculas,
 nombre_personal_guionistas
FROM public."auxiliar_guionizan";

-- selecionamos 20 guionizan aleatorios
--SELECT * FROM public."Guionizan" ORDER BY random() LIMIT 20;

CREATE TABLE IF NOT EXISTS public.auxiliar_paginaweb
(
    pagina_web text NOT NULL
    
);

CREATE TABLE IF NOT EXISTS public."auxiliar_caratulas"
(
    nombre_caratula text NOT NULL, --quizas quitar los guiones
    tamanio text ,  -- algunas tienen barra baja
    anio_peliculas integer,
    titulo_peliculas text,
    fecha text, --cast a tipo TIMESTAMP
    pagina_web_pagina_web text -- poner :

);


\copy auxiliar_caratulas(anio_peliculas,titulo_peliculas,nombre_caratula,fecha,pagina_web_pagina_web,tamanio) from './csv/caratulas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER false, ENCODING 'UTF8');
--SELECT * FROM public."auxiliar_caratulas";


CREATE TABLE IF NOT EXISTS public.auxiliar_criticas
(
    anio_peliculas integer,
    titulo_peliculas text,
    nombre_critico text,
    puntuacion float,
    texto_critica text,
    pagina_web_pagina_web text
);

\copy auxiliar_criticas(anio_peliculas,titulo_peliculas,nombre_critico,puntuacion,texto_critica,pagina_web_pagina_web) from './csv/criticas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER false, ENCODING 'UTF8');
--realizamos la union de paginas web
--SELECT pagina_web_pagina_web FROM public.auxiliar_caratulas ORDER BY random() LIMIT 20;
INSERT INTO public.auxiliar_paginaweb (pagina_web)
SELECT DISTINCT pagina_web_pagina_web
FROM public.auxiliar_caratulas
UNION
SELECT DISTINCT pagina_web_pagina_web
FROM public.auxiliar_criticas;
--Probamos la union de paginas web
--SELECT * FROM public.auxiliar_paginaweb ORDER BY random() LIMIT 20;


CREATE TABLE IF NOT EXISTS public."Paginaweb"
(
    pagina_web text NOT NULL,
    CONSTRAINT pagina_web_pk PRIMARY KEY (pagina_web)
);

--insertamos en la tabla paginaweb desde la tabla auxiliar_paginaweb
INSERT INTO public."Paginaweb" (pagina_web)
SELECT DISTINCT CONCAT(REPLACE(pagina_web, 'https.//', 'https://'), '/') AS pagina_web
 
FROM public.auxiliar_paginaweb;
-- selecionamos 20 paginas web aleatorios
--SELECT * FROM public."Paginaweb" ORDER BY random() LIMIT 20;

CREATE TABLE IF NOT EXISTS public."Caratulas"
(
    nombre_caratula text NOT NULL,
    tamanio text ,
    anio_peliculas integer NOT NULL,
    titulo_peliculas text NOT NULL,
    CONSTRAINT "Caratulas_pk" PRIMARY KEY (nombre_caratula, anio_peliculas, titulo_peliculas),
    CONSTRAINT "fk_Peliculas" FOREIGN KEY (anio_peliculas, titulo_peliculas)
        REFERENCES public."Peliculas" (anio, titulo) MATCH SIMPLE
        
);

--insertamos en la tabla caratulas desde la tabla auxiliar_caratulas
INSERT INTO public."Caratulas" (nombre_caratula, tamanio, anio_peliculas, titulo_peliculas)
SELECT DISTINCT
 nombre_caratula,
 --cambiar donde lo encuentre de caratula_mediana a caratula mediana
     REGEXP_REPLACE(tamanio, '(\w+)_(\w+)', '\1') AS tamanio,
 anio_peliculas,
 titulo_peliculas
FROM public."auxiliar_caratulas";
-- selecionamos 20 caratulas aleatorios
--SELECT * FROM public."Caratulas" ORDER BY random() LIMIT 20;

--insertamos en la tabla caratulas desde la tabla auxiliar_caratulas
--quitar de de tamanio el guion bajo si lo tiene ej: Cara_pequena
INSERT INTO public."Caratulas" (nombre_caratula, tamanio, anio_peliculas, titulo_peliculas)
SELECT DISTINCT
 nombre_caratula,
 tamanio,
 anio_peliculas,
 titulo_peliculas
FROM public."auxiliar_caratulas"
ON CONFLICT (nombre_caratula, anio_peliculas, titulo_peliculas) DO NOTHING;-- necesita un mejor fix
-- selecionamos 20 caratulas aleatorios
--SELECT * FROM public."Caratulas" ORDER BY random() LIMIT 20;


CREATE TABLE IF NOT EXISTS public."Criticas"
(
    anio_peliculas integer NOT NULL,
    titulo_peliculas text NOT NULL,
    nombre_critico text NOT NULL,
    puntuacion float,
    texto_critica text,
    pagina_web_pagina_web text,
    CONSTRAINT "Criticas_pk" PRIMARY KEY (anio_peliculas, titulo_peliculas, nombre_critico),
    CONSTRAINT "fk_Paginaweb" FOREIGN KEY (pagina_web_pagina_web)
        REFERENCES public."Paginaweb" (pagina_web) MATCH SIMPLE,
    CONSTRAINT "fk_Peliculas" FOREIGN KEY (anio_peliculas, titulo_peliculas)
        REFERENCES public."Peliculas" (anio, titulo) MATCH SIMPLE
      
);

--insertamos en la tabla criticas desde la tabla auxiliar_criticas
INSERT INTO public."Criticas" (anio_peliculas, titulo_peliculas, nombre_critico, puntuacion, texto_critica, pagina_web_pagina_web)
SELECT DISTINCT
 anio_peliculas,
 titulo_peliculas,
 nombre_critico,
 puntuacion,
 texto_critica,
 CONCAT(REPLACE(pagina_web_pagina_web, 'https.//', 'https://'), '/') AS pagina_web_pagina_web
FROM public."auxiliar_criticas"
ON CONFLICT (anio_peliculas, titulo_peliculas, nombre_critico) DO NOTHING;-- necesita un mejor fix
-- selecionamos 20 criticas aleatorios
--SELECT * FROM public."Criticas" ORDER BY random() LIMIT 20;


CREATE TABLE IF NOT EXISTS public."auxiliar_alojadas"
(
    fecha text,
    nombre_caratula_caratulas text,
    anio_peliculas_caratulas integer,
    pagina_web_pagina_web text,
    titulo_peliculas_caratulas text,
    tamanio text
);
--2020	Fortuna	fortuna-2020	2021-04-16 12:56:19	https.//palomitas.com/películas/fortuna-2020_Carátula_mediana.jpg	Carátula_mediana

\copy auxiliar_alojadas( anio_peliculas_caratulas, titulo_peliculas_caratulas, nombre_caratula_caratulas, fecha, pagina_web_pagina_web,tamanio) from './csv/caratulas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER false, ENCODING 'UTF8');
--SELECT * FROM public."auxiliar_alojadas" ORDER BY random() LIMIT 20;
CREATE TABLE IF NOT EXISTS public."Alojadas"
(
    fecha timestamp,
    nombre_caratula_caratulas text NOT NULL,
    anio_peliculas_caratulas integer NOT NULL,
    pagina_web_pagina_web text NOT NULL,
    titulo_peliculas_caratulas text,
    CONSTRAINT alojadas_pk PRIMARY KEY (nombre_caratula_caratulas, anio_peliculas_caratulas, pagina_web_pagina_web, titulo_peliculas_caratulas),
    CONSTRAINT "fk_Caratulas" FOREIGN KEY (nombre_caratula_caratulas, anio_peliculas_caratulas, titulo_peliculas_caratulas)
        REFERENCES public."Caratulas" (nombre_caratula, anio_peliculas, titulo_peliculas) MATCH SIMPLE,
    CONSTRAINT fk_pagina_web FOREIGN KEY (pagina_web_pagina_web)
        REFERENCES public."Paginaweb" (pagina_web) MATCH SIMPLE
      
);


--insertamos en la tabla alojadas desde la tabla auxiliar_alojadas
-- hay que castear la fecha a timestamp y
INSERT INTO public."Alojadas" (fecha, nombre_caratula_caratulas, anio_peliculas_caratulas, pagina_web_pagina_web, titulo_peliculas_caratulas)
SELECT DISTINCT

    CAST(NULLIF(SUBSTRING(fecha FROM '[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+'), '') AS TIMESTAMP) AS fecha,
 nombre_caratula_caratulas,
 anio_peliculas_caratulas,
 CONCAT(REPLACE(pagina_web_pagina_web, 'https.//', 'https://'), '/') AS pagina_web_pagina_web,
 titulo_peliculas_caratulas
FROM public."auxiliar_alojadas"
ON CONFLICT (nombre_caratula_caratulas, anio_peliculas_caratulas, pagina_web_pagina_web, titulo_peliculas_caratulas) DO NOTHING;-- necesita un mejor fix

-- selecionamos 20 alojadas aleatorios
--SELECT * FROM public."Alojadas" ORDER BY random() LIMIT 20;




-- ON UPDATE CASCADE

ROLLBACK;