package ch.lren.hbpmip.rapidminer.models;

import com.rapidminer.operator.learner.AbstractLearner;
import com.rapidminer.operator.learner.PredictionModel;

import java.util.Map;

/**
 *
 * Wrapper around RapidMiner Learner and corresponding classifier Model
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

    public abstract String toRep();

    public abstract String toAction();

    public Class<? extends AbstractLearner> getLearnerClass() {
        return learnerClass;
    }
}
