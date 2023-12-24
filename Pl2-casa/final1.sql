------------------------------------------------------------------------------------------------------------------------
----                                              CABECERA                                                          ----
------------------------------------------------------------------------------------------------------------------------
-- Nombres de los integrantes del grupo:
-- 1. Isaac Marval Hernandez
-- 2. Pedro Bustos Sánchez
------------------------------------------------------------------------------------------------------------------------
----                                              Entrega PL3                                                       ----
------------------------------------------------------------------------------------------------------------------------






BEGIN;
\pset pager off

------------------------------------------------------------------------------------------------------------------------
----                                              CREACION DE TABLAS                                                ----
------------------------------------------------------------------------------------------------------------------------

\echo "---------------------- Creacion de tablas -----------------"

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
\copy auxiliar_actuan(anio_peliculas,titulo_peliculas,nombre_personal_actores,anio_nacimiento_actor,ano_fallecimiento_actor,nombre_personaje)  from './csv/actores_peliculas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER false, ENCODING 'UTF8');

CREATE TABLE IF NOT EXISTS public."Actuan"
(
    "nombre_Personal_Actores" text NOT NULL,
    "anio_Peliculas" integer NOT NULL,
    "titulo_Peliculas" text NOT NULL,
    "nombre_Personaje" text,
    CONSTRAINT "Actuan_pk" PRIMARY KEY ("nombre_Personal_Actores", "anio_Peliculas", "titulo_Peliculas"),
    CONSTRAINT "fk_Actores" FOREIGN KEY ("nombre_Personal_Actores")
        REFERENCES public."Actores" ("nombre_Personal") MATCH SIMPLE,
    CONSTRAINT "fk_Peliculas" FOREIGN KEY ("titulo_Peliculas", "anio_Peliculas")
        REFERENCES public."Peliculas" (titulo, anio) MATCH SIMPLE
       
);
-- insertamos desde la tabla auxilixar_actuan
INSERT INTO public."Actuan" ("nombre_Personal_Actores", "anio_Peliculas", "titulo_Peliculas", "nombre_Personaje")
SELECT
 nombre_personal_actores,
 CAST(anio_peliculas AS INTEGER) AS anio_peliculas,
 titulo_peliculas,
 nombre_personaje
FROM public."auxiliar_actuan";
-- selecionamos 20 actuan aleatorios
--SELECT * FROM public."Actuan" ORDER BY random() LIMIT 20;


CREATE TABLE IF NOT EXISTS public."auxiliar_guionizan"
(
    nombre_personal_guionistas text,
    anio_peliculas integer,
    titulo_peliculas text,
    anio_nacimiento_guionista text,
    anio_fallecimiento_guionista text
);
--copiamos los datos del csv a la tabla auxiliar_guionizan
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
-- insertamos desde la tabla auxilixar_guionizan
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

--copiamos los datos del csv a la tabla auxiliar_caratulas
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
    pagina_web_pagina_web text,
    CONSTRAINT "Caratulas_pk" PRIMARY KEY (nombre_caratula, anio_peliculas, titulo_peliculas),
    CONSTRAINT "fk_Paginaweb" FOREIGN KEY (pagina_web_pagina_web)
        REFERENCES public."Paginaweb" (pagina_web) MATCH SIMPLE,
    CONSTRAINT "fk_Peliculas" FOREIGN KEY (anio_peliculas, titulo_peliculas)
        REFERENCES public."Peliculas" (anio, titulo) MATCH SIMPLE
        
);

--insertamos en la tabla caratulas desde la tabla auxiliar_caratulas
INSERT INTO public."Caratulas" (nombre_caratula, tamanio, anio_peliculas, titulo_peliculas, pagina_web_pagina_web)
SELECT DISTINCT
 nombre_caratula,
 --cambiar donde lo encuentre de caratula_mediana a caratula mediana
     REGEXP_REPLACE(tamanio, '(\w+)_(\w+)', '\1') AS tamanio,
 anio_peliculas,
 titulo_peliculas,
    CONCAT(REPLACE(pagina_web_pagina_web, 'https.//', 'https://'), '/') AS pagina_web_pagina_web
