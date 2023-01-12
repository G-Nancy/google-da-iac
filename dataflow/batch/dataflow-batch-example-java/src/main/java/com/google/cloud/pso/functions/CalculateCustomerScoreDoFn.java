package com.google.cloud.pso.functions;

import com.google.cloud.pso.model.Customer;
import com.google.cloud.pso.model.CustomerWithScore;
import org.apache.beam.sdk.transforms.DoFn;

import java.util.Random;

public class CalculateCustomerScoreDoFn extends DoFn<Customer, CustomerWithScore> {

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

