package com.google.cloud.pso.transforms;

import com.google.cloud.pso.functions.CalculateCustomerScoreHttpDoFn;
import com.google.cloud.pso.functions.UpperCaseLastNameSimpleFunction;
import com.google.cloud.pso.functions.ValidateCustomerDoFn;
import com.google.cloud.pso.model.Customer;
import com.google.cloud.pso.model.FailedRecord;
import com.google.cloud.pso.model.CustomerWithScore;
import org.apache.beam.sdk.transforms.MapElements;
import org.apache.beam.sdk.transforms.PTransform;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.PCollectionTuple;
import org.apache.beam.sdk.values.TupleTag;
import org.apache.beam.sdk.values.TupleTagList;

// "T" in ETL

/**
 * Encapsulate all transformation logic on the parsed input
 * and return a PCollectionTuple consisting of two tags, one for
 * successfully processed records and one for failed records
 */
public class TransformRecordsPTransform
        extends PTransform<PCollection<Customer>, PCollectionTuple> {

    private String customerScoringServiceUrl;

    private String runId;

    public static final TupleTag<CustomerWithScore> successOutput =
            new TupleTag<CustomerWithScore>(){};

    // Error output with each customer and the exception that happened
    public static final TupleTag<FailedRecord> errorOutput =
            new TupleTag<FailedRecord>(){};

    public TransformRecordsPTransform(String customerScoringServiceUrl, String runId){
        this.customerScoringServiceUrl = customerScoringServiceUrl;
        this.runId = runId;
    }

    @Override
    public PCollectionTuple expand(PCollection<Customer> customers) {

        // 1. Validate and filter out invalid customers
        // 2. Convert LastName to Upper Case
        PCollection<Customer> processedCustomers = customers.apply(ParDo.of(new ValidateCustomerDoFn()))
                .apply(MapElements.via(new UpperCaseLastNameSimpleFunction()));

        //PCollection<CustomerWithScore> customersWithScores = processedCustomers.apply(ParDo.of(new CalculateCustomerScoreDoFn()));

        // Call the customer scoring service via a DoFn and return two streams of data, success and error records
        return processedCustomers.apply(
                ParDo.of(
                        new CalculateCustomerScoreHttpDoFn(
                                customerScoringServiceUrl,
                                runId,
                                successOutput,
                                errorOutput)
                ).withOutputTags(successOutput,
                        TupleTagList.of(errorOutput)
                )
        );

        // how to reference one tagged output from the PCollectionTuple
        //PCollection<CustomerWithScore> customersWithScores = customersWithScoresTuple.get(successOutput);
    }



}


