# babel_api_client.model.KoreaderStatusResponse

## Load the model package
```dart
import 'package:babel_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**devices** | [**List<KoreaderDeviceResponse>**](KoreaderDeviceResponse.md) |  | [default to const []]
**ereaderBooks** | **int** | Library books marked \"on my e-reader\" | 
**lastSeenAt** | [**DateTime**](DateTime.md) | The last time KOReader called Babel; null if it never did | [optional] 
**lastUnmatchedAt** | [**DateTime**](DateTime.md) | The last time KOReader asked for a book that is not in your library | [optional] 
**recent** | [**List<KoreaderBookResponse>**](KoreaderBookResponse.md) | The books it synced last | [default to const []]
**statsAt** | [**DateTime**](DateTime.md) | When KOReader's statistics last came | [optional] 
**statsBooks** | **int** | Books they cover | 
**statsSeconds** | **int** | Reading time they add up to | 
**unknownBooks** | **int** | Books KOReader sent a position for that are not in your library | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


