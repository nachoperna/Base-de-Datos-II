-- a. Vista1, que contenga el saldo de cada uno de los clientes menores de 30 años de la ciudad ‘Napoli, que posean más de 3 servicios.

	-- Ejemplo de vista NO actualizable automaticamente en PostgreSQL: 
	create or replace view Vista1
	as (select c.saldo from cliente c
	    join persona p on p.id_persona = c.id_cliente
	    join direccion d on d.id_persona = p.id_persona
	    join barrio b on d.id_barrio = b.id_barrio
	    join ciudad ci on b.id_ciudad = ci.id_ciudad
	    join equipo e on c.id_cliente = e.id_cliente
	    where extract(year from age(current_timestamp, fecha_nacimiento)) < 30 and ci.nombre ilike 'Napoli' and e.id_servicio is not null
	    group by e.id_cliente, c.saldo having count(e.id_servicio) > 3);

		-- Esta vista no es automaticamente actualizable porque contiene una clausula GROUP BY en el TOP LEVEL.

	-- Esta vista SI seria automaticamente actualizable en PostgreSQL:
	create or replace view Vista1
	as (select saldo, id_cliente from cliente
	    where saldo is not null and id_cliente in
	    (select id_persona from persona
	    where extract(year from age(current_timestamp, fecha_nacimiento)) < 30 and id_persona in
	        (select id_persona from direccion where id_barrio in
	        (select id_barrio from barrio where id_ciudad in
	        (select id_ciudad from ciudad where nombre ilike 'Napoli')))) and id_cliente in
	    (select id_cliente from equipo
	        where id_servicio is not null
	        group by id_cliente having count(id_servicio) > 3));

		/* 
			Esta vista si es automaticamente actualizable en PostgreSQL porque:
			- tiene solo UNA entrada en la clausula FROM
			- no contiene clausulas WITH, DISTINCT, GROUP BY, HAVING, LIMIT o OFFSET en el nivel superior
			- no contiene operaciones de conjunto
			- la seleccion de columnas no tiene funciones de agregacion
		*/

	-- Si la Vista1 tuviera especificada opcion WITH CHECK OPTION, obtendría el mismo resultado que si no lo tuviera porque no se referencia a otra vista dentro de vista1, y al insertar en la misma siempre se comprobaria la condicion de vista1 sin importar si tiene especificada WCO.

		-- FUNCIONA VISTA1

