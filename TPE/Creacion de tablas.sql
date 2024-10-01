-- Table: Barrio
CREATE TABLE Barrio (
    id_barrio int  NOT NULL,
    nombre varchar(20)  NOT NULL,
    id_ciudad int  NOT NULL,
    CONSTRAINT Barrio_pk PRIMARY KEY (id_barrio)
);

-- Table: Categoria
CREATE TABLE Categoria (
    id_cat int  NOT NULL,
    nombre varchar(50)  NOT NULL,
    CONSTRAINT Categoria_pk PRIMARY KEY (id_cat)
);

-- Table: Ciudad
CREATE TABLE Ciudad (
    id_ciudad int  NOT NULL,
    nombre varchar(80)  NOT NULL,
    CONSTRAINT Ciudad_pk PRIMARY KEY (id_ciudad)
);

-- Table: Cliente
CREATE TABLE Cliente (
    id_cliente int  NOT NULL,
    saldo numeric(18,3)  NULL,
    CONSTRAINT Cliente_pk PRIMARY KEY (id_cliente)
);

-- Table: Comprobante
CREATE TABLE Comprobante (
    id_comp bigint  NOT NULL,
    id_tcomp int  NOT NULL,
    fecha timestamp  NULL,
    comentario varchar(2048)  NOT NULL,
    estado varchar(20)  NULL,
    fecha_vencimiento timestamp  NULL,
    id_turno int  NULL,
    importe numeric(18,5)  NOT NULL,
    id_cliente int  NOT NULL,
    id_lugar int,
    CONSTRAINT pk_comprobante PRIMARY KEY (id_comp,id_tcomp)
);

-- Table: Direccion
CREATE TABLE Direccion (
    id_direccion int  NOT NULL,
    id_persona int  NOT NULL,
    calle varchar(50)  NOT NULL,
    numero int  NOT NULL,
    piso int  NULL,
    depto varchar(50)  NULL,
    id_barrio int  NOT NULL,
    CONSTRAINT Direccion_pk PRIMARY KEY (id_direccion,id_persona)
);

-- Table: Equipo
CREATE TABLE Equipo (
    id_equipo int  NOT NULL,
    nombre varchar(80)  NOT NULL,
    MAC varchar(20)  NOT NULL default '00:00:00:00:00:00',
    IP varchar(20)  NULL,
    AP varchar(20)  NULL,
    id_servicio int  NULL,
    id_cliente int  NULL,
    fecha_alta timestamp  NOT NULL,
    fecha_baja timestamp  NULL,
    tipo_conexion varchar(20)  NULL,
    tipo_asignacion varchar(20)  NULL,
    CONSTRAINT Equipo_pk PRIMARY KEY (id_equipo)
);

-- Table: LineaComprobante
CREATE TABLE LineaComprobante (
    nro_linea int  NOT NULL,
    id_comp bigint  NOT NULL,
    id_tcomp int  NOT NULL,
    descripcion varchar(80)  NOT NULL,
    cantidad int  NOT NULL,
    importe numeric(18,5)  NOT NULL,
    id_servicio int  NULL,
    CONSTRAINT pk_lineacomp PRIMARY KEY (nro_linea,id_comp,id_tcomp)
);

-- Table: Persona
CREATE TABLE Persona (
    id_persona int  NOT NULL,
    tipo varchar(10)  NOT NULL,
    tipodoc varchar(10)  NOT NULL,
    nrodoc varchar(10)  NOT NULL,
    nombre varchar(40)  NOT NULL,
    apellido varchar(40)  NOT NULL,
    fecha_nacimiento timestamp  NOT NULL,
    fecha_alta timestamp  NOT NULL default now(),
    fecha_baja timestamp  NULL,
    CUIT varchar(20)  NULL,
    activo boolean  NOT NULL,
    mail varchar(100)  NULL,
    telef_area int  NULL,
    telef_numero int  NULL,
    CONSTRAINT pk_persona PRIMARY KEY (id_persona)
);

-- Table: Personal
CREATE TABLE Personal (
    id_personal int  NOT NULL,
    id_rol int  NOT NULL,
    CONSTRAINT Personal_pk PRIMARY KEY (id_personal)
);

-- Table: Rol
CREATE TABLE Rol (
    id_rol int  NOT NULL,
    nombre varchar(50)  NOT NULL,
    CONSTRAINT Rol_pk PRIMARY KEY (id_rol)
);

