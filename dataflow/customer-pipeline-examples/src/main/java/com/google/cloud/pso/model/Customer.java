package com.google.cloud.pso.model;

import com.google.api.services.bigquery.model.TableRow;
import com.google.common.base.Objects;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.apache.beam.sdk.coders.AvroCoder;
import org.apache.beam.sdk.coders.DefaultCoder;

import java.io.Serializable;
import java.time.LocalDate;

@DefaultCoder(AvroCoder.class)
public class Customer implements Serializable {
    private Long id;
    private String firstName;
    private String lastName;
    private LocalDate dateOfBirth;
    private String address;

    public Customer(Long id, String firstName, String lastName, LocalDate dateOfBirth, String address) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.dateOfBirth = dateOfBirth;
        this.address = address;
    }

    public Long getId() {
        return id;
    }

    public String getFirstName() {
        return firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    public String getAddress() {
        return address;
    }

    @Override
    public String toString() {
        return "Customer{" +
                "id=" + id +
                ", firstName='" + firstName + '\'' +
                ", lastName='" + lastName + '\'' +
                ", dateOfBirth=" + dateOfBirth +
                ", address='" + address + '\'' +
                '}';
    }

    public String toJsonString(){
        Gson gson = new GsonBuilder()
                .setPrettyPrinting()
                .registerTypeAdapter(LocalDate.class, new LocalDateAdapter())
                .create();

        return gson.toJson(this);
    }

    public static Customer fromJsonString(String jsonStr){
        Gson gson = new GsonBuilder()
                .setPrettyPrinting()
                .registerTypeAdapter(LocalDate.class, new LocalDateAdapter())
                .create();

        return gson.fromJson(jsonStr, Customer.class);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Customer customer = (Customer) o;
        return Objects.equal(id, customer.id) && Objects.equal(firstName, customer.firstName) && Objects.equal(lastName, customer.lastName) && Objects.equal(dateOfBirth, customer.dateOfBirth) && Objects.equal(address, customer.address);
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(id, firstName, lastName, dateOfBirth, address);
    }

    /**
     * Parse a BigQuery TableRow returned by BigQueryIO to a Customer object
     * @param row
     * @return
     */
    public static Customer fromTableRow(TableRow row) {

        /**
         * Check this snippet for parsing all data types
         * https://github.com/apache/beam/blob/master/examples/java/src/main/java/org/apache/beam/examples/snippets/transforms/io/gcp/bigquery/BigQueryMyData.java
         */

        Long id = Long.parseLong((String) row.get("id"));
        String firstName = (String) row.get("first_name");
        String lastName = (String) row.get("last_name");
        LocalDate dateOfBirth = LocalDate.parse((String) row.get("date_of_birth"));
        String address = (String) row.get("address");

        return new Customer(id,firstName,lastName, dateOfBirth, address);
    }


}
