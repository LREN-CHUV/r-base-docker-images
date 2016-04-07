package ch.lren.hbpmip.rapidminer;

import java.io.IOException;
import java.util.Map;

import com.rapidminer.operator.*;
import com.rapidminer.operator.performance.*;
import org.codehaus.jackson.Version;
import org.codehaus.jackson.map.module.SimpleModule;

import com.rapidminer.Process;
import com.rapidminer.RapidMiner;
import com.rapidminer.example.ExampleSet;
import com.rapidminer.operator.learner.PredictionModel;
import com.rapidminer.operator.validation.XValidation;
import com.rapidminer.tools.OperatorService;

import ch.lren.hbpmip.rapidminer.db.DBException;
import ch.lren.hbpmip.rapidminer.exceptions.RapidMinerException;
import ch.lren.hbpmip.rapidminer.models.RapidMinerModel;
import ch.lren.hbpmip.rapidminer.serializers.pfa.MultiClassificationPerformanceSerializer;
import ch.lren.hbpmip.rapidminer.serializers.pfa.RapidMinerExperimentSerializer;


/**
 *
 * Default experiment consisting of training and validating a specific models
 * The models is:
 * 1) Trained using all the data
 * 2) Validated using k1-fold random cross-validation
 * 3) Validated using k2-fold random cross-validation
 *
 * @author Arnaud Jutzeler
 */
public class RapidMinerExperiment {

    public final String name = "rapidminer";
    public final String doc = "RapidMiner Classification Model\n";
    public final String docker_image = System.getProperty("DOCKER_IMAGE", System.getenv().getOrDefault("DOCKER_IMAGE", "hbpmip/java-rapidminer:latest"));

    private static boolean isRPMInit = false;

    private ClassificationInput input;
    private RapidMinerModel classifier;
    private int[] ks;

    private Process process;

    private MultiClassificationPerformance[] validationResults;
    public Exception exception;

    /**
     *
     * @param input
     * @param classifier
     * @param ks
     */
    public RapidMinerExperiment(ClassificationInput input, RapidMinerModel classifier, int[] ks) {
        this.input = input;
        this.classifier = classifier;
        this.ks = ks;
    }

    /**
     *
     * @param input
     * @param classifier
     */
    public RapidMinerExperiment(ClassificationInput input, RapidMinerModel classifier) {
        this(input, classifier, new int[]{2, 10});
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

        if(validationResults != null || exception != null) {
            System.out.println("This experiment was already run!");
            return;
        }

        try {

            // Create the RapidMiner process
            process = new Process();

            // Classifier
            Operator classifierOp = OperatorService.createOperator(classifier.getLearnerClass());
            Map<String, String> parameters = classifier.getParameters();
            for (Map.Entry<String, String> entry : parameters.entrySet()) {
                classifierOp.setParameter(entry.getKey(), entry.getValue());
            }
            process.getRootOperator().getSubprocess(0).addOperator(classifierOp);
            process.getRootOperator()
                    .getSubprocess(0)
                    .getInnerSources()
                    .getPortByIndex(0)
                    .connectTo(classifierOp.getInputPorts().getPortByName("training set"));
            classifierOp.getOutputPorts().getPortByName("model").connectTo(process.getRootOperator()
                    .getSubprocess(0)
                    .getInnerSinks()
                    .getPortByIndex(0));

            // k-fold cross-validations
            for(int i = 0; i < ks.length; i++) {
                XValidation validationOp = OperatorService.createOperator(XValidation.class);
                validationOp.setParameter("PARAMETER_AVERAGE_PERFORMANCES_ONLY", "true");
                validationOp.setParameter("PARAMETER_LEAVE_ONE_OUT", "false");
                validationOp.setParameter("PARAMETER_NUMBER_OF_VALIDATIONS", Integer.toString(ks[i]));
                validationOp.setParameter("PARAMETER_SAMPLING_TYPE", "shuffled");

                // Training subprocess
                classifierOp = OperatorService.createOperator(classifier.getLearnerClass());
                for (Map.Entry<String, String> entry : parameters.entrySet()) {
                    classifierOp.setParameter(entry.getKey(), entry.getValue());
                }
                validationOp.getSubprocess(0).addOperator(classifierOp);

                connect(validationOp.getSubprocess(0), "training", classifierOp,
                        "training set");
                connect(classifierOp, "model", validationOp.getSubprocess(0),
                        "model");

                // Testing subprocess
                Operator modelApplier = OperatorService
                        .createOperator(ModelApplier.class);
                Operator performance = OperatorService
                        .createOperator(SimplePerformanceEvaluator.class);

                validationOp.getSubprocess(1).addOperator(modelApplier);
                validationOp.getSubprocess(1).addOperator(performance);

                connect(validationOp.getSubprocess(1), "model", modelApplier, "model");
                connect(validationOp.getSubprocess(1), "test set", modelApplier,
                        "unlabelled data");
                connect(modelApplier, "labelled data", performance, "labelled data");
                connect(performance, "performance", validationOp.getSubprocess(1),
                        "averagable 1");

                process.getRootOperator().getSubprocess(0).addOperator(validationOp);
                process.getRootOperator()
                        .getSubprocess(0)
                        .getInnerSources()
                        .getPortByIndex(i + 1)
                        .connectTo(validationOp.getInputPorts().getPortByName("training"));
                validationOp.getOutputPorts().getPortByName("averagable 1").connectTo(process.getRootOperator()
                        .getSubprocess(0)
                        .getInnerSinks()
                        .getPortByIndex(i + 1));
            }

            // Run process
            ExampleSet exampleSet = input.createExampleSet();
            IOContainer ioResult = process.run(new IOContainer(exampleSet, exampleSet, exampleSet));

            PredictionModel trainedModel = ioResult.get(PredictionModel.class, 0);
            classifier.setTrainedModel(trainedModel);

            validationResults = new MultiClassificationPerformance[ks.length];
            for(int i = 0; i < ks.length; i++) {
                validationResults[i] = (MultiClassificationPerformance) ioResult.get(PerformanceVector.class, i).getMainCriterion();
            }

        } catch (OperatorCreationException | OperatorException | ClassCastException ex) {
            this.exception = new RapidMinerException(ex);
        } catch (DBException ex) {
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
        org.codehaus.jackson.map.ObjectMapper myObjectMapper = new org.codehaus.jackson.map.ObjectMapper();
        SimpleModule module = new SimpleModule("RapidMiner", new Version(1, 0, 0, null));
        module.addSerializer(RapidMinerExperiment.class, new RapidMinerExperimentSerializer());
        module.addSerializer(MultiClassificationPerformance.class, new MultiClassificationPerformanceSerializer());
        myObjectMapper.registerModule(module);
        return myObjectMapper.writeValueAsString(this);
    }

    /**
     *
     * @return
     */
    public ClassificationInput getInput() {
        return input;
    }

    /**
     *
     * @return
     */
    public RapidMinerModel getClassifier() {
        return classifier;
    }

    /**
     *
     * @return
     */
    public MultiClassificationPerformance[] getValidationResults() {
        return validationResults;
    }
}