-- EJERCICIO 7

-- SETEO
	create table TextosporAutor(
    autor varchar(50) not null primary key,
    cant_textos int not null default 0,
    fecha_ultima_public date
	);

-- a.
	-- IMPLEMENTACION
	create or replace procedure proc_regarticulos()
	language 'plpgsql' as $$
	    declare
	        ult_pub date;
	    begin
	        ult_pub = (select a1.fecha_pub from articulo a1
	                                    join articulo a2 using (autor)
	                                    order by fecha_pub desc
	                                    limit 1);
	        insert into textosporautor
	        select autor, count(*), ult_pub from articulo
	        group by autor;
	    end;
	    $$;

	-- ejemplo de utilizacion
	    INSERT INTO ARTICULO (id_articulo, titulo, autor, nacionalidad, fecha_pub)
	    VALUES
	    (1, 'Aprendiendo SQL', 'Juan Pérez', 'Mexicana', '2023-01-15'),
	    (2, 'PostgreSQL Avanzado', 'Juan Pérez', 'Mexicana', '2023-03-20'),
	    (3, 'Bases de Datos Relacionales', 'Juan Pérez', 'Mexicana', '2023-05-10'),
	    (4, 'Optimización de Consultas', 'Juan Pérez', 'Mexicana', '2023-07-01'),
	    (5, 'Análisis de Datos con SQL', 'Juan Pérez', 'Mexicana', '2023-09-25');

	    call proc_regArticulos();

	    select * from textosporautor;
	    delete from textosporautor; -- para intentar de vuelta con otros datos

-- b.
	-- IMPLEMENTACION
	create or replace trigger tr_artNuevo
	    after insert or delete on articulo
	    for each row execute function fn_artNuevo();

	create or replace function fn_artNuevo()
	returns trigger as $$
	    begin
	        if (tg_op = 'INSERT') then
	            if (exists(select 1 from textosporautor where autor = new.autor)) then
	                update textosporautor set cant_textos = cant_textos + 1 where autor = new.autor;
	            else
	                raise notice 'no existe el autor en la tabla articulo';
	                insert into textosporautor values (new.autor, 1, current_date);
	            end if;
	        elsif (tg_op = 'DELETE') then
	            raise notice 'autor = %', old.autor;
	            update textosporautor set cant_textos = cant_textos - 1 where autor = old.autor;
	        end if;
	        return new;
	    end
	    $$ language 'plpgsql';

	-- TESTEO
	INSERT INTO ARTICULO (id_articulo, titulo, autor, nacionalidad, fecha_pub)
		    VALUES
		    (1, 'Aprendiendo SQL', 'Juan Pérez', 'Mexicana', '2023-01-15'),
		    (2, 'PostgreSQL Avanzado', 'Juan Pérez', 'Mexicana', '2023-03-20'),
		    (3, 'Bases de Datos Relacionales', 'Juan Pérez', 'Mexicana', '2023-05-10'),
		    (4, 'Optimización de Consultas', 'Juan Pérez', 'Mexicana', '2023-07-01'),
		    (5, 'Análisis de Datos con SQL', 'Juan Pérez', 'Mexicana', '2023-09-25');

	select * from articulo; -- mostrar datos correctamente ingresados
	select * from textosporautor; -- mostrar la correcta funcionalidad del trigger

	delete from articulo where id_articulo = 5; -- borrar dato para testear que se descuente la cantidad de textos publicados
	select * from textosporautor; -- mostrar la correcta funcionalidad del trigger

	delete from articulo; -- resetear tabla para probar otros testings
	delete from textosporautor; -- resetear tabla para probar otros testings.
