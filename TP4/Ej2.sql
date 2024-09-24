-- Ejercicio 2
    -- 1.
    create or replace view empleado_dist_20
        as (select id_empleado, nombre, apellido, sueldo, fecha_nacimiento from empleado
            where id_distribuidor = 20);

    select * from empleado_dist_20;
    -- Estandar SQL: vista actualizable porque conserva la columna de la clave primaria, no tiene funciones de agregacion, no tiene clausula DISTINCT y no tiene subconsultas en el SELECT.
    -- PostgreSQL: vista actualizable porque tiene solo una entrada en el FROM, no contiene DISTINCT, WITH, GROUP BY, HAVING, LIMIT ni OFFSET. No tiene operadores de conjunto, y no tiene funciones de agregacion.

    -- 2.
    create or replace view empleado_dist_2000
        as (select id_empleado, nombre, apellido, sueldo from empleado_dist_20
            where sueldo > 2000);

    select * from empleado_dist_2000 order by sueldo;
    -- Estandar SQL: vista actualizable porque conserva la columna de la clave primaria, no tiene funciones de agregacion, no tiene clausula DISTINCT y no tiene subconsultas en el SELECT.
    -- PostgreSQL: vista actualizable porque tiene solo una entrada en el FROM, no contiene DISTINCT, WITH, GROUP BY, HAVING, LIMIT ni OFFSET. No tiene operadores de conjunto, y no tiene funciones de agregacion.

    -- 3,
    create or replace view empleado_dist_20_70
        as (select * from empleado_dist_20 where extract(year from fecha_nacimiento) between 1970 and 1979);

    select * from empleado_dist_20_70;
    -- Estandar SQL: vista actualizable porque conserva la columna de la clave primaria, no tiene funciones de agregacion, no tiene clausula DISTINCT y no tiene subconsultas en el SELECT.
    -- PostgreSQL: vista actualizable porque tiene solo una entrada en el FROM, no contiene DISTINCT, WITH, GROUP BY, HAVING, LIMIT ni OFFSET. No tiene operadores de conjunto, y no tiene funciones de agregacion.

    -- 4.
    create or replace view peliculas_entregadas
        as (select codigo_pelicula, sum(cantidad) from renglon_entrega
            group by codigo_pelicula);

    select * from peliculas_entregadas where codigo_pelicula = 12660;
    select * from renglon_entrega where codigo_pelicula = 12660;

    -- Estandar SQL: no es automaticamente actualizable porque tiene una funcion de agregacion.
    -- Postgre SQL: no es automaticamente actualizable porque tiene una funcion de agregacion.

    -- 5.
    create or replace view distrib_nac
        as (select id_distribuidor, nro_inscripcion, encargado from nacional
            where id_distribuidor IN
                (select id_distribuidor from internacional
                    where codigo_pais = 'AR'));

    select * from distrib_nac;
    -- Estandar SQL: vista actualizable porque conserva la columna de la clave primaria, no tiene funciones de agregacion, no tiene clausula DISTINCT y no tiene subconsultas en el SELECT.
    -- PostgreSQL: vista actualizable porque tiene solo una entrada en el FROM, no contiene DISTINCT, WITH, GROUP BY, HAVING, LIMIT ni OFFSET. No tiene operadores de conjunto, y no tiene funciones de agregacion.

    -- 6.
    create or replace view distrib_nac_mas2emp
        as (select * from distrib_nac
            where id_distribuidor IN
                (select id_distribuidor from distribuidor
                 where id_distribuidor IN
                    (select id_distribuidor from empleado))
            group by id_distribuidor, nro_inscripcion, encargado HAVING count(*) > 2);

    select * from distrib_nac_mas2emp; -- no hay departamentos de distribuidoras Argentinas con mas de 2 empleados
    -- Estandar SQL: es automaticamente actualizable.
    -- Postgre SQL: no es automaticamente actualizable porque tiene una clausula GROUP BY y HAVING en el top level.