FROM public."auxiliar_caratulas";
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
SELECT DISTINCT ON (anio_peliculas, titulo_peliculas, nombre_critico)
 anio_peliculas,
 titulo_peliculas,
 nombre_critico,
 puntuacion,
 texto_critica,
 CONCAT(REPLACE(pagina_web_pagina_web, 'https.//', 'https://'), '/') AS pagina_web_pagina_web
FROM public."auxiliar_criticas";-- necesita un mejor fix
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
FROM public."auxiliar_alojadas";



-- selecionamos 20 alojadas aleatorios
--SELECT * FROM public."Alojadas" ORDER BY random() LIMIT 20;


------------------------------------------------------------------------------------------------------------------------
----                                              CONSULTAS                                                         ----
------------------------------------------------------------------------------------------------------------------------

\echo "---------------------- Consultas -----------------"

---1---
\echo "1. Mostrar el nombre de los directores nacidos en 1970. Construir la expresión equivalente en álgebra relacional."
SELECT DISTINCT d."nombre_Personal",p.anio_nacimiento 
FROM public."Directores" d JOIN public."Personal" p ON d."nombre_Personal" = p.nombre WHERE p.anio_nacimiento = 1970;
--π_nombre_Personal(σ_anio_nacimiento=1970(π_nombre_Personal(Ρ_nombre_Personal, Directores ⨝_(nombre_Personal = nombre) Personal)))

---2---
\echo "2. Mostrar todos los idiomas de las películas, junto al número de películas que hay en ese idioma. La salida debe de estar ordenada del idioma con más películas al que tiene menos. Construir la expresión equivalente en álgebra relacional."--2. Mostrar todos los idiomas de las películas, junto al número de películas que hay en ese idioma. La salida debe de estar ordenada del idioma con más películas al que tiene menos. Construir la expresión equivalente en álgebra relacional.
SELECT DISTINCT p.idioma, COUNT(*) AS NumPeliculas 
FROM public."Peliculas" p GROUP BY p.idioma ORDER BY NumPeliculas DESC;

---3---
\echo "3. Mostrar el nombre del actor o actores más jóvenes junto a su año de nacimiento"--3. Mostrar el nombre del actor o actores más jóvenes junto a su año de nacimiento
SELECT DISTINCT a."nombre_Personal", p.anio_nacimiento 
FROM public."Actores" a JOIN public."Personal" p ON a."nombre_Personal" = p.nombre WHERE p.anio_nacimiento = (SELECT MIN(anio_nacimiento) FROM public."Personal");

---4---
\echo "4. Mostrar el nombre de los actores que aparezcan en más de una película junto con  el número de películas en las cuales ha actuado. Construir la expresión equivalente en álgebra relacional"--4. Mostrar el nombre de los actores que aparezcan en más de una película junto con  el número de películas en las cuales ha actuado. Construir la expresión equivalente en álgebra relacional
SELECT DISTINCT a."nombre_Personal", COUNT(*) AS NumPeliculas 
FROM public."Actores" a JOIN public."Actuan" ac ON a."nombre_Personal" = ac."nombre_Personal_Actores" GROUP BY a."nombre_Personal" HAVING COUNT(*) > 1;

---5---
\echo "5. Mostrar un listado de géneros con la cantidad de películas pertenecientes al mismo, ordenados por los que tienen más películas a los que tienen menos"--5. Mostrar un listado de géneros con la cantidad de películas pertenecientes al mismo, ordenados por los que tienen más películas a los que tienen menos
SELECT DISTINCT p.genero, COUNT(*) AS NumPeliculas 
FROM public."Peliculas" p GROUP BY p.genero ORDER BY NumPeliculas DESC;

---6---
\echo "--6. Mostrar el nombre de todos guionistas que han trabajado en películas de género de deportes y cine negro"
SELECT  g."nombre_Personal"
FROM "Guionistas" g
JOIN "Guionizan" gz ON gz."nombre_Personal_Guionistas" = g."nombre_Personal"
JOIN public."Peliculas" p ON gz."titulo_Peliculas" = p.titulo
WHERE p.genero = 'Sport' OR p.genero = 'Film-Noir';

