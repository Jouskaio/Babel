# babel_api_client.api.RequestsApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listBookRequests**](RequestsApi.md#listbookrequests) | **GET** /v1/requests | List Requests
[**requestBook**](RequestsApi.md#requestbook) | **POST** /v1/requests | Request Book


# **listBookRequests**
> RequestsResponse listBookRequests()

List Requests

Your requests, with their progress (the ones still waiting are checked first).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RequestsApi();

try {
    final result = api_instance.listBookRequests();
    print(result);
} catch (e) {
    print('Exception when calling RequestsApi->listBookRequests: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**RequestsResponse**](RequestsResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestBook**
> BookRequestResponse requestBook(newRequest)

Request Book

Ask the server to find and download a book (premium readers).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RequestsApi();
final newRequest = NewRequest(); // NewRequest | 

try {
    final result = api_instance.requestBook(newRequest);
    print(result);
} catch (e) {
    print('Exception when calling RequestsApi->requestBook: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **newRequest** | [**NewRequest**](NewRequest.md)|  | 

### Return type

[**BookRequestResponse**](BookRequestResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

