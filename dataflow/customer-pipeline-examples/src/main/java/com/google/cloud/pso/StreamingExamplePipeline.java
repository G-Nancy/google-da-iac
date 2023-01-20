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

import com.google.cloud.pso.model.*;
import com.google.cloud.pso.transforms.*;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.transforms.Flatten;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.PCollectionList;
import org.apache.beam.sdk.values.PCollectionTuple;

public class StreamingExamplePipeline {

    static void run(StreamingExampleOptions options) {

        final String runId = options.getJobName();

        Pipeline p = Pipeline.create(options);

        PCollectionTuple parsedCustomerResults = p.
                apply("Extract",
                        new ExtractStreamedRecordsPTransform(options.getInputSubscription(), runId));

        PCollection<Customer> extractedCustomers = parsedCustomerResults.get(ExtractStreamedRecordsPTransform.successOutput);
        PCollection<FailedRecord> extractionFailedRecords = parsedCustomerResults.get(ExtractStreamedRecordsPTransform.errorOutput);

        PCollectionTuple transformedCustomers = extractedCustomers
                .apply("Transform", new TransformRecordsPTransform(
                        options.getCustomerScoringServiceUrl(),
                        runId
                ));

        // here we load into two tables: success and error
        PCollection<CustomerWithScore> customersWithScore = transformedCustomers
                .get(TransformRecordsPTransform.successOutput);

        customersWithScore.apply("Load Success Records", new LoadSuccessRecordsPTransform(options.getOutputTable()));

        PCollection<FailedRecord> transformationFiledRecords = transformedCustomers
                .get(TransformRecordsPTransform.errorOutput);

        // Union failed records from the extraction and transformation steps
        PCollection<FailedRecord> allFailedRecords = PCollectionList
                .of(extractionFailedRecords)
                .and(transformationFiledRecords)
                .apply(Flatten.pCollections());

        allFailedRecords.apply("Load Failed Records", new LoadFailedRecordsPTransform(options.getErrorTable()));

        p.run();
    }

    public static void main(String[] args) {

        StreamingExampleOptions options =
                PipelineOptionsFactory.fromArgs(args).withValidation().as(StreamingExampleOptions.class);

        run(options);
    }
}
