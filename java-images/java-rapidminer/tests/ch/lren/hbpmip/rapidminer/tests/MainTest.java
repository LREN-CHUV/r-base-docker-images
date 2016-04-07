package ch.lren.hbpmip.rapidminer.tests;

import org.junit.Test;
import static junit.framework.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import ch.lren.hbpmip.rapidminer.Main;
import ch.lren.hbpmip.rapidminer.db.DBConnector;
import ch.lren.hbpmip.rapidminer.db.DBException;


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

		String[] args = {"ch.lren.hbpmip.rapidminer.tests.models.RPMDefault"};
		Main.main(args);

		DBConnector.DBResults results = DBConnector.getDBResult(jobId);

		assertTrue(results != null);
		assertEquals("job_test", results.node);
		assertEquals("pfa_json", results.shape);
		System.out.println(results.data);
		assertTrue(results.data.contains("validation") && !results.data.contains("error"));
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

		String[] args = {"ch.lren.hbpmip.rapidminer.tests.models.RPMDefault"};
		Main.main(args);

		DBConnector.DBResults results = DBConnector.getDBResult(jobId);

		assertTrue(results != null);
		assertEquals("job_test", results.node);
		assertEquals("pfa_json", results.shape);
		System.out.println(results.data);
		assertTrue(results.data.contains("validation") && !results.data.contains("error"));
	}

	@Test
	public void testMain3() throws DBException {

		System.out.println("We cannot perform classification with invalid model");

		String jobId = "003";

		System.setProperty("JOB_ID", jobId);
		System.setProperty("PARAM_query", "select prov, left_amygdala, right_poparoper from brain");
		System.setProperty("PARAM_variables", "prov");
		System.setProperty("PARAM_covariables", "left_amygdala,right_poparoper");
		System.setProperty("PARAM_grouping", "");

		String[] args = {"ch.chuv.hbp.rapidminer.tests.models.sjkhdfj"};
		Main.main(args);

		DBConnector.DBResults results = DBConnector.getDBResult(jobId);

		assertTrue(results == null);
	}
}