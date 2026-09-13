import 'package:web/web.dart' as web;

void downloadFileImpl(String content, String fileName, String mimeType) {
  final encoded = Uri.encodeComponent(content);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = 'data:$mimeType;charset=utf-8,$encoded';
  anchor.download = fileName;
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
}
