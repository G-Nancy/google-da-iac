package com.google.cloud.pso.transforms;

import com.google.api.services.bigquery.model.TableRow;
import com.google.cloud.pso.model.FailedRecord;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO;
import org.apache.beam.sdk.transforms.MapElements;
import org.apache.beam.sdk.transforms.PTransform;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.PDone;
import org.apache.beam.sdk.values.TypeDescriptor;

// "L" in ETL
public class LoadFailedRecordsPTransform
        extends PTransform<PCollection<FailedRecord>, PDone> {


    private String targetTableSpec;
    public LoadFailedRecordsPTransform(String targetTableSpec){
        this.targetTableSpec = targetTableSpec;
    }

    @Override
    public PDone expand(PCollection<FailedRecord> records) {

        records
                // convert the Java object to TableRow
                .apply(MapElements.into(TypeDescriptor.of(TableRow.class)).via(FailedRecord::toTableRow))
                // insert the TableRow to BigQuery
                .apply(
                        "Write to BigQuery",
                        BigQueryIO.writeTableRows()
                                .to(targetTableSpec)
                                .withCreateDisposition(BigQueryIO.Write.CreateDisposition.CREATE_NEVER)
                                .withWriteDisposition(BigQueryIO.Write.WriteDisposition.WRITE_APPEND));

        return PDone.in(records.getPipeline());
    }
}
