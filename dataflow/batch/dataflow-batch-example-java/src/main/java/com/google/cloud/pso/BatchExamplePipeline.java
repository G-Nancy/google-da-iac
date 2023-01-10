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

import com.google.cloud.pso.model.BatchExampleOptions;
import com.google.cloud.pso.model.Customer;
import com.google.cloud.pso.model.CustomerWithScore;
import com.google.cloud.pso.model.FailedRecord;
import com.google.cloud.pso.transforms.ExtractRecordsPTransform;
import com.google.cloud.pso.transforms.LoadFailedRecordsPTransform;
import com.google.cloud.pso.transforms.LoadSuccessRecordsPTransform;
import com.google.cloud.pso.transforms.TransformRecordsPTransform;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.PCollectionTuple;

public class BatchExamplePipeline {

    static void run(BatchExampleOptions options) {

        Pipeline p = Pipeline.create(options);

        PCollection<Customer> extractedCustomers = p.
                apply("Extract",
                new ExtractRecordsPTransform(options.getInputTable()));

        PCollectionTuple transformedCustomers = extractedCustomers
                .apply("Transform", new TransformRecordsPTransform(
                        options.getCustomerScoringServiceUrl(),
                        options.getJobName()
                        ));

        // here we load into two tables: success and error
        PCollection<CustomerWithScore> customersWithScore = transformedCustomers
                .get(TransformRecordsPTransform.successOutput);

        customersWithScore.apply("Load Success Records", new LoadSuccessRecordsPTransform(options.getOutputTable()));

        PCollection<FailedRecord> customersWithErrors = transformedCustomers
                .get(TransformRecordsPTransform.errorOutput);

        customersWithErrors.apply("Load Error Records", new LoadFailedRecordsPTransform(options.getErrorTable()));

        p.run();
    }

    public static void main(String[] args) {

        BatchExampleOptions options =
                PipelineOptionsFactory.fromArgs(args).withValidation().as(BatchExampleOptions.class);

        run(options);
    }
}
