/*==============================================================*/
/* DBMS name:      PostgreSQL 9.x                               */
/* Created on:     9/10/2018 4:19:19 PM                         */
/*==============================================================*/


/*==============================================================*/
/* Table: BUILDING                                              */
/*==============================================================*/
create table BUILDING (
   CAMPUS_ID            INT4                 not null,
   BUILDING_ID          CHAR(8)              not null,
   BUILDING_NAME        TEXT                 not null,
   constraint PK_BUILDING primary key (CAMPUS_ID, BUILDING_ID)
);

/*==============================================================*/
/* Table: CAMPUS                                                */
/*==============================================================*/
create table CAMPUS (
   CAMPUS_ID            SERIAL               not null,
   CAMPUS_NAME          TEXT                 not null,
   constraint PK_CAMPUS primary key (CAMPUS_ID)
);

/*==============================================================*/
/* Table: CHARACTERISTIC                                        */
/*==============================================================*/
create table CHARACTERISTIC (
   CHARACTERISTIC_ID    SERIAL               not null,
   CHARACTERISTIC_NAME  TEXT                 not null,
   constraint PK_CHARACTERISTIC primary key (CHARACTERISTIC_ID)
);

/*==============================================================*/
/* Table: DEPARTMENT                                            */
/*==============================================================*/
create table DEPARTMENT (
   DEPARTMENT_ID        SERIAL               not null,
   FACULTY_ID           INT4                 null,
   DEPARTMENT_NAME      TEXT                 not null,
   constraint PK_DEPARTMENT primary key (DEPARTMENT_ID)
);

/*==============================================================*/
/* Table: DEPARTMENT_MEMBERS                                    */
/*==============================================================*/
create table DEPARTMENT_MEMBERS (
   CIP                  CHAR(8)              not null,
   DEPARTMENT_ID        INT4                 not null,
   constraint PK_DEPARTMENT_MEMBERS primary key (CIP, DEPARTMENT_ID)
);

/*==============================================================*/
/* Table: FACULTY                                               */
/*==============================================================*/
create table FACULTY (
   FACULTY_ID           SERIAL               not null,
   FACULTY_NAME         TEXT                 not null,
   constraint PK_FACULTY primary key (FACULTY_ID)
);

/*==============================================================*/
/* Table: LOG                                                   */
/*==============================================================*/
create table LOG (
   LOG_ID               SERIAL               not null,
   CIP                  CHAR(8)              null,
   LOG_TIMESTAMP        TIMESTAMP            not null,
   LOG_DATA             TEXT                 not null,
   constraint PK_LOG primary key (LOG_ID)
);

/*==============================================================*/
/* Table: MEMBER                                                */
/*==============================================================*/
create table MEMBER (
   CIP                  CHAR(8)              not null,
   SURNAME              TEXT                 not null,
   NAME                 TEXT                 not null,
   EMAIL                TEXT                 not null,
   constraint PK_MEMBER primary key (CIP)
);

/*==============================================================*/
/* Table: MEMBER_ROLES                                          */
/*==============================================================*/
create table MEMBER_ROLES (
   CIP                  CHAR(8)              not null,
   ROLE_ID              INT4                 not null,
   constraint PK_MEMBER_ROLES primary key (CIP, ROLE_ID)
);

/*==============================================================*/
/* Table: PERMISSION                                            */
/*==============================================================*/
create table PERMISSION (
   PERMISSION_ID        SERIAL               not null,
   PERMISSION_NAME      TEXT                 not null,
   constraint PK_PERMISSION primary key (PERMISSION_ID)
);

/*==============================================================*/
/* Table: PRIVILEGES                                            */
/*==============================================================*/
create table PRIVILEGES (
   ROLE_ID              INT4                 not null,
   ROOM_TYPE_ID         INT4                 not null,
   PERMISSION_ID        INT4                 not null,
   DEPARTMENT_ID        INT4                 not null,
   constraint PK_PRIVILEGES primary key (ROLE_ID, ROOM_TYPE_ID, PERMISSION_ID, DEPARTMENT_ID)
);

