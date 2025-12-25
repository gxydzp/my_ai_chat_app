// lib/widgets/explore/composer_bar.dart
import 'package:flutter/material.dart';

class ComposerBar extends StatefulWidget {
  final String hintText;
  final Future<void> Function(String text) onSend;

  const ComposerBar({
    super.key,
    required this.hintText,
    required this.onSend,
  });

  @override
  State<ComposerBar> createState() => _ComposerBarState();
}

class _ComposerBarState extends State<ComposerBar> {
  final _c = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) return;
    final text = _c.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    await widget.onSend(text);
    _c.clear();
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: const Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _c,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _sending ? null : _send,
              child: _sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('发送'),
            ),
          ],
        ),
      ),
    );
  }
}
