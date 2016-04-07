package ch.lren.hbpmip.rapidminer.tests.models;

import ch.lren.hbpmip.rapidminer.models.RapidMinerModel;
import com.rapidminer.operator.learner.lazy.DefaultLearner;
import com.rapidminer.operator.learner.lazy.DefaultModel;
import org.apache.commons.collections15.map.LinkedMap;

import java.util.Map;

/**
 *
 * Trivial RapidMiner model 'DefautModel'
 *
 * @author Arnaud Jutzeler
 *
 */
public class RPMDefault extends RapidMinerModel<DefaultModel> {

    public RPMDefault() {
        super(DefaultLearner.class);
    }

    @Override
    public Map<String, String> getParameters() {
        LinkedMap map = new LinkedMap<String, String>();
        map.put("method", "mode");
        return map;
    }

    @Override
    public String toRep() {
       // return "" + label.getMapping().mapIndex((int) model.getValue());
        return "" + trainedModel.getValue();
    }

    @Override
    public String toAction() {
        return null;
    }
}
