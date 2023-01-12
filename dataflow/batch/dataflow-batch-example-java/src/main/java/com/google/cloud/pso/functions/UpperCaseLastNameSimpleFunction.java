package com.google.cloud.pso.functions;

import com.google.cloud.pso.model.Customer;
import org.apache.beam.sdk.transforms.SimpleFunction;

public class UpperCaseLastNameSimpleFunction extends SimpleFunction<Customer, Customer> {

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
