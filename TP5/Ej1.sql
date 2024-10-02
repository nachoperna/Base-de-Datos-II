-- Ejercicio 1

-- a.
	explain analyze SELECT p.titulo, e.nro_entrega
	FROM pelicula p, renglon_entrega re, entrega e
	WHERE p.codigo_pelicula = re.codigo_pelicula
	AND re.nro_entrega = e.nro_entrega
	AND upper(genero) = 'TERROR';

	Nested Loop  (cost=814.21..2146.77 rows=330 width=16) (actual time=10.671..10.673 rows=0 loops=1)
	  ->  Hash Join  (cost=813.93..2047.29 rows=330 width=16) (actual time=10.671..10.672 rows=0 loops=1)
	        Hash Cond: (re.codigo_pelicula = p.codigo_pelicula)
	        ->  Seq Scan on renglon_entrega re  (cost=0.00..1060.07 rows=66007 width=11) (actual time=0.007..0.007 rows=1 loops=1)
	        ->  Hash  (cost=811.94..811.94 rows=159 width=17) (actual time=10.622..10.623 rows=0 loops=1)
	              Buckets: 1024  Batches: 1  Memory Usage: 8kB
	              ->  Seq Scan on pelicula p  (cost=0.00..811.94 rows=159 width=17) (actual time=10.622..10.622 rows=0 loops=1)
	                    Filter: (upper((genero)::text) = 'TERROR'::text)
	                    Rows Removed by Filter: 31796
	  ->  Index Only Scan using pk_nro_entrega on entrega e  (cost=0.28..0.30 rows=1 width=5) (never executed)
	        Index Cond: (nro_entrega = re.nro_entrega)
	        Heap Fetches: 0

	 /* 
	 	Utiliza un Nested Loop que combina 2 registros a traves de la iteracino de todos los registros en el primer conjunto
	 	y tratando de encontrar coincidencias en el segundo conjunto. Se retornan todos los registros coincidentes.

	 	Luego usa un Hash Join que une 2 registros haciendo hashing de uno (busqueda por igualdad de codigo_pelicula entre renglon_entrega y pelicula)
			-> Usa Seq Scan para encontrar registros relevantes escaneando secuencialmente el registro de entrada (renglon_entrega). Seq Scan hace solamente lectura
			-> Usa Hash para generar una hash table con los registros de entrada
				-> Usa Seq Scan para encontrar los registros relevantes en la tabla pelicula

		Usa un Index Only Scan para encontrar los registros relevantes en la tabla entrega basandose en el indice pk_nro_entrega
	 */

-- b.	 	
	SELECT V.nombre, V.apellido, V.e_mail, V.telefono
	FROM Voluntario V
	WHERE V.nro_voluntario IN (SELECT H.nro_voluntario
	FROM Historico H
	WHERE H.fecha_fin < to_date('1998-07-24', ‘yyyy-mm-dd’) AND
	H.id_tarea IN (SELECT T.id_tarea
	FROM Tarea T
	WHERE (T.max_horas - T.min_horas) <= 5000));

	Hash Semi Join  (cost=45.29..50.93 rows=79 width=47)
	  Hash Cond: (v.nro_voluntario = h.nro_voluntario)
	  ->  Seq Scan on voluntario v  (cost=0.00..3.17 rows=117 width=52)
	  ->  Hash  (cost=43.60..43.60 rows=135 width=14)
	        ->  Hash Join  (cost=19.24..43.60 rows=135 width=14)
	              Hash Cond: ((h.id_tarea)::text = (t.id_tarea)::text)
	              ->  Seq Scan on historico h  (cost=0.00..22.15 rows=270 width=52)
	"                    Filter: (fecha_fin < to_date('1998-07-24'::text, 'yyyy-mm-dd'::text))"
	              ->  Hash  (cost=17.80..17.80 rows=115 width=38)
	                    ->  HashAggregate  (cost=16.65..17.80 rows=115 width=38)
	                          Group Key: (t.id_tarea)::text
	                          ->  Seq Scan on tarea_vol t  (cost=0.00..16.30 rows=140 width=38)
	                                Filter: ((max_horas - min_horas) <= '5000'::numeric)

	/* 
		Utiliza un Hash Semi Join al utilizar una subconsulta entre la tabla voluntario e historico
			-> Seq Scan sobre la tabla voluntario para encontrar los registros relevantes
			-> Hash
				-> Hash Join para unir 2 registros usando a traves de una condicion (historico y tarea a traves de id_tarae)
					-> Seq Scan sobre la tabla historico para encontrar los registros relevantes
					-> Hash 
						-> HashAggregate une registros a traves de una alguna agrupacion o funcion de agregacion y primero usa el Hash para ordenar los registros por alguna clave
							-> Seq Scan sobre la tabla tarea para encontrar los registros relevantes
	*/