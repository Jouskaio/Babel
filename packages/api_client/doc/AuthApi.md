# babel_api_client.api.AuthApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getAuthProviders**](AuthApi.md#getauthproviders) | **GET** /v1/auth/providers | Get Providers
[**login**](AuthApi.md#login) | **POST** /v1/auth/login | Login
[**loginWithApple**](AuthApi.md#loginwithapple) | **POST** /v1/auth/apple | Login With Apple
[**loginWithGoogle**](AuthApi.md#loginwithgoogle) | **POST** /v1/auth/google | Login With Google
[**logout**](AuthApi.md#logout) | **POST** /v1/auth/logout | Logout
[**refreshSession**](AuthApi.md#refreshsession) | **POST** /v1/auth/refresh | Refresh
[**register**](AuthApi.md#register) | **POST** /v1/auth/register | Register


# **getAuthProviders**
> ProvidersResponse getAuthProviders()

Get Providers

List the sign-in methods enabled on this server.

### Example
```dart
import 'package:babel_api_client/api.dart';

final api_instance = AuthApi();

try {
    final result = api_instance.getAuthProviders();
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->getAuthProviders: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ProvidersResponse**](ProvidersResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **login**
> TokenResponse login(loginRequest, xBabelClient)

Login

Sign in with email and password.

### Example
```dart
import 'package:babel_api_client/api.dart';

final api_instance = AuthApi();
final loginRequest = LoginRequest(); // LoginRequest | 
final xBabelClient = xBabelClient_example; // String | 

try {
    final result = api_instance.login(loginRequest, xBabelClient);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->login: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginRequest** | [**LoginRequest**](LoginRequest.md)|  | 
 **xBabelClient** | **String**|  | [optional] 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **loginWithApple**
> TokenResponse loginWithApple(providerLoginRequest, xBabelClient)

Login With Apple

Sign in (or sign up) with an Apple ID token.

### Example
```dart
import 'package:babel_api_client/api.dart';

final api_instance = AuthApi();
final providerLoginRequest = ProviderLoginRequest(); // ProviderLoginRequest | 
final xBabelClient = xBabelClient_example; // String | 

try {
    final result = api_instance.loginWithApple(providerLoginRequest, xBabelClient);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->loginWithApple: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **providerLoginRequest** | [**ProviderLoginRequest**](ProviderLoginRequest.md)|  | 
 **xBabelClient** | **String**|  | [optional] 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **loginWithGoogle**
> TokenResponse loginWithGoogle(providerLoginRequest, xBabelClient)

Login With Google

Sign in (or sign up) with a Google ID token.

### Example
```dart
import 'package:babel_api_client/api.dart';

final api_instance = AuthApi();
final providerLoginRequest = ProviderLoginRequest(); // ProviderLoginRequest | 
final xBabelClient = xBabelClient_example; // String | 

try {
    final result = api_instance.loginWithGoogle(providerLoginRequest, xBabelClient);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->loginWithGoogle: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **providerLoginRequest** | [**ProviderLoginRequest**](ProviderLoginRequest.md)|  | 
 **xBabelClient** | **String**|  | [optional] 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logout**
> logout(xBabelClient, babelRefresh, refreshRequest)

Logout

Sign out: the refresh token, and every token derived from it, is revoked.

### Example
```dart
import 'package:babel_api_client/api.dart';

final api_instance = AuthApi();
final xBabelClient = xBabelClient_example; // String | 
final babelRefresh = babelRefresh_example; // String | 
final refreshRequest = RefreshRequest(); // RefreshRequest | 

try {
    api_instance.logout(xBabelClient, babelRefresh, refreshRequest);
} catch (e) {
    print('Exception when calling AuthApi->logout: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xBabelClient** | **String**|  | [optional] 
 **babelRefresh** | **String**|  | [optional] 
 **refreshRequest** | [**RefreshRequest**](RefreshRequest.md)|  | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshSession**
> TokenResponse refreshSession(xBabelClient, babelRefresh, refreshRequest)

Refresh

Exchange a refresh token for new tokens. The old refresh token stops working.

### Example
```dart
import 'package:babel_api_client/api.dart';

final api_instance = AuthApi();
final xBabelClient = xBabelClient_example; // String | 
final babelRefresh = babelRefresh_example; // String | 
final refreshRequest = RefreshRequest(); // RefreshRequest | 

try {
    final result = api_instance.refreshSession(xBabelClient, babelRefresh, refreshRequest);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->refreshSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xBabelClient** | **String**|  | [optional] 
 **babelRefresh** | **String**|  | [optional] 
 **refreshRequest** | [**RefreshRequest**](RefreshRequest.md)|  | [optional] 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **register**
> TokenResponse register(registerRequest, xBabelClient)

Register

Create an account with email and password, and sign in.

### Example
```dart
import 'package:babel_api_client/api.dart';

final api_instance = AuthApi();
final registerRequest = RegisterRequest(); // RegisterRequest | 
final xBabelClient = xBabelClient_example; // String | 

try {
    final result = api_instance.register(registerRequest, xBabelClient);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->register: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerRequest** | [**RegisterRequest**](RegisterRequest.md)|  | 
 **xBabelClient** | **String**|  | [optional] 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

