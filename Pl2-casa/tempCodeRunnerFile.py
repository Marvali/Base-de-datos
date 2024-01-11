"""
CABEZERA
CREADORES DEL PROGRAMA: Isaac Y Pedro

"""


import sys

import psycopg2

class portException(Exception): pass                                                                                    



def ask_conn_parameters():
    try:  
        """
            ask_conn_parameters:: () -> IO String
            pide los parámetros de conexión
        """
        print ('1. administrador\n2. gestor\n3. critico\n4. cliente\n5. postgres')

        answer = int(input(' ¿Qué usuario quieres usar? '))
        match answer:
            case 1:
                user = 'administrador'
                password = 'administrador'

            case 2:
                user = 'gestor'
                password = 'gestor'

            case 3:
                user = 'critico'
                password = 'critico'
        
            case 4:
                user = 'cliente'
                password = 'cliente'
        
            case 5:
                user = 'postgres'
                password = 'ISAACSAMUEL'

            case other:
                print('No has introducido un usuario válido')
                menu()
        
        answer1 = input ('¿quieres usar los valores default host = localhost, port = 5432, database = postgres? (s/n)')
        if (answer1 == 's'):
            host = 'localhost'
            port = 5432
            database = 'postgres'
        else:
            host = input('Introduce el host: ')
            while True:
                try:
                    port = int(input('TCP port number: '))
                    break
                except ValueError:
                    print("The port is not valid!")
            database = input('Introduce el nombre de la base de datos: ')

        
    except portException:
        print("The port is not valid!")
    except KeyboardInterrupt:
        print("Program interrupted by user.")
    finally:
        return (host, port, user, password, database)


def menu():
    print ('1. Consulta\n2. Insertar\n0. Salir')

    eleccion = int(input('¿Qué quieres hacer?'))

    match eleccion:
        case 1:
            consulta = input('Introduce la consulta: ')
            return consulta, 'query'
        
        case 2:
            critica = input('Introduce la crítica: ')
            return critica, 'insert'
        
        case 0:
            sys.exit()

        case other:
            print('No has introducido una opción válida: ')
            menu()


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
            except psycopg2.errors.UndefinedTable:
                print("La tabla no existe")
            except psycopg2.errors.SyntaxError:
                print("Error de sintaxis")
            cur.close()
    except portException:
        print("The port is not valid!")
    except KeyboardInterrupt:
        print("Program interrupted by user.")
    finally:
        print("Program finished")
if __name__ == "__main__":                                                 
    if '--test' in sys.argv:                                                    
        import doctest                                                           
        doctest.testmod()                                                      
    else:                                                                      
        main()