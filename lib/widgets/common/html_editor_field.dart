import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class HtmlEditorField extends StatefulWidget{
    final String? initialContent;
    final String hintText;
    final double height;
    final void Function(String) onChange;

    const HtmlEditorField({
        super.key,
        this.initialContent,
        this.hintText = '내용을 입력해주세요',
        this.height = 300,
        required this.onChange,
    });

    @override
    State<HtmlEditorField> createState() => _HtmlEditorFieldState();
}

class _HtmlEditorFieldState extends State<HtmlEditorField>{
    final HtmlEditorController _controller = HtmlEditorController();

    @override
    void initState(){
        super.initState();
        if(widget.initialContent != null && widget.initialContent!.isNotEmpty){
           WidgetsBinding.instance.addPostFrameCallback((_){
            _controller.setText(widget.initialContent!);
           });
        }
    }

    @override
    Widget build(BuildContext context){
        return Container(
            height: widget.height,
            decoration: BoxDecoration(
                border: Border.all(color:  const Color(0xFFA8B4BE), width: 1),
                borderRadius: BorderRadius.circular(4),
            ),
            child: HtmlEditor(
                controller: _controller,
                htmlEditorOptions: HtmlEditorOptions(
                    hint: widget.hintText,
                    shouldEnsureVisible: true,
                ),
                htmlToolbarOptions: HtmlToolbarOptions(
                    toolbarPosition: ToolbarPosition.aboveEditor,
                    toolbarType: ToolbarType.nativeGrid,
                    defaultToolbarButtons: [
                        StyleButtons(),
                        FontSettingButtons(fontSizeUnit: false),
                        FontButtons(),
                        ColorButtons(),
                        ListButtons(),
                        ParagraphButtons(),
                        InsertButtons(
                            video: false,
                            audio: false,
                        ),
                    ],
                ),
                otherOptions: OtherOptions(
                    height: widget.height,
                    decoration: BoxDecoration(
                        border: Border.fromBorderSide(BorderSide.none),
                    ),
                ),
                callbacks: Callbacks(
                    onChangeContent: (String? changed){
                        if(widget.onChange != null && changed != null){
                            widget.onChange!(changed);
                        }
                    },
                ),
            ),
        );
    }
}


