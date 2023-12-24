def main():
    """
        main :: () -> IO None
    """
    try:
        (host, port, user, password, database) = ask_conn_parameters()
        connstring = f'host={host} port={port} user={user} password={password} dbname={database}'
        conn    = psycopg2.connect(connstring)                           
        
        while True:
            cur = conn.cursor()
            operation, operation_type = menu()
            if operation is None:
                break
            cur.execute(operation)
            if operation_type == 'query':
                for record in cur.fetchall():
                    print(record)
            elif operation_type == 'insert':
                conn.commit()
            cur.close()                                                           # cierra la conexion
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

