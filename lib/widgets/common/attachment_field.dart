import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class AttachmentField extends StatefulWidget {
    final void Function(List<dynamic>)? onChanged;

    const AttachmentField({
        super.key,
        this.onChanged
    });

    @override
    State<AttachmentField> createState() => _AttachmentFieldState();
}

class _AttachmentFieldState extends State<AttachmentField> {
    late DropzoneViewController _dropzoneViewController;
    final List<PlatformFile> _pickedFiles = [];
    final List<Map<String, dynamic>> _droppedFiles = [];

    Future<void> _pickFiles() async {
        final result = await FilePicker.platform.pickFiles(
            allowMultiple: true,
        );
        if(result != null ){
            setState(() {
                _pickedFiles.addAll(result.files);
                widget.onChanged?.call([..._pickedFiles, ..._droppedFiles]);
            });
        }
    }

    void _onDropzoneCreated(DropzoneViewController controller){
        _dropzoneViewController = controller;
    }

    Future<void> _onFileDrop(dynamic ev) async{
        final name = await _dropzoneViewController.getFilename(ev);
        final size = await _dropzoneViewController.getFileSize(ev);
        setState((){
            _droppedFiles.add({
                'name': name,
                'size': size,
            });
            widget.onChanged?.call([..._pickedFiles, ..._droppedFiles]);
        });
    }

    void _removePickedFile(int index){
        setState((){
            _pickedFiles.removeAt(index);
            widget.onChanged?.call([..._pickedFiles, ..._droppedFiles]);
        });
    }

    void _removeDroppedFile(int index){
        setState((){
            _droppedFiles.removeAt(index);
            widget.onChanged?.call([..._pickedFiles, ..._droppedFiles]);
        });
    }

    @override
    Widget build(BuildContext context){
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                OutlinedButton(
                    onPressed: _pickFiles,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF41505D),
                        side: const BorderSide(
                    color: Color(0xFFA8B4BE),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  '첨부파일 추가',
                  style: TextStyle(
                    fontFamily: 'Wanted Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
                const SizedBox(height: 16),
                Container(
                    height: 62,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: Stack(
                        children: [
                            DropzoneView(
                                operation: DragOperation.copy,
                                cursor: CursorType.grab,
                                onCreated: _onDropzoneCreated,
                                onDrop: _onFileDrop,
                            ),
                            const Center(
                                child: Text('드래그해서 파일을 올려주세요', style: TextStyle(fontSize: 14, fontFamily: 'Wanted Sans', color: Color(0xFF41505D))),
                            ),
                        ],
                    ),
                ),
                if(_pickedFiles.isNotEmpty || _droppedFiles.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                            children:[
                                ..._pickedFiles.asMap().entries.map(
                                    (entry) => _buildFileItem(
                                        entry.value.name,
                                        '${(entry.value.size / 1024).toStringAsFixed(2)} KB',
                                        () => _removePickedFile(entry.key)
                                    )
                                ),
                                ..._droppedFiles.asMap().entries.map(
                                    (entry) => _buildFileItem(
                                        entry.value['name'],
                                        '${(entry.value['size'] / 1024).toStringAsFixed(2)} KB',
                                        () => _removeDroppedFile(entry.key)
                                    )
                                )
                            ]
                        )
                    )
            ]
        );
    }

    Widget _buildFileItem(String name, String size, VoidCallback onDelete){
        return ListTile(
            dense: true,
            title: Text(name, style: const TextStyle(fontSize: 14, fontFamily: 'Wanted Sans')),
            subtitle: Text(size, style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Wanted Sans')),
            trailing: IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close, size: 16),
            ),
        );
    }
}