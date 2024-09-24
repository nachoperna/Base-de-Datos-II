-- Ejercicio 4

CREATE OR REPLACE VIEW tarea10000hs AS
SELECT *  FROM tarea_vol
WHERE max_horas > 10000
WITH LOCAL CHECK OPTION;

CREATE OR REPLACE VIEW tarea10000rep AS
SELECT *  FROM tarea10000hs
WHERE id_tarea LIKE '%REP%'
WITH LOCAL CHECK OPTION;

-- a.
    -- 1.
    select * from tarea10000rep;
    INSERT INTO tarea10000rep (id_tarea, nombre_tarea, min_horas, max_horas)
     VALUES ( 'MGR', 'Org Salud', 18000, 20000);
    -- no deja insertar porque la insercion viola la propia condicion de la vista al no tener un id_tarea que contenga las letras 'REP'

    -- 2.
    INSERT INTO tarea10000hs (id_tarea, nombre_tarea, min_horas, max_horas)
     VALUES (  'REPA', 'Organiz Salud', 4000, 5500);
    -- no deja insertar porque la insercion viola la condicion de la vista referenciada tarea10000hs con max_horas < 10000 al tener CHECK OPTION

    -- 3.
    INSERT INTO tarea10000rep (id_tarea, nombre_tarea, min_horas, max_horas)
     VALUES ( 'CC_REP', 'Organizacion Salud', 8000, 9000);
    -- no deja insertar porque la insercion viola la condicion de la vista referenciada tarea10000hs con max_horas < 10000 al tener CHECK OPTION

    -- 4.
    INSERT INTO tarea10000hs (id_tarea, nombre_tarea, min_horas, max_horas)
     VALUES (  'ROM', 'Org Salud', 10000, 12000);

    select * from tarea10000hs where id_tarea = 'ROM';
    -- inserta exitosamente porque cumple con la condicion de la vista de tener un max_horas > 10000
    select * from tarea_vol where id_tarea = 'ROM';
    -- inserta exitosamente en la lista tarea_vol porque satisface la condicion de la vista
    
-- b.
    -- no entendi a que se refiere con objetos
