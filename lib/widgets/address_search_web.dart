import 'dart:js' as js;

// 웹 환경에서 카카오 주소 검색 API 호출
void openKakaoPostcode() {
  js.context.callMethod('openKakaoPostcode');
}

// 주소 선택 이벤트 리스너 설정 (콜백 함수를 JavaScript에 전달)
void setupAddressSelectedListener(Function(String) callback) {
  js.context.callMethod('setupAddressSelectedListener', [
    js.allowInterop(callback)
  ]);
}

// 주소 선택 이벤트 리스너 해제
void tearDownAddressSelectedListener() {
  js.context.callMethod('tearDownAddressSelectedListener');
} 