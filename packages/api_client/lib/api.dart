//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

library babel_api_client;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'api_client.dart';
part 'api_helper.dart';
part 'api_exception.dart';
part 'auth/authentication.dart';
part 'auth/api_key_auth.dart';
part 'auth/oauth.dart';
part 'auth/http_basic_auth.dart';
part 'auth/http_bearer_auth.dart';

part 'api/account_api.dart';
part 'api/admin_api.dart';
part 'api/auth_api.dart';
part 'api/catalog_api.dart';
part 'api/health_api.dart';
part 'api/library_api.dart';
part 'api/sources_api.dart';
part 'api/sync_api.dart';

part 'model/ao3_config.dart';
part 'model/batch_import_response.dart';
part 'model/book_format.dart';
part 'model/change_op.dart';
part 'model/change_password_request.dart';
part 'model/change_response.dart';
part 'model/check_source_response.dart';
part 'model/create_source_request.dart';
part 'model/device_kind.dart';
part 'model/device_response.dart';
part 'model/edition_response.dart';
part 'model/entity_kind.dart';
part 'model/entry_status.dart';
part 'model/follow_response.dart';
part 'model/forgot_password_request.dart';
part 'model/generic_config.dart';
part 'model/git_hub_config.dart';
part 'model/health_response.dart';
part 'model/identity_provider.dart';
part 'model/import_response.dart';
part 'model/isbn_lookup_response.dart';
part 'model/library_item_response.dart';
part 'model/link_kind.dart';
part 'model/link_preview_response.dart';
part 'model/link_request.dart';
part 'model/login_request.dart';
part 'model/op_outcome.dart';
part 'model/opds_config.dart';
part 'model/operation_request.dart';
part 'model/operation_result.dart';
part 'model/provider_login_request.dart';
part 'model/providers_response.dart';
part 'model/pull_response.dart';
part 'model/push_request.dart';
part 'model/push_response.dart';
part 'model/reading_position_response.dart';
part 'model/refresh_request.dart';
part 'model/register_device_request.dart';
part 'model/register_request.dart';
part 'model/reset_password_request.dart';
part 'model/source_detail_response.dart';
part 'model/source_entry_response.dart';
part 'model/source_kind.dart';
part 'model/source_response.dart';
part 'model/token_response.dart';
part 'model/trending_work_response.dart';
part 'model/update_profile_request.dart';
part 'model/user_response.dart';
part 'model/verify_email_request.dart';
part 'model/web_dav_config.dart';
part 'model/withdraw_request.dart';
part 'model/work_response.dart';
part 'model/work_summary_response.dart';


/// An [ApiClient] instance that uses the default values obtained from
/// the OpenAPI specification file.
var defaultApiClient = ApiClient();

const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};
const _dateEpochMarker = 'epoch';
const _deepEquality = DeepCollectionEquality();
final _dateFormatter = DateFormat('yyyy-MM-dd');
final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

bool _isEpochMarker(String? pattern) => pattern == _dateEpochMarker || pattern == '/$_dateEpochMarker/';
