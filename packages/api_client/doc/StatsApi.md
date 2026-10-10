# babel_api_client.api.StatsApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getProgression**](StatsApi.md#getprogression) | **GET** /v1/me/progression | Get Progression
[**getYearStats**](StatsApi.md#getyearstats) | **GET** /v1/me/stats | Get Year Stats
[**setReadingGoal**](StatsApi.md#setreadinggoal) | **PUT** /v1/me/goal | Set Goal


# **getProgression**
> ProgressionResponse getProgression()

Get Progression

Your level, badges and first steps, computed from what you did.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StatsApi();

try {
    final result = api_instance.getProgression();
    print(result);
} catch (e) {
    print('Exception when calling StatsApi->getProgression: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ProgressionResponse**](ProgressionResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getYearStats**
> YearStatsResponse getYearStats(year, tzOffset)

Get Year Stats

What you read in a year: books finished, reading days, streaks, notes, authors.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StatsApi();
final year = 56; // int | 
final tzOffset = 56; // int | Minutes east of UTC, so days are yours

try {
    final result = api_instance.getYearStats(year, tzOffset);
    print(result);
} catch (e) {
    print('Exception when calling StatsApi->getYearStats: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **year** | **int**|  | [optional] 
 **tzOffset** | **int**| Minutes east of UTC, so days are yours | [optional] [default to 0]

### Return type

[**YearStatsResponse**](YearStatsResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setReadingGoal**
> setReadingGoal(goalRequest)

Set Goal

Set (or remove) your yearly reading goal.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StatsApi();
final goalRequest = GoalRequest(); // GoalRequest | 

try {
    api_instance.setReadingGoal(goalRequest);
} catch (e) {
    print('Exception when calling StatsApi->setReadingGoal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalRequest** | [**GoalRequest**](GoalRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

