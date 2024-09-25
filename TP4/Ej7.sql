-- Ejercicio 7

-- Vista1
create or replace view vista1
as (select v.nro_voluntario, v.nombre, v.apellido, v.horas_aportadas, t.* from voluntario v
    join tarea_vol t using(id_tarea));

    -- Vista no actualizable automaticamente
    -- Trigger INSERT o UPDATE:
    create or replace trigger tr_act_vista1
    instead of insert or update on vista1
    for each row execute function fn_act_vista1();

    create or replace function fn_act_vista1()
    returns trigger as $$
        begin
                if (exists(select 1 from voluntario where nro_voluntario = new.nro_voluntario)) then
                    if (exists(select 1 from tarea_vol where id_tarea = new.id_tarea)) then
                        if (tg_op = 'INSERT') then
                            insert into vista1 values (new.nro_voluntario, new.nombre, new.apellido, new.horas_aportadas, new.nombre_tarea, new.min_horas, new.id_tarea, new.max_horas);
                        elsif (tg_op = 'UPDATE') then
                            -- sentencia update
                        end if;
                    else
                        raise exception 'No exista tarea con ese id_tarea';
                    end if;
                else
                    raise exception 'No existe voluntario con ese nro_voluntario';
                end if;
            return new;
        end;
        $$ language 'plpgsql';

    -- Trigger DELETE:
    create or replace trigger tr_del_vista1
    instead of delete on vista1
    for each row execute function fn_del_vista1();

    create or replace function fn_del_vista1()
    returns trigger as $$
        begin
            if (exists(select 1 from vista1 where nro_voluntario = old.nro_voluntario)) then
                    if (exists(select 1 from vista1 where id_tarea = old.id_tarea)) then
                        delete from vista1 where nro_voluntario = old.nro_voluntario and id_tarea = old.id_tarea;
                    else
                        raise exception 'No exista tarea con ese id_tarea para eliminar';
                    end if;
                else
                    raise exception 'No existe voluntario con ese nro_voluntario para eliminar';
                end if;
            return old;
        end;
        $$ language 'plpgsql';

-- Vista2
create or replace view vista2
as (select i.*, count(h.id_tarea) as "Cantidad de tareas realizadas" from institucion i
    join direccion_vol d on i.id_direccion = d.id_direccion and d.id_pais = 'US'
    join historico h using (id_institucion)
    group by i.id_institucion, nombre_institucion, id_director, i.id_direccion);

    -- Vista no actualizable automaticamente
    -- Trigger INSERT:
    create or replace trigger tr_act_vista2
    instead of insert or update vista2
    for each row execute function fn_act_vista2();

    create or replace function fn_act_vista2()
    returns trigger as $$
        begin
            if (exists(select 1 from institucion where id_institucion = new.id_institucion)) then
                    if (new.id_pais = 'US') then
                        if (tg_op = 'INSERT') then
                            insert into vista2 values (new.nombre_institucion, new.id_director, new.id_direccion, new.id_institucion, default);
                        elsif (tg_op = 'UPDATE') then
                            -- sentencia update
                        end if;
                    else
                        raise exception 'No se puede actualiar informacion si el id_pais no es "US"';
                    end if;
                else
                    raise exception 'No exista institucion con ese id';
                end if;
            return new;
        end;
        $$ language 'plpgsql';
    
    -- Trigger DELETE
    create or replace trigger tr_del_vista2
    instead of delete on vista2
    for each row execute function fn_del_vista2();

    create or replace function fn_del_vista2()
    returns trigger as $$
        begin
            if (exists(select 1 from institucion where id_institucion = old.id_institucion)) then
                delete from vista2 where id_institucion = old.id_institucion;
            else
                raise exception 'No exista institucion con ese id';
            end if;
            return old;
        end;
        $$ language 'plpgsql';

-- Vista3
create or replace view vista3
as (select i.id_institucion, i.nombre_institucion, count(v.*) as "Cantidad de voluntarios" from institucion i
    join voluntario v using(id_institucion)
    group by i.id_institucion, i.nombre_institucion);