---7---
\echo "--7. Solicitar los actores que hayan actuado en películas en idioma japonés y tengan una duración inferior a 100 minutos y cuyo año de nacimiento sea inferior a 1960. a salida mostrará el actor, el papel que hay interpretado en la película, así como el título, año, idioma, y duración de la misma. Construir la expresión equivalente en álgebra relacional"
SELECT DISTINCT a."nombre_Personal", ac."nombre_Personaje", p.titulo, p.anio, p.idioma, p.duracion 
FROM public."Actores" a 
JOIN public."Actuan" ac ON a."nombre_Personal" = ac."nombre_Personal_Actores" 
JOIN public."Peliculas" p ON ac."titulo_Peliculas" = p.titulo AND ac."anio_Peliculas" = p.anio 
JOIN public."Personal" pe ON a."nombre_Personal" = pe."nombre"
WHERE p.idioma = 'ja' AND p.duracion < 100 AND pe.anio_nacimiento < 1960;

---8---
\echo "8. Mostrar la información de las películas que cuentan con al menos 2 carátulas. La  salida será: Título, año de lanzamiento, idioma, duración, calificación y número  que carátulas que tiene"
SELECT DISTINCT p.titulo, p.anio, p.idioma, p.duracion, p.calificacion, COUNT(*) AS NumCaratulas  
FROM public."Peliculas" p JOIN public."Caratulas" c ON p.titulo = c.titulo_peliculas  
AND p.anio = c.anio_peliculas GROUP BY p.titulo, p.anio, p.idioma, p.duracion, p.calificacion  

HAVING COUNT(*) > 1; 
---9---
\echo "9. Mostrar el título y año de lanzamiento de las 3 películas con mayor puntuación  media de entre todas las críticas. Mostrar también dicha puntuación media"
SELECT  p.titulo, p.anio, AVG(c.puntuacion) AS PuntuacionMedia 
FROM public."Peliculas" p JOIN public."Criticas" c ON p.titulo = c.titulo_peliculas AND p.anio = c.anio_peliculas GROUP BY p.titulo, p.anio ORDER BY PuntuacionMedia DESC LIMIT 3;

---10---
\echo 10. Determinar el género o géneros cuyas películas tengan una puntuación media más  baja. Mostrar también dicha puntuación medi

SELECT DISTINCT p.genero, AVG(c.puntuacion) AS PuntuacionMedia 
FROM public."Peliculas" p JOIN public."Criticas" c ON p.titulo = c.titulo_peliculas AND p.anio = c.anio_peliculas GROUP BY p.genero ORDER BY PuntuacionMedia ASC LIMIT 5;


------------------------------------------------------------------------------------------------------------------------
----                                    CREACION DE USUARIOS Y TRIGGERS                                             ----
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
----                                              TRIGGERS                                                          ----
------------------------------------------------------------------------------------------------------------------------
\echo "---------------------- Creacion de usuarios y triggers -----------------"

------   Crear tabla auditoria  ------

CREATE TABLE auditoria(
    operation char(1),
    stamp     timestamp,
    userid    text,
    last_date timestamp,
    last_change text,
    tabla    text
);
 



------   Crear funcion para auditoria ------
CREATE OR REPLACE FUNCTION auditoria() RETURNS TRIGGER AS $audit$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    INSERT INTO auditoria(last_date, operation, stamp, userid, last_change, tabla)
    VALUES (current_timestamp, 'U', now(), current_user, NEW, TG_TABLE_NAME);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO auditoria(last_date, operation, stamp, userid, last_change, tabla)
    VALUES (current_timestamp, 'D', now(), current_user, OLD, TG_TABLE_NAME);
    RETURN OLD;
  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO auditoria(last_date, operation, stamp, userid, last_change, tabla)
    VALUES (current_timestamp, 'I', now(), current_user, NEW, TG_TABLE_NAME);
    RETURN NEW;
  END IF;
END;
$audit$ LANGUAGE plpgsql;


------------------------------------------------------------------------------------------------------------------------
----                                              TRIGGERS                                                          ----
------------------------------------------------------------------------------------------------------------------------


CREATE TRIGGER peliculas_auditoria BEFORE INSERT OR UPDATE ON "Peliculas"
    FOR EACH ROW EXECUTE FUNCTION auditoria();

CREATE TRIGGER personal_auditoria BEFORE INSERT OR UPDATE ON "Personal"
    FOR EACH ROW EXECUTE FUNCTION auditoria();

