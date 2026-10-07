# babel_api_client.model.LibraryItemResponse

## Load the model package
```dart
import 'package:babel_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**addedAt** | [**DateTime**](DateTime.md) |  | 
**audioDuration** | **num** | An audiobook from the reader's Audiobookshelf: its length in seconds | [optional] 
**authors** | **List<String>** |  | [default to const []]
**coverId** | **int** | The catalog cover the reader chose, if any | [optional] 
**coverPath** | **String** | Cover found in the file, relative to the API base URL (may answer 404) | [optional] 
**editionId** | **String** |  | [optional] 
**finishedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**format** | [**BookFormat**](BookFormat.md) |  | [optional] 
**hidden** | **bool** | Out of sight in the library, never shared | [optional] [default to false]
**id** | **String** |  | 
**paper** | **bool** | Owned on paper (it may have a file too) | [optional] [default to false]
**progress** | **num** | Progress declared by hand, in percent (not a device position) | [optional] 
**series** | **String** | The series it belongs to | [optional] 
**seriesIndex** | **num** | Its volume number in it | [optional] 
**sha256** | **String** | Identifies the file; download it from /v1/files/{sha256}. Null for a paper book without a file | [optional] 
**size** | **int** |  | [optional] 
**startedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**stateTime** | [**DateTime**](DateTime.md) | When status or progress last changed (device clock) | [optional] 
**status** | [**ReadingStatus**](ReadingStatus.md) |  | [optional] 
**title** | **String** |  | 
**workId** | **String** | The catalog work: reviews and notes are shared per work | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


