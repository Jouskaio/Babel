# babel_api_client.api.AdminApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getAdminOverview**](AdminApi.md#getadminoverview) | **GET** /v1/admin/overview | Overview
[**listMembers**](AdminApi.md#listmembers) | **GET** /v1/admin/users | List Members
[**listReports**](AdminApi.md#listreports) | **GET** /v1/admin/reports | List Reports
[**resolveReport**](AdminApi.md#resolvereport) | **POST** /v1/admin/reports/{report_id}/resolve | Resolve Report
[**setConnectorEnabled**](AdminApi.md#setconnectorenabled) | **PUT** /v1/admin/connectors/{kind} | Set Connector
[**setPremium**](AdminApi.md#setpremium) | **PUT** /v1/admin/users/{member_id}/premium | Set Premium
[**setSourceQuota**](AdminApi.md#setsourcequota) | **PUT** /v1/admin/users/{member_id}/quota | Set Quota
[**withdrawFile**](AdminApi.md#withdrawfile) | **POST** /v1/admin/files/{sha256}/withdraw | Withdraw File


# **getAdminOverview**
> AdminOverview getAdminOverview()

Overview

Connectors on or off, and how every account's sources last scanned.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();

try {
    final result = api_instance.getAdminOverview();
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->getAdminOverview: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AdminOverview**](AdminOverview.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMembers**
> List<MemberResponse> listMembers()

List Members

Every account, with its roles and Kavita account.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();

try {
    final result = api_instance.listMembers();
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->listMembers: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<MemberResponse>**](MemberResponse.md)

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

final api_instance = AdminApi();

try {
    final result = api_instance.listReports();
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->listReports: $e\n');
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

final api_instance = AdminApi();
final reportId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.resolveReport(reportId);
} catch (e) {
    print('Exception when calling AdminApi->resolveReport: $e\n');
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

# **setConnectorEnabled**
> setConnectorEnabled(kind, connectorRequest)

Set Connector

Switch a kind of source on or off for everyone; sources already added stay.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final kind = ; // SourceKind | 
final connectorRequest = ConnectorRequest(); // ConnectorRequest | 

try {
    api_instance.setConnectorEnabled(kind, connectorRequest);
} catch (e) {
    print('Exception when calling AdminApi->setConnectorEnabled: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **kind** | [**SourceKind**](.md)|  | 
 **connectorRequest** | [**ConnectorRequest**](ConnectorRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setPremium**
> MemberResponse setPremium(memberId, premiumRequest)

Set Premium

Make an account premium (it gets an account on Babel's Kavita), or not any more.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final memberId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final premiumRequest = PremiumRequest(); // PremiumRequest | 

try {
    final result = api_instance.setPremium(memberId, premiumRequest);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->setPremium: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **memberId** | **String**|  | 
 **premiumRequest** | [**PremiumRequest**](PremiumRequest.md)|  | 

### Return type

[**MemberResponse**](MemberResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setSourceQuota**
> setSourceQuota(memberId, quotaRequest)

Set Quota

Limit how many sources one account may connect.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final memberId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final quotaRequest = QuotaRequest(); // QuotaRequest | 

try {
    api_instance.setSourceQuota(memberId, quotaRequest);
} catch (e) {
    print('Exception when calling AdminApi->setSourceQuota: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **memberId** | **String**|  | 
 **quotaRequest** | [**QuotaRequest**](QuotaRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
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

final api_instance = AdminApi();
final sha256 = sha256_example; // String | 
final withdrawRequest = WithdrawRequest(); // WithdrawRequest | 

try {
    api_instance.withdrawFile(sha256, withdrawRequest);
} catch (e) {
    print('Exception when calling AdminApi->withdrawFile: $e\n');
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

