# babel_api_client.model.YearStatsResponse

## Load the model package
```dart
import 'package:babel_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**abandoned** | **int** |  | 
**averageRating** | **num** |  | [optional] 
**bestMonth** | **int** | 1 to 12, the month with most books finished | [optional] 
**busiestDay** | [**DateTime**](DateTime.md) |  | [optional] 
**byMonth** | **List<int>** | Books finished each month, January first | [default to const []]
**currentStreak** | **int** | Run of reading days ending today or yesterday | 
**finished** | [**List<FinishedBookResponse>**](FinishedBookResponse.md) | Books finished, in order | [default to const []]
**formats** | **Map<String, int>** |  | [default to const {}]
**longestStreak** | **int** | Longest run of consecutive reading days | 
**notes** | **int** | Highlights and notes made this year | 
**readingDays** | **int** | Days with some reading | 
**reviews** | **int** |  | 
**started** | **int** |  | 
**topAuthors** | [**List<AuthorCountResponse>**](AuthorCountResponse.md) |  | [default to const []]
**year** | **int** |  | 
**years** | **List<int>** | Years with something to show, latest first | [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


