-- Ejercicio 3.c
create or replace trigger tr_ins_usorecurso
	before insert on uso_recurso
	for each row execute function fn_restricciones();

create or replace function fn_restricciones()
returns trigger as $$
	begin
		if (exists(select 1 from recurso where id_recurso = new.id_recurso)
			and 
			exists(select 1 from etapa where id_proy = new.id_proy and cod_area = new.cod_area and id_etapa = new.id_etapa)) then
			if (exists(select 1 from etapa e 
						join recurso r on new.id_recurso = id_recurso
						where e.id_proy = new.id_proy and e.cod_area = new.cod_area and e.id_etapa = new.id_etapa 
							and e.descripcion ilike 'analisis%'
							and e.fecha_inicio is after to_date('31-10-22-', 'DD-MM-YYYY')
							and r.nombre ilike '%vista%'
							and new.observacion is null)) then
				raise exception 'La insercion en uso_recurso no cumple con las restricciones solicitadas';
		else
			raise exception 'No existe la informacion a ingresar en ETAPA y/o RECURSO para registrar usos de recursos';
		end if;
		return new;
	end
	$$ language 'plpgsql':

-- Ejercicio 2
create or replace procedure proc_recursosDistintos(fecha Date)
	language 'plpgsql' as $$
	declare 
	cantidad int;
	idproy int;
	codarea char(5);
	nombreproy varchar(50);
	begin
		(select distinct count(*) into cantidad, id_proy into idproy, cod_area into codarea, p.nombre into nombreproy
					from proyecto p 
					join uso_recurso u on u.id_proy = p.id_proy and u.cod_area = p.cod_area
					where p.fecha_inicio is after fecha
					group by p.id_proy, p.cod_area)
		insert into recursos_proyecto values (idproy, codarea, nombreproy, cantidad);
	end
	$$;

-- Ejercicio 4
	-- a.
	create or replace view vista_proy_12 
	as (select p.*
		from proyecto p 
		where p.fecha_inicio >= interval'1 year' 
				and p.presupuesto > 5000
				and not exists (select 1 from uso_recurso u
								where u.id_proy = p.id_proy and u.cod_area = p.cod_area));
		-- Vista automaticamente actualizable en PostgreSQL, porque no contiene funciones de agregacion ni de agrupacion en el top level, ni mas de una tabla en la clausula FROM.


	-- b.
	create or replace view vista_area_pr
	as (select a.nombre, a.cod_area, coalesce(avg(p.presupuesto),0)
		from area a join proyecto p using (cod_area)
		where extract(year from p.fecha_inicio) = current_year
		group by cod_area);
		-- Vista NO actualizable automaticamente en PostgreSQL porque contiene funcion de agrupacion en el top level, funcion de agregacion y 2 tablas en la clausula FROM.

	create or replace trigger tr_act_vista
	before insert or update on vista_area_pr
	for each row execute function fn_act_vista();

	create or replace function fn_act_vista()
	returns trigger as $$
	begin
		if (tg_op = 'INSERT') then
			if (exists(select 1 from proyecto where new.cod_area = p.cod_area and extract(year from p.fecha_inicio) != current_year)) then
				raise exception 'La insercion no cumple con la restriccion de que el proyecto debe iniciarse en el año corriente';
			end if;
		else
			if (exists(select 1 from vista_area_pr where a.cod_area = new.cod_area)) then
				update area set nombre = new.nombre where a.cod_area = new.cod_area;
			end if;
		end if;
		return new;
	end
	$$ language 'plpgsql':