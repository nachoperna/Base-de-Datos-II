-- a. 
/* Al ser invocado (una vez por mes), para todos los servicios que son periódicos, se deben
   generar e insertar los registros asociados a la/s factura/s correspondiente/s a los distintos
   clientes. Indicar si se deben proveer parámetros adicionales para su generación y, de ser así, cuales. */

   create or replace procedure generarFacturas()
       language 'plpgsql' as $$
       begin
           insert into lineacomprobante
           values (
                   
                  )
       end;
       $$

   -- tambien de forma recursiva?
   
-- b.
/* Al ser invocado entre dos fechas cualesquiera genere un informe de los empleados
(personal) junto con la cantidad de clientes distintos que cada uno ha atendido en tal periodo y
los tiempos promedio y máximo del conjunto de turnos atendidos en el periodo.*/

   create or replace function generarInformePersonal(inicio_periodo timestamptz, fin_periodo timestamptz)
      returns table (
         id_personal int,
         nombre_personal varchar(40),
         cantidad_clientes_atendidos bigint,
         desde timestamptz,
         hasta timestamptz,
         tiempo_promedio_turno interval,
         tiempo_maximo_turno interval
      )
      as $$
      begin
         return query
         (select p.id_personal, p1.nombre, count(distinct c.id_cliente), inicio_periodo, fin_periodo, avg(t.hasta - t.desde), max(t.hasta - t.desde)
          from personal p
              join persona p1 on p.id_personal = p1.id_persona
              join turno t on t.id_personal = p.id_personal
              join lugar l on l.id_lugar = t.id_lugar
              join comprobante c on l.id_lugar = c.id_lugar
          where t.desde >= inicio_periodo and t.hasta <= fin_periodo
          group by p.id_personal, p1.nombre
         );
      end;
      $$ language 'plpgsql';

      select * from generarInformePersonal(to_timestamp('2024-10-09 00:00:00', 'yyyy-mm-dd HH24:MI:SS'), now());
      