CREATE TRIGGER actores_auditoria BEFORE INSERT OR UPDATE ON "Actores"
    FOR EACH ROW EXECUTE FUNCTION auditoria();

CREATE TRIGGER directores_auditoria BEFORE INSERT OR UPDATE ON "Directores"
    FOR EACH ROW EXECUTE FUNCTION auditoria();

CREATE TRIGGER guionistas_auditoria BEFORE INSERT OR UPDATE ON "Guionistas"
    FOR EACH ROW EXECUTE FUNCTION auditoria();

CREATE TRIGGER actuan_auditoria BEFORE INSERT OR UPDATE ON "Actuan"
    FOR EACH ROW EXECUTE FUNCTION auditoria();

CREATE TRIGGER guionizan_auditoria BEFORE INSERT OR UPDATE ON "Guionizan"
    FOR EACH ROW EXECUTE FUNCTION auditoria();

CREATE TRIGGER paginaweb_auditoria BEFORE INSERT OR UPDATE ON "Paginaweb"
    FOR EACH ROW EXECUTE FUNCTION auditoria();

CREATE TRIGGER caratulas_auditoria BEFORE INSERT OR UPDATE ON "Caratulas"
    FOR EACH ROW EXECUTE FUNCTION auditoria();

CREATE TRIGGER criticas_auditoria BEFORE INSERT OR UPDATE ON "Criticas"
    FOR EACH ROW EXECUTE FUNCTION auditoria();

CREATE TRIGGER alojadas_auditoria BEFORE INSERT OR UPDATE ON "Alojadas"
    FOR EACH ROW EXECUTE FUNCTION auditoria();









------   Pruebas de auditoria ------

\echo "----- Pruebas de auditoria -----"
\echo "INSERT INTO "Peliculas" (anio, titulo, idioma, duracion, calificacion, nombre_personal_directores, genero)" 
\echo "VALUES (2021, 'The Intouchables', 'en', 112, 'R', 'Enno Patalas', 'Biography, Comedy, Drama');"

INSERT INTO "Peliculas" (anio, titulo, idioma, duracion, calificacion, nombre_personal_directores, genero)
VALUES (2021, 'The Intouchables', 'en', 112, 'R', 'Enno Patalas', 'Biography, Comedy, Drama');

INSERT INTO "Personal" (nombre, anio_nacimiento, anio_muerte)
VALUES ('EnnoS PatalasS', 1932, 2018);

INSERT INTO "Actores" ("nombre_Personal")
VALUES ('EnnoS PatalasS');


\echo "------- Resultado de auditoria -------"
SELECT * FROM auditoria;



------   Crear funcion para introducir pagina web ------
--CREATE TABLE IF NOT EXISTS public."Paginaweb"

CREATE OR REPLACE FUNCTION check_webpage() RETURNS TRIGGER AS $pagina_cambio$
BEGIN
    INSERT INTO public."Paginaweb" (pagina_web) VALUES (NEW.pagina_web_pagina_web);
    RETURN NEW;
END;
$pagina_cambio$ LANGUAGE plpgsql;

CREATE TRIGGER check_webpage_before_insert
BEFORE INSERT ON "Caratulas"
FOR EACH ROW EXECUTE FUNCTION check_webpage();

CREATE TRIGGER check_webpage_before_insert
BEFORE INSERT ON "Criticas"
FOR EACH ROW EXECUTE FUNCTION check_webpage();

\echo "------- Pruebas de pagina web -------"
\echo "INSERT INTO "Caratulas" (nombre_caratula, tamanio, anio_peliculas, titulo_peliculas, pagina_web_pagina_web)"
\echo "VALUES ('The Intouchables', 'Carátula_mediana', 2021, 'The Intouchables', 'https://palomitas.com/películas/The Intouchables_Carátula_mediana.jpg');"

INSERT INTO "Caratulas" (nombre_caratula, tamanio, anio_peliculas, titulo_peliculas, pagina_web_pagina_web)
VALUES ('Hellboy', 'Carátula_mediana', 2004, 'Hellboy', 'https://palomitas.com/películas/hellboy_Carátula_mediana.jpg');

