package ch.lren.hbpmip.rapidminer.tests;

import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

import ch.lren.hbpmip.rapidminer.RapidMinerExperiment;
import ch.lren.hbpmip.rapidminer.exceptions.InvalidDataException;
import ch.lren.hbpmip.rapidminer.models.RapidMinerModel;
import com.rapidminer.example.Attribute;
import com.rapidminer.example.table.*;
import com.rapidminer.tools.Ontology;

import ch.lren.hbpmip.rapidminer.exceptions.InvalidModelException;
import ch.lren.hbpmip.rapidminer.tests.models.RPMDefault;

import ch.lren.hbpmip.rapidminer.exceptions.RapidMinerException;
import ch.lren.hbpmip.rapidminer.InputData;

import org.junit.Test;
import static org.junit.Assert.assertTrue;

/**
 * Tests for RapidMinerExperiment
 *
 * @author Arnaud Jutzeler
 *
 */
public class RapidMinerExperimentTest {

	protected class ClassificationInputTest extends InputData {

		public ClassificationInputTest(String[] featuresNames, String variableName, double[][] data, String[] labels) {
			super();
			this.featuresNames = featuresNames;
			this.variableName = variableName;

			List<Attribute> attributes = new LinkedList<>();
			for (int a = 0; a < featuresNames.length; a++) {
				attributes.add(AttributeFactory.createAttribute(featuresNames[a], Ontology.REAL));
			}

			// Create label
			Attribute label = AttributeFactory.createAttribute(variableName, Ontology.NOMINAL);
			attributes.add(label);

			// Create table
			MemoryExampleTable table = new MemoryExampleTable(attributes);

			// Fill the table
			for (int d = 0; d < data.length; d++) {
				double[] tableData = new double[attributes.size()];
				for (int a = 0; a < data[d].length; a++) {
					tableData[a] = data[d][a];
				}

				// Maps the nominal classification to a double value
				tableData[data[d].length] = label.getMapping().mapString(labels[d]);

				// Add data row
				table.addDataRow(new DoubleArrayDataRow(tableData));
			}

			// Create example set
			this.data = table.createExampleSet(label);
		}
	}

	protected class RegressionInputTest extends InputData {

		public RegressionInputTest(String[] featuresNames, String variableName, double[][] data, double[] labels) {
			super();
			this.featuresNames = featuresNames;
			this.variableName = variableName;

			List<Attribute> attributes = new LinkedList<>();
			for (int a = 0; a < featuresNames.length; a++) {
				attributes.add(AttributeFactory.createAttribute(featuresNames[a], Ontology.REAL));
			}

			// Create label
			Attribute label = AttributeFactory.createAttribute(variableName, Ontology.REAL);
			attributes.add(label);

			// Create table
			MemoryExampleTable table = new MemoryExampleTable(attributes);

			// Fill the table
			for (int d = 0; d < data.length; d++) {
				double[] tableData = new double[attributes.size()];
				for (int a = 0; a < data[d].length; a++) {
					tableData[a] = data[d][a];
				}

				tableData[data[d].length] = labels[d];

				// Add data row
				table.addDataRow(new DoubleArrayDataRow(tableData));
			}

			// Create example set
			this.data = table.createExampleSet(label);
		}
	}

	@Test
	public void test_classification() throws IOException, InvalidDataException, InvalidModelException, RapidMinerException {

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
		RapidMinerModel model = new RPMDefault("mode");

		// Run experiment
		RapidMinerExperiment experiment = new RapidMinerExperiment(input, model);
		experiment.run();

		System.out.println(experiment.toRMP());
		System.out.println(experiment.toPFA());
		assertTrue(!experiment.toPFA().contains("error"));
	}

	@Test
	public void test_regression() throws IOException, InvalidDataException, InvalidModelException, RapidMinerException {

		String[] featureNames = new String[]{"input1", "input2"};
		String variableName = "output";
		double[][] data =  new double[][] {
				{1.2, 2.4},
				{6.7, 8.9},
				{4.6, 23.4},
				{7.6, 5.4},
				{1.2, 1.6},
				{3.4, 4.7},
				{3.4, 6.5}
		};
		double[] labels = new double[]{2.4, 4.5, 5.7, 4.5, 23.7, 8.7, 9.2};

		// Get experiment input
		RegressionInputTest input = new RegressionInputTest(featureNames, variableName, data, labels);
		RapidMinerModel model = new RPMDefault("median");

		// Run experiment
		RapidMinerExperiment experiment = new RapidMinerExperiment(input, model);
		experiment.run();

		System.out.println(experiment.toRMP());
		System.out.println(experiment.toPFA());
		assertTrue(!experiment.toPFA().contains("error"));
	}
}