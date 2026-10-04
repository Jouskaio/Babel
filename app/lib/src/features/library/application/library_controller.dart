import 'package:babel_api_client/api.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/files/file_transfer.dart';

final libraryControllerProvider =
    AsyncNotifierProvider<LibraryController, List<LibraryItemResponse>>(
      LibraryController.new,
    );

/// The signed-in reader's library, kept in step with imports and removals.
class LibraryController extends AsyncNotifier<List<LibraryItemResponse>> {
  LibraryApi get _api => ref.read(libraryApiProvider);

  @override
  Future<List<LibraryItemResponse>> build() async =>
      await _api.getLibrary() ?? const [];

  Future<void> reload() async => state = await AsyncValue.guard(build);

  /// Uploads [file]; the new (or already known) book goes on top of the list.
  Future<ImportResponse> import(
    XFile file, {
    void Function(double)? onProgress,
  }) async {
    final result = await ref
        .read(fileTransferProvider)
        .upload(file, onProgress: onProgress);
    final items = state.value ?? const <LibraryItemResponse>[];
    state = AsyncData([
      result.item,
      ...items.where((i) => i.id != result.item.id),
    ]);
    return result;
  }

  Future<void> remove(LibraryItemResponse item) async {
    await _api.removeFromLibrary(item.id);
    state = AsyncData([...?state.value?.where((i) => i.id != item.id)]);
  }
}
