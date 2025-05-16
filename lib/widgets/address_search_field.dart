import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:johabon_pwa/utils/remedi_kopo/index.dart';

// 조건부 import (웹 전용)
import 'address_search_web.dart' if (dart.library.io) 'address_search_stub.dart';

class AddressSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool showDetailAddress;
  final Function(String)? onAddressSelected;
  final Function(String, String)? onDetailAddressSelected;

  const AddressSearchField({
    super.key,
    required this.controller,
    this.label = '주소',
    this.hint = '주소를 검색하려면 클릭하세요',
    this.showDetailAddress = true,
    this.onAddressSelected,
    this.onDetailAddressSelected,
  });

  @override
  _AddressSearchFieldState createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  final TextEditingController _detailAddressController = TextEditingController();
  bool _isAddressSelected = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // 웹 환경에서 주소 검색 결과 수신 이벤트 리스너 등록
      setupAddressSelectedListener((address) {
        _handleAddressSelected(address);
      });
    }
  }

  @override
  void dispose() {
    _detailAddressController.dispose();
    if (kIsWeb) {
      // 웹 환경에서 이벤트 리스너 해제
      tearDownAddressSelectedListener();
    }
    super.dispose();
  }

  void _handleAddressSelected(String address) {
    setState(() {
      widget.controller.text = address;
      _isAddressSelected = true;
      if (widget.onAddressSelected != null) {
        widget.onAddressSelected!(address);
      }
    });
  }

  void _searchAddress() async {
    if (kIsWeb) {
      // 웹 환경에서는 JavaScript 함수 호출
      openKakaoPostcode();
    } else {
      // 앱 환경에서는 KopoModel 사용
      try {
        KopoModel? model = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RemediKopo(),
          ),
        );
        
        if (model != null) {
          _handleAddressSelected(model.address);
        }
      } catch (e) {
        debugPrint('주소 검색 오류: $e');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('오류'),
            content: const Text('주소 검색 중 오류가 발생했습니다. 다시 시도해주세요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _onDetailAddressSubmitted(String value) {
    if (widget.onDetailAddressSelected != null) {
      widget.onDetailAddressSelected!(widget.controller.text, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 주소 입력 필드
        GestureDetector(
          onTap: _searchAddress,
          child: AbsorbPointer(
            child: TextFormField(
              controller: widget.controller,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '주소를 입력해주세요';
                }
                return null;
              },
            ),
          ),
        ),
        
        // 상세 주소 입력 필드 (주소 선택 완료 후 표시)
        if (widget.showDetailAddress && _isAddressSelected) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _detailAddressController,
            decoration: InputDecoration(
              labelText: '상세 주소',
              hintText: '상세 주소를 입력하세요',
              prefixIcon: const Icon(Icons.home_outlined),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
            onFieldSubmitted: _onDetailAddressSubmitted,
          ),
        ],
      ],
    );
  }
} 