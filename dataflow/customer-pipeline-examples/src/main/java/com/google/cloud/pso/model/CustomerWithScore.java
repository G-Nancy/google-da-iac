package com.google.cloud.pso.model;

import com.google.api.services.bigquery.model.TableRow;
import com.google.common.base.Objects;
import org.apache.beam.sdk.coders.AvroCoder;
import org.apache.beam.sdk.coders.DefaultCoder;

import java.io.Serializable;

@DefaultCoder(AvroCoder.class)
public class CustomerWithScore extends Customer implements Serializable {

    private Integer score;

    public CustomerWithScore(Customer customer, Integer score) {
        super(customer.getId(),
                customer.getFirstName(),
                customer.getLastName(),
                customer.getDateOfBirth(),
                customer.getAddress());
        this.score = score;
    }

    public Integer getScore() {
        return score;
    }

    @Override
    public String toString() {
        return "CustomerWithScore{" +
                "score=" + score +
                "} " + super.toString();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;
        CustomerWithScore that = (CustomerWithScore) o;
        return Objects.equal(score, that.score);
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(super.hashCode(), score);
    }

    public TableRow toTableRow() {

        /**
         * Check this snippet for parsing all data types
         * https://github.com/apache/beam/blob/master/examples/java/src/main/java/org/apache/beam/examples/snippets/transforms/io/gcp/bigquery/BigQueryTableRowCreate.java
         */

        return new TableRow()
                // To learn more about BigQuery data types:
                // https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types
                .set("id", this.getId())
                .set("first_name", this.getFirstName())
                .set("last_name", this.getLastName())
                .set("date_of_birth", this.getDateOfBirth())
                .set("address", this.getAddress())
                .set("score", this.getScore());
    }
}
