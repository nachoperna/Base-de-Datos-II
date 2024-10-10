-- Ejercicio 2

-- a. Conceder al usuario U1 todos los privilegios sobre la tabla Institución, con posibilidad de concederlos a otros usuarios.
	-- Ejecutada por U0:
	grant select on institucion to U1 with grant option
	grant update on institucion to U1 with grant option
	grant delete on institucion to U1 with grant option	

	grant usage on institucion to U1 with grant option -- alternativa

-- b. Permitir que el usuario U2 sólo consulte los datos de la tabla Voluntario.
	-- Ejecutada por U0:
	grant select on voluntario to U2

-- c. Permitir que U2 autorice a U3 para que pueda insertar en la tabla Voluntario.
	-- No puede ser ejecutado porque U2 no tiene permiso de insercion sobre la tabal voluntario.
	-- Para que se pueda:
		-- U0 le otorga permiso de insercion sobre tabla voluntario a U2 con permiso de pasarlo.
		grant insert on voluntario to U2 with grant option
		-- U2 le otorga el permiso de insercion a U3
		grant insert on voluntario to U3

-- d. Dar a todos los usuarios del sistema privilegios de inserción y actualización sobre la tabla Tarea. ¿Cuál sería la diferencia si se incluye o no la cláusula WITH GRANT OPTION?
	-- Ejecutado por U0:
	grant insert on tarea to U1, U2, U3
	grant update on tarea to U1, U2, U3
	-- Sin WGO: el usuario maestro db_instal tiene la posibilidad de revocar los permisos de insercion y actualizacion sobre la tabla tarea a todos los usuarios y ya nadie tendra ese permiso.
	-- Con WGO: un usuario puede recibir el mismo permiso por diferentes usuarios y solo perderian el permiso absoluto si el DBA lo revoca a todos por igual utilizando CASCADE. Caso contrario, puede seguir conservandolo por otra rama.

-- e. Retirar el privilegio de borrado sobre Institución a U1.
	-- Ejecutado por U0:
	revoke delete on institucion from U1 -- U1 conserva permisos de lectura y actualizacion

-- f. Quitar el privilegio de inserción a todos los usuarios sobre la tabla Tarea ¿Qué usuario podría entonces insertar datos en esa tabla?
	-- Ejecutado por U0:
	revoke delete on tarea from U1, U2, U3
	-- Sin CASCADE solo podria seguir insertando datos en tarea aquellos usuarios que recibieron el permiso por otros usuarios aparte de U0.
	-- Con CASCADE solo el admin U0 podria insertar datos en la tabla tarea.

-- g. Crear un rol ins_prov con capacidad de insertar datos de provincias y países.
	-- Ejecutado por U0:
	create role ins_prov
	grant insert on pais to ins_prov
	grant insert(provincia) on direccion to ins_prov 

-- h. Crear dos usuarios U3 y U4 y asignarles el rol ins_prov.
	-- Ejecutado por U0:
	create user U3 -- ya deberia estar creado si antes le habiamos asignado algo
	create user U4
	grant ins_prov to U3, U4

-- i. Permitir que los usuarios con el rol ins_prov puedan también actualizar el nombre del voluntario.
	-- Ejecutado por U0:
	grant update(nombre) on voluntario to ins_prov

-- j. Eliminar el rol ins_prov ¿qué sucede con los usuarios U3 y U4?
	-- Ejecutado por U0:
	drop role ins_prov
	-- los usuarios U3 y U4 pierden todos los privilegios obtenidos con ese rol.