import sys

import psycopg2

class portException(Exception): pass                                                                                    



def ask_conn_parameters():
    try:  
        """
            ask_conn_parameters:: () -> IO String
            pide los parámetros de conexión
        """
        print ('1. administrador')
        print ('2. gestor')
        print ('3. critico')
        print ('4. cliente')
        print ('5.postgres')
        answer = input(' ¿Qué usuario quieres usar? ')
        if (answer == '1'):
            user = 'administrador'
            password = 'administrador'

        elif (answer == '2'):
            user = 'gestor'
            password = 'gestor'

        elif (answer == '3'):
            user = 'critico'
            password = 'critico'
        
        elif (answer == '4'):
            user = 'cliente'
            password = 'cliente'
        
        elif (answer == '5'):
            user = 'postgres'
            password = 'ISAACSAMUEL'

        else:
            print('No has introducido un usuario válido')
            sys.exit()
        
        answer1 = input ('¿quieres usar los valores default host = localhost, port = 5432, database = postgres? (s/n)')
        if (answer1 == 's'):
            host = 'localhost'
            port = 5432
            database = 'postgres'
        else:
            host = input('Introduce el host')
            port = ask_port('TCP port number: ')
            database = input('Introduce el nombre de la base de datos')


        
    except portException:
        print("The port is not valid!")
    except KeyboardInterrupt:
        print("Program interrupted by user.")
    finally:
        return (host, port, user, password, database)


def menu():
    print ('1. Consulta')
    print ('2. Insertar')
    print ('0. Salir')
    eleccion = input('¿Qué quieres hacer?')
    while eleccion != '3':
        if eleccion == '1':
            consulta = input('Introduce la consulta')
            return consulta, 'query'
        elif eleccion == '2':
            critica = input('Introduce la crítica')
            return critica, 'insert'
        elif eleccion == '0':
            sys.exit()
        else:
            print('No has introducido una opción válida')
        eleccion = input('¿Qué quieres hacer?')


def main():
    try:
        (host, port, user, password, database) = ask_conn_parameters()
        connstring = f'host={host} port={port} user={user} password={password} dbname={database}'
        conn = psycopg2.connect(connstring)                           
        
        while True:
            cur = conn.cursor()
            operation, operation_type = menu()
            if operation is None:
                break
            try:
                cur.execute(operation)
                if operation_type == 'query':
                    for record in cur.fetchall():
                        print(record)
                elif operation_type == 'insert':
                    conn.commit()
            except psycopg2.errors.InsufficientPrivilege:
                print("No tienes permisos para hacer esta operación, intenta con otro usuario")
            cur.close()
    except portException:
        print("The port is not valid!")
    except KeyboardInterrupt:
        print("Program interrupted by user.")
    finally:
        print("Program finished")
if __name__ == "__main__":                                                      # Es el modula principal?
    if '--test' in sys.argv:                                                    # Si el usuario ha escrito --test
        import doctest                                                           
        doctest.testmod()                                                       # Ejecuta las pruebas
    else:                                                                       # else
        main()                                                                  # ejecuta el programa principal



    






