package com.google.cloud.pso;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.auth.oauth2.IdTokenCredentials;
import com.google.auth.oauth2.IdTokenProvider;
import org.apache.http.HttpEntity;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;
import org.junit.Test;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.HashMap;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.net.URLEncoder;

public class SandboxTest {

////    def _grab_new_auth_token(self) -> str:
////            # There are two ways to grap a token: if we are running in GCE, we use the metadata server;
////        # if we are running in local, we try to use gcloud to grab a valid token.
////
////    metadata_server_token_url = 'http://metadata/computeMetadata/v1/instance/service-accounts/default/identity?audience='
////    token_request_url = metadata_server_token_url + self._web_service_url
////
////            token_request_headers = {'Metadata-Flavor': 'Google'}
////        # Fetch the token
////                try:  # If running in a GCE instance
////                token_response = requests.get(token_request_url, headers=token_request_headers)
////                jwt = token_response.content.decode("utf-8")
////                # This token corresponds to the controller service account of Dataflow. That service account needs to have
////                # the Cloud Run Invoker role in the destination Cloud Run service.
////                except requests.exceptions.ConnectionError:
////                # We are not running in GCP, try to use gcloud
////                # OPSSUITE-8859: set `shell=True` for developers running this on Windows OS
////                cmd = subprocess.run(["gcloud", "auth", "print-identity-token"], capture_output=True, shell=True)
////                jwt = cmd.stdout.strip().decode('utf-8')
////                # This token will not correspond to a service account, but to the nominal user running the pipeline using
////                # the direct runner. That user needs also to have the Cloud Invoker role in the Cloud Run service for
////                # this token to work.
////
////                # If this "except" block fails, we don't know how to authenticate
////
////                return jwt
//
//    private static String serviceUrl = "https://example-customer-scoring-java-kiwdmfjrka-ey.a.run.app/api/customer/score";
//
//    private static String token = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImEyOWFiYzE5YmUyN2ZiNDE1MWFhNDMxZTk0ZmEzNjgwYWU0NThkYTUiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIzMjU1NTk0MDU1OS5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsImF1ZCI6IjMyNTU1OTQwNTU5LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTEzNzc2MTU3NTI1NTgxNDUzMTg0IiwiaGQiOiJ3YWRpZS5qb29uaXgubmV0IiwiZW1haWwiOiJhZG1pbkB3YWRpZS5qb29uaXgubmV0IiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJLSXU4OFQ4bV9QOERlT29sQ3UtbF93IiwiaWF0IjoxNjczMjU4MDU1LCJleHAiOjE2NzMyNjE2NTV9.kGVYx-PumXMMzLMj-V4S4ylcJq8FsWl6LJOK_fLv_eMHulfUJyT4YbR8uGpm6K-f-YqqjU5finHgnGLRvSoWdnCy0PB3R8YOEOQdL6Aa9tk3rMchEC0sP7Q6PnHz6QEjJTp4guohLfqeBrOotpZBssB6Xxre9tEIMCozVzo0nBeH9eAKKghYV6UhhbmAkUyVg9FMeaKxbuQ10-Kj2Tlb62iWfrPK9w9y07zVTShG6JpBY9IL6jaMadgSG7Oa0QjDxFiR9EGX1c6olm6e5SWYxF3DeCXR0_kzbtdMS-SbVQ_HQDK35lGgIDwEHlp7qivIkoeHFeFjfOF5I8wnxyt-ZA";
//    private static String getAuthToken() throws Exception {
//
//        String metadata_server_token_url = "http://metadata/computeMetadata/v1/instance/service-accounts/default/identity?audience=";
//        String token_request_url = metadata_server_token_url + serviceUrl;
//
//        HashMap<String, String> headers = new HashMap<>();
//        headers.put("Metadata-Flavor", "Google");
//
//        return sendGET(token_request_url, headers);
//    }
//
//    private static String callService () throws Exception{
//
//        HashMap<String, String> headers = new HashMap<>();
//        headers.put("Authorization", String.format("Bearer %s", token));
//        return sendGET(serviceUrl, headers);
//    }
//
//    private static String sendGET(String url, Map<String, String> headers) throws Exception {
//
//        HttpURLConnection con = null;
//        try {
//
//            URL obj = new URL(url);
//            con = (HttpURLConnection) obj.openConnection();
//            con.setRequestMethod("POST");
//
//            for (String key : headers.keySet()) {
//                con.setRequestProperty(key, headers.get(key));
//            }
//
//            con.setRequestProperty("Content-Type", "application/json");
//
//            Map<String, String> parameters = new HashMap<>();
//            parameters.put("customerId", "1");
//
//            con.setDoOutput(true);
//            DataOutputStream out = new DataOutputStream(con.getOutputStream());
//            try( DataOutputStream wr = new DataOutputStream( con.getOutputStream())) {
//                String paramsString = getParamsString(parameters);
//                System.out.println("params "+ paramsString);
//                wr.writeBytes(getParamsString(parameters) );
//                out.flush();
//            }
//
//            int responseCode = con.getResponseCode();
//            System.out.println("GET Response Code :: " + responseCode);
//            if (responseCode == HttpURLConnection.HTTP_OK) { // success
//                BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
//                String inputLine;
//                StringBuffer response = new StringBuffer();
//
//                while ((inputLine = in.readLine()) != null) {
//                    response.append(inputLine);
//                }
//                in.close();
//
//                // print result
//                System.out.println(response.toString());
//                return response.toString();
//            } else {
//                System.out.println("GET request did not work.");
//            }
//        } finally {
//            if (con != null) {
//                con.disconnect();
//            }
//        }
//
//        return "NONE";
//    }
//
//    @Test
//    public void test() throws Exception {
//
//       // getAuthToken();
//
//       // callService();
//
//        anotherPost();
//
////        HttpURLConnection con = null;
////        try{
////            URL url = new URL("https://example-customer-scoring-java-kiwdmfjrka-ey.a.run.app");
////            con = (HttpURLConnection) url.openConnection();
////            con.setRequestMethod("GET");
////
////            Map<String, String> parameters = new HashMap<>();
////            parameters.put("customerId", "1");
////
////            con.setDoOutput(true);
////            DataOutputStream out = new DataOutputStream(con.getOutputStream());
////            out.writeBytes(getParamsString(parameters));
////            out.flush();
////            out.close();
////
////            con.setRequestProperty("Content-Type", "application/json");
////            con.setConnectTimeout(5000);
////            con.setReadTimeout(5000);
////
////            int status = con.getResponseCode();
////            System.out.println("Status "+status);
////
////            BufferedReader in = new BufferedReader(
////                    new InputStreamReader(con.getInputStream()));
////            String inputLine;
////            StringBuffer content = new StringBuffer();
////            while ((inputLine = in.readLine()) != null) {
////                content.append(inputLine);
////            }
////            in.close();
////
////            con.disconnect();
////            System.out.println("Call returned "+content);
////        }finally {
////            if(con != null) {
////                con.disconnect();
////            }
////        }
//    }
//
//    public static String getParamsString(Map<String, String> params)
//            throws UnsupportedEncodingException {
//        StringBuilder result = new StringBuilder();
//
//        for (Map.Entry<String, String> entry : params.entrySet()) {
//            result.append(URLEncoder.encode(entry.getKey(), "UTF-8"));
//            result.append("=");
//            result.append(URLEncoder.encode(entry.getValue(), "UTF-8"));
//            result.append("&");
//        }
//
//        String resultString = result.toString();
//        return resultString.length() > 0
//                ? resultString.substring(0, resultString.length() - 1)
//                : resultString;
//    }
//
//    @Test
//    public void anotherPost() throws IOException, InterruptedException {
//
//        Customer customer = new Customer(
//                10L,
//                "Karim",
//                "Wadie",
//                LocalDate.MAX,
//                "Berlin"
//        );
//
//        ObjectMapper objectMapper = new ObjectMapper();
//        // register module to serialize LocalDate
//        objectMapper.registerModule(new JavaTimeModule());
//
//        String requestBody = objectMapper
//                .writeValueAsString(customer);
//
//        HttpClient client = HttpClient.newHttpClient();
//        HttpRequest request = HttpRequest.newBuilder()
//                .uri(URI.create(serviceUrl))
//                .headers("Content-Type","application/json")
//                .POST(HttpRequest.BodyPublishers.ofString(requestBody))
//                //.POST(HttpRequest.BodyPublishers.ofByteArray(requestBody))
//                .build();
//
//        System.out.println("request = "+ request.toString());
//
//        HttpResponse<String> response = client.send(request,
//                HttpResponse.BodyHandlers.ofString());
//
//        System.out.println(response.body());
//    }


}
