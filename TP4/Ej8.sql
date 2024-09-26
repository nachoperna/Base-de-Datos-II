-- Ejercicio 8

CREATE VIEW voluntario1000hs AS
SELECT v.* FROM voluntario v
WHERE v.horas_aportadas > 1000
WITH LOCAL CHECK OPTION;

CREATE VIEW voluntario1000mayor AS
SELECT m.* FROM voluntario1000hs m
WHERE AGE(m.fecha_nacimiento ) > interval '21 year'
WITH LOCAL CHECK OPTION;

-- a.
	-- 1.
	INSERT INTO Voluntario1000Hs (nro_voluntario, apellido, fecha_nacimiento, horas_aportadas, ....)
	VALUES ( 344555, 'Perez', to_date('1986-10-28', 'yyyy-MM-dd'), 6, );
	-- No permite insertar en la vista porque chequea localmente la condicion y horas_aportadas es mnenor a 1000.

	-- 2.
	INSERT INTO Voluntario1000Mayor (nro_voluntario, apellido, fecha_nacimiento, horas_aportadas, ....)
	VALUES ( 366777, 'Gomez', to_date('1990-11-27', 'yyyy-MM-dd'), 1100, ...);
	-- Inserta en vista porque su edad es mayor a 21 años, y como la vista referenciada tambien tiene CHECK OPTION, verifica que se cumpla que tenga horas_aportadas > 1000, y tambien cumple esa condicion.

	-- 3.
	INSERT INTO Voluntario1000Mayor (nro_voluntario, apellido, fecha_nacimiento, horas_aportadas, ....)
	VALUES ( 366777, 'Gomez', to_date('1990-11-27', 'yyyy-MM-dd'), 60, ...);
	-- No inserta porque cumple la condicion de la vista voluntario1000mayor pero la vista referenciada al tener definico un CHECK OPTION, tambien verifica que sus horas_aportadas > 1000 y no lo cumple.

	-- 4.
	INSERT INTO Voluntario1000Hs (nro_voluntario, apellido, fecha_nacimiento, horas_aportadas, ....)
	VALUES ( 366777, 'Gomez', to_date('1990-11-27', 'yyyy-MM-dd'), 2300, ...);
	-- Inserta en vista porque cumple la condicion de horas_aportadas > 1000;

-- b.
	-- 2. Inserta en vista voluntario1000hs y tabla voluntario.
	-- 4. Inserta en vista voluntario1000mayor, en vista voluntario1000hs y en tabla voluntario.