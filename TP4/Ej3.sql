-- Ejercicio 3

-- a.
	-- si se agrega WITH CHECK OPTION entonces toda actualizacion deberia cumplir con la condicion impuesta en la vista para que se efectue.

-- b.
	INSERT INTO ENVIOS500 VALUES (‘P1’, ‘A1’, 500);
	-- SIN CHECK: inserta exitosamente en tabla ENVIO y ENVIOS500 porque cumple la condicion de la vista donde cantidad >= 500
	-- CON CHECK: "

	INSERT INTO ENVIOS500 VALUES (‘P2’, ‘A2’, 300);
	-- SIN CHECK: inserta en tabla ENVIO y no inserta en tabla ENVIOS500 al no cumplir con la condicion de cantidad. Hay migracion.
	-- CON CHECK: no inserta en tabla ENVIOS500 al no cumplir la condicion de cantidad, y por lo tanto tampoco inserta en ENVIO.

	UPDATE ENVIOS500 SET cantidad=100 WHERE id_proveedor= ’P1’;
	-- SIN CHECK: inserta en tabla ENVIO y no inserta en ENVIOS500 al no cumplir la condicino de cantidad. Hay migracion.
	-- CON CHECK: no inserta en tabla ENVIOS500 al no cumplir la condicion de cantidad, y por lo tanto tampoco inserta en ENVIO.

	UPDATE ENVIOS500 SET cantidad=1000 WHERE id_proveedor= ’P2’;
	-- SIN CHECK: inserta exitosamente en tabla ENVIO y ENVIOS500 porque cumple la condicion de la vista donde cantidad >= 500
	-- CON CHECK: "

	INSERT INTO ENVIOS500 VALUES (‘P1’, ‘A3’, 700);
	-- SIN CHECK: inserta exitosamente en tabla ENVIO y ENVIOS500 porque cumple la condicion de la vista donde cantidad >= 500
	-- CON CHECK: "