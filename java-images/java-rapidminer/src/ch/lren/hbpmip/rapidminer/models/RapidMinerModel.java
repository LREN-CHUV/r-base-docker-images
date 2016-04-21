package ch.lren.hbpmip.rapidminer.models;

import java.io.IOException;
import java.util.Map;

import com.fasterxml.jackson.core.JsonGenerator;

import com.rapidminer.operator.learner.AbstractLearner;


/**
 *
 * Wrapper around RapidMiner Learner and corresponding Model
 * This is the only models dependent to be subclassed when integrating new RapidMiner algorithms
 *
 * @author Arnaud Jutzeler
 *
 */
public abstract class RapidMinerModel<M> {

    private Class<? extends AbstractLearner> learnerClass;
    protected M trainedModel;

    public RapidMinerModel(Class<? extends AbstractLearner> learnerClass) {
        this.learnerClass = learnerClass;
    }

    public void setTrainedModel(M trainedModel) {
        this.trainedModel = trainedModel;
    }

    public abstract Map<String,String> getParameters();

    public void writeRepresentation(JsonGenerator jgen) throws IOException {
        if (trainedModel != null) {
            writeModelRepresentation(jgen);
        }
    }

    protected abstract void writeModelRepresentation(JsonGenerator jgen) throws IOException;

    public abstract void writeAction(JsonGenerator jgen) throws IOException;

    public Class<? extends AbstractLearner> getLearnerClass() {
        return learnerClass;
    }

    public boolean isFitted() {
        return trainedModel != null;
    }
}
