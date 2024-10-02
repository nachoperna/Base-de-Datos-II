-- Ejercicio 2

SELECT * FROM tarea
WHERE id_tarea IN (
SELECT t.id_tarea
FROM tarea t inner join voluntario v on (t.id_tarea = v.id_tarea)
GROUP BY t.id_tarea
HAVING COUNT(v.nro_voluntario) > 5);

Hash Join  (cost=36.75..52.08 rows=141 width=164)
  Hash Cond: ((tarea_vol.id_tarea)::text = (t.id_tarea)::text)
  ->  Seq Scan on tarea_vol  (cost=0.00..14.20 rows=420 width=164)
  ->  Hash  (cost=35.92..35.92 rows=67 width=38)
        ->  HashAggregate  (cost=32.75..35.25 rows=67 width=38)
              Group Key: t.id_tarea
              Filter: (count(v.nro_voluntario) > 5)
              ->  Hash Join  (cost=19.45..31.52 rows=246 width=43)
                    Hash Cond: ((v.id_tarea)::text = (t.id_tarea)::text)
                    ->  Seq Scan on voluntario v  (cost=0.00..3.17 rows=117 width=13)
                    ->  Hash  (cost=14.20..14.20 rows=420 width=38)
                          ->  Seq Scan on tarea_vol t  (cost=0.00..14.20 rows=420 width=38)


--Es posible mejorarla aplicando reglas de equivalencia:

	-- 3. Hay una secuencia de proyecciones sobre la tabla TAREA que no aporta informacion a la consulta.
		SELECT * FROM tarea t inner join voluntario v on (t.id_tarea = v.id_tarea)
		GROUP BY t.id_tarea
		HAVING COUNT(v.nro_voluntario) > 5);