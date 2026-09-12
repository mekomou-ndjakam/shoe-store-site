// One-off generator: walks assets/products/store_images and writes a static
// Dart map of folder -> image paths (capped per folder) so the app never has
// to scan the ~10k-file AssetManifest at runtime.
//
// Run with: dart run tool/generate_asset_index.dart
import 'dart:io';

const int cap = 40;
const List<String> extensions = ['.jpg', '.jpeg', '.png', '.webp'];

// In this dataset, the first file(s) of a folder are very often a brand
// logo or banner graphic saved as PNG, while the real product photos are
// almost always JPEG. Sorting JPEG/WEBP first (then PNG last) means the
// per-folder cap below naturally drops most logo graphics instead of
// picking them as the folder's first — and therefore most visible —
// images.
int _extensionPriority(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 0;
  if (lower.endsWith('.webp') || lower.endsWith('.avif')) return 1;
  return 2; // .png and anything else
}

List<String> _sortedFolderFiles(Directory folder) {
  final files = folder
      .listSync()
      .whereType<File>()
      .where((f) => extensions.any((ext) => f.path.toLowerCase().endsWith(ext)))
      .map((f) => f.path.replaceAll('\\', '/'))
      .toList();
  files.sort((a, b) {
    final priority = _extensionPriority(a).compareTo(_extensionPriority(b));
    if (priority != 0) return priority;
    return a.compareTo(b);
  });
  return files;
}

void main() {
  final root = Directory('assets/products/store_images');
  final folders = root.listSync().whereType<Directory>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final buffer = StringBuffer();
  buffer.writeln('// GENERATED FILE — do not edit by hand.');
  buffer.writeln('// Regenerate with: dart run tool/generate_asset_index.dart');
  buffer.writeln('// Precomputed folder -> image paths so the app never has to scan the');
  buffer.writeln('// 10k-file AssetManifest at runtime (that scan alone can take minutes');
  buffer.writeln('// in an unoptimized debug/JS build).');
  buffer.writeln('const Map<String, List<String>> kFolderAssets = {');

  var totalFiles = 0;
  for (final folder in folders) {
    final folderName = folder.uri.pathSegments.where((s) => s.isNotEmpty).last;
    final capped = _sortedFolderFiles(folder).take(cap).toList();
    totalFiles += capped.length;

    buffer.writeln('  ${_dartString(folderName)}: [');
    for (final path in capped) {
      buffer.writeln('    ${_dartString(path)},');
    }
    buffer.writeln('  ],');
  }

  buffer.writeln('};');

  File('lib/data/generated_asset_index.dart').writeAsStringSync(buffer.toString());
  stdout.writeln('Wrote lib/data/generated_asset_index.dart — ${folders.length} folders, $totalFiles images.');

  final pubspecBuffer = StringBuffer();
  for (final folder in folders) {
    for (final path in _sortedFolderFiles(folder).take(cap)) {
      pubspecBuffer.writeln('    - $path');
    }
  }
  File('tool/pubspec_asset_list.txt').writeAsStringSync(pubspecBuffer.toString());
  stdout.writeln('Wrote tool/pubspec_asset_list.txt for pasting into pubspec.yaml.');
}

String _dartString(String value) {
  final escaped = value.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
  return "'$escaped'";
}
