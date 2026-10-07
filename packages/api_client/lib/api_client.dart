//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ApiClient {
  ApiClient({this.basePath = 'http://localhost', this.authentication,});

  final String basePath;
  final Authentication? authentication;

  var _client = Client();
  final _defaultHeaderMap = <String, String>{};

  /// Returns the current HTTP [Client] instance to use in this class.
  ///
  /// The return value is guaranteed to never be null.
  Client get client => _client;

  /// Requests to use a new HTTP [Client] in this class.
  set client(Client newClient) {
    _client = newClient;
  }

  Map<String, String> get defaultHeaderMap => _defaultHeaderMap;

  void addDefaultHeader(String key, String value) {
     _defaultHeaderMap[key] = value;
  }

  // We don't use a Map<String, String> for queryParams.
  // If collectionFormat is 'multi', a key might appear multiple times.
  Future<Response> invokeAPI(
    String path,
    String method,
    List<QueryParam> queryParams,
    Object? body,
    Map<String, String> headerParams,
    Map<String, String> formParams,
    String? contentType,
  ) async {
    await authentication?.applyToParams(queryParams, headerParams);

    headerParams.addAll(_defaultHeaderMap);
    if (contentType != null) {
      headerParams['Content-Type'] = contentType;
    }

    final urlEncodedQueryParams = queryParams.map((param) => '$param');
    final queryString = urlEncodedQueryParams.isNotEmpty ? '?${urlEncodedQueryParams.join('&')}' : '';
    final uri = Uri.parse('$basePath$path$queryString');

    try {
      // Special case for uploading a single file which isn't a 'multipart/form-data'.
      if (
        body is MultipartFile && (contentType == null ||
        !contentType.toLowerCase().startsWith('multipart/form-data'))
      ) {
        final request = StreamedRequest(method, uri);
        request.headers.addAll(headerParams);
        request.contentLength = body.length;
        body.finalize().listen(
          request.sink.add,
          onDone: request.sink.close,
          // ignore: avoid_types_on_closure_parameters
          onError: (Object error, StackTrace trace) => request.sink.close(),
          cancelOnError: true,
        );
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      if (body is MultipartRequest) {
        final request = MultipartRequest(method, uri);
        request.fields.addAll(body.fields);
        request.files.addAll(body.files);
        request.headers.addAll(body.headers);
        request.headers.addAll(headerParams);
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      final msgBody = contentType == 'application/x-www-form-urlencoded'
        ? formParams
        : await serializeAsync(body);
      final nullableHeaderParams = headerParams.isEmpty ? null : headerParams;

      switch(method) {
        case 'POST': return await _client.post(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'PUT': return await _client.put(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'DELETE': return await _client.delete(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'PATCH': return await _client.patch(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'HEAD': return await _client.head(uri, headers: nullableHeaderParams,);
        case 'GET': return await _client.get(uri, headers: nullableHeaderParams,);
      }
    } on SocketException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Socket operation failed: $method $path',
        error,
        trace,
      );
    } on TlsException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'TLS/SSL communication failed: $method $path',
        error,
        trace,
      );
    } on IOException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'I/O operation failed: $method $path',
        error,
        trace,
      );
    } on ClientException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'HTTP connection failed: $method $path',
        error,
        trace,
      );
    } on Exception catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Exception occurred: $method $path',
        error,
        trace,
      );
    }

    throw ApiException(
      HttpStatus.badRequest,
      'Invalid HTTP operation: $method $path',
    );
  }

  Future<dynamic> deserializeAsync(String value, String targetType, {bool growable = false,}) async =>
    // ignore: deprecated_member_use_from_same_package
    deserialize(value, targetType, growable: growable);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use deserializeAsync() instead.')
  dynamic deserialize(String value, String targetType, {bool growable = false,}) {
    // Remove all spaces. Necessary for regular expressions as well.
    targetType = targetType.replaceAll(' ', ''); // ignore: parameter_assignments

    // If the expected target type is String, nothing to do...
    return targetType == 'String'
      ? value
      : fromJson(json.decode(value), targetType, growable: growable);
  }

  // ignore: deprecated_member_use_from_same_package
  Future<String> serializeAsync(Object? value) async => serialize(value);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use serializeAsync() instead.')
  String serialize(Object? value) => value == null ? '' : json.encode(value);

  /// Returns a native instance of an OpenAPI class matching the [specified type][targetType].
  static dynamic fromJson(dynamic value, String targetType, {bool growable = false,}) {
    try {
      switch (targetType) {
        case 'String':
          return value is String ? value : value.toString();
        case 'int':
          return value is int ? value : int.parse('$value');
        case 'double':
          return value is double ? value : double.parse('$value');
        case 'bool':
          if (value is bool) {
            return value;
          }
          final valueString = '$value'.toLowerCase();
          return valueString == 'true' || valueString == '1';
        case 'DateTime':
          return value is DateTime ? value : DateTime.tryParse(value);
        case 'AbsBookResponse':
          return AbsBookResponse.fromJson(value);
        case 'AbsLibraryResponse':
          return AbsLibraryResponse.fromJson(value);
        case 'AbsLinkRequest':
          return AbsLinkRequest.fromJson(value);
        case 'AbsLinkResponse':
          return AbsLinkResponse.fromJson(value);
        case 'Ao3Config':
          return Ao3Config.fromJson(value);
        case 'Audience':
          return AudienceTypeTransformer().decode(value);
        case 'AudioChapterResponse':
          return AudioChapterResponse.fromJson(value);
        case 'AudioProgressRequest':
          return AudioProgressRequest.fromJson(value);
        case 'AudioTrackResponse':
          return AudioTrackResponse.fromJson(value);
        case 'AuthorCountResponse':
          return AuthorCountResponse.fromJson(value);
        case 'AuthorResponse':
          return AuthorResponse.fromJson(value);
        case 'BatchImportResponse':
          return BatchImportResponse.fromJson(value);
        case 'BookDetailsRequest':
          return BookDetailsRequest.fromJson(value);
        case 'BookFormat':
          return BookFormatTypeTransformer().decode(value);
        case 'BookNoteResponse':
          return BookNoteResponse.fromJson(value);
        case 'BookTitleResponse':
          return BookTitleResponse.fromJson(value);
        case 'BookTraceResponse':
          return BookTraceResponse.fromJson(value);
        case 'ChangeOp':
          return ChangeOpTypeTransformer().decode(value);
        case 'ChangePasswordRequest':
          return ChangePasswordRequest.fromJson(value);
        case 'ChangeResponse':
          return ChangeResponse.fromJson(value);
        case 'CheckSourceResponse':
          return CheckSourceResponse.fromJson(value);
        case 'CreateSourceRequest':
          return CreateSourceRequest.fromJson(value);
        case 'DeviceKind':
          return DeviceKindTypeTransformer().decode(value);
        case 'DeviceResponse':
          return DeviceResponse.fromJson(value);
        case 'EditionResponse':
          return EditionResponse.fromJson(value);
        case 'EntityKind':
          return EntityKindTypeTransformer().decode(value);
        case 'EntryStatus':
          return EntryStatusTypeTransformer().decode(value);
        case 'FeedEntryResponse':
          return FeedEntryResponse.fromJson(value);
        case 'FeedKind':
          return FeedKindTypeTransformer().decode(value);
        case 'FinishedBookResponse':
          return FinishedBookResponse.fromJson(value);
        case 'FollowResponse':
          return FollowResponse.fromJson(value);
        case 'ForgotPasswordRequest':
          return ForgotPasswordRequest.fromJson(value);
        case 'FriendStatus':
          return FriendStatusTypeTransformer().decode(value);
        case 'FriendsResponse':
          return FriendsResponse.fromJson(value);
        case 'GenericConfig':
          return GenericConfig.fromJson(value);
        case 'Genre':
          return GenreTypeTransformer().decode(value);
        case 'GenreCountResponse':
          return GenreCountResponse.fromJson(value);
        case 'GitHubConfig':
          return GitHubConfig.fromJson(value);
        case 'HealthResponse':
          return HealthResponse.fromJson(value);
        case 'IdentityProvider':
          return IdentityProviderTypeTransformer().decode(value);
        case 'ImportResponse':
          return ImportResponse.fromJson(value);
        case 'IsbnLookupResponse':
          return IsbnLookupResponse.fromJson(value);
        case 'KavitaLinkResponse':
          return KavitaLinkResponse.fromJson(value);
        case 'KavitaStatus':
          return KavitaStatusTypeTransformer().decode(value);
        case 'LibraryItemResponse':
          return LibraryItemResponse.fromJson(value);
        case 'LinkKavitaRequest':
          return LinkKavitaRequest.fromJson(value);
        case 'LinkKind':
          return LinkKindTypeTransformer().decode(value);
        case 'LinkPreviewResponse':
          return LinkPreviewResponse.fromJson(value);
        case 'LinkRequest':
          return LinkRequest.fromJson(value);
        case 'LoginRequest':
          return LoginRequest.fromJson(value);
        case 'MemberResponse':
          return MemberResponse.fromJson(value);
        case 'OpOutcome':
          return OpOutcomeTypeTransformer().decode(value);
        case 'OpdsConfig':
          return OpdsConfig.fromJson(value);
        case 'OperationRequest':
          return OperationRequest.fromJson(value);
        case 'OperationResult':
          return OperationResult.fromJson(value);
        case 'PaperBookRequest':
          return PaperBookRequest.fromJson(value);
        case 'PaperRequest':
          return PaperRequest.fromJson(value);
        case 'PlaybackResponse':
          return PlaybackResponse.fromJson(value);
        case 'PremiumRequest':
          return PremiumRequest.fromJson(value);
        case 'ProviderLoginRequest':
          return ProviderLoginRequest.fromJson(value);
        case 'ProvidersResponse':
          return ProvidersResponse.fromJson(value);
        case 'PullResponse':
          return PullResponse.fromJson(value);
        case 'PushRequest':
          return PushRequest.fromJson(value);
        case 'PushResponse':
          return PushResponse.fromJson(value);
        case 'PushTokenRequest':
          return PushTokenRequest.fromJson(value);
        case 'ReaderPageResponse':
          return ReaderPageResponse.fromJson(value);
        case 'ReaderResponse':
          return ReaderResponse.fromJson(value);
        case 'ReadingPositionResponse':
          return ReadingPositionResponse.fromJson(value);
        case 'ReadingResponse':
          return ReadingResponse.fromJson(value);
        case 'ReadingStatus':
          return ReadingStatusTypeTransformer().decode(value);
        case 'RecommendRequest':
          return RecommendRequest.fromJson(value);
        case 'RecommendationResponse':
          return RecommendationResponse.fromJson(value);
        case 'RefreshRequest':
          return RefreshRequest.fromJson(value);
        case 'RegisterDeviceRequest':
          return RegisterDeviceRequest.fromJson(value);
        case 'RegisterRequest':
          return RegisterRequest.fromJson(value);
        case 'RelationResponse':
          return RelationResponse.fromJson(value);
        case 'RemotePositionResponse':
          return RemotePositionResponse.fromJson(value);
        case 'ReportReason':
          return ReportReasonTypeTransformer().decode(value);
        case 'ReportRequest':
          return ReportRequest.fromJson(value);
        case 'ReportResponse':
          return ReportResponse.fromJson(value);
        case 'ResetPasswordRequest':
          return ResetPasswordRequest.fromJson(value);
        case 'ReviewRequest':
          return ReviewRequest.fromJson(value);
        case 'ReviewResponse':
          return ReviewResponse.fromJson(value);
        case 'SharedNoteResponse':
          return SharedNoteResponse.fromJson(value);
        case 'ShelfResponse':
          return ShelfResponse.fromJson(value);
        case 'SocialProfileResponse':
          return SocialProfileResponse.fromJson(value);
        case 'SourceDetailResponse':
          return SourceDetailResponse.fromJson(value);
        case 'SourceEntryResponse':
          return SourceEntryResponse.fromJson(value);
        case 'SourceKind':
          return SourceKindTypeTransformer().decode(value);
        case 'SourceMatchResponse':
          return SourceMatchResponse.fromJson(value);
        case 'SourceResponse':
          return SourceResponse.fromJson(value);
        case 'TokenResponse':
          return TokenResponse.fromJson(value);
        case 'TrendingWorkResponse':
          return TrendingWorkResponse.fromJson(value);
        case 'UpdateProfileRequest':
          return UpdateProfileRequest.fromJson(value);
        case 'UpdateSocialProfileRequest':
          return UpdateSocialProfileRequest.fromJson(value);
        case 'UserResponse':
          return UserResponse.fromJson(value);
        case 'VerifyEmailRequest':
          return VerifyEmailRequest.fromJson(value);
        case 'WebDavConfig':
          return WebDavConfig.fromJson(value);
        case 'WithdrawRequest':
          return WithdrawRequest.fromJson(value);
        case 'WorkLinkRequest':
          return WorkLinkRequest.fromJson(value);
        case 'WorkNoteResponse':
          return WorkNoteResponse.fromJson(value);
        case 'WorkReadersResponse':
          return WorkReadersResponse.fromJson(value);
        case 'WorkResponse':
          return WorkResponse.fromJson(value);
        case 'WorkReviewResponse':
          return WorkReviewResponse.fromJson(value);
        case 'WorkSummaryResponse':
          return WorkSummaryResponse.fromJson(value);
        case 'YearStatsResponse':
          return YearStatsResponse.fromJson(value);
        default:
          dynamic match;
          if (value is List && (match = _regList.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toList(growable: growable);
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toSet();
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)?.group(1)) != null) {
            return Map<String, dynamic>.fromIterables(
              value.keys.cast<String>(),
              value.values.map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,)),
            );
          }
      }
    } on Exception catch (error, trace) {
      throw ApiException.withInner(HttpStatus.internalServerError, 'Exception during deserialization.', error, trace,);
    }
    throw ApiException(HttpStatus.internalServerError, 'Could not find a suitable class for deserialization',);
  }
}

/// Primarily intended for use in an isolate.
class DeserializationMessage {
  const DeserializationMessage({
    required this.json,
    required this.targetType,
    this.growable = false,
  });

  /// The JSON value to deserialize.
  final String json;

  /// Target type to deserialize to.
  final String targetType;

  /// Whether to make deserialized lists or maps growable.
  final bool growable;
}

/// Primarily intended for use in an isolate.
Future<dynamic> decodeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : json.decode(message.json);
}

/// Primarily intended for use in an isolate.
Future<dynamic> deserializeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : ApiClient.fromJson(
        json.decode(message.json),
        targetType,
        growable: message.growable,
      );
}

/// Primarily intended for use in an isolate.
Future<String> serializeAsync(Object? value) async => value == null ? '' : json.encode(value);
