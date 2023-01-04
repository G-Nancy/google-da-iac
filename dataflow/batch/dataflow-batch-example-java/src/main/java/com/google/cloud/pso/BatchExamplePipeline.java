/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.google.cloud.pso;

import com.google.api.services.bigquery.model.TableRow;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO;
import org.apache.beam.sdk.metrics.Counter;
import org.apache.beam.sdk.metrics.Metrics;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.options.Validation.Required;
import org.apache.beam.sdk.transforms.*;
import org.apache.beam.sdk.values.PBegin;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.PDone;
import org.apache.beam.sdk.values.TypeDescriptor;

import java.util.Random;

public class BatchExamplePipeline {



    // "E" in ETL
    public static class ExtractRecords
            extends PTransform<PBegin, PCollection<Customer>> {

        private BatchExampleOptions options;
        public ExtractRecords(BatchExampleOptions options){
            this.options = options;
        }

        @Override
        public PCollection<Customer> expand(PBegin p) {

            PCollection<TableRow> tableRowsPC = p.apply(
                    "Read from BigQuery query",
                    BigQueryIO.readTableRows()
                            .fromQuery(String.format("SELECT id, first_name, last_name, date_of_birth, address FROM `%s`", options.getInputTable()))
                            .usingStandardSql());

            PCollection<Customer> customerPC = tableRowsPC.apply(
                    "TableRows to Customer",
                    MapElements.into(TypeDescriptor.of(Customer.class)).via(Customer::fromTableRow));

            return customerPC;
        }
    }

    // "T" in ETL
    public static class TransformRecords
            extends PTransform<PCollection<Customer>, PCollection<CustomerWithScore>> {
        @Override
        public PCollection<CustomerWithScore> expand(PCollection<Customer> customers) {

            // 1. Validate and filter out invalid customers
            // 2. Convert LastName to Upper Case
            PCollection<Customer> processedCustomers = customers.apply(ParDo.of(new ValidateCustomerDoFn()))
                    .apply(MapElements.via(new UpperCaseLastNameSimpleFunction()));

            PCollection<CustomerWithScore> customersWithScores = processedCustomers.apply(ParDo.of(new CalculateCustomerScore()));

            return customersWithScores;
        }
    }

    // "L" in ETL
    public static class LoadRecords
            extends PTransform<PCollection<CustomerWithScore>, PDone> {

        private BatchExampleOptions options;
        public LoadRecords(BatchExampleOptions options){
            this.options = options;
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
                            .to(options.getOutputTable())
                            .withCreateDisposition(BigQueryIO.Write.CreateDisposition.CREATE_NEVER)
                            .withWriteDisposition(BigQueryIO.Write.WriteDisposition.WRITE_TRUNCATE));

            return PDone.in(customersWithScore.getPipeline());
        }
    }

    static class ValidateCustomerDoFn extends DoFn<Customer, Customer> {
        private final Counter invalidCustomersCount = Metrics.counter(ValidateCustomerDoFn.class, "invalidCustomersCount");

        @ProcessElement
        public void processElement(@Element Customer element, OutputReceiver<Customer> receiver) {

            // This is a naive validation logic to demonstrate functionality
            if(element.getFirstName().startsWith("A")){
                invalidCustomersCount.inc();
            }else{

                // multiple elements could be added to the output if needed (1-to-many)
                receiver.output(element);
            }
        }
    }

    public static class UpperCaseLastNameSimpleFunction extends SimpleFunction<Customer, Customer> {

        @Override
        public Customer apply(Customer input) {
            // randomly generate scores from 1 to 10
            return new Customer(
                    input.getId(),
                    input.getFirstName(),
                    input.getLastName().toUpperCase(),
                    input.getDateOfBirth(),
                    input.getAddress()
            );
        }
    }

    public static class CalculateCustomerScore extends DoFn<Customer, CustomerWithScore> {

        private Random randomGenerator;

        /*
        Use setup function to initialize the DoFn on each worker
         */
        @Setup
        public void setup(){
            randomGenerator=new Random();
        }

        @ProcessElement
        public void processElement(@Element Customer element, OutputReceiver<CustomerWithScore> receiver) {
            // randomly generate scores from 1 to 10
            receiver.output(new CustomerWithScore(element, randomGenerator.nextInt(10)+1));
        }
    }




    /**
     * Options supported by {@link BatchExamplePipeline}.
     *
     * <p>Concept #4: Defining your own configuration options. Here, you can add your own arguments to
     * be processed by the command-line parser, and specify default values for them. You can then
     * access the options values in your pipeline code.
     *
     * <p>Inherits standard configuration options.
     */
    public interface BatchExampleOptions extends PipelineOptions {

        @Description("BigQuery table to read from")
        @Required
        String getInputTable();

        void setInputTable(String value);

        @Description("BigQuery table to write to")
        @Required
        String getOutputTable();

        void setOutputTable(String value);
    }

    static void runBatchExample(BatchExampleOptions options) {
        Pipeline p = Pipeline.create(options);

        // Concepts #2 and #3: Our pipeline applies the composite CountWords transform, and passes the
        // static FormatAsTextFn() to the ParDo transform.
        p.apply("Extract", new ExtractRecords(options))
                .apply("Transform", new TransformRecords())
                .apply("Load", new LoadRecords(options));

        p.run();
    }

    public static void main(String[] args) {
        BatchExampleOptions options =
                PipelineOptionsFactory.fromArgs(args).withValidation().as(BatchExampleOptions.class);

        runBatchExample(options);
    }
}
