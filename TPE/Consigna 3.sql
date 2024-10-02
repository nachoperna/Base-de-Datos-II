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

	-- Esta vista SI seria automaticamente actualizable en PostgreSQL (creeria porque me da paja insertar valores en todas las tablas para comprobarlo):
	create or replace view Vista1
	as (select saldo from cliente
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

/* b. Vista2, con los datos de los clientes activos del sistema que hayan sido dados de alta en el
año actual y que poseen al menos un servicio activo, incluyendo el/los servicio/s activo/s que
cada uno posee y su costo. */

	-- Ejemplo de vista no actualizable automaticamente segun estas condiciones:
	create or replace view Vista2
	as (select p.*, s.nombre as "Nombre servicio", s.costo as "Costo servicio" from cliente c
	    join persona p on p.id_persona = c.id_cliente
	    join equipo e on c.id_cliente = e.id_cliente
	    join servicio s on e.id_servicio = s.id_servicio
	    where p.activo is true and extract(year from p.fecha_alta) = extract(year from current_date));

		/* 
			Vista2 no es automaticamente actualizable en PostgreSQL porque:
			- tiene mas de una entrada en lista FROM
		*/

	-- Implementacion mediante TRIGGER:
		create or replace trigger tr_vista2
		    instead of insert or update on vista2
		    for each row execute function fn_vista2();

		create or replace function fn_vista2()
		returns trigger as $$
		    begin
		        if (tg_op = 'INSERT') then
		            insert into vista2 values (new.id_persona, new.tipo, new.tipodoc, new.nrodoc, new.nombre, new.apellido, new.fecha_nacimiento, new.fecha_alta, new.fecha_baja, new.cuit, new.activo, new.mail, new.telef_area, new.telef_numero);
		        else
		            -- sentencia update
		        end if;
		        return new;
		    end;
		    $$ language 'plpgsql';