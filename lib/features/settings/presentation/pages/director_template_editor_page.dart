// =============================================================================
// 导演模板编辑器 — V1.0
// =============================================================================
//
// 提供导演模板的：
// 1. 列表管理（查看、删除、编辑用户自定义模板）
// 2. 三段式编辑（角色 / 场景 / 指导）+ 实时预览
// 3. 从预置模板复制为新模板
// 4. 保存为我的模板

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/tts_director_template.dart';
import 'voice_settings_page.dart';

/// 我的模板管理页面
class MyDirectorTemplatesPage extends ConsumerWidget {
  const MyDirectorTemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(voiceSettingsProvider);
    final customTemplates = settings.customTemplates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的导演模板'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '从零创建',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DirectorTemplateEditorPage(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 顶部提示
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.indigo.withValues(alpha: 0.05),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.indigo, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '共 ${customTemplates.length} 个自定义模板'
                    '${customTemplates.isEmpty ? ' · 点击右上角 ✚ 创建第一个' : ''}',
                    style: const TextStyle(fontSize: 13, color: Colors.indigo),
                  ),
                ),
              ],
            ),
          ),
          // 预置模板区
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: const [
                Icon(Icons.auto_awesome, color: Colors.deepPurple, size: 18),
                SizedBox(width: 8),
                Text('预置模板（不可编辑，可复制为我的）',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: DirectorTemplatePresets.all.map((t) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DirectorTemplateEditorPage(
                          presetToCopy: t,
                        ),
                      ),
                    ),
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.name,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(t.category,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                          const Spacer(),
                          const Text('点击复制 →',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.deepPurple)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          // 我的模板列表
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: const [
                Icon(Icons.folder_special, color: Colors.indigo, size: 18),
                SizedBox(width: 8),
                Text('我的模板',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: customTemplates.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.style, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('还没有自定义模板',
                              style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 4),
                          Text('点击右上角 ✚ 或复制预置模板',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: customTemplates.length,
                    itemBuilder: (_, i) {
                      final t = customTemplates[i];
                      final isSelected = t.id == settings.directorTemplateId;
                      return ListTile(
                        leading: const Icon(Icons.style, color: Colors.indigo),
                        title: Text(t.name),
                        subtitle: Text(
                          '${t.category} · ${t.role.substring(0, t.role.length > 20 ? 20 : t.role.length)}…',
                          maxLines: 1,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Colors.green)
                            else
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(voiceSettingsProvider.notifier)
                                      .setDirectorTemplateId(t.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('已切换到「${t.name}」'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: const Text('使用'),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DirectorTemplateEditorPage(
                                    editing: t,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, ref, t),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DirectorTemplate t,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除模板'),
        content: Text('确定要删除「${t.name}」吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(voiceSettingsProvider.notifier).deleteCustomTemplate(t.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已删除「${t.name}」')),
        );
      }
    }
  }
}

/// 导演模板三段式编辑器
class DirectorTemplateEditorPage extends ConsumerStatefulWidget {
  /// 编辑现有自定义模板
  final DirectorTemplate? editing;

  /// 从预置模板复制为新模板
  final DirectorTemplate? presetToCopy;

  const DirectorTemplateEditorPage({
    super.key,
    this.editing,
    this.presetToCopy,
  });

  @override
  ConsumerState<DirectorTemplateEditorPage> createState() =>
      _DirectorTemplateEditorPageState();
}

class _DirectorTemplateEditorPageState
    extends ConsumerState<DirectorTemplateEditorPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _roleController;
  late final TextEditingController _sceneController;
  late final TextEditingController _directionController;
  String _category = '自定义';

  static const _categories = ['自定义', '基础人设', '复杂情绪', '情色系', '特殊场景'];

  @override
  void initState() {
    super.initState();
    final src = widget.editing ?? widget.presetToCopy;
    _nameController = TextEditingController(
      text: src != null
          ? (widget.editing != null ? src.name : '${src.name}·副本')
          : '',
    );
    _roleController = TextEditingController(text: src?.role ?? '');
    _sceneController = TextEditingController(text: src?.scene ?? '');
    _directionController = TextEditingController(text: src?.direction ?? '');
    if (src != null) {
      _category = src.category;
    }
    // 实时刷新预览
    for (final c in [
      _nameController,
      _roleController,
      _sceneController,
      _directionController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _sceneController.dispose();
    _directionController.dispose();
    super.dispose();
  }

  /// 实时拼接预览
  String get _preview {
    final buffer = StringBuffer();
    if (_roleController.text.isNotEmpty) {
      buffer.write('角色：${_roleController.text}\n');
    }
    if (_sceneController.text.isNotEmpty) {
      buffer.write('场景：${_sceneController.text}\n');
    }
    if (_directionController.text.isNotEmpty) {
      buffer.write('指导：${_directionController.text}');
    }
    return buffer.toString().trimRight();
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      (_roleController.text.isNotEmpty ||
          _sceneController.text.isNotEmpty ||
          _directionController.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑模板' : '创建模板'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _canSave ? _save : null,
            tooltip: '保存',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 名称 + 分类
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '模板名称 *',
                    hintText: '例如：御姐·冷艳',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: _category,
                  items: _categories
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _category = v);
                  },
                  decoration: const InputDecoration(
                    labelText: '分类',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 角色
          TextField(
            controller: _roleController,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: '角色（身份、性格、说话习惯）',
              hintText: '例如：一位神秘而强大的女性长辈。言语不多但每一句都掷地有声。',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),

          // 场景
          TextField(
            controller: _sceneController,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: '场景（时间、事件、对方反应）',
              hintText: '例如：深夜，对方疲惫地来到她面前寻求指引。她表面冷淡，但已准备好一盏热茶。',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),

          // 指导
          TextField(
            controller: _directionController,
            minLines: 4,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: '指导（语速、气息、共鸣点、句中停顿）',
              hintText: '例如：语速缓慢（每分钟 180-220 字），语调低沉而稳。'
                  '句中停顿 0.5-1.0 秒。共鸣点靠后（胸腔深处），音色略带沙哑。',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),

          // 实时预览
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.deepPurple.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.preview, color: Colors.deepPurple, size: 18),
                    SizedBox(width: 6),
                    Text('实时预览（将发送给 MiMo 的导演描述）',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple)),
                  ],
                ),
                const Divider(height: 12),
                SelectableText(
                  _preview.isEmpty ? '（空）' : _preview,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 字数统计
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '总字数：${_preview.length}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '建议 ≤ 500 字',
                style: TextStyle(
                  fontSize: 12,
                  color: _preview.length > 500 ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 保存按钮（大）
          FilledButton.icon(
            onPressed: _canSave ? _save : null,
            icon: const Icon(Icons.save),
            label: Text(isEditing ? '保存修改' : '保存为我的模板'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    final id = widget.editing?.id ??
        'custom_${DateTime.now().millisecondsSinceEpoch}';

    final t = DirectorTemplate(
      id: id,
      name: name,
      category: _category,
      role: _roleController.text.trim(),
      scene: _sceneController.text.trim(),
      direction: _directionController.text.trim(),
      isPreset: false,
    );

    final notifier = ref.read(voiceSettingsProvider.notifier);
    if (widget.editing != null) {
      notifier.updateCustomTemplate(t);
    } else {
      notifier.addCustomTemplate(t);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.editing != null ? '已更新' : '已创建模板')),
    );
    Navigator.pop(context);
  }
}
