# babel_api_client.api.DiscoverApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getPlaylist**](DiscoverApi.md#getplaylist) | **GET** /v1/catalog/playlists/{key} | Get Playlist
[**getSuggestions**](DiscoverApi.md#getsuggestions) | **GET** /v1/me/for-you | Get Suggestions
[**listPlaylists**](DiscoverApi.md#listplaylists) | **GET** /v1/catalog/playlists | List Playlists


# **getPlaylist**
> List<WorkSummaryResponse> getPlaylist(key)

Get Playlist

The popular works of a playlist.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DiscoverApi();
final key = key_example; // String | 

try {
    final result = api_instance.getPlaylist(key);
    print(result);
} catch (e) {
    print('Exception when calling DiscoverApi->getPlaylist: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**List<WorkSummaryResponse>**](WorkSummaryResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSuggestions**
> List<SuggestionResponse> getSuggestions()

Get Suggestions

Books you may like: more of the genres and authors you finish most, without those you already have.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DiscoverApi();

try {
    final result = api_instance.getSuggestions();
    print(result);
} catch (e) {
    print('Exception when calling DiscoverApi->getSuggestions: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<SuggestionResponse>**](SuggestionResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPlaylists**
> List<String> listPlaylists()

List Playlists

The playlists of books there are (their names are the app's).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DiscoverApi();

try {
    final result = api_instance.listPlaylists();
    print(result);
} catch (e) {
    print('Exception when calling DiscoverApi->listPlaylists: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**List<String>**

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

