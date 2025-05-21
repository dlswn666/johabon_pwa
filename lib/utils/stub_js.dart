// 웹이 아닌 환경에서 사용할 js 스텁 파일
class JsObject {
  void callMethod(String name, List<dynamic> args) {
    // 웹이 아닌 환경에서는 아무 작업도 수행하지 않음
  }
}

final context = JsObject();

// allowInterop 스텁 구현
T allowInterop<T extends Function>(T function) => function; 