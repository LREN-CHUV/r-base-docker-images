
-- DROP TABLE results_box_stats;

ALTER USER test SET search_path to 'public'

CREATE TABLE results_box_stats
(
  request_id character varying(32) NOT NULL,
  node character varying(32) NOT NULL,
  id numeric,
  min numeric,
  q1 numeric,
  median numeric,
  q3 numeric,
  max numeric,

  CONSTRAINT results_linear_regression_pkey PRIMARY KEY (request_id, node, id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE results_linear_regression
  OWNER TO analytics;
GRANT ALL ON TABLE results_linear_regression TO analytics;
