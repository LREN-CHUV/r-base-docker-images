package eu.hbp.mip.container.rapidminer;

import java.io.IOException;

import eu.hbp.mip.container.rapidminer.db.DBConnector;
import eu.hbp.mip.container.rapidminer.db.DBException;
import eu.hbp.mip.container.rapidminer.models.RapidMinerModel;


/**
 *
 * Entrypoint
 *
 * @author Arnaud Jutzeler
 *
 */
public class Main {

	public static void main(String[] args) {

		try {
			Class modelClass = Class.forName(args[0]);
			RapidMinerModel model = (RapidMinerModel) modelClass.newInstance();

			// Run experiment
			RapidMinerExperiment experiment = new RapidMinerExperiment(model);
			experiment.run();

			// Write results PFA in DB
			String pfa = experiment.toPFA();
			DBConnector.saveResults(experiment);

		} catch (ClassNotFoundException | InstantiationException | IllegalAccessException |
				IOException | DBException | ClassCastException e) {
			e.printStackTrace();
		}
	}
}