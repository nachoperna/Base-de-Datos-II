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

    -- NO FUNCIONA con restriccion declarativa (deja cambiar estado activo a false y que la fechabaja siga siendo null)

    create or replace trigger tr_check_baja
        before update of activo on persona
        for each row execute function fn_check_baja();

    create or replace function fn_check_baja()
    returns trigger as $$
        begin
            if (new.activo = false) then -- comprueba que quiera dar de baja al cliente
                if (exists(select 1 from persona where id_persona = new.id_persona
                                                 and fecha_baja is not null
                                                 and extract(month from age(fecha_alta, fecha_baja)) > 6)) then
                    update persona set activo = new.activo where id_persona = new.id_persona;
                else
                    raise exception 'No existe la persona o su fecha de baja no es 6 meses posterior a su alta en el sistema';
                end if;
            end if;
            return new;
        end;
        $$ language 'plpgsql';

    -- FUNCIONA 

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

    -- Triggers para la correcta insercion de una linea en un comprobante.(NO NECESARIA)
    create or replace trigger tr_ins_linea
        before insert or update on lineacomprobante
        for each row execute function fn_actLineaComprobante();

    create or replace function fn_actLineaComprobante()
    returns trigger as $$
        begin
            if (exists(select 1 from comprobante where id_comp = new.id_comp and id_tcomp = new.id_tcomp)
                and exists(select 1 from servicio where id_servicio = new.id_servicio)) then -- idservicio puede ser nulo en lineacomprobante no entiendo por que pero lo chequeo igual
                if (tg_op = 'INSERT') then
                    insert into lineacomprobante values (new.nro_linea, new.id_comp, new.id_tcomp, new.descripcion, new.cantidad, new.importe, new.id_servicio);
                    update comprobante set importe =+ (new.importe * new.cantidad) where id_comp = new.id_comp and id_tcomp = new.id_tcomp;
                else -- update
                    if (exists(select 1 from lineacomprobante where nro_linea = new.nro_linea and id_comp = new.id_comp and id_tcomp = new.id_tcomp and id_servicio = new.id_servicio)) then
                        -- esta implementacion evita el problema de no saber si el usuario quiere aumentar el importe de una linea
                        -- o decrementarlo
                        update comprobante set importe =- (old.importe * old.cantidad) where id_comp = old.id_comp and id_tcomp = old.id_tcomp; -- le resta el monto de linea anterior
                        update comprobante set importe =+ (new.importe * new.cantidad) where id_comp = new.id_comp and id_tcomp = new.id_tcomp; -- le suma el nuevo monto de linea
                    else
                        raise exception 'No existe una linea con esos id';
                    end if;
                end if;
            else
                raise exception 'No existe un comprobante o servicio con esos id';
            end if;
            return new;
        end;
        $$ language 'plpgsql';

    create or replace trigger tr_del_LineaComprobante
        after delete on lineacomprobante
        for each row execute function fn_del_LineaComprobante();

    create or replace function fn_del_LineaComprobante()
    returns trigger as $$
        begin
            if (exists(select 1 from lineacomprobante where nro_linea = old.nro_linea and id_comp = old.id_comp and id_tcomp = old.id_tcomp and id_servicio = old.id_servicio)) then
                delete from lineacomprobante where nro_linea = old.nro_linea and id_comp = old.id_comp and id_tcomp = old.id_tcomp and id_servicio = old.id_servicio;
                update comprobante set importe =- (old.importe * old.cantidad) where id_comp = old.id_comp and id_tcomp = old.id_tcomp;
            end if;
            return old;
        end;
        $$ language 'plpgsql';
        
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

    -- FUNCIONA