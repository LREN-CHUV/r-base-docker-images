package eu.hbp.mip.container.rapidminer.models;

import java.io.IOException;
import java.util.Map;

import eu.hbp.mip.container.rapidminer.InputData;
import com.fasterxml.jackson.core.JsonGenerator;

import com.rapidminer.example.ExampleSet;
import com.rapidminer.operator.IOContainer;
import com.rapidminer.operator.Operator;
import com.rapidminer.operator.OperatorCreationException;
import com.rapidminer.operator.OperatorException;
import com.rapidminer.operator.learner.AbstractLearner;
import com.rapidminer.operator.learner.PredictionModel;
import com.rapidminer.tools.OperatorService;
import com.rapidminer.Process;


/**
 *
 * Wrapper around RapidMiner Learner and corresponding Model
 * This is the only models dependent to be subclassed when integrating new RapidMiner algorithms
 *
 * @author Arnaud Jutzeler
 *
 */
public abstract class RapidMinerModel<M extends PredictionModel> {

    private Class<? extends AbstractLearner> learnerClass;

    // Remark: This should be private, but we need the IOObject
    // to build the PFA representation for some models as they all have private fields...
    protected Process process;

    protected M trainedModel;

    public RapidMinerModel(Class<? extends AbstractLearner> learnerClass) {
        this.learnerClass = learnerClass;
    }

    @SuppressWarnings("unchecked")
    public void train(InputData trainingData) throws OperatorCreationException, OperatorException {

        // Create the RapidMiner process
        process = new Process();

        // Model training
        Operator modelOp = OperatorService.createOperator(this.learnerClass);
        Map<String, String> parameters = getParameters();
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
        ExampleSet exampleSet = trainingData.getData();
        IOContainer ioResult = process.run(new IOContainer(exampleSet, exampleSet, exampleSet));

        trainedModel = (M) ioResult.get(PredictionModel.class, 0);
    }

    protected abstract Map<String,String> getParameters();

    public void writeRepresentation(JsonGenerator jgen) throws IOException {
        if (trainedModel != null) {
            writeModelRepresentation(jgen);
        }
    }

    public String toRMP() {
        return process.getRootOperator().getXML(false);
    }

    /**
     *
     * Give jgen in cells context to be able to write representation
     * and then the action
     *
     * @param jgen
     * @throws IOException
     */
    protected abstract void writeModelRepresentation(JsonGenerator jgen) throws IOException;

    public boolean isAlreadyTrained() {
        return trainedModel != null;
    }
}
