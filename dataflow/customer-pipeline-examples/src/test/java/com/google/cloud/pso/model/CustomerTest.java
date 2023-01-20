package com.google.cloud.pso.model;

import org.junit.Test;

import java.time.LocalDate;

import static org.junit.Assert.assertEquals;

public class CustomerTest {

    @Test
    public void fromJson() {

        Customer expected = new Customer(
                1L, "f", "l", LocalDate.of(2000,1,1), "a");

        Customer actual = Customer.fromJsonString("{\n" +
                "  \"id\": 1,\n" +
                "  \"firstName\": \"f\",\n" +
                "  \"lastName\": \"l\",\n" +
                "  \"dateOfBirth\": \"2000-01-01\",\n" +
                "  \"address\": \"a\"\n" +
                "}");

        assertEquals(expected, actual);
    }
}
