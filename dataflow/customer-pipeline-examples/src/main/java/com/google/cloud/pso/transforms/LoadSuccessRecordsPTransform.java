package com.google.cloud.pso.transforms;

import com.google.api.services.bigquery.model.TableRow;
import com.google.cloud.pso.model.CustomerWithScore;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO;
import org.apache.beam.sdk.transforms.MapElements;
import org.apache.beam.sdk.transforms.PTransform;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.PDone;
import org.apache.beam.sdk.values.TypeDescriptor;

// "L" in ETL
public class LoadSuccessRecordsPTransform
        extends PTransform<PCollection<CustomerWithScore>, PDone> {


    private String targetTableSpec;
    public LoadSuccessRecordsPTransform(String targetTableSpec){
        this.targetTableSpec = targetTableSpec;
    }

    @Override
    public PDone expand(PCollection<CustomerWithScore> customersWithScore) {

        customersWithScore
                // convert the Java object to TableRow
                .apply(MapElements.into(TypeDescriptor.of(TableRow.class)).via(CustomerWithScore::toTableRow))
                // insert the TableRow to BigQuery
                .apply(
                        "Write to BigQuery",
                        BigQueryIO.writeTableRows()
                                .to(targetTableSpec)
                                .withCreateDisposition(BigQueryIO.Write.CreateDisposition.CREATE_NEVER)
                                .withWriteDisposition(BigQueryIO.Write.WriteDisposition.WRITE_APPEND));

        return PDone.in(customersWithScore.getPipeline());
    }
}
