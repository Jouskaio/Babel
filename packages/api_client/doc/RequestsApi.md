# babel_api_client.api.RequestsApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**cancelBookRequest**](RequestsApi.md#cancelbookrequest) | **DELETE** /v1/requests/{work_id} | Cancel Request
[**getChaptarrLink**](RequestsApi.md#getchaptarrlink) | **GET** /v1/me/chaptarr | Get Chaptarr Link
[**linkChaptarr**](RequestsApi.md#linkchaptarr) | **PUT** /v1/me/chaptarr | Link Chaptarr
[**listBookRequests**](RequestsApi.md#listbookrequests) | **GET** /v1/requests | List Requests
[**requestBook**](RequestsApi.md#requestbook) | **POST** /v1/requests | Request Book
[**unlinkChaptarr**](RequestsApi.md#unlinkchaptarr) | **DELETE** /v1/me/chaptarr | Unlink Chaptarr


# **cancelBookRequest**
> cancelBookRequest(workId, language)

Cancel Request

Cancel a request: it disappears from your list and you can ask again.

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
final workId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final language = language_example; // String | 

try {
    api_instance.cancelBookRequest(workId, language);
} catch (e) {
    print('Exception when calling RequestsApi->cancelBookRequest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **workId** | **String**|  | 
 **language** | **String**|  | [optional] [default to '']

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChaptarrLink**
> ChaptarrLinkResponse getChaptarrLink()

Get Chaptarr Link

Whether you linked your own Chaptarr (its key is never given back).

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
    final result = api_instance.getChaptarrLink();
    print(result);
} catch (e) {
    print('Exception when calling RequestsApi->getChaptarrLink: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ChaptarrLinkResponse**](ChaptarrLinkResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **linkChaptarr**
> ChaptarrLinkResponse linkChaptarr(chaptarrLinkRequest)

Link Chaptarr

Link your own Chaptarr: its address and API key are checked, then kept (the key encrypted). Your book requests then go to it.

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
final chaptarrLinkRequest = ChaptarrLinkRequest(); // ChaptarrLinkRequest | 

try {
    final result = api_instance.linkChaptarr(chaptarrLinkRequest);
    print(result);
} catch (e) {
    print('Exception when calling RequestsApi->linkChaptarr: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chaptarrLinkRequest** | [**ChaptarrLinkRequest**](ChaptarrLinkRequest.md)|  | 

### Return type

[**ChaptarrLinkResponse**](ChaptarrLinkResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

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

Ask the server to find and download a book (premium readers). The answer is immediate; the search goes on in the background, see the status of your requests.

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

# **unlinkChaptarr**
> unlinkChaptarr()

Unlink Chaptarr

Forget your Chaptarr; the books already requested stay as they are.

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
    api_instance.unlinkChaptarr();
} catch (e) {
    print('Exception when calling RequestsApi->unlinkChaptarr: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

