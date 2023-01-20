package com.google.cloud.pso.functions;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.google.api.client.http.HttpStatusCodes;
import com.google.cloud.pso.model.Customer;
import com.google.cloud.pso.model.CustomerWithScore;
import com.google.cloud.pso.model.FailedRecord;
import org.apache.beam.repackaged.core.org.apache.commons.lang3.exception.ExceptionUtils;
import org.apache.beam.sdk.metrics.Counter;
import org.apache.beam.sdk.metrics.Metrics;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.values.TupleTag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class ParseCustomerFromJsonDoFn extends DoFn<String, Customer> {

    /**
     * https://beam.apache.org/releases/javadoc/2.43.0/org/apache/beam/sdk/transforms/ParDo.html
     */

    private final static Logger LOG = LoggerFactory.getLogger(ParseCustomerFromJsonDoFn.class);
    private final Counter okCount = Metrics.counter(ParseCustomerFromJsonDoFn.class, "parseJsonCustomerOk");
    private final Counter notOkCount = Metrics.counter(ParseCustomerFromJsonDoFn.class, "parseJsonCustomerNotOk");

    private final String runId;

    // Output customers that are processed successfully by the service
    public final TupleTag<Customer> successOutput;

    // Error output with each customer and the exception that happened
    public final TupleTag<FailedRecord> errorOutput;

    public ParseCustomerFromJsonDoFn(
            String runId,
            TupleTag<Customer> successOutput,
            TupleTag<FailedRecord> errorOutput
    ) {
        this.runId = runId;
        this.successOutput = successOutput;
        this.errorOutput = errorOutput;
    }

    @ProcessElement
    public void processElement(@Element String element, MultiOutputReceiver out) {

        try {
            Customer parsedCustomer = Customer.fromJsonString(element);
            out.get(successOutput).output(parsedCustomer);
            okCount.inc();
        } catch (Exception ex) {
            String exceptionName = ex.getClass().getName();
            String error = String.format("Exception: %s | Message: %s | Stacktrace: %s",
                    ex.getClass().getName(), ex.getMessage(), ExceptionUtils.getStackTrace(ex));

            out.get(errorOutput).output(
                    new FailedRecord(element,
                            error,
                            exceptionName,
                            runId,
                            ParseCustomerFromJsonDoFn.class.getName()
                    )
            );

            notOkCount.inc();

            LOG.error(error);
        }
    }
}
