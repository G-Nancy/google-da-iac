package com.google.cloud.pso.functions;

import com.google.api.client.http.HttpStatusCodes;
import com.google.cloud.pso.model.Customer;
import com.google.cloud.pso.model.FailedRecord;
import com.google.cloud.pso.model.CustomerWithScore;
import com.google.cloud.pso.HttpHelper;
import org.apache.beam.repackaged.core.org.apache.commons.lang3.exception.ExceptionUtils;
import org.apache.beam.sdk.metrics.Counter;
import org.apache.beam.sdk.metrics.Metrics;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.values.TupleTag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.net.http.HttpResponse;

public class CalculateCustomerScoreHttpDoFn extends DoFn<Customer, CustomerWithScore> {

    private final static Logger LOG = LoggerFactory.getLogger(CalculateCustomerScoreHttpDoFn.class);
    private final Counter httpOkCount = Metrics.counter(CalculateCustomerScoreHttpDoFn.class, "customerScoringHttpOk");
    private final Counter httpNotOkCount = Metrics.counter(CalculateCustomerScoreHttpDoFn.class, "customerScoringHttpNotOk");

    private final String serviceUrl;
    private String authToken;

    private String runId;

    // Output customers that are processed successfully by the service
    public final TupleTag<CustomerWithScore> successOutput;

    // Error output with each customer and the exception that happened
    public final TupleTag<FailedRecord> errorOutput;

    public CalculateCustomerScoreHttpDoFn(String serviceUrl,
                                          String runId,
                                          TupleTag<CustomerWithScore> successOutput,
                                          TupleTag<FailedRecord> errorOutput
                                          ){
        this.serviceUrl = serviceUrl;
        this.successOutput = successOutput;
        this.errorOutput = errorOutput;
        this.runId = runId;
    }

    @Setup
    public void setup(){}

    @StartBundle
    public void startBundle (){
        authToken = HttpHelper.obtainAuthToken();
    }

    @ProcessElement
    public void processElement(@Element Customer element, MultiOutputReceiver out) {

        String error = "";
        String exceptionName = "";
        try{
            HttpResponse<String> response = HttpHelper.post(
                    serviceUrl,
                    element
            );

            if(response.statusCode() == HttpStatusCodes.STATUS_CODE_OK){

                out.get(successOutput).output(
                        new CustomerWithScore(
                                element,
                                Integer.valueOf(response.body()))
                );

                httpOkCount.inc();

                return;
            }else{
                error = String.format("HTTP NOK. Status code: %s", response.statusCode());
            }

        }catch (Exception ex){
            exceptionName = ex.getClass().getName();
            error = String.format("Exception: %s | Message: %s | Stacktrace: %s",
                    ex.getClass().getName(), ex.getMessage(), ExceptionUtils.getStackTrace(ex));

            LOG.error(error);
        }

        httpNotOkCount.inc();
        out.get(errorOutput).output(
                new FailedRecord(element.toJsonString(),
                        error,
                        exceptionName,
                        runId,
                        CalculateCustomerScoreHttpDoFn.class.getName()
                        )
        );

    }
}