/* b. Vista2, con los datos de los clientes activos del sistema que hayan sido dados de alta en el
año actual y que poseen al menos un servicio activo, incluyendo el/los servicio/s activo/s que
cada uno posee y su costo. */

	create or replace view Vista2
	as (select p.*, s.nombre as "Nombre servicio", s.id_servicio, s.costo as "Costo servicio" from cliente c
            join persona p on p.id_persona = c.id_cliente
            join equipo e on c.id_cliente = e.id_cliente
            join servicio s on e.id_servicio = s.id_servicio
	    where p.activo is true and extract(year from p.fecha_alta) = extract(year from current_date) and s.activo is true);

		/*
			Vista2 no es automaticamente actualizable en PostgreSQL porque:
			- tiene mas de una entrada en lista FROM

			Vista2 no es posible hacerla automaticamente actualizable porque necesita mostrar columnas de más de una tabla, 
			lo que es imposible sin utilizar anidaciones con JOIN y PostgreSQL no admite mas de una tabla en la clausula FROM para vistas actualizables automaticamente.
		*/

	-- Implementacion mediante TRIGGER:
		create or replace trigger tr_act_vista2
		    instead of insert or update on vista2
		    for each row execute function fn_act_vista2();

		create or replace function fn_act_vista2()
		returns trigger as $$
		    begin
		        if (tg_op = 'INSERT') then
		            insert into persona values (new.id_persona, new.tipo, new.tipodoc, new.nrodoc, new.nombre, new.apellido, new.fecha_nacimiento, new.fecha_alta, new.fecha_baja, new.cuit, new.activo, new.mail, new.telef_area, new.telef_numero);
		            insert into servicio values (new.id_servicio, new.nombre, false, new."Costo servicio", null, null, true, 1);
		        else -- sentencia update (al no saber que columna especifica puede querer modificar el usuario debemos comprobar posibles cambios en todas las columnas actualizables)
		            if old."Costo servicio" is distinct from new."Costo servicio" then
                        update servicio set costo = new."Costo servicio" where id_servicio = (select id_servicio from equipo where id_cliente = new.id_persona);
                    end if;
                    if (old.fecha_baja is distinct from new.fecha_baja) then
		                update equipo set fecha_baja = new.fecha_baja where id_cliente = new.id_persona and id_servicio = new.id_servicio;
		            end if;
		            if (old.telef_numero is distinct from new.telef_numero) then
		                update persona set telef_numero = new.telef_numero where id_persona = new.id_persona;
		            end if;
		            if (old.telef_area is distinct from new.telef_area) then
                        update persona set telef_area = new.telef_area where id_persona = new.id_persona;
                    end if;
		            if (old.activo is distinct from new.activo) then
                        update persona set activo = new.activo where id_persona = new.id_persona;
                    end if;
		            if (old.mail is distinct from new.mail) then
                        update persona set mail = new.mail where id_persona = new.id_persona;
                    end if;
                    -- quitamos de la posibilidad de actualizacion del usuario a las columnas id_persona e id_servicio ya que son unicos y no deben poder cambiarse por PK.
		        end if;
		        return new;
		    end;
		    $$ language 'plpgsql';

        create or replace trigger tr_del_vista2
        instead of delete on vista2
        for each row execute function fn_del_vista2();

        create or replace function fn_del_vista2()
        returns trigger as $$
            begin
                if (exists(select 1 from vista2 where id_persona = old.id_persona and id_servicio = old.id_servicio)) then
                    delete from vista2 where id_persona = old.id_persona and id_servicio = old.id_servicio;
                else
                    raise exception 'No se encuentran los id a borrar en Vista2';
                end if;
                return old;
            end;
            $$ language 'plpgsql';

/*
    c. Vista3, que contenga, por cada uno de los servicios periódicos registrados en el sistema, los
    datos del servicio y el monto facturado mensualmente durante los últimos 5 años, ordenado por
    servicio, año, mes y monto.
*/

	create or replace view vista3
	as (select s.*, c.fecha, sum(c.importe) as "Facturacion mensual" from servicio s -- datos del servicio, fecha de facturacion y suma mensual de facturacion
	    join lineacomprobante l on s.id_servicio = l.id_servicio
	    join comprobante c on l.id_comp = c.id_comp and l.id_tcomp = c.id_tcomp
	    where s.periodico is true and c.fecha >= (now() - (interval '5 years')) -- se controla que el servicio sea periodico y que la fecha de la factura del servicio este dentro de los ultimos 5 años
	    group by extract(month from c.fecha), s.id_servicio, c.fecha, c.importe -- se agrupa por mes
	    order by s.id_servicio, extract(year from c.fecha), extract(month from c.fecha), c.importe
	    );

	-- Vista3 no es automaticamente actualizable en PostgreSQL porque:
	    -- contiene mas de una entrada en la clausula FROM
	    -- contiene funcion de agrupacion en el top level
	    -- contiene funcion de agregacion en el top level

	create or replace trigger tr_act_vista3
	    instead of insert or update on vista3
	    for each row execute function fn_act_vista3();

	create or replace function fn_act_vista3()
	returns trigger as $$
	    begin
	        if (tg_op = 'INSERT') then
	            insert into servicio values (new.id_servicio, new.nombre, true, new.costo, new.intervalo, new.tipo_intervalo, new.activo, new.id_cat);
	        else
	            if (exists(select 1 from servicio where id_servicio = new.id_servicio and periodico is true)) then
	                if (old.nombre is distinct from new.nombre) then
	                    update servicio set nombre = new.nombre where id_servicio = new.id_servicio;
	                end if;
	                if (old.costo is distinct from new.costo) then
	                    update servicio set costo = new.costo where id_servicio = new.id_servicio;
	                end if;
	                if (old.activo is distinct from new.activo) then
	                    update servicio set activo = new.activo where id_servicio = new.id_servicio;
	                end if;
	            else
	                raise exception 'No existe el servicio a actualizar';
	            end if;
	        end if;
	        return new;
	    end;
	    $$ language 'plpgsql';