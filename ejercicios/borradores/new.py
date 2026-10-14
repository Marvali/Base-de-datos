import sys
import psycopg2

OPERATION_QUERY = 'query'
OPERATION_INSERT = 'insert'

VALID_USERS = {
    1: ('administrador', 'administrador'),
    2: ('gestor', 'gestor'),
    3: ('critico', 'critico'),
    4: ('cliente', 'cliente'),
}


class portException(Exception):
    pass


def get_integer_input(prompt):
    while True:
        try:
            return int(input(prompt))
        except ValueError:
            print("Invalid input. Please enter a number.")


def ask_conn_parameters():
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

    connection_params = {
        'host': input('Enter the host: '),
        'port': get_integer_input('Enter the port: '),
        'database': input('Enter the database name: '),
        'user': username,
        'password': password
    }

    return connection_params


def menu():
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
