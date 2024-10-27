-- Ejercicio 1
	-- a.
	create or replace view vista_1
	as (select tipo_mensaje, cod_mensaje, asunto, texto, fecha_envio
		from mensaje 
		where (tipo_mensaje, cod_mensaje) in 
			(select tipo_mensaje, cod_mensaje
				from adjunto
				where extract(year from anio_creacion) = current_year) 
					and tamanio < 50
				group by tipo_mensaje, cod_mensaje having count(*) >= 3));
		-- Vista automaticamente actualizable en PostgreSQL.

	-- b.
	create or replace view vista_2
	as (select a.*, coalesce(au.durecion, im.resolucion) as "tamaño"
		from adjunto a 
		join audio au on au.id_adjunto = a.id_adjunto
		join imagen im on im.id_adjunto = im.id_adjunto);
		-- Vista no actualizable automaticamente en PostgreSQL al tener que mostrar columnas de mas de una tabla.

-- Ejercicio 3
create or replace trigger tr_act_vista2
before insert or update on vista_2
for each row execute function fn_actVista2();

create or replace function fn_actVista2()
	returns trigger as $$
	begin
		if (new.tipo_mensaje is not null and new.cod_mensaje is not null) then
			if (not exists(select 1 from mensaje where m.tipo_mensaje = new.tipo_mensaje and m.cod_mensaje = new.cod_mensaje)) then
				raise exception 'No existe el mensaje a insertar/actualizar';
			end if;
		end if;
		if (tg_op = 'INSERT') then
			ínsert into adjunto values (new.id_adjunto, new.tamanio, new.ubicacion, new.anio_creacion, new.descripcion, new.tipo_adj, new.tipo_mensaje, new.cod_mensaje);
			if (new.tipo_adj = 'A') then
				insert into audio values (new.id_adjunto, new.duracion);
			else
				insert into imagen values (new.id_adjunto, new.resolucion);
			end if;
		else
			if (exists(select 1 from adjunto where id_adjunto = new.id_adjunto)) then
				if (old.tamanio is distinct from new.tamanio) then
					update adjunto set tamanio = new.tamanio
				end if;
				if (old.ubicacion is distinct from new.ubicacion) then
					update adjunto set ubicacion = new.ubicacion;
				end if;
				if (old.descripcion is distinct from new.descripcion) then
					update adjunto set descripcion = new.descripcion;
				end if;
			end if; 
		end if;
		return new;
	end
	$$ language 'plpgsql';

create or replace trigger tr_del_vista2
	after delete on vista_2
	for each row execute function fn_delVista2();

create or replace function fn_delVista2()
	returns trigger as $$
	begin
		if (exists(select 1 from adjunto where id_adjunto = old.id_adjunto)) then
			if (old.tipo_adj = 'A') then
				delete from audio where id_adjunto = old.id_adjunto;
			else
				delete from imagen where id_adjunto = old.id_adjunto;
			end if;
			delete from adjunto where id_adjunto = old.id_adjunto;
		end if;
	end
	$$ language 'plpgsql';

-- Ejercicio 7
	SELECT *
	FROM unc_esq_peliculas.pelicula p
	JOIN unc_esq_peliculas.renglon_entrega re ON (p.codigo_pelicula =
	re.codigo_pelicula)
	JOIN unc_esq_peliculas.entrega e ON (re.nro_entrega = e.nro_entrega)
	JOIN unc_esq_peliculas.distribuidor d ON (e.id_distribuidor =
	d.id_distribuidor)
	JOIN unc_esq_peliculas.internacional i ON (e.id_distribuidor = i.id_distribuidor)
	WHERE p.idioma LIKE 'Español%' AND i.codigo_pais = ‘GL’;

	-- a.
		-- No responde a lo solicitado porque hay un error de sintaxis donde en el SELECT no se indica de que tabla queremos mostrar todos sus atributos
		-- En este caso, debe mostrar solo los datos de la tabla pelicula, asique seria "p.*". Fuera de eso, cumple con lo solicitado.

	-- b.
		-- NO representa una consulta optimizada porque utiliza ensambles para usar solamente un dato de clave primaria que necesitamos.
		-- Ademas, hace un ensamble innecesario con la tabla distribuidor cuando podemos unir ENTREGA directamente con INTERNACIONAL porque distribuidor es una jerarquia.
		-- Debemos usar subconsultas para optimizarla asi podemos seleccionar solamente las columnas que queremos de las tablas que necesitamos.
		select *
		from pelicula
		where idioma ilike 'español%'
			and codigo_pelicula in 
				(select codigo_pelicula
					from renglon_entrega
					where nro_entrega in 
						(select nro_entrega
							from entrega 
							where id_distribuidor in 
								(select id_distribuidor
									from internacional
									where codigo_pais ilike 'gl')));

-- Ejercicio 9
create or replace procedure cantidadEntregas(tipo_dis char(1))
	language 'plpgsql' as $$
	declare
	id numeric(5,0);
	nombre varchar(80);
	cant int;
	begin
		delete from repentrega;
		(select d.id_distribuidor into id, d.nombre into nombre, count(*) into cant
			from distribuidor d
			join entrega e on e.id_distribuidor = d.id_distribuidor
			where d.tipo = tipo_dis
			group by d.id_distribuidor, d.nombre)
		insert into repentrega values (id, nombre, cant);
	end
	$$;