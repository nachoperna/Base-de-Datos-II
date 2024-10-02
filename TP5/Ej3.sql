-- Ejercicio 3

-- a. Listar los datos de los empleados investigadores que trabajan en algún proyecto
	SELECT DISTINCT E.*
	FROM EMPLEADO E ,
	TRABAJA_EN T ,
	PROYECTO P
	WHERE E.id_empleado = T.id_empleado
	AND P.cod_proyecto = T.cod_proyecto
	AND E.cargo = 'investigador';

	-- a.1 ¿Es necesario el ensamble con Empleado?
		-- Si es necesario para poder verificar que su cargo sea el de investigador.

	-- a.2 ¿Es necesario el ensamble con Proyecto?
		/* 
			No es necesario porque solo nos interesa conocer aquellos empleados investigadores
			que trabajan en algun proyecto sin importar los datos del proyecto, y la informacion 
			necesaria y suficiente esta en las tablas Empleado y Trabajan_en 
		*/

	-- a.3 ¿Qué implicancias tiene la inclusión del “distinct”?
		/* 
			Sirve para contabilizar por única vez a cada empleado investigador que esta trabajando
			en algún proyecto. Si no se incluye la clausula DISTINCT, una misma persona que trabaja en
			varios proyectos puede contabilizarse multiples veces.
		*/

-- b. Listar los datos de los proyectos de IA que tienen empleados trabajando
	SELECT DISTINCT P.*
	FROM TRABAJA_EN T ,
	PROYECTO P
	WHERE P.cod_proyecto = T.cod_proyecto
	AND P.nombre = 'IA';

	-- b.1 Analizar para la restricción de clave primaria establecida como (id_empleado, cod_proyecto)
		/* 
			No entiendo muy bien la consigna pero en este caso la clausula DISTINCT
			se puede eliminar porque no van a existir 2 proyectos de IA con el mismo
			cod_proyecto.
		*/
