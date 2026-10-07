//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class StatsApi {
  StatsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get Year Stats
  ///
  /// What you read in a year: books finished, reading days, streaks, notes, authors.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] year:
  ///
  /// * [int] tzOffset:
  ///   Minutes east of UTC, so days are yours
  Future<Response> getYearStatsWithHttpInfo({ int? year, int? tzOffset, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/stats';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (year != null) {
      queryParams.addAll(_queryParams('', 'year', year));
    }
    if (tzOffset != null) {
      queryParams.addAll(_queryParams('', 'tz_offset', tzOffset));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get Year Stats
  ///
  /// What you read in a year: books finished, reading days, streaks, notes, authors.
  ///
  /// Parameters:
  ///
  /// * [int] year:
  ///
  /// * [int] tzOffset:
  ///   Minutes east of UTC, so days are yours
  Future<YearStatsResponse?> getYearStats({ int? year, int? tzOffset, }) async {
    final response = await getYearStatsWithHttpInfo( year: year, tzOffset: tzOffset, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'YearStatsResponse',) as YearStatsResponse;
    
    }
    return null;
  }

  /// Set Goal
  ///
  /// Set (or remove) your yearly reading goal.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [GoalRequest] goalRequest (required):
  Future<Response> setReadingGoalWithHttpInfo(GoalRequest goalRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/goal';

    // ignore: prefer_final_locals
    Object? postBody = goalRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Set Goal
  ///
  /// Set (or remove) your yearly reading goal.
  ///
  /// Parameters:
  ///
  /// * [GoalRequest] goalRequest (required):
  Future<void> setReadingGoal(GoalRequest goalRequest,) async {
    final response = await setReadingGoalWithHttpInfo(goalRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
