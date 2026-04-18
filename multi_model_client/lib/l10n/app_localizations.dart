import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Multi-Model Client'**
  String get appTitle;

  /// Sessions menu item
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// Models menu item
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get models;

  /// Knowledge menu item
  ///
  /// In en, this message translates to:
  /// **'Knowledge'**
  String get knowledge;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Create session button text
  ///
  /// In en, this message translates to:
  /// **'Create Session'**
  String get createSession;

  /// New session default name
  ///
  /// In en, this message translates to:
  /// **'New Session'**
  String get newSession;

  /// Session name input label
  ///
  /// In en, this message translates to:
  /// **'Session Name'**
  String get sessionName;

  /// Session name input hint
  ///
  /// In en, this message translates to:
  /// **'Enter session name'**
  String get enterSessionName;

  /// Model selection label
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get selectModel;

  /// Model label
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// Create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Export button text
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Rename button text
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// Clear button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Loading state text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error state text
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Empty state title for sessions
  ///
  /// In en, this message translates to:
  /// **'No Sessions Yet'**
  String get noSessionsYet;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with your AI models'**
  String get startConversation;

  /// Success message when session is created
  ///
  /// In en, this message translates to:
  /// **'Session created successfully'**
  String get sessionCreated;

  /// Success message when session is deleted
  ///
  /// In en, this message translates to:
  /// **'Session deleted'**
  String get sessionDeleted;

  /// Success message when session is renamed
  ///
  /// In en, this message translates to:
  /// **'Session renamed'**
  String get sessionRenamed;

  /// Success message when messages are cleared
  ///
  /// In en, this message translates to:
  /// **'Messages cleared'**
  String get messagesCleared;

  /// Success message when model is changed
  ///
  /// In en, this message translates to:
  /// **'Model changed'**
  String get modelChanged;

  /// Empty state title for chat
  ///
  /// In en, this message translates to:
  /// **'Start a Conversation'**
  String get startConversationTitle;

  /// Empty state subtitle for chat
  ///
  /// In en, this message translates to:
  /// **'Send a message to begin chatting with the AI'**
  String get sendMessage;

  /// Message input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// Send button text
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Stop button text
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// Generating status text
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// Attach file tooltip
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get attachFile;

  /// Export session tooltip
  ///
  /// In en, this message translates to:
  /// **'Export session'**
  String get exportSession;

  /// Rename session dialog title
  ///
  /// In en, this message translates to:
  /// **'Rename Session'**
  String get renameSession;

  /// New name input label
  ///
  /// In en, this message translates to:
  /// **'New Name'**
  String get newName;

  /// Change model dialog title
  ///
  /// In en, this message translates to:
  /// **'Change Model'**
  String get changeModel;

  /// Clear messages dialog title
  ///
  /// In en, this message translates to:
  /// **'Clear Messages'**
  String get clearMessages;

  /// Clear messages confirmation text
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all messages? This action cannot be undone.'**
  String get clearMessagesConfirm;

  /// Delete session confirmation text
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this session? This action cannot be undone.'**
  String get deleteSessionConfirm;

  /// Appearance settings section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Theme settings label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Theme selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Chinese language option
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// Model management settings tile title
  ///
  /// In en, this message translates to:
  /// **'Model Management'**
  String get modelManagement;

  /// Model management settings tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Configure local and remote models'**
  String get configureModels;

  /// Download models settings tile title
  ///
  /// In en, this message translates to:
  /// **'Download Models'**
  String get downloadModels;

  /// Download models settings tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Hugging Face & ModelScope'**
  String get huggingFaceModelScope;

  /// Memory settings tile title
  ///
  /// In en, this message translates to:
  /// **'Memory Settings'**
  String get memorySettings;

  /// Memory settings tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Configure memory extraction'**
  String get configureMemory;

  /// Knowledge base settings tile title
  ///
  /// In en, this message translates to:
  /// **'Knowledge Base'**
  String get knowledgeBase;

  /// Knowledge base settings tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage knowledge bases'**
  String get manageKnowledgeBases;

  /// Voice settings tile title
  ///
  /// In en, this message translates to:
  /// **'Voice Settings'**
  String get voiceSettings;

  /// Voice settings tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Text-to-speech configuration'**
  String get textToSpeechConfig;

  /// Data and storage settings section
  ///
  /// In en, this message translates to:
  /// **'Data & Storage'**
  String get dataStorage;

  /// Storage settings tile title
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// Storage settings tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage local data and cache'**
  String get manageDataCache;

  /// Backup settings tile title
  ///
  /// In en, this message translates to:
  /// **'Backup & Export'**
  String get backupExport;

  /// Backup settings tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Export or backup your data'**
  String get exportBackupData;

  /// Storage info dialog title
  ///
  /// In en, this message translates to:
  /// **'Storage Info'**
  String get storageInfo;

  /// Database storage label
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get database;

  /// Cache storage label
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get cache;

  /// Total storage label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Clear cache button text
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// Success message when cache is cleared
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// Error message when cache clear fails
  ///
  /// In en, this message translates to:
  /// **'Failed to clear cache'**
  String get clearCacheFailed;

  /// Export database option title
  ///
  /// In en, this message translates to:
  /// **'Export Database'**
  String get exportDatabase;

  /// Export database option subtitle
  ///
  /// In en, this message translates to:
  /// **'Export all sessions and settings'**
  String get exportAllData;

  /// Import database option title
  ///
  /// In en, this message translates to:
  /// **'Import Database'**
  String get importDatabase;

  /// Import database option subtitle
  ///
  /// In en, this message translates to:
  /// **'Import from a backup file'**
  String get importFromBackup;

  /// Export sessions option title
  ///
  /// In en, this message translates to:
  /// **'Export Sessions'**
  String get exportSessions;

  /// Export sessions option subtitle
  ///
  /// In en, this message translates to:
  /// **'Export specific sessions to text'**
  String get exportSpecificSessions;

  /// About settings section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version settings tile title
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Latest version badge
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// Open source licenses tile title
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// Coming soon message
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon'**
  String get comingSoon;

  /// Search sessions tooltip
  ///
  /// In en, this message translates to:
  /// **'Search sessions'**
  String get searchSessions;

  /// Filter sessions tooltip
  ///
  /// In en, this message translates to:
  /// **'Filter sessions'**
  String get filterSessions;

  /// Error state title for sessions
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Sessions'**
  String get failedToLoadSessions;

  /// Error state title for messages
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Messages'**
  String get failedToLoadMessages;

  /// Error message when session creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create session'**
  String get failedToCreateSession;

  /// Error message when session deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete session'**
  String get failedToDeleteSession;

  /// Error message when sending message fails
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get failedToSendMessage;

  /// Loading messages text
  ///
  /// In en, this message translates to:
  /// **'Loading messages...'**
  String get loadingMessages;

  /// Loading sessions text
  ///
  /// In en, this message translates to:
  /// **'Loading sessions...'**
  String get loadingSessions;

  /// Relative time: just now
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// Relative time: minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(int count);

  /// Relative time: hours ago
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// Relative time: days ago
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @voiceDialog.
  ///
  /// In en, this message translates to:
  /// **'Voice Dialog'**
  String get voiceDialog;

  /// No description provided for @voiceDialogSettings.
  ///
  /// In en, this message translates to:
  /// **'Voice Dialog Settings'**
  String get voiceDialogSettings;

  /// No description provided for @startVoiceDialog.
  ///
  /// In en, this message translates to:
  /// **'Start Voice Dialog'**
  String get startVoiceDialog;

  /// No description provided for @stopVoiceDialog.
  ///
  /// In en, this message translates to:
  /// **'Stop Voice Dialog'**
  String get stopVoiceDialog;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// No description provided for @speaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking...'**
  String get speaking;

  /// No description provided for @voiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice Input'**
  String get voiceInput;

  /// No description provided for @voiceOutput.
  ///
  /// In en, this message translates to:
  /// **'Voice Output'**
  String get voiceOutput;

  /// No description provided for @voiceModel.
  ///
  /// In en, this message translates to:
  /// **'Voice Model'**
  String get voiceModel;

  /// No description provided for @enableVoiceInput.
  ///
  /// In en, this message translates to:
  /// **'Enable Voice Input'**
  String get enableVoiceInput;

  /// No description provided for @enableVoiceOutput.
  ///
  /// In en, this message translates to:
  /// **'Enable Voice Output'**
  String get enableVoiceOutput;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @enableAppLock.
  ///
  /// In en, this message translates to:
  /// **'Enable App Lock'**
  String get enableAppLock;

  /// No description provided for @disableAppLock.
  ///
  /// In en, this message translates to:
  /// **'Disable App Lock'**
  String get disableAppLock;

  /// No description provided for @setPin.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get setPin;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PIN mismatch'**
  String get pinMismatch;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get wrongPin;

  /// No description provided for @enableBiometric.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric'**
  String get enableBiometric;

  /// No description provided for @biometricAuth.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricAuth;

  /// No description provided for @faceId.
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get faceId;

  /// No description provided for @touchId.
  ///
  /// In en, this message translates to:
  /// **'Touch ID'**
  String get touchId;

  /// No description provided for @fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get fingerprint;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareAsMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Share as Markdown'**
  String get shareAsMarkdown;

  /// No description provided for @shareAsText.
  ///
  /// In en, this message translates to:
  /// **'Share as Text'**
  String get shareAsText;

  /// No description provided for @shareAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Share as PDF'**
  String get shareAsPdf;

  /// No description provided for @shareSession.
  ///
  /// In en, this message translates to:
  /// **'Share Session'**
  String get shareSession;

  /// No description provided for @shareKnowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'Share Knowledge Base'**
  String get shareKnowledgeBase;

  /// No description provided for @shareMemory.
  ///
  /// In en, this message translates to:
  /// **'Share Memory'**
  String get shareMemory;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup Success'**
  String get backupSuccess;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup Failed'**
  String get backupFailed;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restore Success'**
  String get restoreSuccess;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore Failed'**
  String get restoreFailed;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last Backup'**
  String get lastBackup;

  /// No description provided for @noBackup.
  ///
  /// In en, this message translates to:
  /// **'No Backup'**
  String get noBackup;

  /// No description provided for @localModel.
  ///
  /// In en, this message translates to:
  /// **'Local Model'**
  String get localModel;

  /// No description provided for @remoteModel.
  ///
  /// In en, this message translates to:
  /// **'Remote Model'**
  String get remoteModel;

  /// No description provided for @addLocalModel.
  ///
  /// In en, this message translates to:
  /// **'Add Local Model'**
  String get addLocalModel;

  /// No description provided for @addRemoteModel.
  ///
  /// In en, this message translates to:
  /// **'Add Remote Model'**
  String get addRemoteModel;

  /// No description provided for @modelSettings.
  ///
  /// In en, this message translates to:
  /// **'Model Settings'**
  String get modelSettings;

  /// No description provided for @inferenceParams.
  ///
  /// In en, this message translates to:
  /// **'Inference Parameters'**
  String get inferenceParams;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @topP.
  ///
  /// In en, this message translates to:
  /// **'Top P'**
  String get topP;

  /// No description provided for @maxTokens.
  ///
  /// In en, this message translates to:
  /// **'Max Tokens'**
  String get maxTokens;

  /// No description provided for @folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folder;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @createFolder.
  ///
  /// In en, this message translates to:
  /// **'Create Folder'**
  String get createFolder;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder Name'**
  String get folderName;

  /// No description provided for @enterFolderName.
  ///
  /// In en, this message translates to:
  /// **'Enter folder name'**
  String get enterFolderName;

  /// No description provided for @moveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Move to Folder'**
  String get moveToFolder;

  /// No description provided for @pinSession.
  ///
  /// In en, this message translates to:
  /// **'Pin Session'**
  String get pinSession;

  /// No description provided for @unpinSession.
  ///
  /// In en, this message translates to:
  /// **'Unpin Session'**
  String get unpinSession;

  /// No description provided for @archiveSession.
  ///
  /// In en, this message translates to:
  /// **'Archive Session'**
  String get archiveSession;

  /// No description provided for @unarchiveSession.
  ///
  /// In en, this message translates to:
  /// **'Unarchive Session'**
  String get unarchiveSession;

  /// No description provided for @archivedSessions.
  ///
  /// In en, this message translates to:
  /// **'Archived Sessions'**
  String get archivedSessions;

  /// No description provided for @prompt.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get prompt;

  /// No description provided for @prompts.
  ///
  /// In en, this message translates to:
  /// **'Prompts'**
  String get prompts;

  /// No description provided for @systemPrompt.
  ///
  /// In en, this message translates to:
  /// **'System Prompt'**
  String get systemPrompt;

  /// No description provided for @promptTemplate.
  ///
  /// In en, this message translates to:
  /// **'Prompt Template'**
  String get promptTemplate;

  /// No description provided for @createPrompt.
  ///
  /// In en, this message translates to:
  /// **'Create Prompt'**
  String get createPrompt;

  /// No description provided for @editPrompt.
  ///
  /// In en, this message translates to:
  /// **'Edit Prompt'**
  String get editPrompt;

  /// No description provided for @promptVariables.
  ///
  /// In en, this message translates to:
  /// **'Prompt Variables'**
  String get promptVariables;

  /// No description provided for @promptCategory.
  ///
  /// In en, this message translates to:
  /// **'Prompt Category'**
  String get promptCategory;

  /// No description provided for @mcpServer.
  ///
  /// In en, this message translates to:
  /// **'MCP Server'**
  String get mcpServer;

  /// No description provided for @mcpServers.
  ///
  /// In en, this message translates to:
  /// **'MCP Servers'**
  String get mcpServers;

  /// No description provided for @addMcpServer.
  ///
  /// In en, this message translates to:
  /// **'Add MCP Server'**
  String get addMcpServer;

  /// No description provided for @mcpServerName.
  ///
  /// In en, this message translates to:
  /// **'Server Name'**
  String get mcpServerName;

  /// No description provided for @mcpServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get mcpServerUrl;

  /// No description provided for @connectMcpServer.
  ///
  /// In en, this message translates to:
  /// **'Connect MCP Server'**
  String get connectMcpServer;

  /// No description provided for @disconnectMcpServer.
  ///
  /// In en, this message translates to:
  /// **'Disconnect MCP Server'**
  String get disconnectMcpServer;

  /// No description provided for @mcpServerConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get mcpServerConnected;

  /// No description provided for @mcpServerDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get mcpServerDisconnected;

  /// No description provided for @skill.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get skill;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @skillMarket.
  ///
  /// In en, this message translates to:
  /// **'Skill Market'**
  String get skillMarket;

  /// No description provided for @builtinSkills.
  ///
  /// In en, this message translates to:
  /// **'Built-in Skills'**
  String get builtinSkills;

  /// No description provided for @customSkills.
  ///
  /// In en, this message translates to:
  /// **'Custom Skills'**
  String get customSkills;

  /// No description provided for @addSkill.
  ///
  /// In en, this message translates to:
  /// **'Add Skill'**
  String get addSkill;

  /// No description provided for @enableSkill.
  ///
  /// In en, this message translates to:
  /// **'Enable Skill'**
  String get enableSkill;

  /// No description provided for @disableSkill.
  ///
  /// In en, this message translates to:
  /// **'Disable Skill'**
  String get disableSkill;

  /// No description provided for @videoUnderstanding.
  ///
  /// In en, this message translates to:
  /// **'Video Understanding'**
  String get videoUnderstanding;

  /// No description provided for @extractFrames.
  ///
  /// In en, this message translates to:
  /// **'Extract Key Frames'**
  String get extractFrames;

  /// No description provided for @analyzeVideo.
  ///
  /// In en, this message translates to:
  /// **'Analyze Video'**
  String get analyzeVideo;

  /// No description provided for @videoAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Video Analysis'**
  String get videoAnalysis;

  /// No description provided for @frameExtraction.
  ///
  /// In en, this message translates to:
  /// **'Frame Extraction'**
  String get frameExtraction;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No Results'**
  String get noResults;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchPlaceholder;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Action'**
  String get confirmAction;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @uninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get uninstall;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @cut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmClear.
  ///
  /// In en, this message translates to:
  /// **'Confirm Clear'**
  String get confirmClear;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation Failed'**
  String get operationFailed;

  /// No description provided for @operationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Operation Success'**
  String get operationSuccess;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get networkError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown Error'**
  String get unknownError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
