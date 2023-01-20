package com.google.cloud.pso.transforms;

import com.google.api.services.bigquery.model.TableRow;
import com.google.cloud.pso.model.Customer;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO;
import org.apache.beam.sdk.transforms.MapElements;
import org.apache.beam.sdk.transforms.PTransform;
import org.apache.beam.sdk.values.PBegin;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.TypeDescriptor;

// "E" in ETL
public class ExtractBatchRecordsPTransform
        extends PTransform<PBegin, PCollection<Customer>> {

    private String inputTableSpec;
    public ExtractBatchRecordsPTransform(String inputTableSpec){
        this.inputTableSpec = inputTableSpec;
    }

    @Override
    public PCollection<Customer> expand(PBegin p) {

        PCollection<TableRow> tableRowsPC = p.apply(
                "Read from BigQuery query",
                BigQueryIO.readTableRows()
                        .fromQuery(String.format("SELECT id, first_name, last_name, date_of_birth, address FROM `%s`", inputTableSpec))
                        .usingStandardSql());

        PCollection<Customer> customerPC = tableRowsPC.apply(
                "TableRows to Customer",
                MapElements.into(TypeDescriptor.of(Customer.class)).via(Customer::fromTableRow));

        return customerPC;
    }
}

