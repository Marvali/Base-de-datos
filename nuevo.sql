-- esto es un comentario variable de entorno
-- password isaacsamuel
-- passwordCASA ISAACSAMUEL

-- para hablar con el cmd \! dir ejemplo\
-- \c [Nombre la de DB]: conexión a una base de datos
-- \l lista todas las bases de datos existentes
--\d lista todas las tablas
--\d [Nombre de tabla]: lista todos los atributos de la tabla
--\i [Nombre y ruta de un fichero *.sql]: Ejecuta el código SQL del
--fichero
--\o [Nombre y ruta de un fichero]: Escribe el resultado del código SQL
--en el fichero correspondiente en lugar de mostrarlo por la consola


\pset pager off

BEGIN;

-- TODO LO DEL MEDIO DESAPARECERA
/*
\echo : 'Creando la tabla de usuarios'
CREATE TABLE peliculas(
    anio INTEGER,
    titulo VARCHAR(255),
    generos VARCHAR(255),
    puntuacion REAL,
    duracion VARCHAR(255),
    idioma VARCHAR(255),
    calificacion VARCHAR(255)
    );
   -- \d nuevo.sql ¿¿puedo ahcer esto dentro del scrpt??
    -- ¿¿como se que se creo antes del rollback??
    --ROLLBACK;

*/


\copy peliculas(anio,titulo,generos,puntuacion,duracion,idioma,calificacion) from 'C:\Users\isaac\Documents\GitHub\Base-de-datos\peliculas.csv' delimiter ',' csv header;
 --select * from peliculas where puntuacion>8.5;    