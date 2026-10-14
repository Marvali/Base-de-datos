# Base de datos de películas · PostgreSQL

Diseño e implementación completa de una base de datos relacional de cine: modelado, carga y depuración de datos desde CSV, consultas analíticas, **triggers de auditoría y lógica de negocio**, **roles con permisos diferenciados** y un cliente de consola en Python.

Proyecto en pareja del grado en Ingeniería en Sistemas de Información (Universidad de Alcalá, Bases de Datos 2023-24, PECL2 + PECL3).

**Autores:** Isaac Marval Hernández · Pedro Bustos Sánchez

## Qué demuestra este proyecto

| Área | Contenido |
|---|---|
| Modelado relacional | 11 tablas con claves primarias compuestas y claves foráneas (películas, personal, actores, directores, guionistas, carátulas, críticas, páginas web…) |
| ETL en SQL | Carga con `\copy` a tablas auxiliares y depuración con `NULLIF`, `REGEXP_REPLACE`, `SUBSTRING`, `CAST`, `DISTINCT ON`, `UNION` (~8 000 filas en 6 CSV) |
| Consultas | 10 consultas con `JOIN`, `GROUP BY`, `HAVING`, subconsultas y agregados |
| PL/pgSQL | Función y triggers de **auditoría** (INSERT/UPDATE/DELETE) sobre todas las tablas, alta automática de páginas web y **puntuación media** recalculada con cada crítica |
| Seguridad | Cuatro roles (`administrador`, `gestor`, `critico`, `cliente`) con `GRANT`/`REVOKE` según el principio de mínimo privilegio |
| Python | Cliente de consola con `psycopg2` que gestiona permisos, errores y transacciones |

## Estructura

```
sql/peliculas_db.sql   Script único: tablas, carga, consultas, triggers y usuarios
data/                  CSV de entrada (películas, reparto, direcciones, guiones, carátulas, críticas)
app/cli.py             Cliente de consola en Python
docs/esquema.md        Modelo de datos y descripción de triggers y roles
```

## Cómo ejecutarlo

Requisitos: PostgreSQL 12+ con `psql`, y (opcional) Python 3.9+.

```bash
# Desde la raíz del repositorio (los \copy usan rutas relativas a ./data/)
psql -U postgres -d postgres -f sql/peliculas_db.sql
```

El script se ejecuta en una sola transacción y muestra por pantalla el resultado de las consultas y de las pruebas de triggers.

Cliente Python (opcional):

```bash
pip install -r app/requirements.txt
python app/cli.py
```

## Documentación

El modelo de datos (diagrama E-R), los triggers y los permisos de cada rol están descritos en [docs/esquema.md](docs/esquema.md).

## Notas

- Los usuarios de demostración se crean con contraseñas simples (`administrador`, `gestor`…) solo con fines didácticos; en un entorno real habría que cambiarlas.
- Los datos son sintéticos/de práctica.
