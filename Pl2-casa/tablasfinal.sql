-- EJEMPLO DE INSETAR PELICULAS EN LA TABLA PELICULAS
CREATE TABLE IF NOT EXISTS public.peliculas(
anioestreno integer NOT NULL,
titulo text NOT NULL,
generos text NOT NULL,
idioma text NOT NULL,
duracion integer NOT NULL,
calificacion text NOT NULL
);

INSERT INTO peliculas(anioestreno, titulo, generos, idioma, duracion, calificacion)
SELECT anioestreno, titulo, generos, idioma, CAST(SUBSTRING(duracion FROM '[0-9]+') AS INTEGER) AS duracion, calificacion
FROM peliculas1;


INSERT INTO peliculas (anioestreno, titulo, generos, idioma, duracion, calificacion)
SELECT
  anioestreno,
  NULLIF(titulo, 'NULL') AS titulo,
  NULLIF(generos, 'NULL') AS generos,
  NULLIF(idioma, 'NULL') AS idioma,
  NULLIF(CAST(NULLIF(SUBSTRING(duracion FROM '[0-9]+') AS INTEGER) AS INTEGER), 'NULL') AS duracion,
  NULLIF(calificacion, 'NULL') AS calificacion
FROM peliculas1
WHERE anioestreno IS NOT NULL;
-- SI HAGO ESTO COMO PUEDO PONER LO DE NOT NULL EN LA TABLA PELICULAS ,ME CARGO ESA FILA?

-- EJEMPLO DE INSETAR CRITICAS EN LA TABLA CRITICAS


CREATE TABLE IF NOT EXISTS public.criticas(
critica text NOT NULL,
nombre_critico text NOT NULL,
anioestreno_pelicula integer NOT NULL,
titulo_pelicula text NOT NULL,
paginaweb text NOT NULL,
puntuacion float NOT NULL 
);


