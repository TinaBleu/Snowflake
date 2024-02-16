---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------   USER DEFINED FUNCTIONS (WITH PYTHON) IN SNOWFLAKE   ------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ############## FUNCIÓN: CONTEO DE CAMBIOS DENTRO DE UN ARRAY ################ --
-- Hoy voy a escribir esto en español porque ¿por que no? Vamos a hacer una función que se encargue de lo siguiente:
/*

1) Tome el array de una columna
 1.1) Cuente los conjuntos de números positivos y ceros (seguidos) por ejemplo:
 input_array = [1,0,0,0,2,3,8,6,0,9,0,8,8,0,0,1,0]
 
 en este caso, tenemos 10 conjutnos de números que se dividen en 5 conjuntos de números positivos y 5 conjuntos de ceros. 

2) Traduce los conjuntos a 1's y 0's. Si traducimos eso a código binario tendríamos lo siguiente:

input_array_bin = [1,0,1,0,1,0,1,0,1,0] donde cada 1 representa a los números positivos y cada 0 a los ceros.

3) Cuenta los cambios que existen dentro del array que van de 0 a 1. Si tomamos el array anterior (input_array_bin) tendríamos un total de 4 cambios.

Consideraciones:
- El código ignora los cambios de 1 a 0.
- El código ignora si el array termina en cero, es decir, si el último número es 0 ese no lo va a contar como un cambio.

*/

CREATE /*OR REPLACE*/ FUNCTION binary_shifts(<arg_name> <data_type>) -- Recuerden que en <arg_name> vamos a poner el nombre de la variable que vamos a recibir, puede ser desde el nombre de la columna hasta cualquier nombre para la variable.
RETURNS INTEGER
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
HANDLER = 'binary_shifts'
AS '
def binary_shifts(<arg_name>):
    # Inicializar variables
    shift = 0
    last_state = 0  # Imaginamos que el estado inicial es cero

    # Por si cambia de estado
    positive_shift = <arg_name>[0] > 0

    for num in <arg_name>:
        # Cambio de cero a algún conjunto positivo
        if num > 0 and last_state == 0:
            shift += 1
            last_state = 1
        elif num == 0:
            last_state = 0

    # Consideración en caso que el <arg_name> comience con números positivos
    if positive_shift:
        shift = max(0, shift - 1)

    return shift
';




/* -------- ############## FUENTES ############### -------------

https://docs.snowflake.com/sql-reference/sql/create-function#python-handler

*/
