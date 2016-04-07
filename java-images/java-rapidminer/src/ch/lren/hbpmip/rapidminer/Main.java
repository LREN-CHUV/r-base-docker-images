package ch.lren.hbpmip.rapidminer;

import java.io.IOException;

import ch.lren.hbpmip.rapidminer.db.DBConnector;
import ch.lren.hbpmip.rapidminer.db.DBException;
import ch.lren.hbpmip.rapidminer.models.RapidMinerModel;


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

			// Get experiment input
			ClassificationInput input = ClassificationInput.fromEnv();

			// Run experiment
			RapidMinerExperiment experiment = new RapidMinerExperiment(input, model);
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