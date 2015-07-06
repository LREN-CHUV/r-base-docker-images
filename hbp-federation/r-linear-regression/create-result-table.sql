
-- DROP TABLE results_linear_regression;

CREATE TABLE federation_results_linear_regression
(
  request_id character varying(32) NOT NULL,
  param_beta numeric ARRAY,
  param_sigma numeric ARRAY,
  result_betai numeric,
  result_sigmai numeric,

  CONSTRAINT federation_results_linear_regression_pkey PRIMARY KEY (request_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE federation_results_linear_regression
  OWNER TO postgres;
GRANT ALL ON TABLE federation_results_linear_regression TO postgres;
