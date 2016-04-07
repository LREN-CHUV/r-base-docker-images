package ch.lren.hbpmip.rapidminer;

import ch.lren.hbpmip.rapidminer.db.DBConnector;
import ch.lren.hbpmip.rapidminer.db.DBException;
import com.rapidminer.example.Attribute;
import com.rapidminer.example.ExampleSet;
import com.rapidminer.example.table.AttributeFactory;
import com.rapidminer.example.table.DoubleArrayDataRow;
import com.rapidminer.example.table.MemoryExampleTable;
import com.rapidminer.tools.Ontology;

import java.util.LinkedList;
import java.util.List;

/**
 * 
 * 
 * @author Arnaud Jutzeler
 *
 */
public class ClassificationInput {
	
    protected String[] featuresNames;
	protected String variableName;
	protected String query;

	protected double[][] data;
	protected String[] labels;

	protected ClassificationInput() {

	}

	public ClassificationInput(String[] featuresNames, String variableName, String query) throws DBException {
    	this.featuresNames = featuresNames;
    	this.variableName = variableName;
    	this.query = query;

		getDataFromDB();
	}

    /**
	 *
	 * Create relevant data structure to pass as input to RapidMiner
	 *
	 * @return
	 * @throws DBException
     */
	public ExampleSet createExampleSet() throws DBException {
    	
    	// Create attribute list
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
	    return table.createExampleSet(label);
	}

	private void getDataFromDB() throws DBException {
		DBConnector.getData(this);
	}

	/**
	 *
	 *
	 * @return
     */
	public static ClassificationInput fromEnv() throws DBException {
		// Read first system property then env variables
		final String labelName = System.getProperty("PARAM_variables", System.getenv("PARAM_variables"));
		final String[] featuresNames = System.getProperty("PARAM_covariables", System.getenv("PARAM_covariables")).split(",");
		final String query = System.getProperty("PARAM_query", System.getenv().getOrDefault("PARAM_query", "hbpmip/java-rapidminer:latest"));

		return new ClassificationInput(featuresNames, labelName, query);
	}

	/**
	 *
	 * @return
	 */
	public String[] getFeaturesNames() {
		return featuresNames;
	}

	/**
	 *
	 * @return
	 */
	public String getVariableName() {
		return variableName;
	}

	/**
	 *
	 * @return
	 */
	public String getQuery() {
		return query;
	}

	/**
	 *
	 * @param data
	 * @param labels
     */
	public void setData(double[][] data, String[] labels) {
		this.data = data;
		this.labels = labels;
	}
}