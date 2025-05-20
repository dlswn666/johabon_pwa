import 'package:flutter/foundation.dart';
import 'package:johabon_pwa/models/union_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UnionProvider with ChangeNotifier {
  Union? _currentUnion;
  bool _isLoading = false;
  String? _error;

  Union? get currentUnion => _currentUnion;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<bool> fetchAndSetUnion(String slug) async {
    print("[UnionProvider] fetchAndSetUnion started for slug: $slug");
    _isLoading = true;
    _error = null;
    // currentUnion을 null로 설정하여 이전 조합 정보가 남아있지 않도록 합니다.
    _currentUnion = null; 
    notifyListeners();

    try {
      print("[UnionProvider] Querying Supabase for slug: $slug");
      final response = await _supabaseClient
          .from('unions')
          .select()
          .eq('homepage', slug)
          .maybeSingle(); // slug는 UNIQUE하다고 가정하고 single 사용, 없다면 null

      if (response == null) {
        _error = '조합 정보를 찾을 수 없습니다. (slug: $slug)';
        _isLoading = false;
        print("[UnionProvider] Union not found for slug: $slug");
        notifyListeners();
        return false;
      }

      print("[UnionProvider] Union found for slug: $slug - Data: $response");
      _currentUnion = Union.fromJson(response as Map<String, dynamic>);
      _isLoading = false;
      notifyListeners();
      print("[UnionProvider] Union set successfully: ${_currentUnion?.name}");
      return true;
      
    } on PostgrestException catch (e) {
      _error = '조합 정보 로딩 중 오류 발생 (DB): ${e.message}';
      _isLoading = false;
      print("[UnionProvider] PostgrestException: ${e.message}, Details: ${e.details}");
      notifyListeners();
      return false;
    } catch (e) {
      _error = '조합 정보 로딩 중 알 수 없는 오류 발생: $e';
      _isLoading = false;
      print("[UnionProvider] Unknown error: $e");
      notifyListeners();
      return false;
    }
  }

  // 현재 조합 정보를 초기화하는 메소드
  void clearUnion() {
    print("[UnionProvider] Clearing union data");
    _currentUnion = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
} 