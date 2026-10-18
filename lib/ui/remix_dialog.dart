import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sidedeck/services/audio_processor_service.dart';
import 'package:sidedeck/theme/sidedeck_theme.dart';

class RemixDialog extends StatefulWidget {
  final File audioFile;
  const RemixDialog({super.key, required this.audioFile});

  @override
  State<RemixDialog> createState() => _RemixDialogState();
}

class _RemixDialogState extends State<RemixDialog> {
  double _speed = 0.85; // پیش‌فرض: ۸۵٪ سرعت عادی
  double _reverb = 0.5; // پیش‌فرض: ۵۰٪ شدت ریورب
  bool _isProcessing = false;
  final _processor = AudioProcessorService();

  Future<void> _processAndShare() async {
    setState(() => _isProcessing = true);
    
    final result = await _processor.applySlowedReverb(
      inputFile: widget.audioFile,
      speedFactor: _speed,
      reverbDecay: _reverb,
    );
    
    if (mounted) {
      setState(() => _isProcessing = false);
      if (result != null) {
        Navigator.pop(context); // بستن پنجره
        await _processor.shareAudioFile(result); // باز کردن منوی اشتراک‌گذاری
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطا در پردازش صدا! لطفا دوباره تلاش کنید.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: SideDeckTheme.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.amberAccent),
          SizedBox(width: 8),
          Text(
            'افکت Slowed + Reverb',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'سرعت پخش (Slowed)',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _speed,
                  min: 0.5,
                  max: 1.0,
                  divisions: 10,
                  label: '${_speed.toStringAsFixed(2)}x',
                  activeColor: SideDeckTheme.accentA,
                  onChanged: _isProcessing ? null : (val) => setState(() => _speed = val),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${_speed.toStringAsFixed(2)}x',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'شدت ریورب (Reverb)',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _reverb,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: '${(_reverb * 100).toInt()}%',
                  activeColor: SideDeckTheme.accentB,
                  onChanged: _isProcessing ? null : (val) => setState(() => _reverb = val),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${(_reverb * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amberAccent),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'در حال پردازش...',
                    style: TextStyle(color: Colors.amberAccent, fontSize: 13),
                  ),
                ],
              ),
            )
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
          child: const Text('انصراف', style: TextStyle(color: Colors.grey)),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.amberAccent,
            foregroundColor: Colors.black,
          ),
          onPressed: _isProcessing ? null : _processAndShare,
          icon: const Icon(Icons.share, size: 18),
          label: const Text('پردازش و اشتراک‌گذاری'),
        ),
      ],
    );
  }
}
