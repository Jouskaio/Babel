# babel_api_client.model.BookNoteResponse

## Load the model package
```dart
import 'package:babel_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**at** | [**DateTime**](DateTime.md) |  | 
**chapter** | **int** | Chapter (or page) in the edition it was written in | 
**id** | **String** |  | 
**language** | **String** | Language of the edition it was written in | [optional] 
**note** | **String** |  | [optional] 
**percent** | **num** | Where it is in its book, in percent | [optional] 
**prefix** | **String** | Words just before the quote | [optional] 
**quote** | **String** |  | 
**reader** | [**AuthorResponse**](AuthorResponse.md) |  | 
**region** | **String** |  | [optional] 
**sameFile** | **bool** | Written in this very file: chapter and quote match | 
**suffix** | **String** | Words just after the quote | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


