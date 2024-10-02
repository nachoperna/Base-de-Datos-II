-- a. 
/* Al ser invocado (una vez por mes), para todos los servicios que son periódicos, se deben
   generar e insertar los registros asociados a la/s factura/s correspondiente/s a los distintos
   clientes. Indicar si se deben proveer parámetros adicionales para su generación y, de ser así, cuales. */

   
-- b.
/* Al ser invocado entre dos fechas cualesquiera genere un informe de los empleados
(personal) junto con la cantidad de clientes distintos que cada uno ha atendido en tal periodo y
los tiempos promedio y máximo del conjunto de turnos atendidos en el periodo.*/

create or replace function generarInformePersonal(timestamp inicio_periodo, timestamp fin_periodo)
   returns table (
      id_personal int,
      nombre_personal varchar(40),
      cantidad_clientes_atendidos int,
      desde timestamp set value inicio_periodo,
      hasta timestamp set value fin_periodo,
      tiempo_promedio_turno timestamp,
      tiempo_maximo_turno timestamp
   )
   as $$
   begin
      return query
      (select p.id_personal, p1.nombre, count(distinct c.id_cliente), avg(t.desde - t.hasta), max(t.desde - t.hasta)
       from personal p 
       join persona p1 on id_personal = id_persona
       join turno t on t.id_personal = p.id_personal
       join lugar l on l.id_lugar = t.id_lugar
       join comprobante c on l.id_lugar = c.id_lugar
      )
   end;
   $$ language 'plpgsql';