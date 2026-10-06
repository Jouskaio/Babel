# babel_api_client.api.AudiobooksApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addAudiobook**](AudiobooksApi.md#addaudiobook) | **POST** /v1/audiobookshelf/books/{remote_id} | Add
[**browseAudiobooks**](AudiobooksApi.md#browseaudiobooks) | **GET** /v1/audiobookshelf/libraries/{library_id}/books | Browse
[**getAudioCover**](AudiobooksApi.md#getaudiocover) | **GET** /v1/audio-covers/{key} | Cover
[**getAudiobookLibraries**](AudiobooksApi.md#getaudiobooklibraries) | **GET** /v1/audiobookshelf/libraries | Libraries
[**getAudiobookshelf**](AudiobooksApi.md#getaudiobookshelf) | **GET** /v1/me/audiobookshelf | Get Link
[**getPlayback**](AudiobooksApi.md#getplayback) | **GET** /v1/library/{item_id}/audio | Playback
[**linkAudiobookshelf**](AudiobooksApi.md#linkaudiobookshelf) | **POST** /v1/me/audiobookshelf | Link
[**saveAudioProgress**](AudiobooksApi.md#saveaudioprogress) | **PUT** /v1/library/{item_id}/audio/progress | Save Progress
[**streamAudioTrack**](AudiobooksApi.md#streamaudiotrack) | **GET** /v1/library/{item_id}/audio/tracks/{index} | Stream
[**unlinkAudiobookshelf**](AudiobooksApi.md#unlinkaudiobookshelf) | **DELETE** /v1/me/audiobookshelf | Unlink


# **addAudiobook**
> LibraryItemResponse addAudiobook(remoteId, xBabelDevice)

Add

Add an audiobook to your library (or bring it back, with its data).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AudiobooksApi();
final remoteId = remoteId_example; // String | 
final xBabelDevice = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.addAudiobook(remoteId, xBabelDevice);
    print(result);
} catch (e) {
    print('Exception when calling AudiobooksApi->addAudiobook: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **remoteId** | **String**|  | 
 **xBabelDevice** | **String**|  | [optional] 

### Return type

[**LibraryItemResponse**](LibraryItemResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **browseAudiobooks**
> List<AbsBookResponse> browseAudiobooks(libraryId, q, page)

Browse

Audiobooks of a library, by title, or matching [q].

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AudiobooksApi();
final libraryId = libraryId_example; // String | 
final q = q_example; // String | 
final page = 56; // int | 

try {
    final result = api_instance.browseAudiobooks(libraryId, q, page);
    print(result);
} catch (e) {
    print('Exception when calling AudiobooksApi->browseAudiobooks: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **libraryId** | **String**|  | 
 **q** | **String**|  | [optional] 
 **page** | **int**|  | [optional] [default to 0]

### Return type

[**List<AbsBookResponse>**](AbsBookResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAudioCover**
> getAudioCover(key)

Cover

An audiobook's cover, kept by Babel when it was added.

### Example
```dart
import 'package:babel_api_client/api.dart';

final api_instance = AudiobooksApi();
final key = key_example; // String | 

try {
    api_instance.getAudioCover(key);
} catch (e) {
    print('Exception when calling AudiobooksApi->getAudioCover: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAudiobookLibraries**
> List<AbsLibraryResponse> getAudiobookLibraries()

Libraries

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AudiobooksApi();

try {
    final result = api_instance.getAudiobookLibraries();
    print(result);
} catch (e) {
    print('Exception when calling AudiobooksApi->getAudiobookLibraries: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<AbsLibraryResponse>**](AbsLibraryResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAudiobookshelf**
> AbsLinkResponse getAudiobookshelf()

Get Link

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AudiobooksApi();

try {
    final result = api_instance.getAudiobookshelf();
    print(result);
} catch (e) {
    print('Exception when calling AudiobooksApi->getAudiobookshelf: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AbsLinkResponse**](AbsLinkResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlayback**
> PlaybackResponse getPlayback(itemId)

Playback

What the player needs: tracks to stream, chapters, and Audiobookshelf's position.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AudiobooksApi();
final itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getPlayback(itemId);
    print(result);
} catch (e) {
    print('Exception when calling AudiobooksApi->getPlayback: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **String**|  | 

### Return type

[**PlaybackResponse**](PlaybackResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **linkAudiobookshelf**
> AbsLinkResponse linkAudiobookshelf(absLinkRequest)

Link

Link your Audiobookshelf with an API key, or your password used once.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AudiobooksApi();
final absLinkRequest = AbsLinkRequest(); // AbsLinkRequest | 

try {
    final result = api_instance.linkAudiobookshelf(absLinkRequest);
    print(result);
} catch (e) {
    print('Exception when calling AudiobooksApi->linkAudiobookshelf: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **absLinkRequest** | [**AbsLinkRequest**](AbsLinkRequest.md)|  | 

### Return type

[**AbsLinkResponse**](AbsLinkResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **saveAudioProgress**
> saveAudioProgress(itemId, audioProgressRequest)

Save Progress

Keep Audiobookshelf's own progress in step (its other apps resume there).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AudiobooksApi();
final itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final audioProgressRequest = AudioProgressRequest(); // AudioProgressRequest | 

try {
    api_instance.saveAudioProgress(itemId, audioProgressRequest);
} catch (e) {
    print('Exception when calling AudiobooksApi->saveAudioProgress: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **String**|  | 
 **audioProgressRequest** | [**AudioProgressRequest**](AudioProgressRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **streamAudioTrack**
> streamAudioTrack(itemId, index, range)

Stream

One audio track, streamed from Audiobookshelf (byte ranges supported).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AudiobooksApi();
final itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final index = 56; // int | 
final range = range_example; // String | 

try {
    api_instance.streamAudioTrack(itemId, index, range);
} catch (e) {
    print('Exception when calling AudiobooksApi->streamAudioTrack: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **String**|  | 
 **index** | **int**|  | 
 **range** | **String**|  | [optional] 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unlinkAudiobookshelf**
> unlinkAudiobookshelf()

Unlink

Forget the linked Audiobookshelf; audiobooks already added keep their data.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AudiobooksApi();

try {
    api_instance.unlinkAudiobookshelf();
} catch (e) {
    print('Exception when calling AudiobooksApi->unlinkAudiobookshelf: $e\n');
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

