// v0.43.0 实现 A2A + MCP Streamable HTTP UI 入口
//
// 集成位置：
// 1. Project Workspace - Agent 节点（调用远端 A2A Server）
// 2. MCP 配置页 - Streamable HTTP 端点
// 3. 多模态消息输入 - 图片上传 + 预处理

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/multimodal/domain/multimodal_message.dart';
import '../../../core/multimodal/services/image_preprocess_service.dart';

/// 多模态图片输入组件
class MultimodalImageInput extends ConsumerStatefulWidget {
  /// 图片处理完成回调
  final void Function(List<ImagePart> images) onImagesSelected;

  /// 最大图片数
  final int maxImages;

  /// 最大文件大小（字节）
  final int maxFileSizeBytes;

  const MultimodalImageInput({
    super.key,
    required this.onImagesSelected,
    this.maxImages = 4,
    this.maxFileSizeBytes = 20 * 1024 * 1024,
  });

  @override
  ConsumerState<MultimodalImageInput> createState() => _MultimodalImageInputState();
}

class _MultimodalImageInputState extends ConsumerState<MultimodalImageInput> {
  final List<ImageProcessResult> _processedImages = [];
  final ImagePreprocessService _preprocessor = const ImagePreprocessService();
  bool _isProcessing = false;

  Future<void> _pickAndProcessImages() async {
    if (_processedImages.length >= widget.maxImages) {
      _showSnack('最多支持 ${widget.maxImages} 张图片');
      return;
    }

    setState(() => _isProcessing = true);
    try {
      // 真实实现应使用 file_picker：
      // final result = await FilePicker.platform.pickFiles(
      //   type: FileType.image,
      //   allowMultiple: true,
      // );
      // 此处为占位演示
      _showSnack('图片选择需要 file_picker 集成，v0.43.0 后续完善');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _removeImage(int index) {
    setState(() => _processedImages.removeAt(index));
    widget.onImagesSelected(_processedImages.map((i) => i.toImagePart()).toList());
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 已选图片预览
        if (_processedImages.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _processedImages.length,
              itemBuilder: (context, index) {
                final img = _processedImages[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          img.bytes,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                      // Token 估算提示
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: const BoxDecoration(color: Colors.black54),
                          child: Text(
                            '~${img.estimatedTokens}tok',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        // 添加按钮
        Row(
          children: [
            IconButton(
              onPressed: _isProcessing ? null : _pickAndProcessImages,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.image_outlined),
              tooltip: '添加图片',
            ),
            Text(
              '${_processedImages.length}/${widget.maxImages}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

/// A2A Agent 节点 Provider - Project Workspace 使用
final a2aAgentCardProvider = FutureProvider.family<AgentCardInfo?, String>((ref, agentUrl) async {
  // 真实实现应调用 A2AClient.getAgentCard()
  // 此处返回占位数据
  return AgentCardInfo(
    name: 'Remote Agent',
    description: '远端 A2A Agent (占位)',
    url: agentUrl,
    skills: const ['*'],
  );
});

class AgentCardInfo {
  final String name;
  final String description;
  final String url;
  final List<String> skills;

  const AgentCardInfo({
    required this.name,
    required this.description,
    required this.url,
    required this.skills,
  });
}

/// MCP Streamable HTTP 配置卡片
class StreamableHttpConfigCard extends StatefulWidget {
  final String? initialEndpoint;
  final String? initialAuthToken;
  final void Function(String endpoint, String? authToken) onSave;

  const StreamableHttpConfigCard({
    super.key,
    this.initialEndpoint,
    this.initialAuthToken,
    required this.onSave,
  });

  @override
  State<StreamableHttpConfigCard> createState() => _StreamableHttpConfigCardState();
}

class _StreamableHttpConfigCardState extends State<StreamableHttpConfigCard> {
  late final TextEditingController _endpointController;
  late final TextEditingController _tokenController;
  bool _obscureToken = true;

  @override
  void initState() {
    super.initState();
    _endpointController = TextEditingController(text: widget.initialEndpoint ?? '');
    _tokenController = TextEditingController(text: widget.initialAuthToken ?? '');
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'MCP Streamable HTTP',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _endpointController,
              decoration: const InputDecoration(
                labelText: 'Endpoint URL',
                hintText: 'https://api.example.com/mcp',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                labelText: 'Bearer Token (可选)',
                hintText: 'sk-...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureToken ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureToken = !_obscureToken),
                ),
              ),
              obscureText: _obscureToken,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    widget.onSave(
                      _endpointController.text.trim(),
                      _tokenController.text.trim().isEmpty ? null : _tokenController.text.trim(),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('保存'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
