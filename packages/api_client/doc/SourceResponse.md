# babel_api_client.model.SourceResponse

## Load the model package
```dart
import 'package:babel_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**bookCount** | **int** | Book files found by the last scan | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**folder** | **String** |  | [optional] 
**hasToken** | **bool** |  | 
**id** | **String** |  | 
**kind** | [**SourceKind**](SourceKind.md) |  | 
**lastAdded** | **int** | Books the last scan found that are new | [optional] [default to 0]
**lastError** | **String** |  | [optional] 
**lastRemoved** | **int** | Books the last scan found gone | [optional] [default to 0]
**lastScanAt** | [**DateTime**](DateTime.md) |  | [optional] 
**location** | **String** | Repository, address or account, for display | 
**name** | **String** |  | 
**repository** | **String** |  | [optional] 
**scanning** | **bool** | A scan is under way in the background: ask again shortly | [optional] [default to false]
**username** | **String** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


