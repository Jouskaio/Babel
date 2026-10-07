//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class SocialApi {
  SocialApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Add Friend
  ///
  /// Send a friend request, or accept the one this reader sent you.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] handle (required):
  Future<Response> addFriendWithHttpInfo(String handle,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/friends/{handle}'
      .replaceAll('{handle}', handle);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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

  /// Add Friend
  ///
  /// Send a friend request, or accept the one this reader sent you.
  ///
  /// Parameters:
  ///
  /// * [String] handle (required):
  Future<ReaderResponse?> addFriend(String handle,) async {
    final response = await addFriendWithHttpInfo(handle,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ReaderResponse',) as ReaderResponse;
    
    }
    return null;
  }

  /// Block Reader
  ///
  /// Block a reader: friendship and follows end both ways; neither sees the other.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] handle (required):
  Future<Response> blockReaderWithHttpInfo(String handle,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/blocks/{handle}'
      .replaceAll('{handle}', handle);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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

  /// Block Reader
  ///
  /// Block a reader: friendship and follows end both ways; neither sees the other.
  ///
  /// Parameters:
  ///
  /// * [String] handle (required):
  Future<void> blockReader(String handle,) async {
    final response = await blockReaderWithHttpInfo(handle,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Comment Review
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] reviewId (required):
  ///
  /// * [CommentRequest] commentRequest (required):
  Future<Response> commentReviewWithHttpInfo(String reviewId, CommentRequest commentRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/reviews/{review_id}/comments'
      .replaceAll('{review_id}', reviewId);

    // ignore: prefer_final_locals
    Object? postBody = commentRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Comment Review
  ///
  /// Parameters:
  ///
  /// * [String] reviewId (required):
  ///
  /// * [CommentRequest] commentRequest (required):
  Future<CommentResponse?> commentReview(String reviewId, CommentRequest commentRequest,) async {
    final response = await commentReviewWithHttpInfo(reviewId, commentRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CommentResponse',) as CommentResponse;
    
    }
    return null;
  }

  /// Delete Review
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  Future<Response> deleteReviewWithHttpInfo(String itemId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}/review'
      .replaceAll('{item_id}', itemId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Delete Review
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  Future<void> deleteReview(String itemId,) async {
    final response = await deleteReviewWithHttpInfo(itemId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete Review Comment
  ///
  /// Delete your comment, or any comment under your review.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] reviewId (required):
  ///
  /// * [String] commentId (required):
  Future<Response> deleteReviewCommentWithHttpInfo(String reviewId, String commentId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/reviews/{review_id}/comments/{comment_id}'
      .replaceAll('{review_id}', reviewId)
      .replaceAll('{comment_id}', commentId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Delete Review Comment
  ///
  /// Delete your comment, or any comment under your review.
  ///
  /// Parameters:
  ///
  /// * [String] reviewId (required):
  ///
  /// * [String] commentId (required):
  Future<void> deleteReviewComment(String reviewId, String commentId,) async {
    final response = await deleteReviewCommentWithHttpInfo(reviewId, commentId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Follow Reader
  ///
  /// Follow a reader's public activity (no request needed).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] handle (required):
  Future<Response> followReaderWithHttpInfo(String handle,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/following/{handle}'
      .replaceAll('{handle}', handle);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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

  /// Follow Reader
  ///
  /// Follow a reader's public activity (no request needed).
  ///
  /// Parameters:
  ///
  /// * [String] handle (required):
  Future<ReaderResponse?> followReader(String handle,) async {
    final response = await followReaderWithHttpInfo(handle,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ReaderResponse',) as ReaderResponse;
    
    }
    return null;
  }

  /// Get Blocked
  ///
  /// Readers you blocked.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getBlockedWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/blocks';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Get Blocked
  ///
  /// Readers you blocked.
  Future<List<AuthorResponse>?> getBlocked() async {
    final response = await getBlockedWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<AuthorResponse>') as List)
        .cast<AuthorResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get Feed
  ///
  /// What friends and followed readers shared lately, newest first.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getFeedWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/feed';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Get Feed
  ///
  /// What friends and followed readers shared lately, newest first.
  Future<List<FeedEntryResponse>?> getFeed() async {
    final response = await getFeedWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<FeedEntryResponse>') as List)
        .cast<FeedEntryResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get Friends
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getFriendsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/friends';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Get Friends
  Future<FriendsResponse?> getFriends() async {
    final response = await getFriendsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'FriendsResponse',) as FriendsResponse;
    
    }
    return null;
  }

  /// Get Reader
  ///
  /// A reader's page: only what they share with you.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] handle (required):
  Future<Response> getReaderWithHttpInfo(String handle,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/readers/{handle}'
      .replaceAll('{handle}', handle);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Get Reader
  ///
  /// A reader's page: only what they share with you.
  ///
  /// Parameters:
  ///
  /// * [String] handle (required):
  Future<ReaderPageResponse?> getReader(String handle,) async {
    final response = await getReaderWithHttpInfo(handle,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ReaderPageResponse',) as ReaderPageResponse;
    
    }
    return null;
  }

  /// Get Recommendations
  ///
  /// Books your friends recommended to you, newest first.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getRecommendationsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/recommendations';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Get Recommendations
  ///
  /// Books your friends recommended to you, newest first.
  Future<List<RecommendationResponse>?> getRecommendations() async {
    final response = await getRecommendationsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<RecommendationResponse>') as List)
        .cast<RecommendationResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get Review
  ///
  /// Your review of this book, if any.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  Future<Response> getReviewWithHttpInfo(String itemId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}/review'
      .replaceAll('{item_id}', itemId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Get Review
  ///
  /// Your review of this book, if any.
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  Future<ReviewResponse?> getReview(String itemId,) async {
    final response = await getReviewWithHttpInfo(itemId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ReviewResponse',) as ReviewResponse;
    
    }
    return null;
  }

  /// Get Review Comments
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] reviewId (required):
  Future<Response> getReviewCommentsWithHttpInfo(String reviewId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/reviews/{review_id}/comments'
      .replaceAll('{review_id}', reviewId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Get Review Comments
  ///
  /// Parameters:
  ///
  /// * [String] reviewId (required):
  Future<List<CommentResponse>?> getReviewComments(String reviewId,) async {
    final response = await getReviewCommentsWithHttpInfo(reviewId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<CommentResponse>') as List)
        .cast<CommentResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get Profile
  ///
  /// Your handle and what you share.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getSocialProfileWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/profile';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Get Profile
  ///
  /// Your handle and what you share.
  Future<SocialProfileResponse?> getSocialProfile() async {
    final response = await getSocialProfileWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SocialProfileResponse',) as SocialProfileResponse;
    
    }
    return null;
  }

  /// Get Work Readers
  ///
  /// Reviews and notes on all editions of a work that you may see.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] workId (required):
  Future<Response> getWorkReadersWithHttpInfo(String workId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/works/{work_id}/readers'
      .replaceAll('{work_id}', workId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Get Work Readers
  ///
  /// Reviews and notes on all editions of a work that you may see.
  ///
  /// Parameters:
  ///
  /// * [String] workId (required):
  Future<WorkReadersResponse?> getWorkReaders(String workId,) async {
    final response = await getWorkReadersWithHttpInfo(workId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'WorkReadersResponse',) as WorkReadersResponse;
    
    }
    return null;
  }

  /// Like Review
  ///
  /// Like a review you may see.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] reviewId (required):
  Future<Response> likeReviewWithHttpInfo(String reviewId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/reviews/{review_id}/like'
      .replaceAll('{review_id}', reviewId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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

  /// Like Review
  ///
  /// Like a review you may see.
  ///
  /// Parameters:
  ///
  /// * [String] reviewId (required):
  Future<void> likeReview(String reviewId,) async {
    final response = await likeReviewWithHttpInfo(reviewId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// List Reports
  ///
  /// Reports, unresolved first.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listReportsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/admin/reports';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// List Reports
  ///
  /// Reports, unresolved first.
  Future<List<ReportResponse>?> listReports() async {
    final response = await listReportsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<ReportResponse>') as List)
        .cast<ReportResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Mark Read
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] recommendationId (required):
  Future<Response> markRecommendationReadWithHttpInfo(String recommendationId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/recommendations/{recommendation_id}/read'
      .replaceAll('{recommendation_id}', recommendationId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Mark Read
  ///
  /// Parameters:
  ///
  /// * [String] recommendationId (required):
  Future<void> markRecommendationRead(String recommendationId,) async {
    final response = await markRecommendationReadWithHttpInfo(recommendationId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Recommend
  ///
  /// Recommend a book of your library, or a title or link, to a friend.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RecommendRequest] recommendRequest (required):
  Future<Response> recommendWithHttpInfo(RecommendRequest recommendRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/recommendations';

    // ignore: prefer_final_locals
    Object? postBody = recommendRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Recommend
  ///
  /// Recommend a book of your library, or a title or link, to a friend.
  ///
  /// Parameters:
  ///
  /// * [RecommendRequest] recommendRequest (required):
  Future<RecommendationResponse?> recommend(RecommendRequest recommendRequest,) async {
    final response = await recommendWithHttpInfo(recommendRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RecommendationResponse',) as RecommendationResponse;
    
    }
    return null;
  }

  /// Remove Friend
  ///
  /// Cancel or decline a request, or end a friendship.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] handle (required):
  Future<Response> removeFriendWithHttpInfo(String handle,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/friends/{handle}'
      .replaceAll('{handle}', handle);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Remove Friend
  ///
  /// Cancel or decline a request, or end a friendship.
  ///
  /// Parameters:
  ///
  /// * [String] handle (required):
  Future<ReaderResponse?> removeFriend(String handle,) async {
    final response = await removeFriendWithHttpInfo(handle,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ReaderResponse',) as ReaderResponse;
    
    }
    return null;
  }

  /// Report Reader
  ///
  /// Report a reader to the administrators (the reader is not told).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ReportRequest] reportRequest (required):
  Future<Response> reportReaderWithHttpInfo(ReportRequest reportRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/reports';

    // ignore: prefer_final_locals
    Object? postBody = reportRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Report Reader
  ///
  /// Report a reader to the administrators (the reader is not told).
  ///
  /// Parameters:
  ///
  /// * [ReportRequest] reportRequest (required):
  Future<void> reportReader(ReportRequest reportRequest,) async {
    final response = await reportReaderWithHttpInfo(reportRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Resolve Report
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] reportId (required):
  Future<Response> resolveReportWithHttpInfo(String reportId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/admin/reports/{report_id}/resolve'
      .replaceAll('{report_id}', reportId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Resolve Report
  ///
  /// Parameters:
  ///
  /// * [String] reportId (required):
  Future<void> resolveReport(String reportId,) async {
    final response = await resolveReportWithHttpInfo(reportId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Save Review
  ///
  /// Rate and review a book of your library, and choose who sees it.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [ReviewRequest] reviewRequest (required):
  Future<Response> saveReviewWithHttpInfo(String itemId, ReviewRequest reviewRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}/review'
      .replaceAll('{item_id}', itemId);

    // ignore: prefer_final_locals
    Object? postBody = reviewRequest;

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

  /// Save Review
  ///
  /// Rate and review a book of your library, and choose who sees it.
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [ReviewRequest] reviewRequest (required):
  Future<ReviewResponse?> saveReview(String itemId, ReviewRequest reviewRequest,) async {
    final response = await saveReviewWithHttpInfo(itemId, reviewRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ReviewResponse',) as ReviewResponse;
    
    }
    return null;
  }

  /// Search Readers
  ///
  /// Readers whose handle starts with ``q``.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] q (required):
  Future<Response> searchReadersWithHttpInfo(String q,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/readers';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'q', q));

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

  /// Search Readers
  ///
  /// Readers whose handle starts with ``q``.
  ///
  /// Parameters:
  ///
  /// * [String] q (required):
  Future<List<ReaderResponse>?> searchReaders(String q,) async {
    final response = await searchReadersWithHttpInfo(q,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<ReaderResponse>') as List)
        .cast<ReaderResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Unblock Reader
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] handle (required):
  Future<Response> unblockReaderWithHttpInfo(String handle,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/blocks/{handle}'
      .replaceAll('{handle}', handle);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Unblock Reader
  ///
  /// Parameters:
  ///
  /// * [String] handle (required):
  Future<void> unblockReader(String handle,) async {
    final response = await unblockReaderWithHttpInfo(handle,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Unfollow Reader
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] handle (required):
  Future<Response> unfollowReaderWithHttpInfo(String handle,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/following/{handle}'
      .replaceAll('{handle}', handle);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Unfollow Reader
  ///
  /// Parameters:
  ///
  /// * [String] handle (required):
  Future<ReaderResponse?> unfollowReader(String handle,) async {
    final response = await unfollowReaderWithHttpInfo(handle,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ReaderResponse',) as ReaderResponse;
    
    }
    return null;
  }

  /// Unlike Review
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] reviewId (required):
  Future<Response> unlikeReviewWithHttpInfo(String reviewId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/social/reviews/{review_id}/like'
      .replaceAll('{review_id}', reviewId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Unlike Review
  ///
  /// Parameters:
  ///
  /// * [String] reviewId (required):
  Future<void> unlikeReview(String reviewId,) async {
    final response = await unlikeReviewWithHttpInfo(reviewId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Update Profile
  ///
  /// Choose a handle (3 to 30 letters, digits, dots, underscores) and what you share.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [UpdateSocialProfileRequest] updateSocialProfileRequest (required):
  Future<Response> updateSocialProfileWithHttpInfo(UpdateSocialProfileRequest updateSocialProfileRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/profile';

    // ignore: prefer_final_locals
    Object? postBody = updateSocialProfileRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Update Profile
  ///
  /// Choose a handle (3 to 30 letters, digits, dots, underscores) and what you share.
  ///
  /// Parameters:
  ///
  /// * [UpdateSocialProfileRequest] updateSocialProfileRequest (required):
  Future<SocialProfileResponse?> updateSocialProfile(UpdateSocialProfileRequest updateSocialProfileRequest,) async {
    final response = await updateSocialProfileWithHttpInfo(updateSocialProfileRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SocialProfileResponse',) as SocialProfileResponse;
    
    }
    return null;
  }
}
