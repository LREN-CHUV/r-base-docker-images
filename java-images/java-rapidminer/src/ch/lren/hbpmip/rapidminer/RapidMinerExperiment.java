package ch.lren.hbpmip.rapidminer;

import java.io.IOException;
import java.util.Map;

import com.fasterxml.jackson.core.Version;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.module.SimpleModule;

import com.rapidminer.Process;
import com.rapidminer.RapidMiner;
import com.rapidminer.example.ExampleSet;
import com.rapidminer.operator.learner.PredictionModel;
import com.rapidminer.tools.OperatorService;
import com.rapidminer.operator.*;

import ch.lren.hbpmip.rapidminer.db.DBException;
import ch.lren.hbpmip.rapidminer.exceptions.RapidMinerException;
import ch.lren.hbpmip.rapidminer.models.RapidMinerModel;
import ch.lren.hbpmip.rapidminer.serializers.pfa.RapidMinerExperimentSerializer;


/**
 *
 * Default experiment consisting of training and validating a specific models
 * The models is:
 * 1) Trained using all the data
 *
 * @author Arnaud Jutzeler
 */
public class RapidMinerExperiment {

    public final String name = "rapidminer";
    public final String doc = "RapidMiner Model\n";
    public final String docker_image = System.getProperty("DOCKER_IMAGE", System.getenv().getOrDefault("DOCKER_IMAGE", "hbpmip/java-rapidminer:latest"));

    private static boolean isRPMInit = false;

    private InputData input;
    private RapidMinerModel model;

    private Process process;

    public Exception exception;

    public RapidMinerExperiment(RapidMinerModel model) {
        this(null, model);
    }

    /**
     *
     * @param input
     * @param model
     */
    public RapidMinerExperiment(InputData input, RapidMinerModel model) {
        this.input = input;
        this.model = model;
    }

    /**
     * Connect the output-port <code>fromPortName</code> from Operator
     * <code>from</code> with the input-port <code>toPortName</code> of Operator
     * <code>to</code>.
     */
    private static void connect(Operator from, String fromPortName,
                                Operator to, String toPortName) {
        from.getOutputPorts().getPortByName(fromPortName).connectTo(
                to.getInputPorts().getPortByName(toPortName));
    }

    /**
     * Connect the output-port <code>fromPortName</code> from Subprocess
     * <code>from</code> with the input-port <code>toPortName</code> of Operator
     * <code>to</code>.
     */
    private static void connect(ExecutionUnit from, String fromPortName,
                                Operator to, String toPortName) {
        from.getInnerSources().getPortByName(fromPortName).connectTo(
                to.getInputPorts().getPortByName(toPortName));
    }

    /**
     * Connect the output-port <code>fromPortName</code> from Operator
     * <code>from</code> with the input-port <code>toPortName</code> of
     * Subprocess <code>to</code>.
     */
    private static void connect(Operator from, String fromPortName,
                                ExecutionUnit to, String toPortName) {
        from.getOutputPorts().getPortByName(fromPortName).connectTo(
                to.getInnerSinks().getPortByName(toPortName));
    }

    /**
     *
     * @throws RapidMinerException
     */
    public void run() {

        if(!isRPMInit) {
            initializeRPM();
        }

        if(model.isFitted() || exception != null) {
            System.out.println("This experiment was already run!");
            return;
        }

        try {

            if(input == null) {
                input = InputData.fromEnv();
            }

            // Create the RapidMiner process
            process = new Process();

            // Model training
            Operator modelOp = OperatorService.createOperator(model.getLearnerClass());
            Map<String, String> parameters = model.getParameters();
            for (Map.Entry<String, String> entry : parameters.entrySet()) {
                modelOp.setParameter(entry.getKey(), entry.getValue());
            }
            process.getRootOperator().getSubprocess(0).addOperator(modelOp);
            process.getRootOperator()
                    .getSubprocess(0)
                    .getInnerSources()
                    .getPortByIndex(0)
                    .connectTo(modelOp.getInputPorts().getPortByName("training set"));
            modelOp.getOutputPorts().getPortByName("model").connectTo(process.getRootOperator()
                    .getSubprocess(0)
                    .getInnerSinks()
                    .getPortByIndex(0));

            // Run process
            ExampleSet exampleSet = input.getData();
            IOContainer ioResult = process.run(new IOContainer(exampleSet, exampleSet, exampleSet));

            PredictionModel trainedModel = ioResult.get(PredictionModel.class, 0);
            model.setTrainedModel(trainedModel);

        } catch (OperatorCreationException | OperatorException | ClassCastException ex) {
            this.exception = new RapidMinerException(ex);
        } catch (DBException ex) {
            this.exception = ex;
        } catch (RapidMinerException ex) {
            this.exception = ex;
        }
    }

    /**
     * Initialize RapidMiner
     * Must be run only once
     */
    private static void initializeRPM() {
        // Init RapidMiner
        System.setProperty("rapidminer.home", System.getProperty("user.dir"));

        RapidMiner.setExecutionMode(RapidMiner.ExecutionMode.COMMAND_LINE);
        RapidMiner.init();
        isRPMInit= true;
    }

    /**
     *
     * Generate the RMP representation of the experiment
     * which is the native xml format used by RapidMiner
     *
     * @return the native xml representation of the RapidMiner process
     */
    public String toRMP() {
        return process.getRootOperator().getXML(false);
    }

    /**
     * Generate the PFA representation of the experiment outcome
     *
     * @return
     * @throws IOException
     */
    public String toPFA() throws IOException {
        ObjectMapper myObjectMapper = new ObjectMapper();
        SimpleModule module = new SimpleModule("RapidMiner", new Version(1, 0, 0, null, null, null));
        module.addSerializer(RapidMinerExperiment.class, new RapidMinerExperimentSerializer());
        myObjectMapper.registerModule(module);
        return myObjectMapper.writeValueAsString(this);
    }

    /**
     *
     * @return
     */
    public InputData getInput() {
        return input;
    }

    /**
     *
     * @return
     */
    public RapidMinerModel getModel() {
        return model;
    }
}