# babel_api_client.api.CommunityApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listCommunity**](CommunityApi.md#listcommunity) | **GET** /v1/community | List Community


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

