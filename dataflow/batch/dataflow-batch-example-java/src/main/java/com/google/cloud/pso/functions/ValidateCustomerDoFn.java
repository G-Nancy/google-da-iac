package com.google.cloud.pso.functions;

import com.google.cloud.pso.model.Customer;
import org.apache.beam.sdk.metrics.Counter;
import org.apache.beam.sdk.metrics.Metrics;
import org.apache.beam.sdk.transforms.DoFn;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ValidateCustomerDoFn extends DoFn<Customer, Customer> {

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

