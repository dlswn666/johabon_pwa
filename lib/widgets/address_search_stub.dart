// 앱 환경에서는 사용하지 않는 더미 함수들

// 앱 환경에서는 KopoModel을 사용하기 때문에 이 함수는 사용되지 않음
void openKakaoPostcode() {
  // Do nothing in mobile environment
}

// 앱 환경에서는 Navigator.push로 주소 검색 화면을 띄우므로 이벤트 리스너가 필요 없음
void setupAddressSelectedListener(Function(String) callback) {
  // Do nothing in mobile environment
}

// 앱 환경에서는 이벤트 리스너가 없으므로 해제할 필요도 없음
void tearDownAddressSelectedListener() {
  // Do nothing in mobile environment
} 