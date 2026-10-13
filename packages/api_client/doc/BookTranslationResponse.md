# babel_api_client.model.BookTranslationResponse

## Load the model package
```dart
import 'package:babel_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**createdAt** | [**DateTime**](DateTime.md) |  | 
**error** | **String** |  | [optional] 
**id** | **String** |  | 
**itemId** | **String** | The book being translated | 
**progress** | **num** | 0 to 100 | 
**resultItemId** | **String** | The translated book, once done | [optional] 
**status** | **String** | queued, running, done or failed | 
**target** | **String** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


