import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:johabon_pwa/utils/remedi_kopo/index.dart';
import 'package:johabon_pwa/config/theme.dart';

class AddressSearchDialog extends StatefulWidget {
  final Function(String) onAddressSelected;
  final Function(String, String)? onDetailAddressSelected;
  final bool showDetailAddress;

  const AddressSearchDialog({
    Key? key,
    required this.onAddressSelected,
    this.onDetailAddressSelected,
    this.showDetailAddress = true,
  }) : super(key: key);

  /// 모달 다이얼로그로 주소 검색 화면 표시
  static Future<void> show({
    required BuildContext context,
    required Function(String) onAddressSelected,
    Function(String, String)? onDetailAddressSelected,
    bool showDetailAddress = true,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddressSearchDialog(
        onAddressSelected: onAddressSelected,
        onDetailAddressSelected: onDetailAddressSelected,
        showDetailAddress: showDetailAddress,
      ),
    );
  }

  @override
  State<AddressSearchDialog> createState() => _AddressSearchDialogState();
}

class _AddressSearchDialogState extends State<AddressSearchDialog> {
  final TextEditingController _detailAddressController = TextEditingController();
  String _selectedAddress = '';
  bool _isAddressSelected = false;

  @override
  void dispose() {
    _detailAddressController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    if (kIsWeb) {
      // 웹 환경에서는 Dialog를 닫고 부모 위젯에서 JavaScript 함수 호출
      Navigator.of(context).pop();
      widget.onAddressSelected(_selectedAddress);
    } else {
      // 앱 환경에서는 KopoModel 사용
      try {
        KopoModel? model = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RemediKopo(),
          ),
        );
        
        if (model != null) {
          setState(() {
            _selectedAddress = model.address;
            _isAddressSelected = true;
          });
          widget.onAddressSelected(_selectedAddress);
        }
      } catch (e) {
        debugPrint('주소 검색 오류: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('주소 검색 중 오류가 발생했습니다. 다시 시도해주세요.'),
            ),
          );
        }
      }
    }
  }

  void _submitDetailAddress() {
    if (widget.onDetailAddressSelected != null && _detailAddressController.text.isNotEmpty) {
      widget.onDetailAddressSelected!(_selectedAddress, _detailAddressController.text);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // 웹 환경에서는 간단한 안내 메시지만 표시 (JavaScript로 처리)
      return AlertDialog(
        title: const Text('주소 검색'),
        content: const Text('주소 검색 창이 열립니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: _searchAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('검색'),
          ),
        ],
      );
    }

    // 앱 환경에서의 모달 다이얼로그
    return AlertDialog(
      title: const Text('주소 검색'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isAddressSelected) ...[
            const Text('아래 버튼을 클릭하여 주소를 검색해주세요.'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _searchAddress,
              icon: const Icon(Icons.search),
              label: const Text('주소 검색'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ] else ...[
            Text(
              '선택한 주소: $_selectedAddress',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (widget.showDetailAddress) ...[
              TextField(
                controller: _detailAddressController,
                decoration: const InputDecoration(
                  labelText: '상세 주소',
                  hintText: '상세 주소를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        if (_isAddressSelected)
          ElevatedButton(
            onPressed: _submitDetailAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('확인'),
          ),
      ],
    );
  }
} 