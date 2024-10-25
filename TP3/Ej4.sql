-- EJERCICIO 4
-- a.
create table his_entrega(
    nro_registro serial,
    fecha timestamp,
    operacion varchar(15),
    cant_reg_afectados int,
    usuario varchar(30)
);

create table reg_afectados(
    cantidad int default 0
);
insert into reg_afectados values (default);
select * from reg_afectados;

create or replace trigger tr_actEntrega1
    after insert or update or delete on entrega
    for each row execute function fn_actRegAfectados();

create or replace trigger tr_actRenglonEntrega1
    after insert or update or delete on renglon_entrega
    for each row execute function fn_actRegAfectados();

create or replace function fn_actRegAfectados()
returns trigger as $$
    begin
        update reg_afectados set cantidad = cantidad + 1;
        return old;
    end;
    $$ language 'plpgsql';

create or replace trigger tr_actEntrega2
    after insert or update or delete on entrega
    for each statement execute function fn_actHisEntrega();

create or replace trigger tr_actRenglonEntrega2
    after insert or update or delete on renglon_entrega
    for each statement execute function fn_actHisEntrega();

create or replace function fn_actHisEntrega()
returns trigger as $$
    begin
        insert into his_entrega values (1, now(), tg_op, (select cantidad from reg_afectados), current_user);
        update reg_afectados set cantidad = 0;
        return old;
    end;
    $$ language 'plpgsql';

select nro_entrega from renglon_entrega order by nro_entrega desc;
insert into renglon_entrega values (8049, 1, 0);
select * from his_entrega;
select codigo_pelicula, count(*) from renglon_entrega group by codigo_pelicula order by count(*) desc;
update renglon_entrega set cantidad = 0 where codigo_pelicula = 13572;
select * from his_entrega;
delete from renglon_entrega where nro_entrega = 8049 and codigo_pelicula = 1;
delete from his_entrega;