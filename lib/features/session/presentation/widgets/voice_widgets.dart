// 语音相关小部件：脉冲动画、麦克风按钮、波形绘制器、音频段
// 从 session_detail_page.dart 拆分

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 语音对话脉冲动画
class VoicePulseAnimation extends StatefulWidget {
  final Color color;

  const VoicePulseAnimation({super.key, required this.color});

  @override
  State<VoicePulseAnimation> createState() => _VoicePulseAnimationState();
}

class _VoicePulseAnimationState extends State<VoicePulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color
                  .withValues(alpha: 1.0 - (_animation.value - 1.0) * 2),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}

/// 语音输入按钮内容（按状态切换显示）
class VoiceInputButtonContent extends StatelessWidget {
  final bool isRecording;
  final bool isRecognizing;
  final double amplitude;
  final bool isCancelling;
  final ThemeData theme;

  const VoiceInputButtonContent({
    super.key,
    required this.isRecording,
    required this.isRecognizing,
    required this.amplitude,
    required this.isCancelling,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // 识别中：旋转图标
    if (isRecognizing && !isRecording) {
      return RecognizingMicButton(theme: theme);
    }

    // 录音中：红色麦克风 + 波形
    if (isRecording) {
      return RecordingMicButton(
        amplitude: amplitude,
        isCancelling: isCancelling,
        theme: theme,
      );
    }

    // 空闲状态：普通麦克风
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.mic,
        color: theme.colorScheme.onPrimaryContainer,
        size: 22,
      ),
    );
  }
}

/// 识别中的麦克风按钮（旋转动画）
class RecognizingMicButton extends StatefulWidget {
  final ThemeData theme;
  const RecognizingMicButton({super.key, required this.theme});

  @override
  State<RecognizingMicButton> createState() => _RecognizingMicButtonState();
}

class _RecognizingMicButtonState extends State<RecognizingMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.tertiaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.autorenew,
          color: widget.theme.colorScheme.onTertiaryContainer,
          size: 22,
        ),
      ),
    );
  }
}

/// 录音中的麦克风按钮（红色 + 波形）
class RecordingMicButton extends StatelessWidget {
  final double amplitude;
  final bool isCancelling;
  final ThemeData theme;

  const RecordingMicButton({
    super.key,
    required this.amplitude,
    required this.isCancelling,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 麦克风容器：36x36（确保总高 < 44）
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCancelling ? Colors.grey : Colors.red.shade400,
            shape: BoxShape.circle,
            boxShadow: isCancelling
                ? null
                : [
                    BoxShadow(
                      color: Colors.red.withAlpha(80),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 音量波形（缩小到 32x32）
              if (!isCancelling)
                CustomPaint(
                  size: const Size(32, 32),
                  painter: MicWaveformPainter(amplitude: amplitude),
                ),
              // 图标（缩小到 18）
              Icon(
                isCancelling ? Icons.delete_outline : Icons.mic,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
        // 提示文字：紧凑排列
        const SizedBox(height: 1),
        Text(
          isCancelling ? '取消' : '录音',
          style: TextStyle(
            fontSize: 8,
            color: isCancelling
                ? Colors.red
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// 麦克风波形绘制器
class MicWaveformPainter extends CustomPainter {
  final double amplitude;
  MicWaveformPainter({required this.amplitude});

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitude < 0.03) return;
    final paint = Paint()
      ..color =
          Colors.white.withAlpha((amplitude * 180).clamp(60, 200).toInt())
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const bars = 6;
    for (int i = 0; i < bars; i++) {
      final angle = (i / bars) * 2 * 3.14159265359;
      final maxR = size.width / 2 - 5;
      final minR = maxR * 0.35;
      // 用 sin 让高度随角度变化，更有声波感
      final waveH = amplitude *
          (minR + (i % 2 == 0 ? maxR - minR : (maxR - minR) * 0.6));
      final x1 = cx + minR * math.cos(angle);
      final y1 = cy + minR * math.sin(angle);
      final x2 = cx + (minR + waveH) * math.cos(angle);
      final y2 = cy + (minR + waveH) * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(MicWaveformPainter old) => old.amplitude != amplitude;
}

/// 音频段落数据类
class AudioSegment {
  final String id;
  final String? transcription;

  AudioSegment({required this.id, this.transcription});
}
