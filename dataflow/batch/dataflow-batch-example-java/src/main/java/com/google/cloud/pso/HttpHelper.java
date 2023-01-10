package com.google.cloud.pso;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.LocalDate;

public class HttpHelper {

    public static String obtainAuthToken(){
        //TODO: refresh auth token and pass it to the HTTP request
        return "TODO";
    }

    public static HttpResponse<String> post(
            String serviceUrl,
            Object parameterBody
    ) throws IOException, InterruptedException {

        ObjectMapper objectMapper = new ObjectMapper();
        // register module to serialize LocalDate
        objectMapper.registerModule(new JavaTimeModule());

        String requestBody = objectMapper
                .writeValueAsString(parameterBody);

        //TODO: reuse the client in ParDo
        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(serviceUrl))
                .headers("Content-Type","application/json")
                .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                .build();

        HttpResponse<String> response = client.send(
                request,
                HttpResponse.BodyHandlers.ofString());

        return response;
    }
}
