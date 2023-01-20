package com.google.cloud.pso.model;

import com.google.cloud.pso.BatchExamplePipeline;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.Validation;

/**
 * Options supported by {@link BatchExamplePipeline}.
 *
 * <p>Concept #4: Defining your own configuration options. Here, you can add your own arguments to
 * be processed by the command-line parser, and specify default values for them. You can then
 * access the options values in your pipeline code.
 *
 * <p>Inherits standard configuration options.
 */
public interface StreamingExampleOptions extends PipelineOptions {

    @Description("PubSub pull subscription to read from")
    @Validation.Required
    String getInputSubscription();

    void setInputSubscription(String value);

    @Description("BigQuery table to write to")
    @Validation.Required
    String getOutputTable();

    void setOutputTable(String value);

    @Description("BigQuery error table to write to")
    @Validation.Required
    String getErrorTable();

    void setErrorTable(String value);

    @Description("Cloud Run endpoint for customer scoring")
    @Validation.Required
    String getCustomerScoringServiceUrl();

    void setCustomerScoringServiceUrl(String value);
}

