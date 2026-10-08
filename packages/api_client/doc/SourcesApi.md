# babel_api_client.api.SourcesApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**checkSource**](SourcesApi.md#checksource) | **POST** /v1/sources/check | Check Source
[**createSource**](SourcesApi.md#createsource) | **POST** /v1/sources | Create Source
[**deleteSource**](SourcesApi.md#deletesource) | **DELETE** /v1/sources/{source_id} | Delete Source
[**getFanficDetails**](SourcesApi.md#getfanficdetails) | **GET** /v1/sources/{source_id}/entries/{entry_id}/details | Get Fanfic Details
[**getSource**](SourcesApi.md#getsource) | **GET** /v1/sources/{source_id} | Get Source
[**getSources**](SourcesApi.md#getsources) | **GET** /v1/sources | Get Sources
[**importSource**](SourcesApi.md#importsource) | **POST** /v1/sources/{source_id}/import | Import All
[**importSourceEntry**](SourcesApi.md#importsourceentry) | **POST** /v1/sources/{source_id}/entries/{entry_id}/import | Import Entry
[**scanSource**](SourcesApi.md#scansource) | **POST** /v1/sources/{source_id}/scan | Scan Source
[**searchSources**](SourcesApi.md#searchsources) | **GET** /v1/sources/search | Search Sources


# **checkSource**
> CheckSourceResponse checkSource(createSourceRequest)

Check Source

Try a source before adding it: nothing is saved.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SourcesApi();
final createSourceRequest = CreateSourceRequest(); // CreateSourceRequest | 

try {
    final result = api_instance.checkSource(createSourceRequest);
    print(result);
} catch (e) {
    print('Exception when calling SourcesApi->checkSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createSourceRequest** | [**CreateSourceRequest**](CreateSourceRequest.md)|  | 

### Return type

[**CheckSourceResponse**](CheckSourceResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createSource**
> SourceDetailResponse createSource(createSourceRequest)

Create Source

Connect a source: access is checked, then it is scanned right away (a slow one, such as AO3, in the background: the answer says so and the scan follows).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SourcesApi();
final createSourceRequest = CreateSourceRequest(); // CreateSourceRequest | 

try {
    final result = api_instance.createSource(createSourceRequest);
    print(result);
} catch (e) {
    print('Exception when calling SourcesApi->createSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createSourceRequest** | [**CreateSourceRequest**](CreateSourceRequest.md)|  | 

### Return type

[**SourceDetailResponse**](SourceDetailResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteSource**
> deleteSource(sourceId, removeBooks, xBabelDevice)

Delete Source

Forget the source and its token.  Imported books stay in the library, unless ``remove_books`` is set.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SourcesApi();
final sourceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final removeBooks = true; // bool | 
final xBabelDevice = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.deleteSource(sourceId, removeBooks, xBabelDevice);
} catch (e) {
    print('Exception when calling SourcesApi->deleteSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **String**|  | 
 **removeBooks** | **bool**|  | [optional] [default to false]
 **xBabelDevice** | **String**|  | [optional] 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFanficDetails**
> FanficDetailsResponse getFanficDetails(sourceId, entryId)

Get Fanfic Details

The summary, tags and numbers AO3 gives for a fanfiction of an AO3 source.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SourcesApi();
final sourceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final entryId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getFanficDetails(sourceId, entryId);
    print(result);
} catch (e) {
    print('Exception when calling SourcesApi->getFanficDetails: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **String**|  | 
 **entryId** | **String**|  | 

### Return type

[**FanficDetailsResponse**](FanficDetailsResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSource**
> SourceDetailResponse getSource(sourceId)

Get Source

The source and the books found by its last scan.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SourcesApi();
final sourceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getSource(sourceId);
    print(result);
} catch (e) {
    print('Exception when calling SourcesApi->getSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **String**|  | 

### Return type

[**SourceDetailResponse**](SourceDetailResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSources**
> List<SourceResponse> getSources()

Get Sources

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SourcesApi();

try {
    final result = api_instance.getSources();
    print(result);
} catch (e) {
    print('Exception when calling SourcesApi->getSources: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<SourceResponse>**](SourceResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **importSource**
> BatchImportResponse importSource(sourceId, xBabelDevice)

Import All

Import books not yet in the library, a batch per call (smaller for slow sources).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SourcesApi();
final sourceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final xBabelDevice = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.importSource(sourceId, xBabelDevice);
    print(result);
} catch (e) {
    print('Exception when calling SourcesApi->importSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **String**|  | 
 **xBabelDevice** | **String**|  | [optional] 

### Return type

[**BatchImportResponse**](BatchImportResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **importSourceEntry**
> LibraryItemResponse importSourceEntry(sourceId, entryId, xBabelDevice)

Import Entry

Import one book; a file already on Babel is not downloaded again.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SourcesApi();
final sourceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final entryId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final xBabelDevice = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.importSourceEntry(sourceId, entryId, xBabelDevice);
    print(result);
} catch (e) {
    print('Exception when calling SourcesApi->importSourceEntry: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **String**|  | 
 **entryId** | **String**|  | 
 **xBabelDevice** | **String**|  | [optional] 

### Return type

[**LibraryItemResponse**](LibraryItemResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **scanSource**
> SourceDetailResponse scanSource(sourceId)

Scan Source

Look for new books in the source (in the background for a slow one: see ``scanning``).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SourcesApi();
final sourceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.scanSource(sourceId);
    print(result);
} catch (e) {
    print('Exception when calling SourcesApi->scanSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **String**|  | 

### Return type

[**SourceDetailResponse**](SourceDetailResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **searchSources**
> List<SourceMatchResponse> searchSources(q)

Search Sources

Books of your sources matching a title or an author, to import the one you want.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SourcesApi();
final q = q_example; // String | 

try {
    final result = api_instance.searchSources(q);
    print(result);
} catch (e) {
    print('Exception when calling SourcesApi->searchSources: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | 

### Return type

[**List<SourceMatchResponse>**](SourceMatchResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

