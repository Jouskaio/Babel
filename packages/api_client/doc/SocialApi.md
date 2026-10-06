# babel_api_client.api.SocialApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addFriend**](SocialApi.md#addfriend) | **PUT** /v1/social/friends/{handle} | Add Friend
[**blockReader**](SocialApi.md#blockreader) | **PUT** /v1/social/blocks/{handle} | Block Reader
[**deleteReview**](SocialApi.md#deletereview) | **DELETE** /v1/library/{item_id}/review | Delete Review
[**followReader**](SocialApi.md#followreader) | **PUT** /v1/social/following/{handle} | Follow Reader
[**getBlocked**](SocialApi.md#getblocked) | **GET** /v1/social/blocks | Get Blocked
[**getFeed**](SocialApi.md#getfeed) | **GET** /v1/social/feed | Get Feed
[**getFriends**](SocialApi.md#getfriends) | **GET** /v1/social/friends | Get Friends
[**getLibraryHistory**](SocialApi.md#getlibraryhistory) | **GET** /v1/library/history | Get History
[**getReader**](SocialApi.md#getreader) | **GET** /v1/social/readers/{handle} | Get Reader
[**getRecommendations**](SocialApi.md#getrecommendations) | **GET** /v1/social/recommendations | Get Recommendations
[**getReview**](SocialApi.md#getreview) | **GET** /v1/library/{item_id}/review | Get Review
[**getSocialProfile**](SocialApi.md#getsocialprofile) | **GET** /v1/me/profile | Get Profile
[**listReports**](SocialApi.md#listreports) | **GET** /v1/admin/reports | List Reports
[**markRecommendationRead**](SocialApi.md#markrecommendationread) | **POST** /v1/social/recommendations/{recommendation_id}/read | Mark Read
[**recommend**](SocialApi.md#recommend) | **POST** /v1/social/recommendations | Recommend
[**removeFriend**](SocialApi.md#removefriend) | **DELETE** /v1/social/friends/{handle} | Remove Friend
[**reportReader**](SocialApi.md#reportreader) | **POST** /v1/social/reports | Report Reader
[**resolveReport**](SocialApi.md#resolvereport) | **POST** /v1/admin/reports/{report_id}/resolve | Resolve Report
[**saveReview**](SocialApi.md#savereview) | **PUT** /v1/library/{item_id}/review | Save Review
[**searchReaders**](SocialApi.md#searchreaders) | **GET** /v1/social/readers | Search Readers
[**unblockReader**](SocialApi.md#unblockreader) | **DELETE** /v1/social/blocks/{handle} | Unblock Reader
[**unfollowReader**](SocialApi.md#unfollowreader) | **DELETE** /v1/social/following/{handle} | Unfollow Reader
[**updateSocialProfile**](SocialApi.md#updatesocialprofile) | **PATCH** /v1/me/profile | Update Profile


# **addFriend**
> ReaderResponse addFriend(handle)

Add Friend

Send a friend request, or accept the one this reader sent you.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();
final handle = handle_example; // String | 

try {
    final result = api_instance.addFriend(handle);
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->addFriend: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **handle** | **String**|  | 

### Return type

[**ReaderResponse**](ReaderResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **blockReader**
> blockReader(handle)

Block Reader

Block a reader: friendship and follows end both ways; neither sees the other.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();
final handle = handle_example; // String | 

try {
    api_instance.blockReader(handle);
} catch (e) {
    print('Exception when calling SocialApi->blockReader: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **handle** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

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

final api_instance = SocialApi();
final itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.deleteReview(itemId);
} catch (e) {
    print('Exception when calling SocialApi->deleteReview: $e\n');
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

# **followReader**
> ReaderResponse followReader(handle)

Follow Reader

Follow a reader's public activity (no request needed).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();
final handle = handle_example; // String | 

try {
    final result = api_instance.followReader(handle);
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->followReader: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **handle** | **String**|  | 

### Return type

[**ReaderResponse**](ReaderResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBlocked**
> List<AuthorResponse> getBlocked()

Get Blocked

Readers you blocked.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();

try {
    final result = api_instance.getBlocked();
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->getBlocked: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<AuthorResponse>**](AuthorResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFeed**
> List<FeedEntryResponse> getFeed()

Get Feed

What friends and followed readers shared lately, newest first.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();

try {
    final result = api_instance.getFeed();
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->getFeed: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<FeedEntryResponse>**](FeedEntryResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFriends**
> FriendsResponse getFriends()

Get Friends

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();

try {
    final result = api_instance.getFriends();
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->getFriends: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**FriendsResponse**](FriendsResponse.md)

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

final api_instance = SocialApi();

try {
    final result = api_instance.getLibraryHistory();
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->getLibraryHistory: $e\n');
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

# **getReader**
> ReaderPageResponse getReader(handle)

Get Reader

A reader's page: only what they share with you.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();
final handle = handle_example; // String | 

try {
    final result = api_instance.getReader(handle);
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->getReader: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **handle** | **String**|  | 

### Return type

[**ReaderPageResponse**](ReaderPageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRecommendations**
> List<RecommendationResponse> getRecommendations()

Get Recommendations

Books your friends recommended to you, newest first.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();

try {
    final result = api_instance.getRecommendations();
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->getRecommendations: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<RecommendationResponse>**](RecommendationResponse.md)

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

final api_instance = SocialApi();
final itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getReview(itemId);
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->getReview: $e\n');
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

# **getSocialProfile**
> SocialProfileResponse getSocialProfile()

Get Profile

Your handle and what you share.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();

try {
    final result = api_instance.getSocialProfile();
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->getSocialProfile: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SocialProfileResponse**](SocialProfileResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listReports**
> List<ReportResponse> listReports()

List Reports

Reports, unresolved first.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();

try {
    final result = api_instance.listReports();
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->listReports: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<ReportResponse>**](ReportResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markRecommendationRead**
> markRecommendationRead(recommendationId)

Mark Read

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();
final recommendationId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.markRecommendationRead(recommendationId);
} catch (e) {
    print('Exception when calling SocialApi->markRecommendationRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **recommendationId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recommend**
> RecommendationResponse recommend(recommendRequest)

Recommend

Recommend a book of your library, or a title or link, to a friend.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();
final recommendRequest = RecommendRequest(); // RecommendRequest | 

try {
    final result = api_instance.recommend(recommendRequest);
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->recommend: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **recommendRequest** | [**RecommendRequest**](RecommendRequest.md)|  | 

### Return type

[**RecommendationResponse**](RecommendationResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeFriend**
> ReaderResponse removeFriend(handle)

Remove Friend

Cancel or decline a request, or end a friendship.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();
final handle = handle_example; // String | 

try {
    final result = api_instance.removeFriend(handle);
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->removeFriend: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **handle** | **String**|  | 

### Return type

[**ReaderResponse**](ReaderResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reportReader**
> reportReader(reportRequest)

Report Reader

Report a reader to the administrators (the reader is not told).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();
final reportRequest = ReportRequest(); // ReportRequest | 

try {
    api_instance.reportReader(reportRequest);
} catch (e) {
    print('Exception when calling SocialApi->reportReader: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reportRequest** | [**ReportRequest**](ReportRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resolveReport**
> resolveReport(reportId)

Resolve Report

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();
final reportId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.resolveReport(reportId);
} catch (e) {
    print('Exception when calling SocialApi->resolveReport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reportId** | **String**|  | 

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

final api_instance = SocialApi();
final itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final reviewRequest = ReviewRequest(); // ReviewRequest | 

try {
    final result = api_instance.saveReview(itemId, reviewRequest);
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->saveReview: $e\n');
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

# **searchReaders**
> List<ReaderResponse> searchReaders(q)

Search Readers

Readers whose handle starts with ``q``.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();
final q = q_example; // String | 

try {
    final result = api_instance.searchReaders(q);
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->searchReaders: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | 

### Return type

[**List<ReaderResponse>**](ReaderResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unblockReader**
> unblockReader(handle)

Unblock Reader

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();
final handle = handle_example; // String | 

try {
    api_instance.unblockReader(handle);
} catch (e) {
    print('Exception when calling SocialApi->unblockReader: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **handle** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unfollowReader**
> ReaderResponse unfollowReader(handle)

Unfollow Reader

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();
final handle = handle_example; // String | 

try {
    final result = api_instance.unfollowReader(handle);
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->unfollowReader: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **handle** | **String**|  | 

### Return type

[**ReaderResponse**](ReaderResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateSocialProfile**
> SocialProfileResponse updateSocialProfile(updateSocialProfileRequest)

Update Profile

Choose a handle (3 to 30 letters, digits, dots, underscores) and what you share.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SocialApi();
final updateSocialProfileRequest = UpdateSocialProfileRequest(); // UpdateSocialProfileRequest | 

try {
    final result = api_instance.updateSocialProfile(updateSocialProfileRequest);
    print(result);
} catch (e) {
    print('Exception when calling SocialApi->updateSocialProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateSocialProfileRequest** | [**UpdateSocialProfileRequest**](UpdateSocialProfileRequest.md)|  | 

### Return type

[**SocialProfileResponse**](SocialProfileResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