INSERT INTO "Criticas" (anio_peliculas, titulo_peliculas, nombre_critico, puntuacion, texto_critica, pagina_web_pagina_web)
VALUES (2004, 'Hellboy', 'Roger Ebert', 3.5, 'The movie is entertaining in its own way, but it''s a long way from the top shelf of recent comic book movies.', 'https://www.rogerebert.com/reviews/hellboy-2004');



------   Puntuacion media de las peliculas ------
CREATE TABLE IF NOT EXISTS public.puntuacion_media
(
    nombre_pelicula text,
    puntuacion_media float
);


------   Crear funcion para puntuacion media ------

CREATE OR REPLACE FUNCTION puntuacion_media() RETURNS TRIGGER AS $puntuacion_media$
BEGIN
    RAISE NOTICE 'Updating average rating for %', NEW.titulo_peliculas;
    IF EXISTS (SELECT 1 FROM public.puntuacion_media WHERE nombre_pelicula = NEW.titulo_peliculas) THEN
        UPDATE public.puntuacion_media
        SET puntuacion_media = (SELECT AVG(c.puntuacion) 
        FROM public."Criticas" c WHERE c.titulo_peliculas = NEW.titulo_peliculas AND c.anio_peliculas = NEW.anio_peliculas)
        WHERE nombre_pelicula = NEW.titulo_peliculas;
    ELSE
        INSERT INTO public.puntuacion_media (nombre_pelicula, puntuacion_media)
        VALUES (NEW.titulo_peliculas, (SELECT AVG(c.puntuacion) 
        FROM public."Criticas" c WHERE c.titulo_peliculas = NEW.titulo_peliculas AND c.anio_peliculas = NEW.anio_peliculas));
    END IF;
    RAISE NOTICE 'Average rating updated to %', (SELECT puntuacion_media FROM public.puntuacion_media WHERE nombre_pelicula = NEW.titulo_peliculas);
    RETURN NULL;
END;
$puntuacion_media$ LANGUAGE plpgsql;


------   trigger de puntuacion media ------
CREATE TRIGGER puntuacion_media
AFTER INSERT OR UPDATE ON "Criticas"
FOR EACH ROW EXECUTE FUNCTION puntuacion_media();


------   Pruebas de puntuacion media ------

\echo "------- Pruebas de puntuacion media -------"
\echo " prueba de insercion de pelicula con puntuacion media"
INSERT INTO "Criticas" (anio_peliculas, titulo_peliculas, nombre_critico, puntuacion, texto_critica, pagina_web_pagina_web)VALUES (2004, 'Hellboy', 'Roger EbertPO', 3.5, 'The movie is entertaining in its own way, but it''s a long way from the top shelf of recent comic book movies.', 'https://www.rogerebertO.com/reviews/hellboy-2004');
SELECT * FROM public.puntuacion_media;

\echo " prueba de update de todas las criticas"

UPDATE public."Criticas"
SET puntuacion = puntuacion;
SELECT * FROM public.puntuacion_media;



------------------------------------------------------------------------------------------------------------------------
----                                              USUARIOS                                                          ----
------------------------------------------------------------------------------------------------------------------------


\echo "---------------------- Creacion de usuarios -----------------"
CREATE USER administrador WITH PASSWORD 'administrador';
CREATE USER gestor WITH PASSWORD 'gestor';
CREATE USER critico WITH PASSWORD 'critico';
CREATE USER cliente WITH PASSWORD 'cliente';

--quitar permsos a los usuarios
REVOKE ALL PRIVILEGES ON DATABASE postgres FROM administrador;
REVOKE ALL PRIVILEGES ON DATABASE postgres FROM gestor;
REVOKE ALL PRIVILEGES ON DATABASE postgres FROM critico;
REVOKE ALL PRIVILEGES ON DATABASE postgres FROM cliente;
--permisos administrador
GRANT ALL PRIVILEGES ON DATABASE postgres TO administrador;
GRANT INSERT, UPDATE, DELETE, SELECT ON ALL TABLES IN SCHEMA public TO administrador;
--permisos gestor
GRANT INSERT, UPDATE, DELETE, SELECT ON ALL TABLES IN SCHEMA public TO gestor;
--permisos critico
GRANT SELECT ON ALL TABLES IN SCHEMA public TO critico;
GRANT INSERT, UPDATE,TR

--permisos cliente
GRANT SELECT ON ALL TABLES IN SCHEMA public TO cliente;






COMMIT;






