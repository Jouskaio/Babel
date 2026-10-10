# babel_api_client.api.PluginsApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**activatePlugin**](PluginsApi.md#activateplugin) | **PUT** /v1/plugins/{plugin_id}/active | Activate Plugin
[**deactivatePlugin**](PluginsApi.md#deactivateplugin) | **DELETE** /v1/plugins/{plugin_id}/active | Deactivate Plugin
[**installPlugin**](PluginsApi.md#installplugin) | **POST** /v1/admin/plugins | Install Plugin
[**listPlugins**](PluginsApi.md#listplugins) | **GET** /v1/plugins | List Plugins
[**uninstallPlugin**](PluginsApi.md#uninstallplugin) | **DELETE** /v1/admin/plugins/{plugin_id} | Uninstall Plugin


# **activatePlugin**
> activatePlugin(pluginId)

Activate Plugin

Switch a plugin on: it becomes one of your sources.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PluginsApi();
final pluginId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.activatePlugin(pluginId);
} catch (e) {
    print('Exception when calling PluginsApi->activatePlugin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pluginId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deactivatePlugin**
> deactivatePlugin(pluginId)

Deactivate Plugin

Switch a plugin off: its source goes (the books you imported stay).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PluginsApi();
final pluginId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.deactivatePlugin(pluginId);
} catch (e) {
    print('Exception when calling PluginsApi->deactivatePlugin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pluginId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **installPlugin**
> PluginResponse installPlugin(installPlugin)

Install Plugin

Install a plugin from a manifest address (checked first); readers can then switch it on.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PluginsApi();
final installPlugin = InstallPlugin(); // InstallPlugin | 

try {
    final result = api_instance.installPlugin(installPlugin);
    print(result);
} catch (e) {
    print('Exception when calling PluginsApi->installPlugin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **installPlugin** | [**InstallPlugin**](InstallPlugin.md)|  | 

### Return type

[**PluginResponse**](PluginResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPlugins**
> List<PluginResponse> listPlugins()

List Plugins

The plugins your administrator installed, and which ones you have on.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PluginsApi();

try {
    final result = api_instance.listPlugins();
    print(result);
} catch (e) {
    print('Exception when calling PluginsApi->listPlugins: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<PluginResponse>**](PluginResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uninstallPlugin**
> uninstallPlugin(pluginId)

Uninstall Plugin

Remove a plugin (the sources readers made from it stay as they are).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PluginsApi();
final pluginId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.uninstallPlugin(pluginId);
} catch (e) {
    print('Exception when calling PluginsApi->uninstallPlugin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pluginId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

