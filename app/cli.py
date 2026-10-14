"""Cliente de consola para la base de datos de películas (PostgreSQL).

Permite conectarse con uno de los roles definidos en sql/peliculas_db.sql
(administrador, gestor, critico, cliente) y lanzar consultas o inserciones.
Las contraseñas no se guardan en el código: se piden por teclado.

Uso:
    pip install -r app/requirements.txt
    python app/cli.py
"""
import getpass
import sys

import psycopg2
from psycopg2 import OperationalError, errors

OPERATION_QUERY = "query"
OPERATION_INSERT = "insert"

# Roles creados por el script SQL.
ROLES = {
    1: "administrador",
    2: "gestor",
    3: "critico",
    4: "cliente",
    5: "postgres",
}


def get_integer_input(prompt):
    """Pide un entero por teclado hasta que el valor introducido sea válido."""
    while True:
        try:
            return int(input(prompt))
        except ValueError:
            print("Entrada no válida. Introduce un número.")


def ask_conn_parameters():
    """Pide el rol y los parámetros de conexión."""
    print("Selecciona un usuario:")
    for num, name in ROLES.items():
        print(f"{num}. {name}")

    choice = get_integer_input("Número de usuario: ")
    while choice not in ROLES:
        choice = get_integer_input("Opción no válida. Número de usuario: ")

    password = getpass.getpass("Contraseña: ")

    if input("¿Usar valores de conexión por defecto? (s/n): ").lower() == "s":
        host, port, database = "localhost", 5432, "postgres"
    else:
        host = input("Host: ")
        port = get_integer_input("Puerto: ")
        database = input("Base de datos: ")

    return {
        "host": host,
        "port": port,
        "dbname": database,
        "user": ROLES[choice],
        "password": password,
    }


def menu():
    """Muestra el menú y devuelve (sentencia, tipo de operación)."""
    while True:
        print("1. Consulta\n2. Insertar\n0. Salir")
        choice = get_integer_input("¿Qué quieres hacer? ")
        if choice == 1:
            return input("Introduce la consulta: "), OPERATION_QUERY
        if choice == 2:
            return input("Introduce la sentencia de inserción: "), OPERATION_INSERT
        if choice == 0:
            sys.exit()
        print("No has introducido una opción válida.")


def main():
    conn = None
    try:
        conn = psycopg2.connect(**ask_conn_parameters())
        while True:
            statement, kind = menu()
            with conn.cursor() as cur:
                try:
                    cur.execute(statement)
                    if kind == OPERATION_QUERY:
                        for record in cur.fetchall():
                            print(record)
                    else:
                        conn.commit()
                except errors.InsufficientPrivilege:
                    conn.rollback()
                    print("No tienes permisos para esta operación; prueba con otro usuario.")
                except errors.UndefinedTable:
                    conn.rollback()
                    print("La tabla no existe.")
                except errors.SyntaxError:
                    conn.rollback()
                    print("Error de sintaxis.")
                except psycopg2.Error as e:
                    conn.rollback()
                    print(f"Error de base de datos: {e}")
    except OperationalError as e:
        print(f"No se pudo conectar a la base de datos: {e}")
    except (KeyboardInterrupt, SystemExit):
        pass
    finally:
        if conn is not None:
            conn.close()
        print("Programa finalizado")


if __name__ == "__main__":
    main()
