-- a) Controlar que las nacionalidades sean 'Argentina', 'Española', 'Inglesa' o 'Chilena'.
	ALTER TABLE ARTICULO ADD CONSTRAINT ART_nacionalidad
		CHECK (nacionalidad IN ('Argentina|Española|Inglesa|Chilena'));

-- b) Para las fechas de publicaciones se debe considerar que sean fechas posteriores o iguales al 2010.
	ALTER TABLE ARTICULO ADD CONSTRAINT ART_fechapub
		CHECK (fecha_pub >= 2010);

-- c) Los artículos publicados luego del año 2020 no deben ser de nacionalidad Inglesa.
	ALTER TABLE ARTICULO ADD CONSTRAINT ART_nacionalidad_fechapub
		CHECK (NOT EXISTS (fecha_pub >= 2020 AND nacionalidad = 'Inglesa'));
	-- debe comprobar por la negativa.

-- d) Sólo se pueden publicar artículos argentinos que contengan hasta 10 palabras claves.
	-- necesita subconsulta