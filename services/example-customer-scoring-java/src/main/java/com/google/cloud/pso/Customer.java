package com.google.cloud.pso;

import com.google.common.base.Objects;
import java.io.Serializable;
import java.time.LocalDate;

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


}
