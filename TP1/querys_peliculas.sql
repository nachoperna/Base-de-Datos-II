-- 11. Muestre los ids, nombres y apellidos de los empleados que no poseen jefe. Incluya también el nombre de la tarea que cada uno realiza, verificando que el sueldo máximo de la misma sea superior a 14800.
SELECT e.nombre, e.apellido, t.nombre_tarea
FROM empleado e JOIN tarea t USING(id_tarea)
WHERE id_jefe IS NULL AND t.sueldo_maximo > 14800;

-- 12. Determine si hay empleados que reciben un sueldo superior al de sus respectivos jefes.
SELECT e.*
FROM empleado e JOIN empleado j ON e.id_jefe = j.id_empleado
WHERE e.sueldo > j.sueldo;

-- 13. Liste el identificador, nombre y tipo de los distribuidores que hayan entregado películas en idioma Español luego del año 2010. Incluya en cada caso la cantidad de películas distintas entregadas.
SELECT DISTINCT d.nombre, d.id_distribuidor, d.tipo
FROM distribuidor d JOIN entrega e USING (id_distribuidor) JOIN renglon_entrega USING (nro_entrega) JOIN pelicula p USING (codigo_pelicula)
WHERE extract(year from e.fecha_entrega) > 2010 AND lower(p.idioma) = 'español';

-- 14. Para cada uno de los empleados registrados en la base, liste su apellido junto con el apellido de su jefe, en caso de tenerlo, sino incluya la expresión ‘(no posee)’. Ordene el resultado por el apellido del empleado.
SELECT e.apellido AS "Apellido Empleado", coalesce(j.apellido, 'No posee') AS "Apellido jefe"
FROM empleado e JOIN empleado j ON e.id_jefe = j.id_empleado
WHERE e.id_jefe IS NOT NULL
ORDER BY e.apellido;

-- 15. Liste el id y nombre de todos los distribuidores existentes junto con la cantidad de videos a los que han realizado entregas.
SELECT d.nombre, d.id_distribuidor, r.cantidad
FROM distribuidor d JOIN entrega USING (id_distribuidor) JOIN renglon_entrega r USING (nro_entrega);

-- 16. Liste los datos de las películas que nunca han sido entregadas por un distribuidor nacional.
SELECT p.*
from pelicula p JOIN renglon_entrega USING (codigo_pelicula) JOIN entrega USING (nro_entrega) JOIN distribuidor d USING (id_distribuidor)
WHERE NOT EXISTS
 (SELECT 1 FROM nacional WHERE d.id_distribuidor = nacional.id_distribuidor);

-- 17. Indicar los departamentos (nombre e identificador completo) que tienen más de 3 empleados realizando tareas de sueldo mínimo inferior a 6000. Mostrar el resultado ordenado por el id de departamento.
SELECT d.nombre, d.id_departamento||', '||d.id_distribuidor AS "Clave"
FROM departamento d
WHERE (d.id_departamento, d.id_distribuidor) IN
(SELECT id_departamento, id_distribuidor FROM empleado WHERE id_tarea IN
    (SELECT id_tarea FROM tarea WHERE sueldo_minimo < 6000))
GROUP BY d.id_departamento, d.id_distribuidor HAVING COUNT(*) > 3
ORDER BY d.id_departamento;

-- 18. Liste los datos de los Departamentos en los que trabajan menos del 10 % de los empleados registrados.
SELECT COUNT(*) As "Cant empleados", *
FROM departamento
WHERE (id_departamento, id_distribuidor) IN
    (SELECT id_departamento, id_distribuidor
     FROM empleado)
GROUP BY id_departamento, id_distribuidor HAVING COUNT(*) < ((SELECT COUNT(*) FROM empleado) * 0.10)
ORDER BY COUNT(*) DESC;

-- 19. Encuentre el/los departamento/s con la mayor cantidad de empleados.
SELECT id_departamento, COUNT(*) AS "Cantidad de empleados"
FROM departamento
WHERE (id_departamento, id_distribuidor) IN
    (SELECT id_departamento, id_distribuidor
     FROM empleado)
GROUP BY id_departamento
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 20. Resuelva los servicios del grupo anterior mediante consultas anidadas, en caso que sea posible.

-- 21. Encuentre los id de distribuidor correspondientes a distribuidores que no han realizado entregas.
(SELECT id_distribuidor
FROM distribuidor)
EXCEPT ALL
(SELECT 1
FROM entrega)

-- 22. Verifique si hay empleados que son jefes de otro/s empleado/s y que además son jefes de algún departamento.
(
    SELECT id_empleado
     FROM empleado
)
INTERSECT
(
    SELECT id_jefe
    FROM empleado
)
INTERSECT
(
    SELECT jefe_departamento
    FROM departamento
)

-- 23. Liste los datos personales de todos los distribuidores (nacionales e internacionales) junto con el encargado, para el caso de distribuidores nacionales.

-- 24. Determine si hay distribuidores que han realizado entregas de películas a todos los videos.
(
    SELECT id_distribuidor
    FROM distribuidor
)
INTERSECT
(
    SELECT id_distribuidor
    FROM entrega
)
UNION
(
    SELECT id_video
    FROM video
)