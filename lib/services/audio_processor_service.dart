import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AudioProcessorService {
  /// اعمال افکت Slowed + Reverb روی فایل ورودی
  Future<File?> applySlowedReverb({
    required File inputFile,
    required double speedFactor, // 0.8 برای آهسته‌تر
    required double reverbDecay, // 0.5 برای ریورب متوسط
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final outputPath = '${directory.path}/remixed_${DateTime.now().millisecondsSinceEpoch}.wav';

      // فیلتر atempo سرعت را تغییر می‌دهد (بدون تغییر پیچ)
      // فیلتر aecho یک افکت اکو/ریورب ایجاد می‌کند
      final filter = 'atempo=$speedFactor,aecho=0.8:0.9:1000|1800:$reverbDecay|${reverbDecay * 0.7}';
      
      // دستور FFmpeg: فرمت خروجی را WAV با کیفیت 16-bit (pcm_s16le) قرار می‌دهیم
      final command = '-y -i "${inputFile.path}" -af "$filter" -c:a pcm_s16le "$outputPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return File(outputPath);
      } else {
        print("FFmpeg Error: ${await session.getFailStackTrace()}");
        return null;
      }
    } catch (e) {
      print("Error processing audio: $e");
      return null;
    }
  }

  /// باز کردن منوی اشتراک‌گذاری گوشی برای ارسال فایل
  Future<void> shareAudioFile(File file) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'ReverMix Audio',
        text: 'Listen to my remix created with ReverMix!',
      );
    } catch (e) {
      print("Error sharing file: $e");
    }
  }
}
