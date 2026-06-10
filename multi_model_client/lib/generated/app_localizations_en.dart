// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MJ Nexus Series:Synpse';

  @override
  String get sessions => 'Sessions';

  @override
  String get models => 'Models';

  @override
  String get knowledge => 'Knowledge';

  @override
  String get settings => 'Settings';

  @override
  String get downloadManager => 'Download Manager';

  @override
  String get clearCompleted => 'Clear Completed';

  @override
  String get createSession => 'Create Session';

  @override
  String get newSession => 'New Session';

  @override
  String get sessionName => 'Session Name';

  @override
  String get enterSessionName => 'Enter session name';

  @override
  String get selectModel => 'Select Model';

  @override
  String get model => 'Model';

  @override
  String get create => 'Create';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get export => 'Export';

  @override
  String get rename => 'Rename';

  @override
  String get clear => 'Clear';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get loading => 'Loading';

  @override
  String get error => 'Error';

  @override
  String get noSessionsYet => 'No Sessions Yet';

  @override
  String get startConversation => 'Start a conversation with your AI models';

  @override
  String get sessionCreated => 'Session created successfully';

  @override
  String get sessionDeleted => 'Session deleted';

  @override
  String get sessionRenamed => 'Session renamed';

  @override
  String get messagesCleared => 'Messages cleared';

  @override
  String get modelChanged => 'Model changed';

  @override
  String get startConversationTitle => 'Start a Conversation';

  @override
  String get sendMessage => 'Send a message to begin chatting with the AI';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get send => 'Send';

  @override
  String get stop => 'Stop';

  @override
  String get generating => 'Generating...';

  @override
  String get attachFile => 'Attach file';

  @override
  String get exportSession => 'Export session';

  @override
  String get renameSession => 'Rename Session';

  @override
  String get newName => 'New Name';

  @override
  String get changeModel => 'Change Model';

  @override
  String get clearMessages => 'Clear Messages';

  @override
  String get clearMessagesConfirm =>
      'Are you sure you want to clear all messages? This action cannot be undone.';

  @override
  String get deleteSessionConfirm =>
      'Are you sure you want to delete this session? This action cannot be undone.';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get language => 'Language';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';

  @override
  String get modelManagement => 'Model Management';

  @override
  String get configureModels => 'Configure local and remote models';

  @override
  String get downloadModels => 'Download Models';

  @override
  String get huggingFaceModelScope => 'Hugging Face & ModelScope';

  @override
  String get memorySettings => 'Memory Settings';

  @override
  String get configureMemory => 'Configure memory extraction';

  @override
  String get knowledgeBase => 'Knowledge Base';

  @override
  String get manageKnowledgeBases => 'Manage knowledge bases';

  @override
  String get voiceSettings => 'Voice Settings';

  @override
  String get textToSpeechConfig => 'Text-to-speech configuration';

  @override
  String get dataStorage => 'Data & Storage';

  @override
  String get storage => 'Storage';

  @override
  String get manageDataCache => 'Manage local data and cache';

  @override
  String get backupExport => 'Backup & Export';

  @override
  String get exportBackupData => 'Export or backup your data';

  @override
  String get storageInfo => 'Storage Info';

  @override
  String get database => 'Database';

  @override
  String get cache => 'Cache';

  @override
  String get total => 'Total';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get clearCacheFailed => 'Failed to clear cache';

  @override
  String get exportDatabase => 'Export Database';

  @override
  String get exportAllData => 'Export all sessions and settings';

  @override
  String get importDatabase => 'Import Database';

  @override
  String get importFromBackup => 'Import from a backup file';

  @override
  String get exportSessions => 'Export Sessions';

  @override
  String get exportSpecificSessions => 'Export specific sessions to text';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get latest => 'Latest';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get comingSoon => 'This feature is coming soon';

  @override
  String get searchSessions => 'Search sessions';

  @override
  String get filterSessions => 'Filter sessions';

  @override
  String get failedToLoadSessions => 'Failed to Load Sessions';

  @override
  String get failedToLoadMessages => 'Failed to Load Messages';

  @override
  String get failedToCreateSession => 'Failed to create session';

  @override
  String get failedToDeleteSession => 'Failed to delete session';

  @override
  String get failedToSendMessage => 'Failed to send message';

  @override
  String get loadingMessages => 'Loading messages...';

  @override
  String get loadingSessions => 'Loading sessions...';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get voiceDialog => 'Voice Dialog';

  @override
  String get voiceDialogSettings => 'Voice Dialog Settings';

  @override
  String get startVoiceDialog => 'Start Voice Dialog';

  @override
  String get stopVoiceDialog => 'Stop Voice Dialog';

  @override
  String get listening => 'Listening...';

  @override
  String get thinking => 'Thinking...';

  @override
  String get speaking => 'Speaking...';

  @override
  String get voiceInput => 'Voice Input';

  @override
  String get voiceOutput => 'Voice Output';

  @override
  String get voiceModel => 'Voice Model';

  @override
  String get enableVoiceInput => 'Enable Voice Input';

  @override
  String get enableVoiceOutput => 'Enable Voice Output';

  @override
  String get appLock => 'App Lock';

  @override
  String get enableAppLock => 'Enable App Lock';

  @override
  String get disableAppLock => 'Disable App Lock';

  @override
  String get setPin => 'Set PIN';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get pinMismatch => 'PIN mismatch';

  @override
  String get wrongPin => 'Wrong PIN';

  @override
  String get enableBiometric => 'Enable Biometric';

  @override
  String get biometricAuth => 'Biometric Authentication';

  @override
  String get faceId => 'Face ID';

  @override
  String get touchId => 'Touch ID';

  @override
  String get fingerprint => 'Fingerprint';

  @override
  String get share => 'Share';

  @override
  String get shareAsMarkdown => 'Share as Markdown';

  @override
  String get shareAsText => 'Share as Text';

  @override
  String get shareAsPdf => 'Share as PDF';

  @override
  String get shareSession => 'Share Session';

  @override
  String get shareKnowledgeBase => 'Share Knowledge Base';

  @override
  String get shareMemory => 'Share Memory';

  @override
  String get backup => 'Backup';

  @override
  String get backupData => 'Backup Data';

  @override
  String get restoreData => 'Restore Data';

  @override
  String get backupSuccess => 'Backup Success';

  @override
  String get backupFailed => 'Backup Failed';

  @override
  String get restoreSuccess => 'Restore Success';

  @override
  String get restoreFailed => 'Restore Failed';

  @override
  String get lastBackup => 'Last Backup';

  @override
  String get noBackup => 'No Backup';

  @override
  String get localModel => 'Local Model';

  @override
  String get remoteModel => 'Remote Model';

  @override
  String get addLocalModel => 'Add Local Model';

  @override
  String get addRemoteModel => 'Add Remote Model';

  @override
  String get modelSettings => 'Model Settings';

  @override
  String get inferenceParams => 'Inference Parameters';

  @override
  String get temperature => 'Temperature';

  @override
  String get topP => 'Top P';

  @override
  String get maxTokens => 'Max Tokens';

  @override
  String get folder => 'Folder';

  @override
  String get folders => 'Folders';

  @override
  String get createFolder => 'Create Folder';

  @override
  String get folderName => 'Folder Name';

  @override
  String get enterFolderName => 'Enter folder name';

  @override
  String get moveToFolder => 'Move to Folder';

  @override
  String get pinSession => 'Pin Session';

  @override
  String get unpinSession => 'Unpin Session';

  @override
  String get archiveSession => 'Archive Session';

  @override
  String get unarchiveSession => 'Unarchive Session';

  @override
  String get archivedSessions => 'Archived Sessions';

  @override
  String get prompt => 'Prompt';

  @override
  String get prompts => 'Prompts';

  @override
  String get systemPrompt => 'System Prompt';

  @override
  String get promptTemplate => 'Prompt Template';

  @override
  String get createPrompt => 'Create Prompt';

  @override
  String get editPrompt => 'Edit Prompt';

  @override
  String get promptVariables => 'Prompt Variables';

  @override
  String get promptCategory => 'Prompt Category';

  @override
  String get mcpServer => 'MCP Server';

  @override
  String get mcpServers => 'MCP Servers';

  @override
  String get addMcpServer => 'Add MCP Server';

  @override
  String get mcpServerName => 'Server Name';

  @override
  String get mcpServerUrl => 'Server URL';

  @override
  String get connectMcpServer => 'Connect MCP Server';

  @override
  String get disconnectMcpServer => 'Disconnect MCP Server';

  @override
  String get mcpServerConnected => 'Connected';

  @override
  String get mcpServerDisconnected => 'Disconnected';

  @override
  String get skill => 'Skill';

  @override
  String get skills => 'Skills';

  @override
  String get skillMarket => 'Skill Market';

  @override
  String get builtinSkills => 'Built-in Skills';

  @override
  String get customSkills => 'Custom Skills';

  @override
  String get addSkill => 'Add Skill';

  @override
  String get enableSkill => 'Enable Skill';

  @override
  String get disableSkill => 'Disable Skill';

  @override
  String get videoUnderstanding => 'Video Understanding';

  @override
  String get extractFrames => 'Extract Key Frames';

  @override
  String get analyzeVideo => 'Analyze Video';

  @override
  String get videoAnalysis => 'Video Analysis';

  @override
  String get frameExtraction => 'Frame Extraction';

  @override
  String get search => 'Search';

  @override
  String get searchResults => 'Search Results';

  @override
  String get noResults => 'No Results';

  @override
  String get searchPlaceholder => 'Search...';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmAction => 'Confirm Action';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get refresh => 'Refresh';

  @override
  String get update => 'Update';

  @override
  String get install => 'Install';

  @override
  String get uninstall => 'Uninstall';

  @override
  String get download => 'Download';

  @override
  String get upload => 'Upload';

  @override
  String get copy => 'Copy';

  @override
  String get paste => 'Paste';

  @override
  String get cut => 'Cut';

  @override
  String get selectAll => 'Select All';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get confirmClear => 'Confirm Clear';

  @override
  String get operationFailed => 'Operation Failed';

  @override
  String get operationSuccess => 'Operation Success';

  @override
  String get networkError => 'Network Error';

  @override
  String get unknownError => 'Unknown Error';

  @override
  String get localModels => 'Local Models';

  @override
  String get remoteApi => 'Remote API';

  @override
  String get importModel => 'Import Model';

  @override
  String get downloadModel => 'Download Model';

  @override
  String get selectModelFolder => 'Select Model Folder';

  @override
  String get noGgufFilesFound => 'No GGUF model files found';

  @override
  String get modelAlreadyExists => 'Model already exists';

  @override
  String get modelImported => 'Model Imported';

  @override
  String modelImportedSuccess(int count) {
    return 'Successfully imported $count models';
  }

  @override
  String get storagePathConfig => 'Storage Path Configuration';

  @override
  String get customStoragePaths =>
      'Customize storage paths for different file types. Leave empty to use default paths.';

  @override
  String get modelDownloadPath => 'Model Download Path';

  @override
  String get modelDownloadPathDesc => 'Local model file storage location';

  @override
  String get knowledgeBasePath => 'Knowledge Base Path';

  @override
  String get knowledgeBasePathDesc =>
      'Uploaded documents and vector data storage location';

  @override
  String get backupPath => 'Backup Path';

  @override
  String get backupPathDesc => 'Data backup file storage location';

  @override
  String get logPath => 'Log Path';

  @override
  String get logPathDesc => 'Application log file storage location';

  @override
  String get databasePath => 'Database Path';

  @override
  String get databasePathDesc =>
      'Application database file storage location (read-only)';

  @override
  String get refreshPaths => 'Refresh Paths';

  @override
  String get directoryUpdated => 'Directory Updated';

  @override
  String get selectDirectory => 'Select Directory';

  @override
  String get custom => 'Custom';

  @override
  String get restoreDefaults => 'Restore Defaults';

  @override
  String get confirmRestoreDefaults =>
      'Are you sure you want to restore default paths?';

  @override
  String get defaultsRestored => 'Default paths restored';

  @override
  String get logManagement => 'Log Management';

  @override
  String get appLogs => 'App Logs';

  @override
  String get allLogs => 'All Logs';

  @override
  String get errorLogs => 'Error Logs';

  @override
  String get warnLogs => 'Warning Logs';

  @override
  String get infoLogs => 'Info Logs';

  @override
  String get debugLogs => 'Debug Logs';

  @override
  String get noLogs => 'No Logs';

  @override
  String get clearLogs => 'Clear Logs';

  @override
  String get clearLogsConfirm => 'Are you sure you want to clear all logs?';

  @override
  String get logsCleared => 'Logs cleared';

  @override
  String get exportLogs => 'Export Logs';

  @override
  String get logDetails => 'Log Details';

  @override
  String get logTime => 'Time';

  @override
  String get logLevel => 'Log Level';

  @override
  String get logMessage => 'Message';

  @override
  String get logSource => 'Source';

  @override
  String get pluginManagement => 'Plugin Management';

  @override
  String get installedPlugins => 'Installed Plugins';

  @override
  String get availablePlugins => 'Available Plugins';

  @override
  String get pluginSettings => 'Plugin Settings';

  @override
  String get installPlugin => 'Install Plugin';

  @override
  String get uninstallPlugin => 'Uninstall Plugin';

  @override
  String get pluginEnabled => 'Plugin enabled';

  @override
  String get pluginDisabled => 'Plugin disabled';

  @override
  String get pluginInstallSuccess => 'Plugin installed successfully';

  @override
  String get pluginInstallFailed => 'Plugin installation failed';

  @override
  String get pluginUninstallSuccess => 'Plugin uninstalled successfully';

  @override
  String get pluginUninstallConfirm =>
      'Are you sure you want to uninstall this plugin?';

  @override
  String get noPluginsInstalled => 'No plugins installed';

  @override
  String get browsePlugins => 'Browse Plugins';

  @override
  String get skillCenter => 'Skill Center';

  @override
  String get builtInSkills => 'Built-in Skills';

  @override
  String get customSkillsList => 'Custom Skills';

  @override
  String get skillSettings => 'Skill Settings';

  @override
  String get skillEnabled => 'Skill enabled';

  @override
  String get skillDisabled => 'Skill disabled';

  @override
  String get configureSkill => 'Configure Skill';

  @override
  String get skillDescription => 'Skill Description';

  @override
  String get skillParameters => 'Skill Parameters';

  @override
  String get userManual => 'User Manual';

  @override
  String get gettingStarted => 'Getting Started';

  @override
  String get features => 'Features';

  @override
  String get faq => 'FAQ';

  @override
  String get troubleshooting => 'Troubleshooting';

  @override
  String get aboutApp => 'About App';

  @override
  String get mmprojModels => 'Projector Models';

  @override
  String get multimodalModel => 'Multimodal Model';

  @override
  String get visionModel => 'Vision Model';

  @override
  String get selectMmproj => 'Select Projector';

  @override
  String get mmprojRequired =>
      'A projector is required for multimodal functionality';

  @override
  String get confirmDeleteModel =>
      'Are you sure you want to delete this model?';

  @override
  String get modelDeleted => 'Model deleted';

  @override
  String get confirmDeleteMmproj =>
      'Are you sure you want to delete this projector?';

  @override
  String get mmprojDeleted => 'Projector deleted';

  @override
  String get modelType => 'Model Type';

  @override
  String get quantization => 'Quantization';

  @override
  String get contextLength => 'Context Length';

  @override
  String get gpuOffload => 'GPU Offload';

  @override
  String get nGpuLayers => 'GPU Layers';

  @override
  String get threads => 'Threads';

  @override
  String get batchSize => 'Batch Size';

  @override
  String get apiProvider => 'API Provider';

  @override
  String get apiKey => 'API Key';

  @override
  String get apiEndpoint => 'API Endpoint';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get enterApiKey => 'Enter API key';

  @override
  String get enterEndpoint => 'Enter API endpoint';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get connectionSuccess => 'Connection successful';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get topK => 'Top K';

  @override
  String get repeatPenalty => 'Repeat Penalty';

  @override
  String get presencePenalty => 'Presence Penalty';

  @override
  String get frequencyPenalty => 'Frequency Penalty';

  @override
  String get modelParams => 'Model Parameters';

  @override
  String get inferenceSettings => 'Inference Settings';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get resetToDefaults => 'Reset to Defaults';

  @override
  String get emptyStateHint => 'No content';

  @override
  String get tapToRetry => 'Tap to retry';

  @override
  String get loadingFailed => 'Loading failed';

  @override
  String get operationInProgress => 'Operation in progress...';

  @override
  String get noLocalModels => 'No Local Models Yet';

  @override
  String get downloadOrImportHint =>
      'You can download GGUF quantized models from the model market,\nor import existing local .gguf files.';

  @override
  String get modelMarket => 'Model Market';

  @override
  String get loadedModel => 'Loaded Model';

  @override
  String get unloadModel => 'Unload Model';

  @override
  String get loadModel => 'Load Model';

  @override
  String get modelLoaded => 'Model loaded';

  @override
  String get modelUnloaded => 'Model unloaded';

  @override
  String get deleteModel => 'Delete Model';

  @override
  String get editModel => 'Edit Model';

  @override
  String get modelInfo => 'Model Info';

  @override
  String get fileSize => 'File Size';

  @override
  String get filePath => 'File Path';

  @override
  String get parameters => 'Parameters';

  @override
  String get quantizationLevel => 'Quantization Level';

  @override
  String get unloading => 'Unloading';

  @override
  String get scanning => 'Scanning';

  @override
  String get scanningModels => 'Scanning models...';

  @override
  String get remoteModels => 'Remote Models';

  @override
  String get editRemoteModel => 'Edit Remote Model';

  @override
  String get deleteRemoteModel => 'Delete Remote Model';

  @override
  String get remoteModelConnected => 'Connected';

  @override
  String get remoteModelDisconnected => 'Disconnected';

  @override
  String get noRemoteModels => 'No Remote Models';

  @override
  String get addRemoteModelHint => 'Tap to add a remote API model';

  @override
  String get openai => 'OpenAI';

  @override
  String get anthropic => 'Anthropic';

  @override
  String get ollama => 'Ollama';

  @override
  String get selectKnowledgeBaseFolder => 'Select Knowledge Base Folder';

  @override
  String get selectBackupFolder => 'Select Backup Folder';

  @override
  String get selectLogFolder => 'Select Log Folder';

  @override
  String get aiFeatures => 'AI Features';

  @override
  String get pluginManagementDesc =>
      'Manage multimodal parsing plugins (OCR, ASR, TTS)';

  @override
  String get skillCenterDesc => 'Browse, manage, and create custom skills';

  @override
  String get storagePathConfigDesc =>
      'Customize model, knowledge base, backup storage locations';

  @override
  String get logManagementDesc => 'View and export application logs';

  @override
  String get helpGuide => 'Help & Guide';

  @override
  String get userManualDesc => 'Beginner\'s guide, model download tutorials';

  @override
  String get multimodalPluginsInfo => 'Multimodal Plugins Info';

  @override
  String get builtinPluginsInfo =>
      'Built-in plugins: OCR (iOS Vision / Android ML Kit), video/audio extraction (System API)';

  @override
  String get downloadOnDemandInfo =>
      'Download on demand: prompted when first using related features';

  @override
  String get voiceSettingsIntegrationInfo =>
      'Voice settings integration: ASR/TTS models shared with voice settings page';

  @override
  String get downloading => 'Downloading';

  @override
  String get downloaded => 'Downloaded';

  @override
  String get notDownloaded => 'Not downloaded';

  @override
  String get deletePlugin => 'Delete Plugin';

  @override
  String get ocrPlugins => 'Text Recognition (OCR)';

  @override
  String get audioExtractorPlugins => 'Video & Audio Extraction';

  @override
  String get voiceModelManagement => 'Voice Model Management';

  @override
  String get voiceModelManagementHint =>
      'ASR speech recognition models and TTS speech synthesis models are managed in Voice Settings. Go to Settings → Voice Settings to configure.';

  @override
  String get goToVoiceSettings => 'Go to Voice Settings';

  @override
  String get managedInSettings => 'Managed in Settings';

  @override
  String get selected => 'selected';

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String get exportSelected => 'Export Selected';

  @override
  String get exportAll => 'Export All';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get logCategory => 'Log Category';

  @override
  String get loadingLogsFailed => 'Failed to load logs';

  @override
  String get loadingMoreLogsFailed => 'Failed to load more logs';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get noLogsToExport => 'No logs to export';

  @override
  String get logsExported => 'Logs exported';

  @override
  String get deleteSuccess => 'Deleted successfully';

  @override
  String get noLogsToShow => 'No logs';

  @override
  String get logLevelError => 'Error';

  @override
  String get logLevelWarning => 'Warning';

  @override
  String get logLevelInfo => 'Info';

  @override
  String get logLevelDebug => 'Debug';

  @override
  String get whatIsLocalModel => 'What is a Local Model?';

  @override
  String get howToDownloadModel => 'How to Download Models?';

  @override
  String get whatIsQuantization => 'What are Quantized Models?';

  @override
  String get howToChooseModel => 'How to Choose the Right Model?';

  @override
  String get whatIsMmproj => 'What is mmproj?';

  @override
  String get startUsing => 'Getting Started';

  @override
  String get localModelDescription =>
      'A local model means downloading AI model files (such as GGUF format) to your device and running them locally.';

  @override
  String get localModelAdvantages => 'Advantages of Local Models';

  @override
  String get downloadModelIntro =>
      'The app has a built-in model market where you can browse and download models.';

  @override
  String get tips => 'Tips';

  @override
  String get featuredModels => 'Featured Models';

  @override
  String get trending => 'Trending';

  @override
  String get trendingModels => 'Trending Models';

  @override
  String get suitableForLocal =>
      'GGUF quantized models suitable for local deployment';

  @override
  String get noRecommendedModels => 'No recommended models';

  @override
  String get noTrendingModels => 'No trending models';

  @override
  String get loadTrendingFailed => 'Failed to load trending models';

  @override
  String get searchFailed => 'Search failed';

  @override
  String get ggufFiles => 'GGUF Files';

  @override
  String get noGgufFilesHint =>
      'No GGUF quantized files found. This model may not support local deployment.';

  @override
  String get multimodalProjector => 'Multimodal Projector (mmproj)';

  @override
  String get mmprojHint =>
      'Required for image/video understanding, needs to be downloaded together with GGUF model';

  @override
  String get modelIntro => 'Model Introduction';

  @override
  String get downloadComplete => 'Download Complete';

  @override
  String get loadLater => 'Load Later';

  @override
  String get loadNow => 'Load Now';

  @override
  String get loadingModel => 'Loading model...';

  @override
  String get modelLoadSuccess => 'Model Loaded Successfully';

  @override
  String modelReadyToChat(String name) {
    return '$name has been loaded and is ready for conversation.';
  }

  @override
  String get later => 'Later';

  @override
  String get startChat => 'Start Chat';

  @override
  String get modelLoadFailed => 'Model load failed';

  @override
  String modelAddedToList(String name) {
    return '$name has been added to model list';
  }

  @override
  String get view => 'View';

  @override
  String get chineseOptimized => 'Chinese Optimized';

  @override
  String get codeGeneration => 'Code Generation';

  @override
  String get mathReasoning => 'Math Reasoning';

  @override
  String get generalChat => 'General Chat';

  @override
  String get loadConfigHint =>
      'Will load model with default config (CPU + 6 threads)';

  @override
  String get deviceCompatibility => 'Device Compatibility Issue';

  @override
  String get availableMemory => 'Available Memory';

  @override
  String get availableStorage => 'Available Storage';

  @override
  String get storageRequired => 'Storage Required';

  @override
  String get memoryRequired => 'Memory Required';

  @override
  String get parameterCount => 'Parameters';

  @override
  String get quantFormat => 'Quantization Format';

  @override
  String get deviceNotMeetMin => 'Device does not meet minimum requirements';

  @override
  String get forceDownloadWarning =>
      'Force download may result in model unable to load or slow performance.';

  @override
  String get tipsTitle => 'Tips';

  @override
  String get visionSupport => 'Multimodal Support (Vision)';

  @override
  String get visionSupportHint =>
      'This model supports image/video understanding. Enabling will also download mmproj projector file.';

  @override
  String get enableVisionSupport => 'Enable Vision Support';

  @override
  String get lowMemoryVisionWarning =>
      'Low memory (<16GB), Vision not recommended';

  @override
  String get startDownload => 'Start Download';

  @override
  String get stillDownload => 'Download Anyway';

  @override
  String get detectingCompatibility => 'Detecting device compatibility...';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get mmprojAlreadyExists =>
      'mmproj projector file already exists, skipping download';

  @override
  String get mmprojDownloadComplete =>
      'mmproj projector file download complete';

  @override
  String get mmprojDownloadFailed => 'mmproj download failed';

  @override
  String get createDownloadTaskFailed => 'Failed to create download task';

  @override
  String get downloadStartFailed => 'Failed to start download';

  @override
  String downloadFailed(String error) {
    return 'Download failed: $error';
  }

  @override
  String get modelDownloadedToLocal =>
      'Model has been successfully downloaded locally.';

  @override
  String get ramRequired => 'RAM Required';

  @override
  String exceedsCurrentConfig(String reasons) {
    return 'Exceeds current configuration: $reasons';
  }

  @override
  String get downloadModelHint =>
      'After download, the model will be automatically registered. You can view and load it in Model Management.';

  @override
  String get downloadAnywayHint =>
      'You can still try to download, but it may not work properly.';

  @override
  String get loadConfigChinese =>
      'Will load with Chinese model config (CPU + 8 threads)';

  @override
  String get loadConfigCode =>
      'Will load with code model config (CPU + 4 threads, 4096 context)';

  @override
  String get loadConfigReasoning =>
      'Will load with reasoning model config (CPU + 8 threads, 8192 context)';

  @override
  String get mmprojInfo =>
      'This model supports image/video understanding. mmproj is a required component for image-to-text.\n\n⚠️ Note: If memory is limited (<16GB), loading mmproj is not recommended as it uses additional memory.';
}
