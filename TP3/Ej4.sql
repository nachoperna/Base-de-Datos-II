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