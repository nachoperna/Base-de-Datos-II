-- Ejercicio 1
create or replace trigger tr_ins_entrega
	after insert on entrega
	for each row execute function fn_act_video();

create or replace function fn_act_video()
	returns trigger as $$
	begin
		if (exists(select 1 from distribuidor d where d.id_distribuidor = new.id_distribuidor)
			and 
			exists(select 1 from video v where v.id_video = new.id_video)) then
			if (not exists(select 1 
							from entrega 
							where id_distribuidor = new.id_distribuidor
								and id_video = new.id_video)) then
				update video set dif_distribuidores = dif_distribuidores + 1 where id_video = new.id_video;
			else
				raise notice 'Distribuidor ya conocido. No incrementa valor de dif_distribuidores';
			end if;
		else
			raise exception 'No existe video o distribuidor para insertar entrega';
		end if;
	end
	$$ language 'plpgsql';

	-- Se requiere controlar que exista el distribuidor y el video al que le queremos asignar una entrega.
	-- Se requiere controlar que el distribuidor a asignar no se encuentre ya en la tabla ENTREGA para poder incrementar el valor de distribuidores diferentes en VIDEO.
	
-- Ejercicio 2
	-- a.
		-- a.1
		create or replace view vista_1
		as (select *
			from mensaje
			where es_privado is true 
				and asunto ilike 'consulta%' 
				and (tipo_mensaje, cod_mensaje) in 
					(select tipo_mensaje, cod_mensaje
						from contiene
						where id_adjunto in 
							(select id_adjunto
								from adjunto
								where tipo_adj = 'I' and extract(year from fecha_creacion) = current_year)));
			-- Vista automaticamente actualizable en PostgreSQL.

		-- a.2
		create or replace view vista_2 
		as (select m.tipo_mensaje, m.cod_mensaje, m.texto, coalesce(count(c.descargado), 0) as "cantidad de archivos descargados"
			from mensaje m
			join contiene c on c.tipo_mensaje = m.tipo_mensaje and c.cod_mensaje = m.cod_mensaje
			group by c.tipo_mensaje, c.cod_mensaje);
			-- Vista no actualizable automaticamente en PostgreSQL porque contiene mas de una tabla en la clausula FROM, una funcion de agrupacion y una funcion de agregacion en el top level.

	-- b.
	create view VISTA_3 as
		select a.id_adjunto, a.tipo_adj, a.tamanio, a.fecha_creacion, ai.resolucion as dimension
		from adjunto a join imagen ai on a.id_adjunto = ai.id_adjunto
		union
		select a.id_adjunto, a.tipo_adj, a.tamanio, a.fecha_creacion, aa.duracion as dimension
		from adjunto a join audio aa on a.id_adjunto = aa.id_adjunto;

	create or replace trigger tr_del_vista3
	instead of delete on VISTA_3
	for each row execute function fn_del_vista3();

	create or replace function fn_del_vista3()
	returns trigger as $$
	begin
		if (not exists(select 1 from VISTA_3 where id_adjunto = new.id_adjunto)) then
			raise exception 'No existe el id_adjunto a eliminar';
		else
			delete from audio where id_adjunto = new.id_adjunto;
			delete from video where id_adjunto = new.id_adjunto;
			delete from adjunto where id_adjunto = new.id_adjunto;
			raise notice 'Borrado con exito';
		end if;
	end
	$$ language 'plpgsql';

-- Ejercicio 3
	-- a y b.
	insert into Tarea_smax (id_tarea, nombre_tarea, sueldo_minimo, sueldo_maximo) values (8009, ‘Tarea 8009’, 6000, 8000);
		-- PROCEDE porque cumple la condicion de Tarea_smax y la de Tarea_9 al tener que chequearla porque Tarea_smax tiene WCO CASCADED.

	insert into Tarea_9 (id_tarea, nombre_tarea, sueldo_minimo, sueldo_maximo) values (8000, ‘Tarea 8000’, 3000, 10000);
		-- PROCEDE y solo se inserta en la tabla TAREA y no aparece en Tarea_9 porque esta vista no tiene WCO.

	insert into Tarea_smax (id_tarea, nombre_tarea, sueldo_minimo, sueldo_maximo) values (9000, ‘Tarea 9000’, 6000, 7000);
		-- RECHAZA porque cumple la condicion de Tarea_smax pero no cumple con Tarea_9.

	insert into Tarea_smin (id_tarea, nombre_tarea, sueldo_minimo, sueldo_maximo) values (8010, ‘Tarea 8010’, 4000, 9000);
		-- PROCEDE y solo se inserta en la tabla TAREA y no aparece en Tarea_9 ni en Tarea_smin porque Tarea_smin al tener WCO LOCAL solo controla su propia condicion, la cual cumple.

-- Ejercicio 4
	-- La consulta responde a lo solicitado.
	-- Optimizar la consulta indicando las restricciones que mas filas ahorren lo antes posible?
	SELECT * FROM equipo e
		JOIN cliente cl ON (e.id_cliente = cl.id_cliente)
		JOIN persona p ON (cl.id_cliente = p.id_persona and p.cuit is null)
		JOIN direccion d ON (d.id_persona = p.id_persona)
		JOIN barrio b ON (d.id_barrio = b.id_barrio)
		JOIN ciudad c ON (b.id_ciudad = c.id_ciudad and c.id_ciudad < 3000);