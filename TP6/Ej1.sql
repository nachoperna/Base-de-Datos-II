-- Ejercicio 1

-- a.Realice el grafo de permisos correspondiente a las sentencias indicadas en 1 y 2. Analice qué sucede en cada caso y si alguna de ellas arroja algún error

	GRANT SELECT ON instalacion TO adm WITH GRANT OPTION; -- se le otorga permiso de lectura al usuario adm sobre la tabla instalacion con posibilidad de traspasar ese permiso
		GRANT SELECT ON instalacion TO doc; -- usuario adm le otorga permiso de lectura al usuario doc sobre la tabla instalacion. Operacion valida

	GRANT UPDATE ON instalacion TO adm WITH GRANT OPTION; -- se le otorga permiso de actualizacion al usuario adm sobre toda la tabla instalacion con posibilidad de traspasar ese permiso
		GRANT UPDATE(cantHoras, tarea) ON instalacion TO doc WITH GRANT OPTION; -- usuario adm le otorga permiso de actualizacion al usuario doc sobre las columnas cantHoras y tarea de la tabla instalacion. Operacion valida

	GRANT DELETE ON instalacion TO adm; -- se le otorga permiso de borrado sobre la tabla instalacion al usuario adm
		GRANT DELETE ON instalacion TO doc; -- usuario adm quiere otorgarle permiso de borrado sobre la tabla instalacion al usuario doc pero hay ERROR porque no adm no tiene la posibilidad de traspasar ese permiso


-- b. Establezca los permisos que conserva el usuario doc sobre la tabla instalacion, si el usuario db_instal ejecuta las siguientes sentencias (considere la posibilidad de error):
	
	REVOKE SELECT ON instalacion FROM adm CASCADE;
		-- usuario doc conserva permiso de UPDATE.

	REVOKE UPDATE(tarea) ON instalacion FROM adm CASCADE;
		-- usuario doc conserva permiso de SELECT y UPDATE(cantHoras) sobre la tabla instalacion.