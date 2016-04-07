package ch.lren.hbpmip.rapidminer.serializers.pfa;

import java.io.IOException;

import com.fasterxml.jackson.core.JsonProcessingException;
import org.codehaus.jackson.JsonGenerator;
import org.codehaus.jackson.map.JsonSerializer;
import org.codehaus.jackson.map.SerializerProvider;

import com.rapidminer.operator.performance.MultiClassificationPerformance;

/**
 *
 * @author Arnaud Jutzeler
 */
public class MultiClassificationPerformanceSerializer extends JsonSerializer<MultiClassificationPerformance> {

    @Override
    public void serialize(MultiClassificationPerformance value, JsonGenerator jgen, SerializerProvider provider)
            throws IOException, JsonProcessingException {

        jgen.writeStartObject();

        // Accuracy
        jgen.writeNumberField("accuracy", value.getMikroAverage());

        // Confusion matrix
        double[][] matrix = value.getCounter();
        jgen.writeArrayFieldStart("confusion_matrix");
        for(int i = 0; i < matrix.length; i++) {
            jgen.writeStartArray();
            for(int j = 0; j < matrix[i].length; j++) {
               jgen.writeNumber(matrix[i][j]);
            }
            jgen.writeEndArray();
        }
        jgen.writeEndArray();

        jgen.writeEndObject();
    }
}
