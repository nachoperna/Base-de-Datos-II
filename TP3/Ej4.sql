-- EJERCICIO 4
-- a. 
    create table his_entrega (
    nro_registro serial not null,
    fecha date not null,
    operacion text not null,
    cant_reg_afectados int not null,
    usuario text not null,
    primary key (nro_registro)
    );

    create or replace function fn_actHistorial()
    returns trigger as $$
        declare
            cant_registros int;
        begin
            cant_registros = (select count(*) from reg_afectados);
            insert into his_entrega (fecha, operacion, cant_reg_afectados, usuario) values (current_timestamp, tg_op, cant_registros, current_user);
            update reg_afectados set cantidad = 0;
            return new;
        end; $$ language 'plpgsql';


    create or replace trigger tr_act_historial
        after insert or update or delete
        on entrega
        for each row execute function fn_actHistorial();

    create or replace function fn_cont_registros()
    returns trigger as $$
        begin
            update reg_afectados set cantidad = cantidad+1;
            return new;
        end; $$ language 'plpgsql';

    create or replace trigger tr_cont_registros
        after insert or update or delete
        on entrega
        for each statement execute function fn_cont_registros();

    create table reg_afectados(
        cantidad int not null default 0
    );

    -- Testeo
    insert into entrega values (8071,current_date,7778,3);
    insert into entrega values (8072, current_date, 7779, 3), (8073, current_date, 7780, 3);
    insert into entrega values (8077,current_date,9999,4);

    select * from his_entrega;
    delete from his_entrega;
    select * from entrega offset 8000;

    delete from entrega where fecha_entrega >= to_date('2024-09-11', 'YYYY-MM-DD');

    select * from reg_afectados;
    delete from reg_afectados;

    insert into reg_afectados values (0);

-- SOLUCION CORRECTA EN SU TOTALIDAD

create table his_entrega(
    nro_registro int default 0 not null,
    fecha timestamp,
    operacion varchar(15),
    cant_reg_afectados int default 0,
    usuario varchar(30)
);

create table reg_afectados(
    tabla varchar(30),
    cantidad int
);
    insert into reg_afectados values ('entrega', 0);
    insert into reg_afectados values ('renglon_entrega', 0);

select * from reg_afectados;

create or replace trigger tr_act_entrega
    after insert or update or delete on entrega
    for each row execute function fn_actHistorialEntrega();

create or replace trigger tr_act_entrega
    after insert or update or delete on renglon_entrega
    for each row execute function fn_actHistorialEntrega();

create or replace function fn_actHistorialEntrega()
returns trigger as $$
    declare
        nroregistro int;
    begin
        update reg_afectados set cantidad = cantidad+1 where tabla = tg_table_name;

        if ((select count(*) from his_entrega) = 0) then
            nroregistro = 0;
        else
            nroregistro = (select nro_registro+1 from his_entrega order by nro_registro desc limit 1);
        end if;
        insert into his_entrega values (nroregistro,
                                        now(),
                                        tg_op,
                                        (select cantidad from reg_afectados where tabla = tg_table_name),
                                        current_user);

        update reg_afectados set cantidad = 0;
        return new;
    end;
    $$ language 'plpgsql';

select * from his_entrega;

select * from video order by id_video desc;
select * from distribuidor order by id_distribuidor desc;
select * from entrega order by nro_entrega desc;
insert into entrega values (8074, now(), 12000, 1050);
select codigo_pelicula from pelicula order by codigo_pelicula desc;
insert into renglon_entrega values (8074, 31802, 1);
update renglon_entrega set cantidad = 2 where nro_entrega = 8074 and codigo_pelicula = 31802;
delete from renglon_entrega where nro_entrega = 8074 and codigo_pelicula = 31802;
delete from entrega where nro_entrega = 8074;