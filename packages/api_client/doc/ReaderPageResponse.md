# babel_api_client.model.ReaderPageResponse

## Load the model package
```dart
import 'package:babel_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**books** | **int** | Null when the library is not shared with you | [optional] 
**finished** | [**List<ReadingResponse>**](ReadingResponse.md) | Books finished lately | [default to const []]
**followers** | **int** |  | 
**friends** | **int** |  | 
**library_** | [**List<BookTitleResponse>**](BookTitleResponse.md) |  | [optional] [default to const []]
**notes** | [**List<SharedNoteResponse>**](SharedNoteResponse.md) |  | [default to const []]
**reader** | [**ReaderResponse**](ReaderResponse.md) |  | 
**reading** | [**List<ReadingResponse>**](ReadingResponse.md) |  | [default to const []]
**reviews** | [**List<ReviewResponse>**](ReviewResponse.md) |  | [default to const []]
**shelves** | [**List<ShelfResponse>**](ShelfResponse.md) |  | [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


