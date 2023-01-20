package com.google.cloud.pso.model;

import com.google.api.services.bigquery.model.TableRow;
import org.apache.beam.sdk.coders.AvroCoder;
import org.apache.beam.sdk.coders.DefaultCoder;

import java.io.Serializable;

@DefaultCoder(AvroCoder.class)
public class FailedRecord implements Serializable  {

    private String recordContent;
    private String error;
    private String exceptionName;
    private String runId;
    private String failedComponent;

    public FailedRecord(String recordContent, String error, String exceptionName, String runId, String failedComponent) {
        this.recordContent = recordContent;
        this.error = error;
        this.exceptionName = exceptionName;
        this.runId = runId;
        this.failedComponent = failedComponent;
    }

    public String getRecordContent() {
        return recordContent;
    }

    public String getError() {
        return error;
    }

    public String getExceptionName() {
        return exceptionName;
    }

    public String getRunId() {
        return runId;
    }

    public String getFailedComponent() {
        return failedComponent;
    }

    @Override
    public String toString() {
        return "FailedRecord{" +
                "recordContent='" + recordContent + '\'' +
                ", error='" + error + '\'' +
                ", ExceptionName='" + exceptionName + '\'' +
                ", runId='" + runId + '\'' +
                ", failedComponent='" + failedComponent + '\'' +
                '}';
    }

    public TableRow toTableRow() {

        /**
         * Check this snippet for parsing all data types
         * https://github.com/apache/beam/blob/master/examples/java/src/main/java/org/apache/beam/examples/snippets/transforms/io/gcp/bigquery/BigQueryTableRowCreate.java
         */

        return new TableRow()
                // To learn more about BigQuery data types:
                // https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types
                .set("record_content", this.recordContent)
                .set("error", this.error)
                .set("exception_name", this.exceptionName)
                .set("run_id", this.runId)
                .set("failed_component", this.failedComponent);
    }
}
