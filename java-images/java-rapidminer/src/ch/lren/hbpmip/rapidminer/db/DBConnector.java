package ch.lren.hbpmip.rapidminer.db;

import java.io.IOException;
import java.sql.* ;
import java.util.ArrayList;

import ch.lren.hbpmip.rapidminer.RapidMinerExperiment;
import ch.lren.hbpmip.rapidminer.ClassificationInput;

/**
 *
 * @author Arnaud Jutzeler
 *
 */
public class DBConnector {

    private static final String IN_URL = System.getenv("IN_JDBC_URL");
    private static final String IN_USER = System.getenv("IN_JDBC_USER");
    private static final String IN_PASS = System.getenv("IN_JDBC_PASSWORD");

    private static final String OUT_URL = System.getenv("OUT_JDBC_URL");
    private static final String OUT_USER = System.getenv("OUT_JDBC_USER");
    private static final String OUT_PASS = System.getenv("OUT_JDBC_PASSWORD");
    private static final String OUT_TABLE = System.getenv().getOrDefault("RESULT_TABLE", "job_result");


    public static void getData(ClassificationInput input)
            throws DBException {

        String labelName = input.getVariableName();
        String[] featuresNames = input.getFeaturesNames();

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {

            conn = DriverManager.getConnection(IN_URL, IN_USER, IN_PASS);

            stmt = conn.createStatement();
            rs = stmt.executeQuery(input.getQuery());
            ArrayList<double[]> data = new ArrayList<>();
            ArrayList<String> labels = new ArrayList<>();
            while (rs.next()) {
                labels.add(rs.getString(labelName));
                double[] features = new double[featuresNames.length];
                for(int i = 0; i < featuresNames.length; i++){
                    features[i] = rs.getDouble(featuresNames[i]);
                }
                data.add(features);
            }

            input.setData(data.toArray(new double[data.size()][]), labels.toArray(new String[labels.size()]));

        } catch (SQLException e) {
            throw new DBException(e);
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {}
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException e) {}
            }
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException e) {}
            }
        }
    }

    public static void saveResults(RapidMinerExperiment experiment)
            throws DBException {

        Connection conn = null;
        Statement stmt = null;
        try {


            conn = DriverManager.getConnection(OUT_URL, OUT_USER, OUT_PASS);

            String jobId = System.getProperty("JOB_ID", System.getenv("JOB_ID"));
            String node = System.getenv("NODE");
            //String outFormat = System.getenv("OUT_FORMAT");
            String function = System.getenv().getOrDefault("FUNCTION", "JAVA");

            String shape = "pfa_json";
            String pfa = experiment.toPFA();

            Statement st = conn.createStatement();
            st.executeUpdate("INSERT INTO " +OUT_TABLE + " (job_id, node, data, shape, function)" +
                    "VALUES ('" + jobId + "', '" + node + "', '" + pfa + "', '" + shape + "', '" + function + "')");

        } catch (SQLException | IOException e) {
            throw new DBException(e);
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {}
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException e) {}
            }
        }
    }

    public static class DBResults {

        public String node;
        public String shape;
        public String data;

        public DBResults(String node, String shape, String data) {
            this.node = node;
            this.shape = shape;
            this.data = data;
        }
    }

    public static DBResults getDBResult(String jobId) throws DBException {

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {

            String URL = System.getenv("OUT_JDBC_URL");
            String USER = System.getenv("OUT_JDBC_USER");
            String PASS = System.getenv("OUT_JDBC_PASSWORD");
            String TABLE = System.getenv().getOrDefault("RESULT_TABLE", "job_result");
            conn = DriverManager.getConnection(URL, USER, PASS);

            Statement st = conn.createStatement();
            rs = st.executeQuery("select node, data, shape from " + TABLE + " where job_id ='" + jobId + "'");

            DBResults results = null;
            while (rs.next()) {
                results = new DBResults(rs.getString("node"), rs.getString("shape"), rs.getString("data"));
            }

            return results;

        } catch (SQLException e) {
            e.printStackTrace();
            throw new DBException(e);
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {}
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException e) {}
            }
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException e) {}
            }
        }
    }
}
