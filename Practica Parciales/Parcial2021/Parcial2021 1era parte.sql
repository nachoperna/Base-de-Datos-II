-- Ejercicio 1
	-- 1.3
		-- a.
		alter table profesor add constraint chk_tiposimple
		check (tipo_prof != 1 or extract(year from fecha_alta) > 2010);
			-- Tipo exlusivo: sin restricciones. (1 or x = 1) => cumple la restriccion
			-- Tipo simple con fecha alta posterior al 2010: (0 or 1 = 1) => cumple la restriccion
			-- Tipo simple con fecha alta anterior al 2010: (0 or 0 = 0) => no cumple la restriccion
			-- Fecha de alta posterior al 2010: (x or 1 = 1) => cumple la restriccion
			-- RESTRICCION SOPORTADA POR POSTGRESQL.

		-- b.
		create assertion ass_check_horas
		check (not exists(select 1 
							from integra i
							join curso c on i.cod_carrera = c.cod_carrera and i.id_curso = c.id_curso
							where c.cant_horas < 200 
							 and exists(select 1 
							 			from profesor p
							 			where p.legajo = i.legajo
							 			group by p.tipo_prof having count(*) >= 5)));
			-- Se controla que no existan cursos MENORES a 200 horas que lo dicten 5 o mas profesores de cada tipo.
			-- RESTRICCION NO SOPORTADA POR POSTGRESQL porque necesita ensambles de tablas en el control para cumplir con las condiciones de los controles.

-- Ejercicio 4
create or replace trigger tr_cambiotarea
	before update of id_tarea on voluntario
	for each row execute function fn_cambioTarea();

create or replace function fn_cambioTarea()
	returns trigger as $$
	begin
		if (exists(select 1 
					from voluntario v 
					join historico h on h.nro_voluntario = v.nro_voluntario
					where nro_voluntario = new.nro_voluntario
						and porcentaje > 15 and extract(year from h.fecha_inicio) = current_year
					group by h.nro_voluntario having count(h.id_tarea) >= 4
					order by h.fecha_inicio desc
					limit 1))) then
			raise exception 'No puede actualizarse la tarea del voluntario numero % porque no puede cambiar de tarea mas de 5 veces por año', new.nro_voluntario;
		else
			raise exception 'No existe el voluntario a actualizar';
		end if;
		return new;
	end
	$$ language 'plpgsql';