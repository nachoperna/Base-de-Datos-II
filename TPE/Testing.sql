-- Testing para comprobar la funcionalidad de los ejercicios

-- 1.
    -- a.
        select * from persona;
        -- Hay un minimo de 3 clientes, todos activos y sin fecha de baja establecida.
        update persona set activo = false where id_persona = 3;
        -- Queremos dejar inactivo a un cliente sin establecer una fecha de baja
        -- Si funciona: no nos permite realizar la operacion porque viola la restriccion "check_fecha_baja".
        update persona set fecha_baja = to_timestamp('2025-11-09', 'yyyy-mm-dd H24:MI:SS') where id_persona = 3;
        -- Establecemos una fecha de baja con diferencia de 1 año y 1 mes.
        -- Si funciona: debe dejar actualizar.
        update persona set fecha_baja = to_timestamp('2024-11-09', 'yyyy-mm-dd H24:MI:SS') where id_persona = 3;
        -- Establecemos una fecha de baja con diferencia de 1 mes.
        -- Si funcionaa: no debe dejar actualizar.

    -- b.
        insert into lineacomprobante values (1, 1, 1, '', 1, 100, 2);
        insert into lineacomprobante values (2, 1, 1, '', 1, 200, 2);
        insert into lineacomprobante values (3, 1, 1, '', 1, 100, 2);
        -- Insertamos 3 lineas de comprobante al comprobante (1,1)
        select nro_linea, id_comp, id_tcomp, importe from lineacomprobante where id_comp = 1 and id_tcomp = 1;
        -- Comprobamos que se encuentren las 3 lineas insertadas
        select id_comp, id_tcomp, importe from comprobante where id_comp = 1 and id_tcomp = 1;
        -- Miramos la tupla del comprobante donde insertamos lineas.
        -- Si funciona: el importe del comprobante debe ser la suma de las lineas (100+200+100 = 400)

        update lineacomprobante set importe = 0 where nro_linea = 3 and id_comp = 1 and id_tcomp = 1;
        -- Modificamos el importe de una linea del comprobante.
        select id_comp, id_tcomp, importe from comprobante where id_comp = 1 and id_tcomp = 1;
        -- Si funciona: el importe del comprobante debe estar modificado por la nueva suma de sus lineas (100+200+0 = 300)

        delete from lineacomprobante where nro_linea = 2 and id_comp = 1 and id_tcomp = 1 and id_servicio = 2;
        -- Borramos una linea del comprobante.
        select id_comp, id_tcomp, importe from comprobante where id_comp = 1 and id_tcomp = 1;
        -- Si funciona: el importe del comprobante debe tener descontado el importe de la linea que eliminamos (300 - 200 = 100)

        delete from lineacomprobante;
        update comprobante set importe = 0;
        -- Regresamos la base al estado anterior del testing

    -- c.
        select * from equipo;
        -- Comprobamos que clientes tienen un equipo con IP asignada actualmente.
        update equipo set ip = '192.168.1.1' where id_cliente = 2;
        -- Le asignamos la IP del cliente 1 al cliente 2.
        -- Si funciona: no nos permite realizar la opreacion porque otro cliente ya tiene esa IP asignada.

-- 2.
    -- a.
        select * from servicio;
        -- Controlamos que servicios periodicos tenemos.
        select * from equipo;
        -- Controlamos que clientes poseen esos servicios.
        call generarFacturas();
        -- Se deben generar la factura para los clientes anteriores.
        select * from comprobante;
        -- Comprobamos que se encuentren cargados los comprobantes de los clientes anteriores con el monto correspondiente por sus servicios periodicos.

    -- b.
        select * from turno;
        -- El personal 1 atendio en 2 turnos (id_turno 1 y 3) y el personal 2 en un solo turno (id_turno 2). Ambos con duracion del turno de 8 horas.
        select * from comprobante;
        -- A fines practicos se insertaron unos comprobantes de prueba.
        select * from generarInformePersonal(to_timestamp('2024-10-09 00:00:00', 'yyyy-mm-dd HH24:MI:SS'), now());
        -- Llamamos a la funcion con la primera fecha siendo la misma de la carga de los turnos y la segunda fecha el dia de hoy.
        -- Si funciona: nos devuelve una tabla virtual con los datos requeridos, donde el tiempo promedio y maximo son de 8 horas porque todos los turnos fueron seteados en 8 horas de duracion.

-- 3.
    -- a.
        -- Insertamos un cliente que viva en Napoli, menor de 30 años y con mas de 3 servicios.
        insert into persona values (4, 'Cliente', 'DNI', '123', 'Cliente4', 'Apellido4', to_timestamp('2001-06-07', 'yyyy-mm-dd HH24:MI:SS'), now(), null, null, true, null, null, null);
        insert into cliente values (4, 7500);
        insert into direccion values (4, 4, '', 4, null, null, 1);
        insert into equipo values (4, '','', null, null, 1, 4, now(), null, null, null);
        insert into equipo values (5, '','', null, null, 2, 4, now(), null, null, null);
        insert into equipo values (6, '','', null, null, 3, 4, now(), null, null, null);
        insert into equipo values (7, '','', null, null, 4, 4, now(), null, null, null);
        select * from equipo where id_cliente = 4;
        -- Comprobamos que el cliente 4 tiene 4 servicios, es menor de 30 años y vive en la ciudad de Napoli.
        select * from vista1;
        -- Si funciona: el cliente 4 deberia aparecer en la tabla.
        update vista1 set saldo = saldo + 100 where id_cliente = 4;
        -- Actualizamos una columna de la vista para comprobar que es actualizable.
        select * from vista1;
        -- Si funciona: el valor de la columna esta cambiado y la vista es actualizable.

    -- b.
        select id_persona from persona where activo is true;
        -- Vemos los clientes activos que tenemos en el sistema.
        select distinct c.id_cliente from persona p
                          join cliente c on p.id_persona = c.id_cliente
                          join equipo e on c.id_cliente = e.id_cliente
                          join servicio s on e.id_servicio = s.id_servicio
                          where p.activo is true;
        -- Obtenemos el ID de los clientes con al menos un servicio activo.
        -- Todos los clientes ingresados tienen fecha de alta en el año actual.
        select * from vista2;
        -- Si funciona: debe mostrar todos los clientes que aparecieron en la consulta anterior junto con los datos de sus servicios.
        update vista2 set "Costo servicio" = "Costo servicio" - 100 where id_persona = 1;
        -- Actualizo el costo de todos los servicios para el cliente 1
        select * from vista2;
        -- Si funciona: el costo del servicio del cliente 1 deberia ser distinto del anterior.

    -- c.
        select * from servicio;
        -- Comprobar que servicios periodicos tenemos
        select * from vista3;
        -- Comprobar que los servicios anteriores aparezcan en la vista con sus montos facturados correctos.