/*==============================================================*/
/* Table: RESERVATION                                           */
/*==============================================================*/
create table RESERVATION (
   CIP                  CHAR(8)              not null,
   CAMPUS_ID            INT4                 not null,
   BUILDING_ID          CHAR(8)              not null,
   ROOM_ID              CHAR(8)              not null,
   START_TIMESTAMP      TIMESTAMP            not null,
   END_TIMESTAMP        TIMESTAMP            not null,
   DESCRIPTION          TEXT                 null,
   constraint PK_RESERVATION primary key (CAMPUS_ID, BUILDING_ID, CIP, ROOM_ID, START_TIMESTAMP)
);

/*==============================================================*/
/* Table: ROLE                                                  */
/*==============================================================*/
create table ROLE (
   ROLE_ID              SERIAL               not null,
   ROLE_NAME            TEXT                 not null,
   constraint PK_ROLE primary key (ROLE_ID)
);

/*==============================================================*/
/* Table: ROOM                                                  */
/*==============================================================*/
create table ROOM (
   CAMPUS_ID            INT4                 not null,
   BUILDING_ID          CHAR(8)              not null,
   ROOM_ID              CHAR(8)              not null,
   PARENT_CAMPUS_ID     INT4                 null,
   PARENT_BUILDING_ID   CHAR(8)              null,
   PARENT_ROOM_ID       CHAR(8)              null,
   ROOM_TYPE_ID         INT4                 null,
   constraint PK_ROOM primary key (CAMPUS_ID, BUILDING_ID, ROOM_ID)
);

/*==============================================================*/
/* Table: ROOM_CHARACTERISTICS                                  */
/*==============================================================*/
create table ROOM_CHARACTERISTICS (
   CAMPUS_ID            INT4                 not null,
   BUILDING_ID          CHAR(8)              not null,
   ROOM_ID              CHAR(8)              not null,
   CHARACTERISTIC_ID    INT4                 not null,
   QUANTITY             INT4                 not null,
   constraint PK_ROOM_CHARACTERISTICS primary key (CAMPUS_ID, BUILDING_ID, ROOM_ID, CHARACTERISTIC_ID)
);

/*==============================================================*/
/* Table: ROOM_TYPE                                             */
/*==============================================================*/
create table ROOM_TYPE (
   ROOM_TYPE_ID         SERIAL               not null,
   ROOM_TYPE_NAME       TEXT                 not null,
   constraint PK_ROOM_TYPE primary key (ROOM_TYPE_ID)
);

/*==============================================================*/
/* Table: ROOM_UNAVAILABILITIES                                 */
/*==============================================================*/
create table ROOM_UNAVAILABILITIES (
   CAMPUS_ID            INT4                 not null,
   BUILDING_ID          CHAR(8)              not null,
   ROOM_ID              CHAR(8)              not null,
   UNAVAILABILITY_ID    INT4                 not null,
   constraint PK_ROOM_UNAVAILABILITIES primary key (CAMPUS_ID, BUILDING_ID, ROOM_ID, UNAVAILABILITY_ID)
);

/*==============================================================*/
/* Table: UNAVAILABILITY                                        */
/*==============================================================*/
create table UNAVAILABILITY (
   UNAVAILABILITY_ID    SERIAL               not null,
   UNAVAILABILITY_START_TIMESTAMP TIMESTAMP            not null,
   UNAVAILABILITY_END_TIMESTAMP TIMESTAMP            not null,
   constraint PK_UNAVAILABILITY primary key (UNAVAILABILITY_ID)
);

alter table BUILDING
   add constraint FK_BUILDING_CONTAINS_CAMPUS foreign key (CAMPUS_ID)
      references CAMPUS (CAMPUS_ID)
      on delete restrict on update restrict;

alter table DEPARTMENT
   add constraint FK_DEPARTME_RELATIONS_FACULTY foreign key (FACULTY_ID)
      references FACULTY (FACULTY_ID)
      on delete restrict on update restrict;

alter table DEPARTMENT_MEMBERS
   add constraint FK_DEPARTME_DEPARTMEN_MEMBER foreign key (CIP)
      references MEMBER (CIP)
      on delete restrict on update restrict;

alter table DEPARTMENT_MEMBERS
   add constraint FK_DEPARTME_DEPARTMEN_DEPARTME foreign key (DEPARTMENT_ID)
      references DEPARTMENT (DEPARTMENT_ID)
      on delete restrict on update restrict;

