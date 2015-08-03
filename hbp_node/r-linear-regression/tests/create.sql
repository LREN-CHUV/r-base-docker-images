CREATE SCHEMA test;
CREATE USER test PASSWORD 'test';
GRANT ALL ON SCHEMA test TO test;
GRANT ALL ON ALL TABLES IN SCHEMA test TO test;

CREATE TABLE test.results_linear_regression
(
  request_id character varying(32) NOT NULL,
  node character varying(32) NOT NULL,
  param_y character varying(512),
  param_a character varying(512),
  result_betai numeric,
  result_sigmai numeric,

  CONSTRAINT results_linear_regression_pkey PRIMARY KEY (request_id, node)
)
WITH (
  OIDS=FALSE
);
