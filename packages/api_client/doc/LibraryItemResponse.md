# babel_api_client.model.LibraryItemResponse

## Load the model package
```dart
import 'package:babel_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**addedAt** | [**DateTime**](DateTime.md) |  | 
**authors** | **List<String>** |  | [default to const []]
**coverPath** | **String** | Cover found in the file, relative to the API base URL (may answer 404) | [optional] 
**editionId** | **String** |  | [optional] 
**finishedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**format** | [**BookFormat**](BookFormat.md) |  | 
**id** | **String** |  | 
**progress** | **num** | Progress declared by hand, in percent (not a device position) | [optional] 
**sha256** | **String** | Identifies the file; download it from /v1/files/{sha256} | 
**size** | **int** |  | 
**startedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**stateTime** | [**DateTime**](DateTime.md) | When status or progress last changed (device clock) | [optional] 
**status** | [**ReadingStatus**](ReadingStatus.md) |  | [optional] 
**title** | **String** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