alter table LOG
   add constraint FK_LOG_RELATIONS_MEMBER foreign key (CIP)
      references MEMBER (CIP)
      on delete restrict on update restrict;

alter table MEMBER_ROLES
   add constraint FK_MEMBER_R_MEMBER_RO_MEMBER foreign key (CIP)
      references MEMBER (CIP)
      on delete restrict on update restrict;

alter table MEMBER_ROLES
   add constraint FK_MEMBER_R_MEMBER_RO_ROLE foreign key (ROLE_ID)
      references ROLE (ROLE_ID)
      on delete restrict on update restrict;

alter table PRIVILEGES
   add constraint FK_PRIVILEG_PRIVILEGE_ROLE foreign key (ROLE_ID)
      references ROLE (ROLE_ID)
      on delete restrict on update restrict;

alter table PRIVILEGES
   add constraint FK_PRIVILEG_PRIVILEGE_ROOM_TYP foreign key (ROOM_TYPE_ID)
      references ROOM_TYPE (ROOM_TYPE_ID)
      on delete restrict on update restrict;

alter table PRIVILEGES
   add constraint FK_PRIVILEG_PRIVILEGE_PERMISSI foreign key (PERMISSION_ID)
      references PERMISSION (PERMISSION_ID)
      on delete restrict on update restrict;

alter table PRIVILEGES
   add constraint FK_PRIVILEG_PRIVILEGE_DEPARTME foreign key (DEPARTMENT_ID)
      references DEPARTMENT (DEPARTMENT_ID)
      on delete restrict on update restrict;

alter table RESERVATION
   add constraint FK_RESERVAT_RESERVATI_MEMBER foreign key (CIP)
      references MEMBER (CIP)
      on delete restrict on update restrict;

alter table RESERVATION
   add constraint FK_RESERVAT_RESERVATI_ROOM foreign key (CAMPUS_ID, BUILDING_ID, ROOM_ID)
      references ROOM (CAMPUS_ID, BUILDING_ID, ROOM_ID)
      on delete restrict on update restrict;

alter table ROOM
   add constraint FK_ROOM_RELATIONS_ROOM_TYP foreign key (ROOM_TYPE_ID)
      references ROOM_TYPE (ROOM_TYPE_ID)
      on delete restrict on update restrict;

alter table ROOM
   add constraint FK_ROOM_RELATIONS_ROOM foreign key (PARENT_CAMPUS_ID, PARENT_BUILDING_ID, PARENT_ROOM_ID)
      references ROOM (CAMPUS_ID, BUILDING_ID, ROOM_ID)
      on delete restrict on update restrict;

alter table ROOM
   add constraint FK_ROOM_RELATIONS_BUILDING foreign key (CAMPUS_ID, BUILDING_ID)
      references BUILDING (CAMPUS_ID, BUILDING_ID)
      on delete restrict on update restrict;

alter table ROOM_CHARACTERISTICS
   add constraint FK_ROOM_CHA_ROOM_CHAR_ROOM foreign key (CAMPUS_ID, BUILDING_ID, ROOM_ID)
      references ROOM (CAMPUS_ID, BUILDING_ID, ROOM_ID)
      on delete restrict on update restrict;

alter table ROOM_CHARACTERISTICS
   add constraint FK_ROOM_CHA_ROOM_CHAR_CHARACTE foreign key (CHARACTERISTIC_ID)
      references CHARACTERISTIC (CHARACTERISTIC_ID)
      on delete restrict on update restrict;

alter table ROOM_UNAVAILABILITIES
   add constraint FK_ROOM_UNA_ROOM_UNAV_ROOM foreign key (CAMPUS_ID, BUILDING_ID, ROOM_ID)
      references ROOM (CAMPUS_ID, BUILDING_ID, ROOM_ID)
      on delete restrict on update restrict;

alter table ROOM_UNAVAILABILITIES
   add constraint FK_ROOM_UNA_ROOM_UNAV_UNAVAILA foreign key (UNAVAILABILITY_ID)
      references UNAVAILABILITY (UNAVAILABILITY_ID)
      on delete restrict on update restrict;

