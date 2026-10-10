# babel_api_client.api.CatalogApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getCover**](CatalogApi.md#getcover) | **GET** /v1/catalog/covers/{cover_id}/{size} | Get Cover
[**getKnownVolumes**](CatalogApi.md#getknownvolumes) | **GET** /v1/catalog/saga/known | Get Known Volumes
[**getSaga**](CatalogApi.md#getsaga) | **GET** /v1/catalog/saga | Get Saga
[**getTrendingWorks**](CatalogApi.md#gettrendingworks) | **GET** /v1/catalog/trending | Get Trending
[**getWork**](CatalogApi.md#getwork) | **GET** /v1/catalog/works/{work_id} | Get Work
[**getWorkCover**](CatalogApi.md#getworkcover) | **GET** /v1/catalog/work-covers/{work_id} | Get Work Cover
[**lookupIsbn**](CatalogApi.md#lookupisbn) | **GET** /v1/catalog/isbn/{isbn} | Lookup Isbn
[**openHardcoverWork**](CatalogApi.md#openhardcoverwork) | **POST** /v1/catalog/works/hardcover | Open Hardcover Work
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

# **getKnownVolumes**
> List<KnownVolumeResponse> getKnownVolumes(series, author)

Get Known Volumes

Volumes Hardcover lists for a saga, to name the ones the catalog lacks (may be empty).

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
final series = series_example; // String | 
final author = author_example; // String | 

try {
    final result = api_instance.getKnownVolumes(series, author);
    print(result);
} catch (e) {
    print('Exception when calling CatalogApi->getKnownVolumes: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **series** | **String**|  | 
 **author** | **String**|  | [optional] 

### Return type

[**List<KnownVolumeResponse>**](KnownVolumeResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSaga**
> List<SagaVolumeResponse> getSaga(series, author)

Get Saga

Every volume of a saga the catalog lists, in order (e.g. all of Homunculus).

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
final series = series_example; // String | 
final author = author_example; // String | 

try {
    final result = api_instance.getSaga(series, author);
    print(result);
} catch (e) {
    print('Exception when calling CatalogApi->getSaga: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **series** | **String**|  | 
 **author** | **String**|  | [optional] 

### Return type

[**List<SagaVolumeResponse>**](SagaVolumeResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

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

# **getWorkCover**
> getWorkCover(workId)

Get Work Cover

The cover of a work found at Hardcover, kept by Babel (public, like other covers).

### Example
```dart
import 'package:babel_api_client/api.dart';

final api_instance = CatalogApi();
final workId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.getWorkCover(workId);
} catch (e) {
    print('Exception when calling CatalogApi->getWorkCover: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **workId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: image/*

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

# **openHardcoverWork**
> WorkSummaryResponse openHardcoverWork(hardcoverWorkRequest)

Open Hardcover Work

A volume only Hardcover lists, as a work you can open (and ask for).

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
final hardcoverWorkRequest = HardcoverWorkRequest(); // HardcoverWorkRequest | 

try {
    final result = api_instance.openHardcoverWork(hardcoverWorkRequest);
    print(result);
} catch (e) {
    print('Exception when calling CatalogApi->openHardcoverWork: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **hardcoverWorkRequest** | [**HardcoverWorkRequest**](HardcoverWorkRequest.md)|  | 

### Return type

[**WorkSummaryResponse**](WorkSummaryResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
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

