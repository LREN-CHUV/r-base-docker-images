
CREATE TABLE some_data
(
  id character varying(32) NOT NULL,
  a int,
  b int,
  
  CONSTRAINT pk_some_data PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

insert into some_data values ("001", 1, 2);
insert into some_data values ("002", 2, 3);
