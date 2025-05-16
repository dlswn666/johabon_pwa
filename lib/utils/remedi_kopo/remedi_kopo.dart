import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'kopo_model.dart';

class RemediKopo extends StatefulWidget {
  const RemediKopo({super.key});

  @override
  State<RemediKopo> createState() => _RemediKopoState();
}

class _RemediKopoState extends State<RemediKopo> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _injectKakaoPostcodeScript();
          },
        ),
      )
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (JavaScriptMessage message) {
          final messageData = message.message;
          if (messageData.isNotEmpty) {
            // 주소 선택 결과 처리
            final model = KopoModel(address: messageData);
            Navigator.pop(context, model);
          }
        },
      )
      ..loadHtmlString(_buildHtmlPage());
  }

  String _buildHtmlPage() {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
        <style>
          body, html {
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 0;
          }
          #container {
            width: 100%;
            height: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: rgba(0, 0, 0, 0.1);
          }
          #loadingIndicator {
            text-align: center;
            font-family: Arial, sans-serif;
            color: #333;
          }
        </style>
      </head>
      <body>
        <div id="container">
          <div id="loadingIndicator">
            <p>주소 검색 화면을 로딩 중입니다...</p>
          </div>
        </div>
        <script>
          // 페이지 로드 완료 시 카카오 주소 검색 실행
          window.onload = function() {
            setTimeout(function() {
              new daum.Postcode({
                oncomplete: function(data) {
                  let address = data.address;
                  if (data.buildingName && data.buildingName !== '') {
                    address += " (" + data.buildingName + ")";
                  }
                  // Flutter로 결과 전달
                  window.Flutter.postMessage(address);
                },
                onresize: function(size) {
                  document.getElementById('container').style.height = size.height+'px';
                },
                width: '100%',
                height: '100%'
              }).embed(document.getElementById('container'));
              document.getElementById('loadingIndicator').style.display = 'none';
            }, 500);
          }
        </script>
      </body>
      </html>
    ''';
  }

  void _injectKakaoPostcodeScript() {
    _webViewController.runJavaScript('''
      if (typeof daum === 'undefined') {
        var script = document.createElement('script');
        script.src = 'https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js';
        document.head.appendChild(script);
      }
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주소 검색'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
} 