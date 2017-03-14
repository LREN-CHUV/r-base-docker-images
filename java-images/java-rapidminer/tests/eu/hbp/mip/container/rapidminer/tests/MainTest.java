package eu.hbp.mip.container.rapidminer.tests;

import eu.hbp.mip.container.rapidminer.Main;
import eu.hbp.mip.container.rapidminer.db.DBException;
import org.junit.Test;
import static junit.framework.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import eu.hbp.mip.container.rapidminer.db.DBConnector;


/**
 * Quasi-end-to-end tests
 *
 * @author Arnaud Jutzeler
 *
 */
public class MainTest {

	@Test
	public void testMain() throws DBException {

		System.out.println("We can perform RPMDefault on one variable, one covariable");

		String jobId = "001";

		System.setProperty("JOB_ID", jobId);
		System.setProperty("PARAM_query", "select prov, left_amygdala, right_poparoper from brain");
		System.setProperty("PARAM_variables", "prov");
		System.setProperty("PARAM_covariables", "left_amygdala,right_poparoper");
		System.setProperty("PARAM_grouping", "");

		System.setProperty("PARAM_MODEL_method", "mode");

		String[] args = {"eu.hbp.mip.container.rapidminer.tests.models.RPMDefault"};
		Main.main(args);

		DBConnector.DBResults results = DBConnector.getDBResult(jobId);

		assertTrue(results != null);
		assertEquals("job_test", results.node);
		assertEquals("pfa_json", results.shape);
		assertTrue(!results.data.contains("error"));

		// TODO Validate PFA
		System.out.println(results.data);
	}

	@Test
	public void testMain2() throws DBException {

		System.out.println("We can perform RPMDefault on one variable, two covariables");

		String jobId = "002";

		System.setProperty("JOB_ID", jobId);
		System.setProperty("PARAM_query", "select prov, left_amygdala, right_poparoper from brain");
		System.setProperty("PARAM_variables", "prov");
		System.setProperty("PARAM_covariables", "left_amygdala,right_poparoper");
		System.setProperty("PARAM_grouping", "");

		System.setProperty("PARAM_MODEL_method", "mode");

		String[] args = {"eu.hbp.mip.container.rapidminer.tests.models.RPMDefault"};
		Main.main(args);

		DBConnector.DBResults results = DBConnector.getDBResult(jobId);

		assertTrue(results != null);
		assertEquals("job_test", results.node);
		assertEquals("pfa_json", results.shape);
		System.out.println(results.data);
		assertTrue(!results.data.contains("error"));
	}

	@Test
	public void testMain3() throws DBException {

		System.out.println("We can perform regression with one variable and two covariables");

		String jobId = "003";

		System.setProperty("JOB_ID", jobId);
		System.setProperty("PARAM_query", "select prov, left_amygdala, right_poparoper from brain");
		System.setProperty("PARAM_variables", "left_amygdala");
		System.setProperty("PARAM_covariables", "prov,right_poparoper");
		System.setProperty("PARAM_grouping", "");

		System.setProperty("PARAM_MODEL_method", "median");

		String[] args = {"eu.hbp.mip.container.rapidminer.tests.models.RPMDefault"};
		Main.main(args);

		DBConnector.DBResults results = DBConnector.getDBResult(jobId);

		assertTrue(results != null);
		assertEquals("job_test", results.node);
		assertEquals("pfa_json", results.shape);
		System.out.println(results.data);
		assertTrue(!results.data.contains("error"));
	}

	@Test
	public void testMain4() throws DBException {

		System.out.println("We cannot perform classification with invalid model");

		String jobId = "004";

		System.setProperty("JOB_ID", jobId);
		System.setProperty("PARAM_query", "select prov, left_amygdala, right_poparoper from brain");
		System.setProperty("PARAM_variables", "prov");
		System.setProperty("PARAM_covariables", "left_amygdala,right_poparoper");
		System.setProperty("PARAM_grouping", "");

		System.setProperty("PARAM_MODEL_method", "mode");

		String[] args = {"eu.hbp.mip.container.rapidminer.tests.models.sjkhdfj"};
		Main.main(args);

		DBConnector.DBResults results = DBConnector.getDBResult(jobId);

		assertTrue(results == null);
	}
}