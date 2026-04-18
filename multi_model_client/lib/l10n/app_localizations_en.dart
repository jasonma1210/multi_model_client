// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Multi-Model Client';

  @override
  String get sessions => 'Sessions';

  @override
  String get models => 'Models';

  @override
  String get knowledge => 'Knowledge';

  @override
  String get settings => 'Settings';

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
  String get loading => 'Loading...';

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
}
