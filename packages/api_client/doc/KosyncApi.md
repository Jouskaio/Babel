# babel_api_client.api.KosyncApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getKoreader**](KosyncApi.md#getkoreader) | **GET** /v1/me/koreader | Get Koreader
[**newKoreaderPassword**](KosyncApi.md#newkoreaderpassword) | **POST** /v1/me/koreader/password | New Koreader Password


# **getKoreader**
> KoreaderResponse getKoreader()

Get Koreader

What to type in KOReader to sync your reading with Babel.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KosyncApi();

try {
    final result = api_instance.getKoreader();
    print(result);
} catch (e) {
    print('Exception when calling KosyncApi->getKoreader: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**KoreaderResponse**](KoreaderResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **newKoreaderPassword**
> KoreaderPasswordResponse newKoreaderPassword()

New Koreader Password

Make (or replace) your KOReader password; it is shown only now.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KosyncApi();

try {
    final result = api_instance.newKoreaderPassword();
    print(result);
} catch (e) {
    print('Exception when calling KosyncApi->newKoreaderPassword: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**KoreaderPasswordResponse**](KoreaderPasswordResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

