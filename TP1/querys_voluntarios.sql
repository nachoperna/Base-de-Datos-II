-- 1. Muestre el apellido, nombre, las horas aportadas y la fecha de nacimiento de todos los voluntarios cuya tarea sea IT_PROG o ST_CLERK y cuyas horas aportadas no sean iguales a 2.500, 3.500 ni 7.000. Ordene por apellido y nombre.
SELECT apellido, nombre, horas_aportadas, fecha_nacimiento
FROM voluntario
WHERE (id_tarea = 'IT_PROG' OR id_tarea = 'ST_CLERK')  AND (horas_aportadas NOT IN (2500|3500|7000))
ORDER BY apellido, nombre;

-- 2. Genere un listado ordenado por número de voluntario, incluyendo también el nombre y apellido y el e-mail de los voluntarios con menos de 10000 horas aportadas. Coloque como encabezado de las columnas los títulos ‘Numero’, 'Nombre y apellido' y 'Contacto'.
SELECT  nro_voluntario AS "Numero", nombre||', '||apellido AS "Nombre y Apellido", e_mail AS "Contacto"
FROM voluntario
WHERE horas_aportadas < 10000
ORDER BY nro_voluntario;

-- 3. Genere un listado de los distintos id de coordinadores en la base de Voluntariado. Tenga en cuenta de no incluir el valor nulo en el resultado.
SELECT DISTINCT id_coordinador
FROM voluntario;

-- 4. Muestre los códigos de las diferentes tareas que están desarrollando los voluntarios que no registran porcentaje de donación.
SELECT id_tarea
FRom voluntario
WHERE porcentaje IS NULL;

-- 5. Muestre los 5 voluntarios que poseen más horas aportadas y que hayan nacido después del año 1995.
SELECT nro_voluntario, horas_aportadas, fecha_nacimiento
FROM voluntario
WHERE extract(year from fecha_nacimiento) >= 1995
ORDER BY horas_aportadas DESC
LIMIT 5;

-- 6. Liste el id, apellido, nombre y edad (expresada en años) de los voluntarios con fecha de cumpleaños en el mes actual. Limite el resultado a los 3 voluntarios de mayor edad.
SELECT nro_voluntario, apellido, nombre, extract(year from fecha_nacimiento) AS "edad"
FROM voluntario
WHERE extract(month from fecha_nacimiento) = extract(month from current_date)
ORDER BY "edad"
LIMIT 3;

-- 7. Encuentre la cantidad mínima, máxima y promedio de horas aportadas por los voluntarios de más de 30 años.
SELECT nro_voluntario, min(horas_aportadas), max(horas_aportadas), avg(horas_aportadas)
FROM voluntario
GROUP BY nro_voluntario HAVING extract(year from age(fecha_nacimiento, current_date)) > 30;

-- 8. Por cada institución con identificador conocido, indicar la cantidad de voluntarios que trabajan en ella y el total de horas que aportan.
SELECT id_institucion, COUNT(*) AS "Cant voluntarios", horas_aportadas
FROM voluntario
GROUP BY id_institucion, horas_aportadas;

-- 9. Muestre el identificador de las instituciones y la cantidad de voluntarios que trabajan en ellas, sólo de aquellas instituciones que tengan más de 10 voluntarios.
SELECT id_institucion, COUNT(*) AS "Cant voluntarios"
FROM voluntario
GROUP BY id_institucion HAVING COUNT(*) > 10;

-- 10. Liste los coordinadores que tienen a su cargo más de 3 voluntarios dentro de una misma institución.
SELECT  id_coordinador
FROM voluntario
GROUP BY id_coordinador, id_institucion HAVING COUNT(*) > 0;
