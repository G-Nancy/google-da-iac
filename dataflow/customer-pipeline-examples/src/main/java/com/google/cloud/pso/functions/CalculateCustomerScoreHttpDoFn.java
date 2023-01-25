package com.google.cloud.pso.functions;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.google.api.client.http.HttpStatusCodes;
import com.google.cloud.pso.model.Customer;
import com.google.cloud.pso.model.FailedRecord;
import com.google.cloud.pso.model.CustomerWithScore;
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

public class CalculateCustomerScoreHttpDoFn extends DoFn<Customer, CustomerWithScore> {

    /**
     * https://beam.apache.org/releases/javadoc/2.43.0/org/apache/beam/sdk/transforms/ParDo.html
     */

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

    private HttpClient client;

    private ObjectMapper objectMapper;

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

    /**
     * If required, a fresh instance of the argument DoFn is created on a worker, and the DoFn.Setup method is called on this instance
     */
    @Setup
    public void setup(){

        client = HttpClient.newHttpClient();
        objectMapper = new ObjectMapper();
        // register module to serialize LocalDate
        objectMapper.registerModule(new JavaTimeModule());
    }


    @StartBundle
    /**
     * For every data bundle processed by a worker, the startBundle method is called to initialize it.
     */
    public void startBundle () throws IOException, InterruptedException {

        /**
         * To be able to call a Cloud Run service from GCP (i.e. from Dataflow) without
         * passing service account key files, we need to generate an auth token to allow
         * the dataflow job to call cloud run via the underlying dataflow service account.
         * We do that in startBundle to avoid token expiration on long-running jobs.
         * The token can be requested from the metadata service as bellow:
         *
         * PS: this code works only on DataflowRunner (on GCP) and it will fail locally.
         * Instead, run "gcloud auth print-identity-token" and use the hard coded token instead
         */

        String metadataServiceUrl = String.format("http://metadata/computeMetadata/v1/instance/service-accounts/default/identity?audience=%s",
                serviceUrl
                );

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(metadataServiceUrl))
                .headers("Metadata-Flavor", "Google")
                .GET()
                .build();

        HttpResponse<String> response = client.send(
                request,
                HttpResponse.BodyHandlers.ofString());

        authToken = response.body();
    }

    @ProcessElement
    public void processElement(@Element Customer element, MultiOutputReceiver out) {

        String error = "";
        String exceptionName = "";
        try{

            // prepare the HTTP request param
            String requestBody = objectMapper
                    .writeValueAsString(element);

            // prepare the HTTP request
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(serviceUrl))
                    .headers("Content-Type","application/json")
                    .headers("Authorization", String.format("Bearer %s", authToken))
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                    .build();

            // parse the response
            HttpResponse<String> response = client.send(
                    request,
                    HttpResponse.BodyHandlers.ofString());

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
