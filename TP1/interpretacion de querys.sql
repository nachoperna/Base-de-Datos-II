-- 25. Analice los resultados de los siguientes grupos de consultas:

-- A.1
    SELECT avg(porcentaje), count(porcentaje), count(*)
    FROM voluntario;
    -- Muestra el promedio del porcentaje de todos los voluntarios, la cantidad de porcentajes registrados, y la cantidad de voluntarios registrados.

-- A.2
    SELECT avg(porcentaje), count(porcentaje), count(*)
    FROM voluntario WHERE porcentaje IS NOT NULL;
     -- Muestra el promedio del porcentaje de todos los voluntarios, la cantidad de voluntarios con porcentaje no nulo, y la cantidad de voluntarios registrados.

-- A.3
    SELECT avg(porcentaje), count(porcentaje), count(*)
    FROM voluntario WHERE porcentaje IS NULL;
    -- Muestra el promedio del porcentaje de todos los voluntarios, la cantidad de porcentajes nulos, y la cantidad de voluntarios registrados.

-- B.1
    SELECT * FROM voluntario
    WHERE nro_voluntario NOT IN (SELECT id_director FROM institucion);
    -- Muestra todos los datos de voluntarios que no son directores de alguna institucion.

-- B.2
    SELECT * FROM voluntario
    WHERE nro_voluntario NOT IN (SELECT id_director FROM institucion WHERE id_director IS NOT NULL);
    -- Muestra todos los datos de voluntarios que no son directores de alguna institucion en la que hay un director.

-- C.1
    SELECT i.id_institucion, count(*)
    FROM institucion i LEFT JOIN voluntario v
    ON (i.id_institucion = v.id_institucion)
    GROUP BY  i.id_institucion;
    -- Muestra los identificadores de institucion y la cantidad de voluntarios que trabajan en ella.

-- C.2
    SELECT v.id_institucion, count(*)
    FROM institucion i LEFT JOIN voluntario v
    ON (i.id_institucion = v.id_institucion);
    -- Muestra el identificador de institucion y la cantidad de instituciones que tienen voluntarios trabajando.

