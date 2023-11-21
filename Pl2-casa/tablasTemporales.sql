

-- USAR ESTA TABLA COMO AUXILIAR PARA VER COMO QUITLARLE LAS COSAS INUTILES, aprender como transformarlo y hacer al hacer insert en la tabla buena, hacer , hacemos insert into pelis select from peliculas aux.
-- convirtir los espacios blancos en null si ves un blanco poner a null,no

BEGIN;
\pset pager off


CREATE TABLE IF NOT EXISTS public.peliculas1(
anioestreno integer ,
titulo text NOT NULL,
idioma text NOT NULL,
generos text NOT NULL,
duracion text NOT NULL,
calificacion text NOT NULL
);
--SELECT * FROM public.peliculas1;
\copy peliculas1(anioestreno,titulo,generos,idioma,duracion,calificacion) from './csv/peliculas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, ENCODING 'UTF8');


-- SELECT duracion, CAST (SUBSTRING(duracion FROM '^[0-9]+') AS INTEGER) AS duracion FROM public.peliculas1; para hacer la comparación --filtrar de int mins, quitar la palabra mins
--SELECT CAST (SUBSTRING(duracion FROM '[0-9]+') AS INTEGER) AS duracion FROM public.peliculas1;




CREATE TABLE IF NOT EXISTS public.criticas1(
critica text NOT NULL,
nombre_critico text NOT NULL,
anioestreno_pelicula integer NOT NULL,
titulo_pelicula text NOT NULL,
paginaweb text NOT NULL,
puntuacion float NOT NULL 
);
--SELECT * FROM public.criticas1; 
\copy criticas1(anioestreno_pelicula,titulo_pelicula,nombre_critico,puntuacion,critica,paginaweb) from './csv/criticas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, ENCODING 'UTF8');
--SELECT * FROM public.criticas1; 


CREATE TABLE IF NOT EXISTS public.directores1(
nombre_director text NOT NULL,
anioestreno integer NOT NULL,
titulo text NOT NULL,
ano_nacimiento_director text NOT NULL, -- quitar los /N para limpiar los datos
ano_fallecimiento_director text 
);
\copy directores1(anioestreno,titulo,nombre_director,ano_nacimiento_director,ano_fallecimiento_director) from './csv/directores_peliculas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, ENCODING 'UTF8');
--SELECT * FROM public.directores1;


--SELECT NULLIF(ano_nacimiento_director, '\N') AS ano_nacimiento_director_sin_n FROM public.directores1;
CREATE TABLE IF NOT EXISTS public.actores1(
nombre_actor text NOT NULL,
anioestreno_pelicula integer NOT NULL,
titulo_pelicula text NOT NULL,
ano_nacimiento_actor text NOT NULL, -- quitar los /N para limpiar los datos
ano_fallecimiento_actor text NOT NULL,
nombre_personaje text NOT NULL
);
\copy actores1(anioestreno_pelicula,titulo_pelicula,nombre_actor,ano_nacimiento_actor,ano_fallecimiento_actor,nombre_personaje) from './csv/actores_peliculas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, ENCODING 'UTF8');
--SELECT * FROM public.actores1;

CREATE TABLE IF NOT EXISTS public.guionistas1(
nombre_guionista text NOT NULL,
anioestreno_pelicula integer NOT NULL,
titulo_pelicula text NOT NULL,
ano_nacimiento_guionista text NOT NULL, -- quitar los /N para limpiar los datos
ano_fallecimiento_guionista text 
);
\copy guionistas1(anioestreno_pelicula,titulo_pelicula,nombre_guionista,ano_nacimiento_guionista,ano_fallecimiento_guionista) from './csv/guionistas_peliculas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, ENCODING 'UTF8');
--SELECT * FROM public.guionistas1;

--2020	Fortuna	fortuna-2020	2021-04-16 12:56:19	https.//palomitas.com/películas/fortuna-2020_Carátula_mediana.jpg	Carátula_mediana

CREATE TABLE IF NOT EXISTS public.caratulas1(
anioestreno_pelicula integer NOT NULL,
titulo_pelicula text NOT NULL,
fecha text NOT NULL, --cambiar a tipo integer quizas multiplicar por algo cada parte de la fecha para crear un numero comparable
url_caratula text NOT NULL,
tamano text NOT NULL,
nombre_caratula text NOT NULL
);
\copy caratulas1(anioestreno_pelicula,titulo_pelicula,nombre_caratula,fecha,url_caratula,tamano) from './csv/caratulas.csv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, ENCODING 'UTF8');

SELECT nombre_caratula,tamano FROM public.caratulas1;

SELECT COUNT (*) FROM public.caratulas1;
SELECT COUNT (nombre_caratula) FROM public.caratulas1;
--SELECT DISTINT CL1 FROM public.caratulas1;



ROLLBACK;


-- SELECT
-- CASE

--WHEN DURATION NULL THEN 0
--WHEN DURATION LIKE '%min%' THEN SPLIT (DURATION, ' ')[0] :: INTEGER
 --ELSE SPLIT (DURATION), ' ')[1] :: INTEGER
 --END AS COLMNA DE DESTINO
 -- PUEDE HABER REPETIDOS CARGARTE LOS REPETIDOS 
 -- VER QUE LAS TABLAS DE DIRECTORES Y GUINISTAS SI SU PELIS EXISTEN EN LA TABLA DE PELICULAS

 -- PARA LA TABLA ACTORES PELIS, HAY QUE VER QUE CALZE PRIMERO LOS ACTORES Y LEGO LAS PELIS, PERO AL CREAR LA DE DELP ERSONAL PUEDE HABER ALGUIEN QUE SEA las 3 cosas y hay que ver si usamos UNION ALL , O UNION, VER LAS REUNIONES SI TENGO TIEMPO