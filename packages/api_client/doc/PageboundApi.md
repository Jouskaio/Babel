# babel_api_client.api.PageboundApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getPagebound**](PageboundApi.md#getpagebound) | **GET** /v1/me/pagebound | Get Pagebound
[**importPagebound**](PageboundApi.md#importpagebound) | **POST** /v1/me/pagebound/import | Import Pagebound
[**linkPagebound**](PageboundApi.md#linkpagebound) | **PUT** /v1/me/pagebound | Link Pagebound
[**unlinkPagebound**](PageboundApi.md#unlinkpagebound) | **DELETE** /v1/me/pagebound | Unlink Pagebound


# **getPagebound**
> PageboundResponse getPagebound()

Get Pagebound

Whether you linked your Pagebound account.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PageboundApi();

try {
    final result = api_instance.getPagebound();
    print(result);
} catch (e) {
    print('Exception when calling PageboundApi->getPagebound: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PageboundResponse**](PageboundResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **importPagebound**
> PageboundImportResponse importPagebound()

Import Pagebound

Bring your public Pagebound reviews into Babel: each book joins your library as a paper book (finished) with your rating and text as a private review.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PageboundApi();

try {
    final result = api_instance.importPagebound();
    print(result);
} catch (e) {
    print('Exception when calling PageboundApi->importPagebound: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PageboundImportResponse**](PageboundImportResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **linkPagebound**
> PageboundResponse linkPagebound(linkPagebound)

Link Pagebound

Link your Pagebound account by its public username (no password is needed).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PageboundApi();
final linkPagebound = LinkPagebound(); // LinkPagebound | 

try {
    final result = api_instance.linkPagebound(linkPagebound);
    print(result);
} catch (e) {
    print('Exception when calling PageboundApi->linkPagebound: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **linkPagebound** | [**LinkPagebound**](LinkPagebound.md)|  | 

### Return type

[**PageboundResponse**](PageboundResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unlinkPagebound**
> unlinkPagebound()

Unlink Pagebound

Forget your Pagebound account (the reviews already imported stay).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PageboundApi();

try {
    api_instance.unlinkPagebound();
} catch (e) {
    print('Exception when calling PageboundApi->unlinkPagebound: $e\n');
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

