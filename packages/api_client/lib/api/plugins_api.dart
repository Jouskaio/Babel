//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class PluginsApi {
  PluginsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Activate Plugin
  ///
  /// Switch a plugin on: it becomes one of your sources.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] pluginId (required):
  Future<Response> activatePluginWithHttpInfo(String pluginId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/plugins/{plugin_id}/active'
      .replaceAll('{plugin_id}', pluginId);

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

  /// Activate Plugin
  ///
  /// Switch a plugin on: it becomes one of your sources.
  ///
  /// Parameters:
  ///
  /// * [String] pluginId (required):
  Future<void> activatePlugin(String pluginId,) async {
    final response = await activatePluginWithHttpInfo(pluginId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Deactivate Plugin
  ///
  /// Switch a plugin off: its source goes (the books you imported stay).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] pluginId (required):
  Future<Response> deactivatePluginWithHttpInfo(String pluginId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/plugins/{plugin_id}/active'
      .replaceAll('{plugin_id}', pluginId);

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

  /// Deactivate Plugin
  ///
  /// Switch a plugin off: its source goes (the books you imported stay).
  ///
  /// Parameters:
  ///
  /// * [String] pluginId (required):
  Future<void> deactivatePlugin(String pluginId,) async {
    final response = await deactivatePluginWithHttpInfo(pluginId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Install Plugin
  ///
  /// Install a plugin from a manifest address (checked first); readers can then switch it on.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [InstallPlugin] installPlugin (required):
  Future<Response> installPluginWithHttpInfo(InstallPlugin installPlugin,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/admin/plugins';

    // ignore: prefer_final_locals
    Object? postBody = installPlugin;

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

  /// Install Plugin
  ///
  /// Install a plugin from a manifest address (checked first); readers can then switch it on.
  ///
  /// Parameters:
  ///
  /// * [InstallPlugin] installPlugin (required):
  Future<PluginResponse?> installPlugin(InstallPlugin installPlugin,) async {
    final response = await installPluginWithHttpInfo(installPlugin,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PluginResponse',) as PluginResponse;
    
    }
    return null;
  }

  /// List Plugins
  ///
  /// The plugins your administrator installed, and which ones you have on.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listPluginsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/plugins';

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

  /// List Plugins
  ///
  /// The plugins your administrator installed, and which ones you have on.
  Future<List<PluginResponse>?> listPlugins() async {
    final response = await listPluginsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<PluginResponse>') as List)
        .cast<PluginResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Uninstall Plugin
  ///
  /// Remove a plugin (the sources readers made from it stay as they are).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] pluginId (required):
  Future<Response> uninstallPluginWithHttpInfo(String pluginId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/admin/plugins/{plugin_id}'
      .replaceAll('{plugin_id}', pluginId);

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

  /// Uninstall Plugin
  ///
  /// Remove a plugin (the sources readers made from it stay as they are).
  ///
  /// Parameters:
  ///
  /// * [String] pluginId (required):
  Future<void> uninstallPlugin(String pluginId,) async {
    final response = await uninstallPluginWithHttpInfo(pluginId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
