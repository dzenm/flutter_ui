import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'package:fbl/fbl.dart';
import '../utils/image_util.dart';

///
/// Created by a0010 on 2023/12/19 11:12
///
class EnsureSendFileWidget extends StatefulWidget {
  final String? title;
  final String? logo;
  final List<XFile> files;
  final void Function(List<XFile> files)? onTap;

  const EnsureSendFileWidget({
    super.key,
    this.title,
    this.logo,
    this.files = const [],
    this.onTap,
  });

  @override
  State<EnsureSendFileWidget> createState() => _EnsureSendFileWidgetState();
}

class _EnsureSendFileWidgetState extends State<EnsureSendFileWidget> {
  final List<SelectedEntity> _files = [];

  @override
  void initState() {
    super.initState();
    _files.addAll(widget.files.map((file) => SelectedEntity(data: file, isSelected: true)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 480,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(children: [
        const SizedBox(height: 16),
        const Text('发送给：'),
        const SizedBox(height: 10),
        Row(children: [
          const SizedBox(width: 8),
          const SizedBox(width: 10),
          Text(widget.title ?? ''),
        ]),
        const SizedBox(height: 8),
        const DividerView(),
        Expanded(child: _buildContent()),
        _buildBottomButton(),
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _buildContent() {
    return ListView.builder(
      itemCount: _files.length,
      itemBuilder: (context, index) {
        SelectedEntity selected = _files[index];
        XFile file = selected.data;
        IconData icon = selected.isSelected ? Icons.check_circle : Icons.circle_outlined;
        Color color = selected.isSelected ? Colors.blue : Colors.white38;
        PathInfo info = PathInfo.parse(file.path);
        Widget child;
        String path = file.path;
        if (info.mimeType == MimeType.image) {
          child = ImageCacheView(url: path, width: 40, height: 56, fit: BoxFit.cover);
        } else if (info.mimeType == MimeType.video) {
          child = Image.asset(ImageUtil.getFileIcon(path), width: 40, height: 56);
        } else {
          child = Image.asset(ImageUtil.getFileIcon(path), width: 40, height: 56);
        }
        return TapLayout(
          height: 72,
          padding: const EdgeInsets.all(8),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          onTap: () {},
          child: Row(children: [
            child,
            const SizedBox(width: 8),
            Expanded(child: Text(file.name, overflow: TextOverflow.ellipsis)),
            TapLayout(
              foreground: Colors.transparent,
              width: 32,
              height: 32,
              onTap: () {
                selected.isSelected = !selected.isSelected;
                _files[index] = selected;
                setState(() {});
              },
              child: Icon(icon, color: color, size: 16),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      TapLayout(
        width: 120,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        background: Colors.blue,
        onTap: () => Navigator.of(context).pop(),
        child: const Text('取消发送', style: TextStyle(color: Colors.white)),
      ),
      TapLayout(
        width: 120,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        background: Colors.blue,
        onTap: () {
          Navigator.of(context).pop();
          if (widget.onTap != null) {
            widget.onTap!(_getSendFile());
          }
        },
        child: Text('确定发送(${_getSendFile().length})', style: const TextStyle(color: Colors.white)),
      ),
    ]);
  }

  List<XFile> _getSendFile() {
    List<XFile> files = [];
    for (var file in _files) {
      if (!file.isSelected) continue;
      files.add(file.data);
    }
    return files;
  }
}
