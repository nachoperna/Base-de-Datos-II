-- a. Las personas que no están activas deben tener establecida una fecha de baja, la cual se debe controlar que sea al menos 6 meses posterior a la de su alta.
    -- Chequeo por la positiva.
    alter table persona add constraint check_fecha_baja
    check (activo = True or fecha_baja is null or (
        extract(year from age(fecha_alta, fecha_baja) >= 1 or extract(month from age(fecha_alta, fecha_baja)) >= 6)));
        -- Chequea que todas las personas esten activas o que no tenga cargada fecha de baja o que si esta cargada, que la diferencia con su fecha de alta sea menor a 6 meses

    -- Chequeo por la negativa.
    alter table persona add constraint check_fecha_baja
    check (not((activo = false and fecha_baja is not null) and (extract(year from age(fecha_alta, fecha_baja)) < 1 and extract(month from age(fecha_alta, fecha_baja)) < 6)));
        -- Chequea que no exista ninguna persona que no este activa, que tenga una fecha de baja cargada y que esta tenga una diferencia mayor a 6 meses con su fecha de alta.

-- b. El importe de un comprobante debe coincidir con el total de los importes indicados en las líneas que lo conforman (si las tuviera).
    
    -- Restriccion declarativa en SQL estándar:
    create assertion ass_importeComprobante
        check (not exists(select 1 from lineacomprobante l join comprobante c using(id_comp, id_tcomp)
                        where l.id_comp = old.id_comp and l.id_tcomp = old.id_tcomp
                        group by c.importe having c.importe != sum(l.importe)));

    -- Implementacion en PostgreSQL:    
    create or replace trigger tr_importeComprobante
    after insert or update on lineacomprobante
    for each row execute function fn_importeComprobante();

    create or replace function fn_importeComprobante()
    returns trigger as $$
        begin
            if (exists(select 1 from lineacomprobante l join comprobante c using(id_comp, id_tcomp)
                        where l.id_comp = old.id_comp and l.id_tcomp = old.id_tcomp
                        group by c.importe having c.importe != sum(l.importe))) then
                raise exception 'No puede insertarse la linea porque no coincide el IMPORTE TOTAL con la suma de todas las lineas de los comprobantes';
            else
                raise notice 'Linea insertada correctamente';
            end if;
            return old;
        end;
        $$ language 'plpgsql';

    -- Justificacion de ambas implementaciones: se debe comprobar que no exista ningun caso que no cumpla la condicion de la consigna, donde ningun IMPORTE TOTAL de Comprobante debe ser distinto de la suma de los importes de todas las lineas que lo componen.

-- c. Las IPs asignadas a los equipos no pueden ser compartidas entre diferentes clientes.
    
    -- Restriccion declarativa en SQL estándar:
    create assertion ass_ipClientes
        check(not exists(select 1 from equipo where id_cliente is not null and id_cliente != new.id_cliente and ip = new.ip));

    -- Implementacion en PostgreSQL:
    create or replace trigger tr_ipClientes
        before insert or update of ip on equipo
        for each row execute function fn_ipClientes();

    create or replace function fn_ipClientes()
    returns trigger as $$
        begin
            if (exists(select 1 from equipo where id_cliente is not null and id_cliente != new.id_cliente and ip = new.ip)) then
                if (tg_op = 'INSERT') then
                    raise exception 'No puede insertarse la IP porque otro cliente ya la tiene asignada';
                else
                    raise exception 'No puede actualizarse la IP porque otro cliente ya la tiene asignada';
                end if;
            end if;
            return new;
        end;
        $$ language 'plpgsql';

    -- Justificacion de ambas implementaciones: se debe comprobar que no exista en la tabla Equipo ningun cliente diferente al dueño de la IP que tenga la misma direccion IP que se quiere insertar o modificar.