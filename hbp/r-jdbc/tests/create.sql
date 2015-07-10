CREATE SCHEMA test;
CREATE USER test PASSWORD 'test';
GRANT ALL ON SCHEMA test TO test;
GRANT ALL ON ALL TABLES IN SCHEMA test TO test;
CREATE TABLE test.test (coltest varchar(20));
insert into test.test (coltest) values ('It works!');
