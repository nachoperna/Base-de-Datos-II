-- Ejercicio 6

CREATE VIEW ciudad_kp_2 AS 
SELECT id_ciudad, nombre_ciudad, c.id_pais, nombre_pais
FROM ciudad c NATURAL JOIN pais p;

CREATE VIEW entregas_kp_3 AS
SELECT nro_entrega, re.codigo_pelicula, cantidad, titulo
FROM renglon_entrega re JOIN pelicula p using (codigo_pelicula);

-- a.
	-- Vista ciudad_kp_2
		-- la clave preservada es id_ciudad que es la clave primaria de la tabla ciudad.
		-- los atributos nombre_ciuodad, id_pais y nombre_pais pueden actualizarse al no pertenecer a la clave.

	-- Vista entregas_kp_3
		-- la clave preservada es nro_entrega, codigo_pelicula que es la clave primaria de la tabla renglon_entrega.
		-- los atributos cantidad y titulo pueden actualizarse.

-- b.
	-- Vista ciudad_kp_2
	create or replace function fn_act_ciudadkp2()
	returns trigger as $$
	    begin
	        if (exists(select 1 from ciudad where new.id_ciudad = id_ciudad) and
	            exists(select 1 from pais where new.id_pais = id_pais)) then
	            if (tg_op = 'INSERT') then
	                insert into ciudad_kp_2 values (new.id_ciudad, new.nombre_ciudad, new.id_pais, new.nombre_pais);
	            end if;
	            else if (tg_op = 'UPDATE') then
	                if (exists(select 1 from ciudad_kp_2 where new.id_ciudad = id_ciudad and new.id_pais = id_pais)) then
	                    -- sentencia update
	                end if;
	            end if;
	        end if;
	        return new;
	    end;
	    $$ language 'plpgsql';

	create or replace trigger tr_act_ciudadkp2
    instead of insert or update on ciudad_kp_2
    for each row execute function fn_act_ciudadkp2();

    create or replace function fn_del_ciudadkp2()
	returns trigger as $$
	    begin
	        if (exists(select 1 from ciudad_kp_2 where new.id_ciudad = id_ciudad and new.id_pais = id_pais)) then
	            delete from ciudad_kp_2 where id_ciudad = old.id_ciudad;
	        end if;
	        return old;
	    end;
	    $$ language 'plpgsql';

	create or replace trigger tr_del_ciudadkp2
	    instead of delete on ciudad_kp_2
	    for each row execute function fn_del_ciudadkp2();

	-- Vista entregas_kp_3
	create or replace trigger tr_act_entregaskp3
	    instead of insert or update on entregas_kp_3
	    for each row execute function fn_act_entregaskp3();

	create or replace function fn_act_entregaskp3()
	returns trigger as $$
	    begin
	        if (exists(select 1 from pelicula where new.codigo_pelicula = codigo_pelicula)) then
	            if (tg_op = 'INSERT') then
	                insert into entregas_kp_3 values (new.nro_entrega, new.codigo_pelicula, new.cantidad, new.titulo);
	            else if (tg_op = 'UPDATE') then
	                if (exists(select 1 from renglon_entrega where new.nro_entrega = nro_entrega)) then
	                    -- sentencia update
	                else
	                    raise exception 'No existe el nro_entrega a modificar';
	                end if;
	            end if;
	            end if;
	        else
	            raise exception 'No existe una pelicula con ese codigo para modificar';
	        end if;
	        return new;
	    end;
	    $$ language 'plpgsql';

	create or replace trigger tr_del_entregaskp3
	    instead of delete on entregas_kp_3
	    for each row execute function fn_del_entregaskp3();

	create or replace function fn_del_entregaskp3()
	returns trigger as $$
	    begin
	        if (exists(select 1 from renglon_entrega where old.nro_entrega = nro_entrega)) then
	            delete from renglon_entrega where nro_entrega = old.nro_entrega;
	        else
	            raise exception 'No existe el nro_entrega a eliminar';
	        end if;
	        return old;
	    end;
	    $$ language 'plpgsql';

-- c.
	-- Sentencias de actualizacion
    -- Vista ciudad_kp_2
        -- Comprobacion de estados anteriores de tablas
        select * from renglon_entrega limit 10;
        select * from ciudad_kp_2 order by id_ciudad desc limit 10;

        -- Actualizaciones
        insert into ciudad_kp_2 values (50217, 'Tandil', 'AR', 'ARGENTINA');
            select * from ciudad_kp_2 order by id_ciudad desc limit 10;
            select * from ciudad_kp_2 where id_ciudad = 50217;
            select * from ciudad order by id_ciudad desc limit 10;
            -- no funciona REVISAR (aparentemente por error del limite del servidor que no deja ejecutar la funcion que llama el trigger
        delete from ciudad_kp_2 where id_ciudad = 50217;

    -- Vista entregas_kp_3
        -- Comprobacion de estados anteriores de tablas
        select * from entregas_kp_3 order by nro_entrega desc limit 10;

        -- Actualizaciones
        insert into entregas_kp_3 values (8050, 21885, 10, 'blablabla');
            select * from entregas_kp_3 where nro_entrega = 8050;
            select * from renglon_entrega where nro_entrega = 8050;