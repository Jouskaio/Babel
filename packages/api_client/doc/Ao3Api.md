# babel_api_client.api.Ao3Api

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**searchAo3**](Ao3Api.md#searchao3) | **GET** /v1/ao3/search | Search Ao3


# **searchAo3**
> Ao3SearchResponse searchAo3(tags, anyTag, text, fandom, language, complete, minWords, minKudos, minHits, updatedWithin, sort, descending, page)

Search Ao3

Works of AO3 matching tags (all of them, or any), text, fandom and numbers, with AO3's own sorting and pages. AO3 is only asked when you search.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = Ao3Api();
final tags = []; // List<String> | 
final anyTag = true; // bool | 
final text = text_example; // String | 
final fandom = fandom_example; // String | 
final language = language_example; // String | 
final complete = true; // bool | 
final minWords = 56; // int | 
final minKudos = 56; // int | 
final minHits = 56; // int | 
final updatedWithin = updatedWithin_example; // String | 
final sort = sort_example; // String | 
final descending = true; // bool | 
final page = 56; // int | 

try {
    final result = api_instance.searchAo3(tags, anyTag, text, fandom, language, complete, minWords, minKudos, minHits, updatedWithin, sort, descending, page);
    print(result);
} catch (e) {
    print('Exception when calling Ao3Api->searchAo3: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tags** | [**List<String>**](String.md)|  | [optional] [default to const []]
 **anyTag** | **bool**|  | [optional] [default to false]
 **text** | **String**|  | [optional] [default to '']
 **fandom** | **String**|  | [optional] [default to '']
 **language** | **String**|  | [optional] [default to '']
 **complete** | **bool**|  | [optional] 
 **minWords** | **int**|  | [optional] 
 **minKudos** | **int**|  | [optional] 
 **minHits** | **int**|  | [optional] 
 **updatedWithin** | **String**|  | [optional] [default to '']
 **sort** | **String**|  | [optional] [default to 'best']
 **descending** | **bool**|  | [optional] [default to true]
 **page** | **int**|  | [optional] [default to 1]

### Return type

[**Ao3SearchResponse**](Ao3SearchResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

