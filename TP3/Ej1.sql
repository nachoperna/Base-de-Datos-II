-- EJERCICIO 1
-- a.
	-- 3.a del TP2
		CREATE OR REPLACE FUNCTION fn_prod_max()
		RETURNS TRIGGER AS $$
		BEGIN
			IF ((SELECT COUNT(p.*)
					FROM PROVEE p
					JOIN PRODUCTO USING(cod_producto)
					JOIN PROVEEDOR USING(nro_prov)
					JOIN SUCURSAL USING(cod_suc);) >= 20) THEN
				raise exception 'Se alcanzo el limite máximo de productos';
			END IF;
			RETURN NEW;
		END $$ LANGUAGE 'plpgsql';

		CREATE OR REPLACE TRIGGER tr_prod_max
		BEFORE INSERT OR UPDATE OF cod_producto
		ON PROVEE
		FOR EACH STATEMENT EXECUTE FUNCTION fn_prod_max();

	-- 3.d del TP2
		create or replace function fn_mismaLocalidad()
		return trigger as $$
		begin
			if (exists(SELECT 1 FROM PROVEE p 
						JOIN PROVEEDOR prov USING(nro_prov)
						JOIN SUCURSAL suc USING(cod_suc)
						WHERE prov.localidad != suc.localidad)) then
				raise exception 'Solo se pueden proveer productos a sucursales de la misma localidad';
			end if;
			return new;
		end $$ language 'plpgsql';

		create or replace trigger tr_mismaLocalidad
		after insert or update of cod_producto
		on PROVEE
		for each row execute function fn_mismaLocalidad();

-- b.
	-- creacion de las tablas del esquema del proveedores en mi perfil de la base de datos.
	-- LLENADO DE TUPLAS A LA TABLA
		-- Inserción de 1 proveedor
		INSERT INTO PROVEEDOR (nro_prov, nombre, direccion, localidad, fecha_nac) 
		VALUES (1, 'Proveedor Ejemplo', 'Calle Falsa 123', 'Ciudad Ejemplo', '1970-01-01');

		-- Inserción de 1 sucursal
		INSERT INTO SUCURSAL (cod_suc, nombre, localidad) 
		VALUES (1, 'Sucursal Ejemplo', 'Ciudad Ejemplo');

		-- Inserción de 20 productos
		INSERT INTO PRODUCTO (cod_producto, presentacion, descripcion, tipo) VALUES
		(1, 'Botella', 'Agua Mineral 500ml', 1),
		(2, 'Caja', 'Cereal 1kg', 2),
		(3, 'Paquete', 'Galletas 300g', 3),
		(4, 'Bolsa', 'Papas Fritas 150g', 4),
		(5, 'Lata', 'Refresco 355ml', 5),
		(6, 'Caja', 'Jugo de Naranja 1L', 6),
		(7, 'Frasco', 'Mermelada 300g', 7),
		(8, 'Bolsa', 'Arroz 1kg', 8),
		(9, 'Paquete', 'Pasta 500g', 9),
		(10, 'Botella', 'Aceite 1L', 10),
		(11, 'Caja', 'Leche 1L', 11),
		(12, 'Lata', 'Atún 170g', 12),
		(13, 'Paquete', 'Café 250g', 13),
		(14, 'Bolsa', 'Azúcar 1kg', 14),
		(15, 'Botella', 'Vinagre 500ml', 15),
		(16, 'Caja', 'Sal 500g', 16),
		(17, 'Lata', 'Tomates Pelados 400g', 17),
		(18, 'Frasco', 'Miel 250g', 18),
		(19, 'Bolsa', 'Harina 1kg', 19),
		(20, 'Caja', 'Galletas 200g', 20);

		-- Inserción en la tabla PROVEE para que el proveedor 1 provea los 20 productos a la sucursal 1
		INSERT INTO PROVEE (cod_producto, nro_prov, cod_suc) VALUES
		(1, 1, 1),
		(2, 1, 1),
		(3, 1, 1),
		(4, 1, 1),
		(5, 1, 1),
		(6, 1, 1),
		(7, 1, 1),
		(8, 1, 1),
		(9, 1, 1),
		(10, 1, 1),
		(11, 1, 1),
		(12, 1, 1),
		(13, 1, 1),
		(14, 1, 1),
		(15, 1, 1),
		(16, 1, 1),
		(17, 1, 1),
		(18, 1, 1),
		(19, 1, 1),
		(20, 1, 1);

	INSERT INTO PROVEE (cod_producto, nro_prov, cod_suc) VALUES (21,1,1)
		-- sentencia que dispara el trigger "tr_prod_max"

	delete from provee where cod_producto = 20;
	delete from producto where cod_producto = 20;
		-- se borra el ultimo producto agregado junto con su referencia para que se pueda probar la otra restriccion de localidad.
	INSERT INTO proveedor (nro_prov, nombre, direccion, localidad, fecha_nac) VALUES (2, 'prov2', 'dir2', 'necochea', '2001-06-07')
		-- insercion de proveeedor con localidad "necochea"
	insert into sucursal (cod_suc, nombre, localidad) VALUES (2, 'suc2', 'tandil')
		-- insercion de sucursal con localidad "tandil"
	insert into producto (cod_producto, presentacion, descripcion, tipo) VALUES (21, 'bla', 'bla', 21)
		-- insercion de un nuevo producto
	insert into provee (cod_producto, nro_prov, cod_suc) VALUES (21,2,2)
		-- sentencia para que el proveedor con localidad "necochea" le provea el producto recien creado a una sucursal de localidad "tandil"
		-- se activa el trigger "tr_mismaLocalidad"