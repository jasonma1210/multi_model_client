// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'MJ Nexus Series:灵犀通';

  @override
  String get sessions => '会话';

  @override
  String get models => '模型';

  @override
  String get knowledge => '知识库';

  @override
  String get settings => '设置';

  @override
  String get downloadManager => '下载管理';

  @override
  String get clearCompleted => '清除已完成记录';

  @override
  String get createSession => '创建会话';

  @override
  String get newSession => '新会话';

  @override
  String get sessionName => '会话名称';

  @override
  String get enterSessionName => '输入会话名称';

  @override
  String get selectModel => '选择模型';

  @override
  String get model => '模型';

  @override
  String get create => '创建';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get export => '导出';

  @override
  String get rename => '重命名';

  @override
  String get clear => '清空';

  @override
  String get retry => '重试';

  @override
  String get close => '关闭';

  @override
  String get save => '保存';

  @override
  String get loading => '加载中';

  @override
  String get error => '错误';

  @override
  String get noSessionsYet => '暂无会话';

  @override
  String get startConversation => '开始与您的AI模型对话';

  @override
  String get sessionCreated => '会话创建成功';

  @override
  String get sessionDeleted => '会话已删除';

  @override
  String get sessionRenamed => '会话已重命名';

  @override
  String get messagesCleared => '消息已清空';

  @override
  String get modelChanged => '模型已更改';

  @override
  String get startConversationTitle => '开始对话';

  @override
  String get sendMessage => '发送消息开始与AI聊天';

  @override
  String get typeMessage => '输入消息...';

  @override
  String get send => '发送';

  @override
  String get stop => '停止';

  @override
  String get generating => '生成中...';

  @override
  String get attachFile => '附件';

  @override
  String get exportSession => '导出会话';

  @override
  String get renameSession => '重命名会话';

  @override
  String get newName => '新名称';

  @override
  String get changeModel => '更改模型';

  @override
  String get clearMessages => '清空消息';

  @override
  String get clearMessagesConfirm => '确定要清空所有消息吗？此操作无法撤销。';

  @override
  String get deleteSessionConfirm => '确定要删除此会话吗？此操作无法撤销。';

  @override
  String get appearance => '外观';

  @override
  String get theme => '主题';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get system => '跟随系统';

  @override
  String get chooseTheme => '选择主题';

  @override
  String get language => '语言';

  @override
  String get chooseLanguage => '选择语言';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';

  @override
  String get modelManagement => '模型管理';

  @override
  String get configureModels => '配置本地和远程模型';

  @override
  String get downloadModels => '下载模型';

  @override
  String get huggingFaceModelScope => 'Hugging Face 和魔搭社区';

  @override
  String get memorySettings => '记忆设置';

  @override
  String get configureMemory => '配置记忆提取';

  @override
  String get knowledgeBase => '知识库';

  @override
  String get manageKnowledgeBases => '管理知识库';

  @override
  String get voiceSettings => '语音设置';

  @override
  String get textToSpeechConfig => '文本转语音配置';

  @override
  String get dataStorage => '数据与存储';

  @override
  String get storage => '存储';

  @override
  String get manageDataCache => '管理本地数据和缓存';

  @override
  String get backupExport => '备份与导出';

  @override
  String get exportBackupData => '导出或备份您的数据';

  @override
  String get storageInfo => '存储信息';

  @override
  String get database => '数据库';

  @override
  String get cache => '缓存';

  @override
  String get total => '总计';

  @override
  String get clearCache => '清空缓存';

  @override
  String get cacheCleared => '缓存已清空';

  @override
  String get clearCacheFailed => '清空缓存失败';

  @override
  String get exportDatabase => '导出数据库';

  @override
  String get exportAllData => '导出所有会话和设置';

  @override
  String get importDatabase => '导入数据库';

  @override
  String get importFromBackup => '从备份文件导入';

  @override
  String get exportSessions => '导出会话';

  @override
  String get exportSpecificSessions => '导出特定会话为文本';

  @override
  String get about => '关于';

  @override
  String get version => '版本';

  @override
  String get latest => '最新版';

  @override
  String get openSourceLicenses => '开源许可证';

  @override
  String get comingSoon => '此功能即将推出';

  @override
  String get searchSessions => '搜索会话';

  @override
  String get filterSessions => '筛选会话';

  @override
  String get failedToLoadSessions => '加载会话失败';

  @override
  String get failedToLoadMessages => '加载消息失败';

  @override
  String get failedToCreateSession => '创建会话失败';

  @override
  String get failedToDeleteSession => '删除会话失败';

  @override
  String get failedToSendMessage => '发送消息失败';

  @override
  String get loadingMessages => '正在加载消息...';

  @override
  String get loadingSessions => '正在加载会话...';

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(int count) {
    return '$count分钟前';
  }

  @override
  String hoursAgo(int count) {
    return '$count小时前';
  }

  @override
  String daysAgo(int count) {
    return '$count天前';
  }

  @override
  String get voiceDialog => '语音对话';

  @override
  String get voiceDialogSettings => '语音对话设置';

  @override
  String get startVoiceDialog => '开始语音对话';

  @override
  String get stopVoiceDialog => '停止语音对话';

  @override
  String get listening => '正在聆听...';

  @override
  String get thinking => '正在思考...';

  @override
  String get speaking => '正在说话...';

  @override
  String get voiceInput => '语音输入';

  @override
  String get voiceOutput => '语音输出';

  @override
  String get voiceModel => '语音模型';

  @override
  String get enableVoiceInput => '启用语音输入';

  @override
  String get enableVoiceOutput => '启用语音输出';

  @override
  String get appLock => '应用锁';

  @override
  String get enableAppLock => '启用应用锁';

  @override
  String get disableAppLock => '禁用应用锁';

  @override
  String get setPin => '设置PIN码';

  @override
  String get enterPin => '输入PIN码';

  @override
  String get confirmPin => '确认PIN码';

  @override
  String get pinMismatch => 'PIN码不匹配';

  @override
  String get wrongPin => 'PIN码错误';

  @override
  String get enableBiometric => '启用生物识别';

  @override
  String get biometricAuth => '生物识别认证';

  @override
  String get faceId => 'Face ID';

  @override
  String get touchId => 'Touch ID';

  @override
  String get fingerprint => '指纹';

  @override
  String get share => '分享';

  @override
  String get shareAsMarkdown => '分享为Markdown';

  @override
  String get shareAsText => '分享为文本';

  @override
  String get shareAsPdf => '分享为PDF';

  @override
  String get shareSession => '分享会话';

  @override
  String get shareKnowledgeBase => '分享知识库';

  @override
  String get shareMemory => '分享记忆';

  @override
  String get backup => '备份';

  @override
  String get backupData => '备份数据';

  @override
  String get restoreData => '恢复数据';

  @override
  String get backupSuccess => '备份成功';

  @override
  String get backupFailed => '备份失败';

  @override
  String get restoreSuccess => '恢复成功';

  @override
  String get restoreFailed => '恢复失败';

  @override
  String get lastBackup => '上次备份';

  @override
  String get noBackup => '暂无备份';

  @override
  String get localModel => '本地模型';

  @override
  String get remoteModel => '远程模型';

  @override
  String get addLocalModel => '添加本地模型';

  @override
  String get addRemoteModel => '添加远程模型';

  @override
  String get modelSettings => '模型设置';

  @override
  String get inferenceParams => '推理参数';

  @override
  String get temperature => '温度';

  @override
  String get topP => 'Top P';

  @override
  String get maxTokens => '最大令牌数';

  @override
  String get folder => '文件夹';

  @override
  String get folders => '文件夹';

  @override
  String get createFolder => '创建文件夹';

  @override
  String get folderName => '文件夹名称';

  @override
  String get enterFolderName => '输入文件夹名称';

  @override
  String get moveToFolder => '移动到文件夹';

  @override
  String get pinSession => '置顶会话';

  @override
  String get unpinSession => '取消置顶';

  @override
  String get archiveSession => '归档会话';

  @override
  String get unarchiveSession => '取消归档';

  @override
  String get archivedSessions => '已归档会话';

  @override
  String get prompt => '提示词';

  @override
  String get prompts => '提示词';

  @override
  String get systemPrompt => '系统提示词';

  @override
  String get promptTemplate => '提示词模板';

  @override
  String get createPrompt => '创建提示词';

  @override
  String get editPrompt => '编辑提示词';

  @override
  String get promptVariables => '提示词变量';

  @override
  String get promptCategory => '提示词分类';

  @override
  String get mcpServer => 'MCP服务器';

  @override
  String get mcpServers => 'MCP服务器';

  @override
  String get addMcpServer => '添加MCP服务器';

  @override
  String get mcpServerName => '服务器名称';

  @override
  String get mcpServerUrl => '服务器地址';

  @override
  String get connectMcpServer => '连接MCP服务器';

  @override
  String get disconnectMcpServer => '断开MCP服务器';

  @override
  String get mcpServerConnected => '已连接';

  @override
  String get mcpServerDisconnected => '未连接';

  @override
  String get skill => '技能';

  @override
  String get skills => '技能';

  @override
  String get skillMarket => '技能市场';

  @override
  String get builtinSkills => '内置技能';

  @override
  String get customSkills => '自定义技能';

  @override
  String get addSkill => '添加技能';

  @override
  String get enableSkill => '启用技能';

  @override
  String get disableSkill => '禁用技能';

  @override
  String get videoUnderstanding => '视频理解';

  @override
  String get extractFrames => '提取关键帧';

  @override
  String get analyzeVideo => '分析视频';

  @override
  String get videoAnalysis => '视频分析';

  @override
  String get frameExtraction => '帧提取';

  @override
  String get search => '搜索';

  @override
  String get searchResults => '搜索结果';

  @override
  String get noResults => '无结果';

  @override
  String get searchPlaceholder => '搜索...';

  @override
  String get confirm => '确认';

  @override
  String get confirmAction => '确认操作';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get ok => '确定';

  @override
  String get apply => '应用';

  @override
  String get reset => '重置';

  @override
  String get refresh => '刷新';

  @override
  String get update => '更新';

  @override
  String get install => '安装';

  @override
  String get uninstall => '卸载';

  @override
  String get download => '下载';

  @override
  String get upload => '上传';

  @override
  String get copy => '复制';

  @override
  String get paste => '粘贴';

  @override
  String get cut => '剪切';

  @override
  String get selectAll => '全选';

  @override
  String get success => '成功';

  @override
  String get warning => '警告';

  @override
  String get info => '提示';

  @override
  String get confirmDelete => '确认删除';

  @override
  String get confirmClear => '确认清空';

  @override
  String get operationFailed => '操作失败';

  @override
  String get operationSuccess => '操作成功';

  @override
  String get networkError => '网络错误';

  @override
  String get unknownError => '未知错误';

  @override
  String get localModels => '本地模型';

  @override
  String get remoteApi => '远程 API';

  @override
  String get importModel => '导入模型';

  @override
  String get downloadModel => '下载模型';

  @override
  String get selectModelFolder => '选择模型文件夹';

  @override
  String get noGgufFilesFound => '未找到 GGUF 模型文件';

  @override
  String get modelAlreadyExists => '模型已存在';

  @override
  String get modelImported => '模型已导入';

  @override
  String modelImportedSuccess(int count) {
    return '成功导入 $count 个模型';
  }

  @override
  String get storagePathConfig => '存储位置配置';

  @override
  String get customStoragePaths => '自定义各类型文件的存储位置。留空则使用默认路径。';

  @override
  String get modelDownloadPath => '模型下载目录';

  @override
  String get modelDownloadPathDesc => '本地模型文件存储位置';

  @override
  String get knowledgeBasePath => '知识库目录';

  @override
  String get knowledgeBasePathDesc => '上传的文档和向量数据存储位置';

  @override
  String get backupPath => '备份目录';

  @override
  String get backupPathDesc => '数据备份文件存储位置';

  @override
  String get logPath => '日志目录';

  @override
  String get logPathDesc => '应用日志文件存储位置';

  @override
  String get databasePath => '数据库目录';

  @override
  String get databasePathDesc => '应用数据库文件存储位置（不可修改）';

  @override
  String get refreshPaths => '刷新路径';

  @override
  String get directoryUpdated => '目录已更新';

  @override
  String get selectDirectory => '选择目录';

  @override
  String get custom => '自定义';

  @override
  String get restoreDefaults => '恢复默认';

  @override
  String get confirmRestoreDefaults => '确定要恢复默认路径吗？';

  @override
  String get defaultsRestored => '已恢复默认路径';

  @override
  String get logManagement => '日志管理';

  @override
  String get appLogs => '应用日志';

  @override
  String get allLogs => '全部日志';

  @override
  String get errorLogs => '错误日志';

  @override
  String get warnLogs => '警告日志';

  @override
  String get infoLogs => '信息日志';

  @override
  String get debugLogs => '调试日志';

  @override
  String get noLogs => '暂无日志';

  @override
  String get clearLogs => '清空日志';

  @override
  String get clearLogsConfirm => '确定要清空所有日志吗？';

  @override
  String get logsCleared => '日志已清空';

  @override
  String get exportLogs => '导出日志';

  @override
  String get logDetails => '日志详情';

  @override
  String get logTime => '时间';

  @override
  String get logLevel => '日志级别';

  @override
  String get logMessage => '消息';

  @override
  String get logSource => '来源';

  @override
  String get pluginManagement => '插件管理';

  @override
  String get installedPlugins => '已安装插件';

  @override
  String get availablePlugins => '可用插件';

  @override
  String get pluginSettings => '插件设置';

  @override
  String get installPlugin => '安装插件';

  @override
  String get uninstallPlugin => '卸载插件';

  @override
  String get pluginEnabled => '插件已启用';

  @override
  String get pluginDisabled => '插件已禁用';

  @override
  String get pluginInstallSuccess => '插件安装成功';

  @override
  String get pluginInstallFailed => '插件安装失败';

  @override
  String get pluginUninstallSuccess => '插件卸载成功';

  @override
  String get pluginUninstallConfirm => '确定要卸载此插件吗？';

  @override
  String get noPluginsInstalled => '暂无已安装插件';

  @override
  String get browsePlugins => '浏览插件';

  @override
  String get skillCenter => '技能中心';

  @override
  String get builtInSkills => '内置技能';

  @override
  String get customSkillsList => '自定义技能';

  @override
  String get skillSettings => '技能设置';

  @override
  String get skillEnabled => '技能已启用';

  @override
  String get skillDisabled => '技能已禁用';

  @override
  String get configureSkill => '配置技能';

  @override
  String get skillDescription => '技能描述';

  @override
  String get skillParameters => '技能参数';

  @override
  String get userManual => '使用说明书';

  @override
  String get gettingStarted => '快速开始';

  @override
  String get features => '功能介绍';

  @override
  String get faq => '常见问题';

  @override
  String get troubleshooting => '故障排除';

  @override
  String get aboutApp => '关于应用';

  @override
  String get mmprojModels => '投影仪模型';

  @override
  String get multimodalModel => '多模态模型';

  @override
  String get visionModel => '视觉模型';

  @override
  String get selectMmproj => '选择投影仪';

  @override
  String get mmprojRequired => '需要投影仪才能使用多模态功能';

  @override
  String get confirmDeleteModel => '确定要删除此模型吗？';

  @override
  String get modelDeleted => '模型已删除';

  @override
  String get confirmDeleteMmproj => '确定要删除此投影仪吗？';

  @override
  String get mmprojDeleted => '投影仪已删除';

  @override
  String get modelType => '模型类型';

  @override
  String get quantization => '量化级别';

  @override
  String get contextLength => '上下文长度';

  @override
  String get gpuOffload => 'GPU 卸载';

  @override
  String get nGpuLayers => 'GPU 层数';

  @override
  String get threads => '线程数';

  @override
  String get batchSize => '批处理大小';

  @override
  String get apiProvider => 'API 提供商';

  @override
  String get apiKey => 'API 密钥';

  @override
  String get apiEndpoint => 'API 端点';

  @override
  String get baseUrl => '基础 URL';

  @override
  String get enterApiKey => '输入 API 密钥';

  @override
  String get enterEndpoint => '输入 API 端点';

  @override
  String get testConnection => '测试连接';

  @override
  String get connectionSuccess => '连接成功';

  @override
  String get connectionFailed => '连接失败';

  @override
  String get topK => 'Top K';

  @override
  String get repeatPenalty => '重复惩罚';

  @override
  String get presencePenalty => '存在惩罚';

  @override
  String get frequencyPenalty => '频率惩罚';

  @override
  String get modelParams => '模型参数';

  @override
  String get inferenceSettings => '推理设置';

  @override
  String get advancedSettings => '高级设置';

  @override
  String get resetToDefaults => '恢复默认设置';

  @override
  String get emptyStateHint => '暂无内容';

  @override
  String get tapToRetry => '点击重试';

  @override
  String get loadingFailed => '加载失败';

  @override
  String get operationInProgress => '操作进行中...';

  @override
  String get noLocalModels => '还没有本地模型';

  @override
  String get downloadOrImportHint =>
      '您可以从模型市场下载 GGUF 量化模型，\n或者导入已有的本地 .gguf 文件。';

  @override
  String get modelMarket => '模型市场';

  @override
  String get loadedModel => '已加载模型';

  @override
  String get unloadModel => '卸载模型';

  @override
  String get loadModel => '加载模型';

  @override
  String get modelLoaded => '模型已加载';

  @override
  String get modelUnloaded => '模型已卸载';

  @override
  String get deleteModel => '删除模型';

  @override
  String get editModel => '编辑模型';

  @override
  String get modelInfo => '模型信息';

  @override
  String get fileSize => '文件大小';

  @override
  String get filePath => '文件路径';

  @override
  String get parameters => '参数';

  @override
  String get quantizationLevel => '量化级别';

  @override
  String get unloading => '卸载中';

  @override
  String get scanning => '扫描中';

  @override
  String get scanningModels => '正在扫描模型...';

  @override
  String get remoteModels => '远程模型';

  @override
  String get editRemoteModel => '编辑远程模型';

  @override
  String get deleteRemoteModel => '删除远程模型';

  @override
  String get remoteModelConnected => '已连接';

  @override
  String get remoteModelDisconnected => '未连接';

  @override
  String get noRemoteModels => '暂无远程模型';

  @override
  String get addRemoteModelHint => '点击添加远程 API 模型';

  @override
  String get openai => 'OpenAI';

  @override
  String get anthropic => 'Anthropic';

  @override
  String get ollama => 'Ollama';

  @override
  String get selectKnowledgeBaseFolder => '选择知识库目录';

  @override
  String get selectBackupFolder => '选择备份目录';

  @override
  String get selectLogFolder => '选择日志目录';

  @override
  String get aiFeatures => 'AI 功能';

  @override
  String get pluginManagementDesc => '管理多模态解析插件（OCR、ASR、TTS）';

  @override
  String get skillCenterDesc => '浏览、管理和创建自定义技能';

  @override
  String get storagePathConfigDesc => '自定义模型、知识库、备份等文件存储位置';

  @override
  String get logManagementDesc => '查看和导出应用日志';

  @override
  String get helpGuide => '帮助与指南';

  @override
  String get userManualDesc => '0基础入门指南、模型下载教程';

  @override
  String get multimodalPluginsInfo => '多模态插件说明';

  @override
  String get builtinPluginsInfo =>
      '内置插件：OCR（iOS Vision / Android ML Kit）、视频音频提取（系统 API）';

  @override
  String get downloadOnDemandInfo => '按需下载：首次使用相关功能时自动提示下载';

  @override
  String get voiceSettingsIntegrationInfo => '语音设置整合：ASR/TTS 模型与语音设置页面共享';

  @override
  String get downloading => '下载中';

  @override
  String get downloaded => '已下载';

  @override
  String get notDownloaded => '未下载';

  @override
  String get deletePlugin => '删除插件';

  @override
  String get ocrPlugins => '文字识别 (OCR)';

  @override
  String get audioExtractorPlugins => '视频音频提取';

  @override
  String get voiceModelManagement => '语音模型管理';

  @override
  String get voiceModelManagementHint =>
      'ASR 语音识别模型和 TTS 语音合成模型在「语音设置」中管理，请前往设置 → 语音设置 进行配置。';

  @override
  String get goToVoiceSettings => '前往语音设置';

  @override
  String get managedInSettings => '设置中可管理';

  @override
  String get selected => '已选';

  @override
  String get deleteSelected => '删除选中';

  @override
  String get exportSelected => '导出选中';

  @override
  String get exportAll => '导出全部';

  @override
  String get clearFilters => '清除筛选';

  @override
  String get logCategory => '日志分类';

  @override
  String get loadingLogsFailed => '加载日志失败';

  @override
  String get loadingMoreLogsFailed => '加载更多日志失败';

  @override
  String get exportFailed => '导出失败';

  @override
  String get noLogsToExport => '没有日志可导出';

  @override
  String get logsExported => '日志已导出';

  @override
  String get deleteSuccess => '删除成功';

  @override
  String get noLogsToShow => '暂无日志';

  @override
  String get logLevelError => '错误';

  @override
  String get logLevelWarning => '警告';

  @override
  String get logLevelInfo => '信息';

  @override
  String get logLevelDebug => '调试';

  @override
  String get whatIsLocalModel => '什么是本地模型？';

  @override
  String get howToDownloadModel => '如何下载模型？';

  @override
  String get whatIsQuantization => '量化模型是什么？';

  @override
  String get howToChooseModel => '如何选择适合自己的模型？';

  @override
  String get whatIsMmproj => '什么是 mmproj？';

  @override
  String get startUsing => '开始使用';

  @override
  String get localModelDescription =>
      '本地模型是指将 AI 大模型文件（如 GGUF 格式）下载到您的设备上，直接在本地运行。';

  @override
  String get localModelAdvantages => '本地模型的优势';

  @override
  String get downloadModelIntro => '应用内置了模型市场，您可以从这里浏览和下载模型。';

  @override
  String get tips => '温馨提示';

  @override
  String get featuredModels => '精选推荐';

  @override
  String get trending => '热门排行';

  @override
  String get trendingModels => '热门模型';

  @override
  String get suitableForLocal => '适合本地部署的 GGUF 量化模型';

  @override
  String get noRecommendedModels => '暂无推荐模型';

  @override
  String get noTrendingModels => '暂无热门模型';

  @override
  String get loadTrendingFailed => '加载热门模型失败';

  @override
  String get searchFailed => '搜索失败';

  @override
  String get ggufFiles => 'GGUF 文件';

  @override
  String get noGgufFilesHint => '未找到 GGUF 量化文件，此模型可能不支持本地部署';

  @override
  String get multimodalProjector => '多模态投影仪 (mmproj)';

  @override
  String get mmprojHint => '用于支持图片/视频理解，需要与 GGUF 模型一起下载';

  @override
  String get modelIntro => '模型简介';

  @override
  String get downloadComplete => '下载完成';

  @override
  String get loadLater => '稍后加载';

  @override
  String get loadNow => '立即加载';

  @override
  String get loadingModel => '正在加载模型...';

  @override
  String get modelLoadSuccess => '模型加载成功';

  @override
  String modelReadyToChat(String name) {
    return '$name 已加载完成，可以开始对话了。';
  }

  @override
  String get later => '稍后再说';

  @override
  String get startChat => '开始对话';

  @override
  String get modelLoadFailed => '模型加载失败';

  @override
  String modelAddedToList(String name) {
    return '$name 已添加到模型列表';
  }

  @override
  String get view => '查看';

  @override
  String get chineseOptimized => '中文优化';

  @override
  String get codeGeneration => '代码生成';

  @override
  String get mathReasoning => '数学推理';

  @override
  String get generalChat => '通用对话';

  @override
  String get loadConfigHint => '将使用默认配置加载模型 (CPU + 6线程)';

  @override
  String get deviceCompatibility => '设备兼容性问题';

  @override
  String get availableMemory => '可用内存';

  @override
  String get availableStorage => '可用存储';

  @override
  String get storageRequired => '存储需求';

  @override
  String get memoryRequired => '内存需求';

  @override
  String get parameterCount => '参数量';

  @override
  String get quantFormat => '量化格式';

  @override
  String get deviceNotMeetMin => '设备不满足最低要求';

  @override
  String get forceDownloadWarning => '强行下载可能导致模型无法加载或运行缓慢。';

  @override
  String get tipsTitle => '温馨提示';

  @override
  String get visionSupport => '多模态支持 (Vision)';

  @override
  String get visionSupportHint => '此模型支持图片/视频理解。启用后将同时下载 mmproj 投影仪文件。';

  @override
  String get enableVisionSupport => '启用 Vision 支持';

  @override
  String get lowMemoryVisionWarning => '内存较小（<16GB），不建议启用 Vision';

  @override
  String get startDownload => '开始下载';

  @override
  String get stillDownload => '仍要下载';

  @override
  String get detectingCompatibility => '正在检测设备兼容性...';

  @override
  String get multimodal => '多模态';

  @override
  String get mmprojAlreadyExists => 'mmproj 投影仪文件已存在，跳过下载';

  @override
  String get mmprojDownloadComplete => 'mmproj 投影仪文件下载完成';

  @override
  String get mmprojDownloadFailed => 'mmproj 下载失败';

  @override
  String get createDownloadTaskFailed => '创建下载任务失败';

  @override
  String get downloadStartFailed => '下载启动失败';

  @override
  String downloadFailed(String error) {
    return '下载失败: $error';
  }

  @override
  String get modelDownloadedToLocal => '模型已成功下载到本地。';

  @override
  String get ramRequired => '内存需求';

  @override
  String exceedsCurrentConfig(String reasons) {
    return '超过当前配置: $reasons';
  }

  @override
  String get downloadModelHint => '下载完成后将自动注册到本地模型，您可以在模型管理中查看和加载。';

  @override
  String get downloadAnywayHint => '仍可尝试下载，但可能无法正常使用。';

  @override
  String get loadConfigChinese => '将使用中文语言模型配置加载 (CPU + 8线程)';

  @override
  String get loadConfigCode => '将使用代码模型配置加载 (CPU + 4线程, 4096上下文)';

  @override
  String get loadConfigReasoning => '将使用推理模型配置加载 (CPU + 8线程, 8192上下文)';

  @override
  String get mmprojInfo =>
      '此模型支持图片/视频理解。mmproj 是多模态 image-to-text 的必要组件。\n\n⚠️ 注意：如果内存较小（<16GB），不建议加载 mmproj，会占用额外内存。';
}
