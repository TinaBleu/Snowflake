---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------    QUERY GENERADOR DE FECHAS EN ORDEN (1 DÍA POR MES, POR PERSONA/COSA/LO QUE SEA)    -----------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* 
Este query funciona de la siguiente manera:
1) Extrae la información de nuestra tabla existente 
(Si no tienes tabla y también quieres datos sintéticos, te recomiendo 
que primero crees esos datos con los que puedas cruzar esta tabla de tiempo)

2) Genera fechas aleatoras.

3) Cruza los datos de tu tabla de cosas con la tabla de fechas generadas. Es decir, le asigna una fecha por cada cosa que existe en tu tabla. 

*/


WITH COSAS AS ( -- >> Esta primer ventana nos puede servir como "comodín" para poder relacionar nuestras fechas generadas con cualquier otra cosa, por ejemplo lugares, personas, etc.
SELECT DISTINCT <Aqui poner columna/s de interés a las que les queremos asignar fechas>
FROM <Tabla de usuarios, cosas varias que requieran una fecha asignada por cosa>
)
, 
FECHAS_ALEATORIAS AS ( -- >> Esta ventana nos va a generar los días consecutivos.
SELECT 
row_number() OVER (ORDER BY SEQ4()) AS dias
, TO_DATE(DATEADD(day, dias, '2020-01-01')) AS FECHA_GENERADA -- >> Esta es la fecha desde donde queremos que se generen las demás fechas. 
FROM TABLE(GENERATOR(rowcount=>730)) -- >> Este es el número de días que queremos generar. En este caso son 365*2 = 730 días.
)
, ROW_NUM AS ( -- >> En esta ventana vamos a truncar todos los días al mes, es decir, la función DATE_TRUNC nos va a 
                 ---   limitar los días al 1ro de cada mes; por lo que tendremos fechas repetidas. Por ejemplo, si 
                 ---   teniamos 19-02-2020 después de haber aplicado el DATE_TRUNC tendremos 01-02-2020 
    SELECT DATE_TRUNC(MONTH,FECHA_GENERADA) AS FECHAS_TRUNCADAS
    , ROW_NUMBER() OVER (PARTITION BY FECHAS_TRUNCADAS ORDER BY FECHAS_TRUNCADAS) RN  -- >> esta línea nos va a generar una columna (RN) 
                                                                              --con todas las fechas iguales enumeradas dentro de una misma partición
    FROM FECHAS_ALEATORIAS
)
, ROW_NUM_FILTER AS ( -- >> Esta ventana se va a encargar de seleccionar la primer ocurrencia de cada partición generada en la ventana anterior (ROW_NUM) 
                        --    por lo que, ahora tendremos una sola fecha por cada mes.
    SELECT *
    FROM ROW_NUM 
    WHERE RN = 1
    )
SELECT FECHAS_TRUNC AS FECHA_OBS
, <COSA_ID>  -- >> Aqui se selecciona la columna/lo que se quiere asignar a cada fecha generada en la ventana anterior (que a su vez, es resultado de l
             --    as ventanas anteriores). ¿Se pueden incluir mas cosas? claro que si, pero debes tomar en cuenta que entre más columnas, el CROSS JOIN 
             --    va amultiplicarlas entre si, por lo que los resultados pueden exponencializarse.
FROM COSAS  
CROSS JOIN ROW_NUM_FILTER;

/*

Espero que te sea de ayuda :) happy coding!

*/