-- Table: Servicio
CREATE TABLE Servicio (
    id_servicio int  NOT NULL,
    nombre varchar(80)  NOT NULL,
    periodico boolean  NOT NULL,
    costo numeric(18,3)  NOT NULL,
    intervalo int  NULL,
    tipo_intervalo varchar(20)  NULL,
    activo boolean  NOT NULL DEFAULT true,
    id_cat int  NOT NULL,
    CONSTRAINT CHECK_0 CHECK (( tipo_intervalo in ( 'semana' , 'quincena' , 'mes' , 'bimestre' ) )) NOT DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT pk_servicio PRIMARY KEY (id_servicio)
);

-- Table: TipoComprobante
CREATE TABLE TipoComprobante (
    id_tcomp int  NOT NULL,
    nombre varchar(30)  NOT NULL,
    tipo varchar(80)  NOT NULL,
    CONSTRAINT pk_tipo_comprobante PRIMARY KEY (id_tcomp)
);

-- Table: Turno
CREATE TABLE Turno (
    id_turno int  NOT NULL,
    desde timestamp  NOT NULL,
    hasta timestamp  NULL,
    dinero_inicio numeric(18,3)  NOT NULL,
    dinero_fin numeric(18,3)  NULL,
    id_personal int  NOT NULL,
    id_lugar int,
    CONSTRAINT Turno_pk PRIMARY KEY (id_turno)
);

-- Table: Lugar
CREATE TABLE Lugar (
    id_lugar int  NOT NULL,
    nombre varchar(50)  NOT NULL,
    CONSTRAINT Lugar_pk PRIMARY KEY (id_lugar)
);

-- foreign keys
-- Reference: LineaComprobante_Servicio (table: LineaComprobante)
ALTER TABLE LineaComprobante ADD CONSTRAINT LineaComprobante_Servicio
    FOREIGN KEY (id_servicio)
    REFERENCES Servicio (id_servicio)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_barrio_ciudad (table: Barrio)
ALTER TABLE Barrio ADD CONSTRAINT fk_barrio_ciudad
    FOREIGN KEY (id_ciudad)
    REFERENCES Ciudad (id_ciudad)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_cliente_persona (table: Cliente)
ALTER TABLE Cliente ADD CONSTRAINT fk_cliente_persona
    FOREIGN KEY (id_cliente)
    REFERENCES Persona (id_persona)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_comprobante_cliente (table: Comprobante)
ALTER TABLE Comprobante ADD CONSTRAINT fk_comprobante_cliente
    FOREIGN KEY (id_cliente)
    REFERENCES Cliente (id_cliente)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_comprobante_tipocomprobante (table: Comprobante)
ALTER TABLE Comprobante ADD CONSTRAINT fk_comprobante_tipocomprobante
    FOREIGN KEY (id_tcomp)
    REFERENCES TipoComprobante (id_tcomp)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_comprobante_turno (table: Comprobante)
ALTER TABLE Comprobante ADD CONSTRAINT fk_comprobante_turno
    FOREIGN KEY (id_turno)
    REFERENCES Turno (id_turno)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_direccion (table: Direccion)
ALTER TABLE Direccion ADD CONSTRAINT fk_direccion
    FOREIGN KEY (id_persona)
    REFERENCES Persona (id_persona)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_direccion_barrio (table: Direccion)
ALTER TABLE Direccion ADD CONSTRAINT fk_direccion_barrio
    FOREIGN KEY (id_barrio)
    REFERENCES Barrio (id_barrio)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_equipo_cliente (table: Equipo)
ALTER TABLE Equipo ADD CONSTRAINT fk_equipo_cliente
    FOREIGN KEY (id_cliente)
    REFERENCES Cliente (id_cliente)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_equipo_servicio (table: Equipo)
ALTER TABLE Equipo ADD CONSTRAINT fk_equipo_servicio
    FOREIGN KEY (id_servicio)
    REFERENCES Servicio (id_servicio)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_lineacomprobante_comprobante (table: LineaComprobante)
ALTER TABLE LineaComprobante ADD CONSTRAINT fk_lineacomprobante_comprobante
    FOREIGN KEY (id_comp, id_tcomp)
    REFERENCES Comprobante (id_comp, id_tcomp)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_personal_persona (table: Personal)
ALTER TABLE Personal ADD CONSTRAINT fk_personal_persona
    FOREIGN KEY (id_personal)
    REFERENCES Persona (id_persona)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_personal_rol (table: Personal)
ALTER TABLE Personal ADD CONSTRAINT fk_personal_rol
    FOREIGN KEY (id_rol)
    REFERENCES Rol (id_rol)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_personal_turno (table: Turno)
ALTER TABLE Turno ADD CONSTRAINT fk_personal_turno
    FOREIGN KEY (id_personal)
    REFERENCES Personal (id_personal)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_servicio_categoria (table: Servicio)
ALTER TABLE Servicio ADD CONSTRAINT fk_servicio_categoria
    FOREIGN KEY (id_cat)
    REFERENCES Categoria (id_cat)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.