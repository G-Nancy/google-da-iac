/*
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.google.cloud.pso;

// import org.checkerframework.checker.units.qual.C;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Random;

@SpringBootApplication(scanBasePackages = "com.google.cloud.pso")

// indicates that the data returned by each method will be written straight into the response body instead of rendering a template.
@RestController
public class ExampleCustomerScoring {

    private Integer maxScore = 10;
    private Integer minScore = 0;
    private Random random;

    public ExampleCustomerScoring() {
        random = new Random();

        // read min and max scores from env variables
        minScore = Integer.valueOf(
                System.getenv().getOrDefault("MIN_SCORE", "0"));
        maxScore = Integer.valueOf(
                System.getenv().getOrDefault("MAX_SCORE", "10"));
    }

    // Example of POST method with @RequestBody
    @PostMapping("/api/customer/score")
    public ResponseEntity<Integer> score(@RequestBody Customer customer) {

        // sample logic of generating random scores using the input param
        if(customer.getId() < 10){
            return ResponseEntity.status(HttpStatus.OK).body(0);
        }else{
            // generate random score between MIN and MAX values
            Integer score = random.nextInt(maxScore - minScore + 1) + minScore;
            return ResponseEntity.status(HttpStatus.OK).body(score);
        }

    }

    // Example of GET method with PathVariable
    @GetMapping("/api/customer/{id}")
    Customer getCustomer(@PathVariable Long id) {

        return new Customer(id,
                "Test",
                "Test",
                LocalDate.MAX,
                "Test"
                );
    }

    public static void main(String[] args) {
        SpringApplication.run(ExampleCustomerScoring.class, args);
    }
}
