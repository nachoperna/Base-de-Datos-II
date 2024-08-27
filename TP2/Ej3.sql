-- a) Cada proveedor no puede proveer más de 20 productos a una misma sucursal.
	-- con subconsulta en el check

-- b) Los nombres de sucursales de Tandil deben comenzar con T.
	ALTER TABLE SUCURSAL ADD CONSTRAINT SUCURSAL_nombre
		CHECK (upper(nombre) LIKE 'T%');

-- c) La descripción y la presentación de un producto no pueden ser ambas nulas.
	ALTER TABLE PRODUCTO ADD CONSTRAINT PRODUCTO_pres_desc
		CHECK (descripcion IS NOT NULL AND presentacion IS NOT NULL);

-- d) Cada proveedor sólo puede proveer productos a sucursales de su localidad.
	-- con subconsulta