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

