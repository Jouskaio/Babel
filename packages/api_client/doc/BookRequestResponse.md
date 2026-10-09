# babel_api_client.model.BookRequestResponse

## Load the model package
```dart
import 'package:babel_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**createdAt** | [**DateTime**](DateTime.md) |  | 
**language** | **String** | The language asked for; empty if none | [optional] [default to '']
**progress** | **num** | Percent downloaded while it runs; null before it starts | [optional] 
**status** | [**RequestStatus**](RequestStatus.md) |  | 
**via** | **String** | Where it was sent: chaptarr or shelfmark | [optional] [default to 'chaptarr']
**workId** | **String** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


