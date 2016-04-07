package ch.lren.hbpmip.rapidminer.tests;

import java.io.IOException;

import ch.lren.hbpmip.rapidminer.RapidMinerExperiment;
import ch.lren.hbpmip.rapidminer.exceptions.InvalidDataException;
import ch.lren.hbpmip.rapidminer.models.RapidMinerModel;
import org.junit.Test;

import ch.lren.hbpmip.rapidminer.exceptions.InvalidModelException;
import ch.lren.hbpmip.rapidminer.tests.models.RPMDefault;

import ch.lren.hbpmip.rapidminer.exceptions.RapidMinerException;
import ch.lren.hbpmip.rapidminer.ClassificationInput;

/**
 * Tests for RapidMinerExperiment
 * 
 * @author Arnaud Jutzeler
 *
 */
public class RapidMinerExperimentTest {

	protected class ClassificationInputTest extends ClassificationInput {

		public ClassificationInputTest(String[] featuresNames, String variableName, double[][] data, String[] labels) {
			super();
			this.featuresNames = featuresNames;
			this.variableName = variableName;
			this.data = data;
			this.labels = labels;
		}
	}

	@Test
	public void test() throws IOException, InvalidDataException, InvalidModelException, RapidMinerException {

		String[] featureNames = new String[]{"input1", "input2"};
		String variableName = "output";
		double[][] data =  new double[][] {
			{1.2, 2.4},
			{6.7, 8.9},
			{4.6, 23.4},
			{7.6, 5.4},
			{1.2, 1.6},
			{3.4, 4.7},
			{3.4, 6.5}};
		String[] labels = new String[]{"YES", "NO", "YES", "NO", "YES", "NO", "NO"};

		// Get experiment input
		ClassificationInputTest input = new ClassificationInputTest(featureNames, variableName, data, labels);
		RapidMinerModel model = new RPMDefault();

		// Run experiment
		RapidMinerExperiment experiment = new RapidMinerExperiment(input, model);
		experiment.run();

		System.out.println(experiment.toRMP());
		System.out.println(experiment.toPFA());
		//TODO Add assertion...
	}
}