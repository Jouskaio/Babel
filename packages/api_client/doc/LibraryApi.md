# babel_api_client.api.LibraryApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addStoredFile**](LibraryApi.md#addstoredfile) | **POST** /v1/library/files/{sha256} | Add Stored File
[**checkFollow**](LibraryApi.md#checkfollow) | **POST** /v1/library/follows/{follow_id}/check | Check Follow
[**deleteReview**](LibraryApi.md#deletereview) | **DELETE** /v1/library/{item_id}/review | Delete Review
[**downloadFile**](LibraryApi.md#downloadfile) | **GET** /v1/files/{sha256} | Download File
[**downloadFileAsCbz**](LibraryApi.md#downloadfileascbz) | **GET** /v1/files/{sha256}/cbz | Download As Cbz
[**getFileCover**](LibraryApi.md#getfilecover) | **GET** /v1/files/{sha256}/cover | Get File Cover
[**getFollows**](LibraryApi.md#getfollows) | **GET** /v1/library/follows | Get Follows
[**getLibrary**](LibraryApi.md#getlibrary) | **GET** /v1/library | Get Library
[**getLibraryHistory**](LibraryApi.md#getlibraryhistory) | **GET** /v1/library/history | Get History
[**getReadingPositions**](LibraryApi.md#getreadingpositions) | **GET** /v1/library/{item_id}/positions | Get Positions
[**getReview**](LibraryApi.md#getreview) | **GET** /v1/library/{item_id}/review | Get Review
[**importFile**](LibraryApi.md#importfile) | **POST** /v1/library/files | Import File
[**importLink**](LibraryApi.md#importlink) | **POST** /v1/library/links | Import Link
[**previewLink**](LibraryApi.md#previewlink) | **POST** /v1/library/links/preview | Preview Link
[**removeFromLibrary**](LibraryApi.md#removefromlibrary) | **DELETE** /v1/library/{item_id} | Remove From Library
[**saveReview**](LibraryApi.md#savereview) | **PUT** /v1/library/{item_id}/review | Save Review
[**stopFollow**](LibraryApi.md#stopfollow) | **DELETE** /v1/library/follows/{follow_id} | Stop Follow
[**withdrawFile**](LibraryApi.md#withdrawfile) | **POST** /v1/admin/files/{sha256}/withdraw | Withdraw File


# **addStoredFile**
> LibraryItemResponse addStoredFile(sha256, xBabelDevice)

Add Stored File

Add a file already on Babel to the library, without uploading it again.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();
final sha256 = sha256_example; // String | 
final xBabelDevice = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.addStoredFile(sha256, xBabelDevice);
    print(result);
} catch (e) {
    print('Exception when calling LibraryApi->addStoredFile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sha256** | **String**|  | 
 **xBabelDevice** | **String**|  | [optional] 

### Return type

[**LibraryItemResponse**](LibraryItemResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **checkFollow**
> FollowResponse checkFollow(followId)

Check Follow

Look for new chapters now; a new version replaces the book's file.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();
final followId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.checkFollow(followId);
    print(result);
} catch (e) {
    print('Exception when calling LibraryApi->checkFollow: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **followId** | **String**|  | 

### Return type

[**FollowResponse**](FollowResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteReview**
> deleteReview(itemId)

Delete Review

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();
final itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.deleteReview(itemId);
} catch (e) {
    print('Exception when calling LibraryApi->deleteReview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **downloadFile**
> downloadFile(sha256)

Download File

Download a stored file. Supports HTTP range requests to resume downloads.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();
final sha256 = sha256_example; // String | 

try {
    api_instance.downloadFile(sha256);
} catch (e) {
    print('Exception when calling LibraryApi->downloadFile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sha256** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/octet-stream

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **downloadFileAsCbz**
> downloadFileAsCbz(sha256)

Download As Cbz

A comic as CBZ: CBR (RAR) files are converted once, for readers that only open ZIP.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();
final sha256 = sha256_example; // String | 

try {
    api_instance.downloadFileAsCbz(sha256);
} catch (e) {
    print('Exception when calling LibraryApi->downloadFileAsCbz: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sha256** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/vnd.comicbook+zip

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFileCover**
> getFileCover(sha256)

Get File Cover

The cover found in a stored file (EPUB, CBZ). Public, like catalog covers.

### Example
```dart
import 'package:babel_api_client/api.dart';

final api_instance = LibraryApi();
final sha256 = sha256_example; // String | 

try {
    api_instance.getFileCover(sha256);
} catch (e) {
    print('Exception when calling LibraryApi->getFileCover: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sha256** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: image/*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFollows**
> List<FollowResponse> getFollows()

Get Follows

Unfinished AO3 works imported by link, checked daily for new chapters.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();

try {
    final result = api_instance.getFollows();
    print(result);
} catch (e) {
    print('Exception when calling LibraryApi->getFollows: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<FollowResponse>**](FollowResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLibrary**
> List<LibraryItemResponse> getLibrary()

Get Library

The books of the signed-in reader, most recent first.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();

try {
    final result = api_instance.getLibrary();
    print(result);
} catch (e) {
    print('Exception when calling LibraryApi->getLibrary: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<LibraryItemResponse>**](LibraryItemResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLibraryHistory**
> List<BookTraceResponse> getLibraryHistory()

Get History

Every book the reader has or once had, removed ones included, latest first.  Removing a book or losing its file never erases the reader's status, review, notes and positions; adding the same file again brings the book back with them.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();

try {
    final result = api_instance.getLibraryHistory();
    print(result);
} catch (e) {
    print('Exception when calling LibraryApi->getLibraryHistory: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<BookTraceResponse>**](BookTraceResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getReadingPositions**
> List<ReadingPositionResponse> getReadingPositions(itemId)

Get Positions

Where each device stopped in this book, most recent first.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();
final itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getReadingPositions(itemId);
    print(result);
} catch (e) {
    print('Exception when calling LibraryApi->getReadingPositions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **String**|  | 

### Return type

[**List<ReadingPositionResponse>**](ReadingPositionResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getReview**
> ReviewResponse getReview(itemId)

Get Review

Your review of this book, if any.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();
final itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getReview(itemId);
    print(result);
} catch (e) {
    print('Exception when calling LibraryApi->getReview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **String**|  | 

### Return type

[**ReviewResponse**](ReviewResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **importFile**
> ImportResponse importFile(file, xBabelDevice)

Import File

Import an EPUB, PDF, CBZ or CBR file into the library.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();
final file = BINARY_DATA_HERE; // MultipartFile | 
final xBabelDevice = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.importFile(file, xBabelDevice);
    print(result);
} catch (e) {
    print('Exception when calling LibraryApi->importFile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **MultipartFile**|  | 
 **xBabelDevice** | **String**|  | [optional] 

### Return type

[**ImportResponse**](ImportResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **importLink**
> LibraryItemResponse importLink(linkRequest, xBabelDevice)

Import Link

Import the book a link points to (AO3 works are fetched at AO3's pace).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();
final linkRequest = LinkRequest(); // LinkRequest | 
final xBabelDevice = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.importLink(linkRequest, xBabelDevice);
    print(result);
} catch (e) {
    print('Exception when calling LibraryApi->importLink: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **linkRequest** | [**LinkRequest**](LinkRequest.md)|  | 
 **xBabelDevice** | **String**|  | [optional] 

### Return type

[**LibraryItemResponse**](LibraryItemResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **previewLink**
> LinkPreviewResponse previewLink(linkRequest)

Preview Link

What a pasted link points to: an AO3 work, a Gutenberg book or a file.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();
final linkRequest = LinkRequest(); // LinkRequest | 

try {
    final result = api_instance.previewLink(linkRequest);
    print(result);
} catch (e) {
    print('Exception when calling LibraryApi->previewLink: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **linkRequest** | [**LinkRequest**](LinkRequest.md)|  | 

### Return type

[**LinkPreviewResponse**](LinkPreviewResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeFromLibrary**
> removeFromLibrary(itemId, xBabelDevice)

Remove From Library

Remove a book from the library.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();
final itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final xBabelDevice = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.removeFromLibrary(itemId, xBabelDevice);
} catch (e) {
    print('Exception when calling LibraryApi->removeFromLibrary: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **String**|  | 
 **xBabelDevice** | **String**|  | [optional] 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **saveReview**
> ReviewResponse saveReview(itemId, reviewRequest)

Save Review

Rate and review a book of your library, and choose who sees it.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();
final itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final reviewRequest = ReviewRequest(); // ReviewRequest | 

try {
    final result = api_instance.saveReview(itemId, reviewRequest);
    print(result);
} catch (e) {
    print('Exception when calling LibraryApi->saveReview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **String**|  | 
 **reviewRequest** | [**ReviewRequest**](ReviewRequest.md)|  | 

### Return type

[**ReviewResponse**](ReviewResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stopFollow**
> stopFollow(followId)

Stop Follow

Stop checking this book for new chapters (the book stays).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();
final followId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.stopFollow(followId);
} catch (e) {
    print('Exception when calling LibraryApi->stopFollow: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **followId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **withdrawFile**
> withdrawFile(sha256, withdrawRequest)

Withdraw File

Withdraw a file from every library and delete it; by default its hash is blocked.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LibraryApi();
final sha256 = sha256_example; // String | 
final withdrawRequest = WithdrawRequest(); // WithdrawRequest | 

try {
    api_instance.withdrawFile(sha256, withdrawRequest);
} catch (e) {
    print('Exception when calling LibraryApi->withdrawFile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sha256** | **String**|  | 
 **withdrawRequest** | [**WithdrawRequest**](WithdrawRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

