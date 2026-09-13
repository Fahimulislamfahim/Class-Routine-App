import 'export_helper_stub.dart'
    if (dart.library.js_interop) 'export_helper_web.dart';

void downloadWebFile(String content, String fileName, String mimeType) {
  downloadFileImpl(content, fileName, mimeType);
}
