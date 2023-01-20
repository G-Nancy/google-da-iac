package com.google.cloud.pso.transforms;

import com.google.cloud.pso.functions.ParseCustomerFromJsonDoFn;
import com.google.cloud.pso.model.Customer;
import com.google.cloud.pso.model.FailedRecord;
import org.apache.beam.sdk.io.gcp.pubsub.PubsubIO;
import org.apache.beam.sdk.transforms.PTransform;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.values.*;

// "E" in ETL
public class ExtractStreamedRecordsPTransform
        extends PTransform<PBegin, PCollectionTuple> {

    private String inputSubscription;

    private String runId;

    public static final TupleTag<Customer> successOutput =
            new TupleTag<Customer>(){};

    // Error output with each customer and the exception that happened
    public static final TupleTag<FailedRecord> errorOutput =
            new TupleTag<FailedRecord>(){};
    public ExtractStreamedRecordsPTransform(String inputSubscription,
                                            String runId
                                          ){
        this.inputSubscription = inputSubscription;
        this.runId = runId;
    }

    @Override
    public PCollectionTuple expand(PBegin p) {

        PCollection<String> jsonStrings = p.apply(
                "Read from PubSub",
                PubsubIO.readStrings().fromSubscription(this.inputSubscription)
        );

        return jsonStrings.apply(
                "Parse JSON to Customer",
                ParDo.of(
                        new ParseCustomerFromJsonDoFn(
                                runId,
                                successOutput,
                                errorOutput)
                ).withOutputTags(successOutput,
                        TupleTagList.of(errorOutput)
                )
        );
    }
}

