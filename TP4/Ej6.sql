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