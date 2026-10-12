# babel_api_client.api.TranslateApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**translateText**](TranslateApi.md#translatetext) | **POST** /v1/translate | Translate Text


# **translateText**
> TranslateResponse translateText(translateRequest)

Translate Text

The text in another language (free machine translation, a few paragraphs at most). A text already in that language comes back as it is; 503 when the service cannot translate now.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = TranslateApi();
final translateRequest = TranslateRequest(); // TranslateRequest | 

try {
    final result = api_instance.translateText(translateRequest);
    print(result);
} catch (e) {
    print('Exception when calling TranslateApi->translateText: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **translateRequest** | [**TranslateRequest**](TranslateRequest.md)|  | 

### Return type

[**TranslateResponse**](TranslateResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

