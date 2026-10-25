# babel_api_client.api.CommunityApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listCommunity**](CommunityApi.md#listcommunity) | **GET** /v1/community | List Community
[**reportCommunityFile**](CommunityApi.md#reportcommunityfile) | **POST** /v1/community/{sha256}/report | Report Community File


# **listCommunity**
> CommunityPageResponse listCommunity(q, page)

List Community

Books shared by every reader (a fanfiction only when its reader shares it), newest first; add one to your library with POST /library/files/{sha256}.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CommunityApi();
final q = q_example; // String | 
final page = 56; // int | 

try {
    final result = api_instance.listCommunity(q, page);
    print(result);
} catch (e) {
    print('Exception when calling CommunityApi->listCommunity: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | [optional] [default to '']
 **page** | **int**|  | [optional] [default to 1]

### Return type

[**CommunityPageResponse**](CommunityPageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reportCommunityFile**
> reportCommunityFile(sha256, fileReportRequest)

Report Community File

Flag a shared file for the administrators (illegal, wrong, unwanted).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CommunityApi();
final sha256 = sha256_example; // String | 
final fileReportRequest = FileReportRequest(); // FileReportRequest | 

try {
    api_instance.reportCommunityFile(sha256, fileReportRequest);
} catch (e) {
    print('Exception when calling CommunityApi->reportCommunityFile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sha256** | **String**|  | 
 **fileReportRequest** | [**FileReportRequest**](FileReportRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

