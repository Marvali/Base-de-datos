import sys
import psycopg2
from psycopg2 import OperationalError

OPERATION_QUERY = 'query'
OPERATION_INSERT = 'insert'

VALID_USERS = {
    1: ('administrador', 'administrador'),
    2: ('gestor', 'gestor'),
    3: ('critico', 'critico'),
    4: ('cliente', 'cliente'),
    5: ('postgres', 'ISAACSAMUEL')
}


class portException(Exception):
    pass


def get_integer_input(prompt):
    """Ask the user for an integer input, and keep asking until a valid integer is entered."""
    while True:
        try:
            return int(input(prompt))
        except ValueError:
            print("Invalid input. Please enter a number.")


def ask_conn_parameters():
    """Ask the user for connection parameters."""
    print('Select a user:')
    for num, (username, _) in VALID_USERS.items():
        print(f'{num}. {username}')

    while True:
        user_choice = get_integer_input('Enter the number for your user: ')
        if user_choice in VALID_USERS:
            break
        else:
            print("Invalid choice. Please select a valid user.")

    username, _ = VALID_USERS[user_choice]
    password = input('Enter your password: ')

    answer_default = input('Do you want to use default connection values? (s/n): ')
    if answer_default.lower() == 's':
        host, port, database = 'localhost', 5432, 'postgres'
    else:
        host = input('Enter the host: ')
        port = get_integer_input('Enter the port: ')
        database = input('Enter the database name: ')

    connection_params = {
        'host': host,
        'port': port,
        'database': database,
        'user': username,
        'password': password
    }

    return connection_params


def menu():
    """Show the menu and ask the user for an option."""
    print('1. Consulta\n2. Insertar\n0. Salir')

    eleccion = int(input('¿Qué quieres hacer?'))

    if eleccion == 1:
        return input('Introduce la consulta: '), OPERATION_QUERY
    elif eleccion == 2:
        return input('Introduce la crítica: '), OPERATION_INSERT
    elif eleccion == 0:
        sys.exit()
    else:
        print('No has introducido una opción válida: ')
        menu()


def main():
    try:
        connection_params = ask_conn_parameters()
        connstring = f'host={connection_params["host"]} port={connection_params["port"]} user={connection_params["user"]} password={connection_params["password"]} dbname={connection_params["database"]}'
        conn = psycopg2.connect(connstring)

        while True:
            cur = conn.cursor()
            operation, operation_type = menu()
            if operation is None:
                break
            try:
                cur.execute(operation)
                if operation_type == OPERATION_QUERY:
                    for record in cur.fetchall():
                        print(record)
                elif operation_type == OPERATION_INSERT:
                    conn.commit()
            except psycopg2.errors.InsufficientPrivilege:
                print("No tienes permisos para hacer esta operación, intenta con otro usuario")
            except psycopg2.errors.UndefinedTable:
                print("La tabla no existe")
            except psycopg2.errors.SyntaxError:
                print("Error de sintaxis")
            except OperationalError as e:
                print(f"Could not connect to the database: {e}")
                return
            except psycopg2.errors.InFailedSqlTransaction:
                print("The transaction could not be completed.")
                conn.rollback()
            finally:
                cur.close()
    except portException:
        print("The port is not valid!")
    except KeyboardInterrupt:
        print("Program interrupted by user.")
    finally:
        conn.close()
        print("Program finished")


if __name__ == "__main__":
    if '--test' in sys.argv:
        import doctest

        doctest.testmod()
    else:
        main()




"""
elif eleccion == 4:
                table_name = input('Introduce el nombre de la tabla: ')
                num_params = int(input('Introduce el número de condiciones a consultar: '))

                params = []
                for i in range(num_params):
                    param_name = input(f'Introduce el nombre del parámetro {i+1}: ')
                    param_value = input(f'Introduce el valor del parámetro {i+1}: ')
                    params.append((param_name, param_value))

                param_conditions = ' AND '.join(f"{name} = '{value}'" for name, value in params)

                query_statement = f"SELECT * FROM {table_name} WHERE {param_conditions}"

                return query_statement, OPERATION_QUERY_WITH_PARAMS



"""