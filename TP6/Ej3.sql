-- Ejercicio 3

-- usuario A ha creado la tabla Usuario(nro_u, nombre, tarea)
-- usuario A ejecuta:	
	GRANT INSERT ON Usuario TO B WITH GRANT OPTION;
	GRANT SELECT ON Usuario TO B WITH GRANT OPTION;
	GRANT SELECT ON Usuario TO C;

-- a. Indique quiénes pueden ejecutar exitosamente los siguientes comandos:

	-- 1.
		SELECT * FROM A.Usuario WHERE nro_u='C';
		-- A, B y C pueden ejecutar

	-- 2.
		INSERT INTO A.Usuario VALUES ('C','Gerente', ‘Control’);
		-- A y B puede ejecutar

	-- 3.
		GRANT SELECT ON A.Usuario TO D;
		-- A y B pueden ejecutar.

-- b. Establezca la habilitación (o no) para realizar los siguientes comandos:
	
	-- 1. B: GRANT INSERT ON Usuario TO D;
		-- B ya tiene el privilegio para pasar el permiso de insercion sobre la tabla Usuario a otros usuarios

	-- 2. A: REVOKE INSERT ON Usuario FROM B CASCADE;
		-- A ya tiene el privilegio de revocar porque es el administrador y B tiene el privilegio de insercion para ser revocado.

-- c. ¿Cuáles permisos conservan los usuarios después de lo anterior?
	-- B conserva permiso de lectura en tabla Usuario.
	-- C conserva permiso de lectura en tabla Usuario.
	-- D conserva permiso de lectura en tabla Usuario.