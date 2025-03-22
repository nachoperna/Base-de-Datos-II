-- 1.a
	-- Se necesita un control a nivel GENERAL porque tenemos mas de una tabla involucrada para la restriccion.
	create assertion check_fecha_compra
	check (not exists(
			select 1
			from material m 
			join utiliza u using (id_material)
			join tarea t using (nro_tarea, area)
			where t.fecha_fin is not null
				and m.fecha_compra is after t.fecha_fin));
	-- Controlamos por la negativa donde pedimos que no exista una tupla donde una tarea tenga fecha de finalizacion asignada y materiales comprados luego de la misma.

-- 1.b
	-- Se necesita un control a nivel TUPLA porque tenemos que controlar la cantidad de tuplas de una mista tabla.
	alter table tarea add constraint check_cant_tareas
	check (not exists(
			select 1
			from tarea
			group by area, extract(year from fecha_inicio) having count(*) > 12 
	));
	-- Controlamos que no exista ninguna tupla en la tabla TAREA donde un mismo area tenga iniciado mas de 12 tareas en un mismo año desde la tarea mas antigua del area hasta la tarea mas reciente del area.

-- 1,c
	-- Se necesita un control a nivel TUPLA porque solo se requiere controlar los valores de los atributos presupuesto y responsable de la tarea TAREA.
	alter table tarea add constraint check_responsable
	check (presupuesto <= 4000 or responsable is not null);
	-- Controlamos que tarae o tenga un presupuesto menor igual a 4000 o en caso contrario tener un responsable designado.

-- 2.a
	-- Se debe controlar los eventos:
		-- insercion en tabla UTILIZA
		-- modificacion de fecha_compra en MATERIAL
		-- modificacion de fecha_fin en TAREA
		-- modificacion de id_material en UTILIZA
		-- modificacion de nro_tarea y area en UTILIZA

-- 2.b
	create or replace trigger tr_insTarea
	before insert on tarea
	for each row execute function fn_insTarea();

	create or replace function fn_insTarea()
	returns trigger as $$
	begin
		if ((select count(*)
					from tarea 
					where area = new.area
					group by area, extract(year from fecha_inicio)) = 12) then
			raise exception 'Se alcanzo el limite maximo de 12 tareas asignadas al area %', new.area;
		return new;
	end $$ language plpgsql;

	-- Suponiendo que existe un area = 1 con 12 tareas asignadas con fecha de inicio en el presente año entonces la siguiente sentencia activaria nuestro trigger y provocaria la excepcion establecida
	insert into tarea values (13, 1, default, default, now(), null, null);

-- 3
	-- a. PROCEDE, la tupla se inserta en tecnico pero no aparece en VTC porque no cumple con la condicion de la vista referenciada VTE.
	-- b. FALLA porque cumple la condicion de VTR pero no cumple la condicion de la vista referenciada VTE que controla gracias al WCO CASCADED de VTR.
	-- c. PROCEDE porque la vista no tiene definido WCO y hay migracion de tupla porque no se cumple la condicion de anio_alta > 2023
	-- d. PROCEDE, la tupla se inserta en TECNICO pero no aparece en VTC porque no cumple la condicion de VTE.

-- 4.a
	create or replace view v1
	as (select m.id_material, m.denominaciom, count(u.*) as "total_tareas", coalesce(avg(u.cantidad), 0) as "cantidad_promedio"
		from material m
		join utiliza u using (id_material)
		where extract(year from m.fecha_compra) = current_year
		group by m.id_material);
	-- no es posible que resulte automaticamente actualizable en postgresql porque se deben usar funciones de agregacion en las columnas que mostramos y una funcion de agrupacion en el top level para esto.

-- 4.b
	create or replace view v2
	as (select t.*
		from tecnico t
		where t.id_tecnico in
			(select id_tecnico
				from asignado
				where (nro_tarea, area) in
					(select nro_tarea, area
						from tarea
						where presupuesto > 2500
							and fecha_fin is null
							and responsable != t.id_tecnico)));
	-- esta vista es automaticamente actualizable en postgresql porque no tiene funciones de agregacion, solo una entrada en la clausula from y no tiene funciones de agrupacion

-- 5.a
	create or replace trigger tr_actPresupuesto
	before update of presupuesto on tarea
	for each row execute function fn_actPresupuesto();

	create or replace function fn_actPresupuesto()
	returns trigger as $$
	begin
		if (new.presupuesto > old.presupuesto * 1.10) then
			raise exception 'El presupuesto no puede aumentarse mas de un 10 porciento del anterior';
		end if;
		return new;
	end $$ language plpgsql;

-- 5.b
	create or replace procedure llenarTabla(anio int)
	language plpgsql as $$
	begin
		delete from tecnicosxespecialidad;
		insert into tecnicosxespecialidad
			(select especialidad, count(*), max(remuneracion)
				from tecnico
				group by especialidad having anio_alta = anio);
	end $$;

-- 6.a
	-- Las consultas 1 y 2 recuperan la informacion solicitada.
	-- La consulta 1 no esta optimizada porque se hace un ensamble innecesario con la tabla TECNICO.
	-- La consulta 2 si esta optimizada porque solo se hace el ensamble necesario con la tabla ASIGNADO para saber si hay por lo emnos un tecnico asignado a la tarea junto con las otras restricciones de atributo correspondientes en la tabla TAREA.

-- 6.b
	-- unc_db1 ejecuta:
	grant select on tarea, asignado(nro_tarea, area) to unc_db2;
	