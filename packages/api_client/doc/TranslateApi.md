# babel_api_client.api.TranslateApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getTranslationLanguages**](TranslateApi.md#gettranslationlanguages) | **GET** /v1/translate/languages | Get Languages
[**listBookTranslations**](TranslateApi.md#listbooktranslations) | **GET** /v1/library/translations | List Translations
[**translateBook**](TranslateApi.md#translatebook) | **POST** /v1/library/{item_id}/translations | Translate Book
[**translateText**](TranslateApi.md#translatetext) | **POST** /v1/translate | Translate Text


# **getTranslationLanguages**
> LanguagesResponse getTranslationLanguages()

Get Languages

What can be translated, and into which languages.

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

try {
    final result = api_instance.getTranslationLanguages();
    print(result);
} catch (e) {
    print('Exception when calling TranslateApi->getTranslationLanguages: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**LanguagesResponse**](LanguagesResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listBookTranslations**
> List<BookTranslationResponse> listBookTranslations()

List Translations

Your book translations, newest first, with their progress.

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

try {
    final result = api_instance.listBookTranslations();
    print(result);
} catch (e) {
    print('Exception when calling TranslateApi->listBookTranslations: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<BookTranslationResponse>**](BookTranslationResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **translateBook**
> BookTranslationResponse translateBook(itemId, bookTranslationRequest)

Translate Book

Translate an EPUB of your library: the translation is made in the background and joins your library as a book of its own. 503 without a translation server.

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
final itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final bookTranslationRequest = BookTranslationRequest(); // BookTranslationRequest | 

try {
    final result = api_instance.translateBook(itemId, bookTranslationRequest);
    print(result);
} catch (e) {
    print('Exception when calling TranslateApi->translateBook: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **String**|  | 
 **bookTranslationRequest** | [**BookTranslationRequest**](BookTranslationRequest.md)|  | 

### Return type

[**BookTranslationResponse**](BookTranslationResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **translateText**
> TranslateResponse translateText(translateRequest)

Translate Text

The text in another language (a few paragraphs). A text already in that language comes back as it is; 503 when the service cannot translate now.

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

