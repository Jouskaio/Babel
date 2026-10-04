# babel_api_client.api.CatalogApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getCover**](CatalogApi.md#getcover) | **GET** /v1/catalog/covers/{cover_id}/{size} | Get Cover
[**getTrendingWorks**](CatalogApi.md#gettrendingworks) | **GET** /v1/catalog/trending | Get Trending
[**getWork**](CatalogApi.md#getwork) | **GET** /v1/catalog/works/{work_id} | Get Work
[**lookupIsbn**](CatalogApi.md#lookupisbn) | **GET** /v1/catalog/isbn/{isbn} | Lookup Isbn
[**searchWorks**](CatalogApi.md#searchworks) | **GET** /v1/catalog/search | Search Works


# **getCover**
> getCover(coverId, size)

Get Cover

Cover image, proxied and cached so clients never call third parties directly.

### Example
```dart
import 'package:babel_api_client/api.dart';

final api_instance = CatalogApi();
final coverId = 56; // int | 
final size = size_example; // String | 

try {
    api_instance.getCover(coverId, size);
} catch (e) {
    print('Exception when calling CatalogApi->getCover: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **coverId** | **int**|  | 
 **size** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: image/jpeg

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTrendingWorks**
> List<TrendingWorkResponse> getTrendingWorks(limit)

Get Trending

Works that are popular this week. Empty when no source is reachable.

### Example
```dart
import 'package:babel_api_client/api.dart';

final api_instance = CatalogApi();
final limit = 56; // int | 

try {
    final result = api_instance.getTrendingWorks(limit);
    print(result);
} catch (e) {
    print('Exception when calling CatalogApi->getTrendingWorks: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **int**|  | [optional] [default to 12]

### Return type

[**List<TrendingWorkResponse>**](TrendingWorkResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getWork**
> WorkResponse getWork(workId, lang)

Get Work

A work with its description and editions.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CatalogApi();
final workId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final lang = lang_example; // String | 

try {
    final result = api_instance.getWork(workId, lang);
    print(result);
} catch (e) {
    print('Exception when calling CatalogApi->getWork: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **workId** | **String**|  | 
 **lang** | **String**|  | [optional] 

### Return type

[**WorkResponse**](WorkResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **lookupIsbn**
> IsbnLookupResponse lookupIsbn(isbn, lang)

Lookup Isbn

Find the edition (and its work) of an ISBN-10 or ISBN-13, e.g. from a barcode scan.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CatalogApi();
final isbn = isbn_example; // String | 
final lang = lang_example; // String | 

try {
    final result = api_instance.lookupIsbn(isbn, lang);
    print(result);
} catch (e) {
    print('Exception when calling CatalogApi->lookupIsbn: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **isbn** | **String**|  | 
 **lang** | **String**|  | [optional] 

### Return type

[**IsbnLookupResponse**](IsbnLookupResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **searchWorks**
> List<WorkSummaryResponse> searchWorks(q, limit, lang)

Search Works

Search works by title, author or keywords, titled in ``lang`` when possible.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CatalogApi();
final q = q_example; // String | 
final limit = 56; // int | 
final lang = lang_example; // String | 

try {
    final result = api_instance.searchWorks(q, limit, lang);
    print(result);
} catch (e) {
    print('Exception when calling CatalogApi->searchWorks: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | 
 **limit** | **int**|  | [optional] [default to 20]
 **lang** | **String**|  | [optional] 

### Return type

[**List<WorkSummaryResponse>**](WorkSummaryResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

