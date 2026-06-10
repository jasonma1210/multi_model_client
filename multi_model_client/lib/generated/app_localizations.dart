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
/// import 'generated/app_localizations.dart';
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
  /// **'MJ Nexus Series:Synpse'**
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

  /// Download manager menu item
  ///
  /// In en, this message translates to:
  /// **'Download Manager'**
  String get downloadManager;

  /// Clear completed downloads button
  ///
  /// In en, this message translates to:
  /// **'Clear Completed'**
  String get clearCompleted;

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
  /// **'Loading'**
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

  /// No description provided for @localModels.
  ///
  /// In en, this message translates to:
  /// **'Local Models'**
  String get localModels;

  /// No description provided for @remoteApi.
  ///
  /// In en, this message translates to:
  /// **'Remote API'**
  String get remoteApi;

  /// No description provided for @importModel.
  ///
  /// In en, this message translates to:
  /// **'Import Model'**
  String get importModel;

  /// No description provided for @downloadModel.
  ///
  /// In en, this message translates to:
  /// **'Download Model'**
  String get downloadModel;

  /// No description provided for @selectModelFolder.
  ///
  /// In en, this message translates to:
  /// **'Select Model Folder'**
  String get selectModelFolder;

  /// No description provided for @noGgufFilesFound.
  ///
  /// In en, this message translates to:
  /// **'No GGUF model files found'**
  String get noGgufFilesFound;

  /// No description provided for @modelAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Model already exists'**
  String get modelAlreadyExists;

  /// No description provided for @modelImported.
  ///
  /// In en, this message translates to:
  /// **'Model Imported'**
  String get modelImported;

  /// No description provided for @modelImportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully imported {count} models'**
  String modelImportedSuccess(int count);

  /// No description provided for @storagePathConfig.
  ///
  /// In en, this message translates to:
  /// **'Storage Path Configuration'**
  String get storagePathConfig;

  /// No description provided for @customStoragePaths.
  ///
  /// In en, this message translates to:
  /// **'Customize storage paths for different file types. Leave empty to use default paths.'**
  String get customStoragePaths;

  /// No description provided for @modelDownloadPath.
  ///
  /// In en, this message translates to:
  /// **'Model Download Path'**
  String get modelDownloadPath;

  /// No description provided for @modelDownloadPathDesc.
  ///
  /// In en, this message translates to:
  /// **'Local model file storage location'**
  String get modelDownloadPathDesc;

  /// No description provided for @knowledgeBasePath.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Base Path'**
  String get knowledgeBasePath;

  /// No description provided for @knowledgeBasePathDesc.
  ///
  /// In en, this message translates to:
  /// **'Uploaded documents and vector data storage location'**
  String get knowledgeBasePathDesc;

  /// No description provided for @backupPath.
  ///
  /// In en, this message translates to:
  /// **'Backup Path'**
  String get backupPath;

  /// No description provided for @backupPathDesc.
  ///
  /// In en, this message translates to:
  /// **'Data backup file storage location'**
  String get backupPathDesc;

  /// No description provided for @logPath.
  ///
  /// In en, this message translates to:
  /// **'Log Path'**
  String get logPath;

  /// No description provided for @logPathDesc.
  ///
  /// In en, this message translates to:
  /// **'Application log file storage location'**
  String get logPathDesc;

  /// No description provided for @databasePath.
  ///
  /// In en, this message translates to:
  /// **'Database Path'**
  String get databasePath;

  /// No description provided for @databasePathDesc.
  ///
  /// In en, this message translates to:
  /// **'Application database file storage location (read-only)'**
  String get databasePathDesc;

  /// No description provided for @refreshPaths.
  ///
  /// In en, this message translates to:
  /// **'Refresh Paths'**
  String get refreshPaths;

  /// No description provided for @directoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Directory Updated'**
  String get directoryUpdated;

  /// No description provided for @selectDirectory.
  ///
  /// In en, this message translates to:
  /// **'Select Directory'**
  String get selectDirectory;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @restoreDefaults.
  ///
  /// In en, this message translates to:
  /// **'Restore Defaults'**
  String get restoreDefaults;

  /// No description provided for @confirmRestoreDefaults.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore default paths?'**
  String get confirmRestoreDefaults;

  /// No description provided for @defaultsRestored.
  ///
  /// In en, this message translates to:
  /// **'Default paths restored'**
  String get defaultsRestored;

  /// No description provided for @logManagement.
  ///
  /// In en, this message translates to:
  /// **'Log Management'**
  String get logManagement;

  /// No description provided for @appLogs.
  ///
  /// In en, this message translates to:
  /// **'App Logs'**
  String get appLogs;

  /// No description provided for @allLogs.
  ///
  /// In en, this message translates to:
  /// **'All Logs'**
  String get allLogs;

  /// No description provided for @errorLogs.
  ///
  /// In en, this message translates to:
  /// **'Error Logs'**
  String get errorLogs;

  /// No description provided for @warnLogs.
  ///
  /// In en, this message translates to:
  /// **'Warning Logs'**
  String get warnLogs;

  /// No description provided for @infoLogs.
  ///
  /// In en, this message translates to:
  /// **'Info Logs'**
  String get infoLogs;

  /// No description provided for @debugLogs.
  ///
  /// In en, this message translates to:
  /// **'Debug Logs'**
  String get debugLogs;

  /// No description provided for @noLogs.
  ///
  /// In en, this message translates to:
  /// **'No Logs'**
  String get noLogs;

  /// No description provided for @clearLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get clearLogs;

  /// No description provided for @clearLogsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all logs?'**
  String get clearLogsConfirm;

  /// No description provided for @logsCleared.
  ///
  /// In en, this message translates to:
  /// **'Logs cleared'**
  String get logsCleared;

  /// No description provided for @exportLogs.
  ///
  /// In en, this message translates to:
  /// **'Export Logs'**
  String get exportLogs;

  /// No description provided for @logDetails.
  ///
  /// In en, this message translates to:
  /// **'Log Details'**
  String get logDetails;

  /// No description provided for @logTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get logTime;

  /// No description provided for @logLevel.
  ///
  /// In en, this message translates to:
  /// **'Log Level'**
  String get logLevel;

  /// No description provided for @logMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get logMessage;

  /// No description provided for @logSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get logSource;

  /// No description provided for @pluginManagement.
  ///
  /// In en, this message translates to:
  /// **'Plugin Management'**
  String get pluginManagement;

  /// No description provided for @installedPlugins.
  ///
  /// In en, this message translates to:
  /// **'Installed Plugins'**
  String get installedPlugins;

  /// No description provided for @availablePlugins.
  ///
  /// In en, this message translates to:
  /// **'Available Plugins'**
  String get availablePlugins;

  /// No description provided for @pluginSettings.
  ///
  /// In en, this message translates to:
  /// **'Plugin Settings'**
  String get pluginSettings;

  /// No description provided for @installPlugin.
  ///
  /// In en, this message translates to:
  /// **'Install Plugin'**
  String get installPlugin;

  /// No description provided for @uninstallPlugin.
  ///
  /// In en, this message translates to:
  /// **'Uninstall Plugin'**
  String get uninstallPlugin;

  /// No description provided for @pluginEnabled.
  ///
  /// In en, this message translates to:
  /// **'Plugin enabled'**
  String get pluginEnabled;

  /// No description provided for @pluginDisabled.
  ///
  /// In en, this message translates to:
  /// **'Plugin disabled'**
  String get pluginDisabled;

  /// No description provided for @pluginInstallSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plugin installed successfully'**
  String get pluginInstallSuccess;

  /// No description provided for @pluginInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Plugin installation failed'**
  String get pluginInstallFailed;

  /// No description provided for @pluginUninstallSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plugin uninstalled successfully'**
  String get pluginUninstallSuccess;

  /// No description provided for @pluginUninstallConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to uninstall this plugin?'**
  String get pluginUninstallConfirm;

  /// No description provided for @noPluginsInstalled.
  ///
  /// In en, this message translates to:
  /// **'No plugins installed'**
  String get noPluginsInstalled;

  /// No description provided for @browsePlugins.
  ///
  /// In en, this message translates to:
  /// **'Browse Plugins'**
  String get browsePlugins;

  /// No description provided for @skillCenter.
  ///
  /// In en, this message translates to:
  /// **'Skill Center'**
  String get skillCenter;

  /// No description provided for @builtInSkills.
  ///
  /// In en, this message translates to:
  /// **'Built-in Skills'**
  String get builtInSkills;

  /// No description provided for @customSkillsList.
  ///
  /// In en, this message translates to:
  /// **'Custom Skills'**
  String get customSkillsList;

  /// No description provided for @skillSettings.
  ///
  /// In en, this message translates to:
  /// **'Skill Settings'**
  String get skillSettings;

  /// No description provided for @skillEnabled.
  ///
  /// In en, this message translates to:
  /// **'Skill enabled'**
  String get skillEnabled;

  /// No description provided for @skillDisabled.
  ///
  /// In en, this message translates to:
  /// **'Skill disabled'**
  String get skillDisabled;

  /// No description provided for @configureSkill.
  ///
  /// In en, this message translates to:
  /// **'Configure Skill'**
  String get configureSkill;

  /// No description provided for @skillDescription.
  ///
  /// In en, this message translates to:
  /// **'Skill Description'**
  String get skillDescription;

  /// No description provided for @skillParameters.
  ///
  /// In en, this message translates to:
  /// **'Skill Parameters'**
  String get skillParameters;

  /// No description provided for @userManual.
  ///
  /// In en, this message translates to:
  /// **'User Manual'**
  String get userManual;

  /// No description provided for @gettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get gettingStarted;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @troubleshooting.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting'**
  String get troubleshooting;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @mmprojModels.
  ///
  /// In en, this message translates to:
  /// **'Projector Models'**
  String get mmprojModels;

  /// No description provided for @multimodalModel.
  ///
  /// In en, this message translates to:
  /// **'Multimodal Model'**
  String get multimodalModel;

  /// No description provided for @visionModel.
  ///
  /// In en, this message translates to:
  /// **'Vision Model'**
  String get visionModel;

  /// No description provided for @selectMmproj.
  ///
  /// In en, this message translates to:
  /// **'Select Projector'**
  String get selectMmproj;

  /// No description provided for @mmprojRequired.
  ///
  /// In en, this message translates to:
  /// **'A projector is required for multimodal functionality'**
  String get mmprojRequired;

  /// No description provided for @confirmDeleteModel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this model?'**
  String get confirmDeleteModel;

  /// No description provided for @modelDeleted.
  ///
  /// In en, this message translates to:
  /// **'Model deleted'**
  String get modelDeleted;

  /// No description provided for @confirmDeleteMmproj.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this projector?'**
  String get confirmDeleteMmproj;

  /// No description provided for @mmprojDeleted.
  ///
  /// In en, this message translates to:
  /// **'Projector deleted'**
  String get mmprojDeleted;

  /// No description provided for @modelType.
  ///
  /// In en, this message translates to:
  /// **'Model Type'**
  String get modelType;

  /// No description provided for @quantization.
  ///
  /// In en, this message translates to:
  /// **'Quantization'**
  String get quantization;

  /// No description provided for @contextLength.
  ///
  /// In en, this message translates to:
  /// **'Context Length'**
  String get contextLength;

  /// No description provided for @gpuOffload.
  ///
  /// In en, this message translates to:
  /// **'GPU Offload'**
  String get gpuOffload;

  /// No description provided for @nGpuLayers.
  ///
  /// In en, this message translates to:
  /// **'GPU Layers'**
  String get nGpuLayers;

  /// No description provided for @threads.
  ///
  /// In en, this message translates to:
  /// **'Threads'**
  String get threads;

  /// No description provided for @batchSize.
  ///
  /// In en, this message translates to:
  /// **'Batch Size'**
  String get batchSize;

  /// No description provided for @apiProvider.
  ///
  /// In en, this message translates to:
  /// **'API Provider'**
  String get apiProvider;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @apiEndpoint.
  ///
  /// In en, this message translates to:
  /// **'API Endpoint'**
  String get apiEndpoint;

  /// No description provided for @baseUrl.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get baseUrl;

  /// No description provided for @enterApiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter API key'**
  String get enterApiKey;

  /// No description provided for @enterEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Enter API endpoint'**
  String get enterEndpoint;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get testConnection;

  /// No description provided for @connectionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connection successful'**
  String get connectionSuccess;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get connectionFailed;

  /// No description provided for @topK.
  ///
  /// In en, this message translates to:
  /// **'Top K'**
  String get topK;

  /// No description provided for @repeatPenalty.
  ///
  /// In en, this message translates to:
  /// **'Repeat Penalty'**
  String get repeatPenalty;

  /// No description provided for @presencePenalty.
  ///
  /// In en, this message translates to:
  /// **'Presence Penalty'**
  String get presencePenalty;

  /// No description provided for @frequencyPenalty.
  ///
  /// In en, this message translates to:
  /// **'Frequency Penalty'**
  String get frequencyPenalty;

  /// No description provided for @modelParams.
  ///
  /// In en, this message translates to:
  /// **'Model Parameters'**
  String get modelParams;

  /// No description provided for @inferenceSettings.
  ///
  /// In en, this message translates to:
  /// **'Inference Settings'**
  String get inferenceSettings;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettings;

  /// No description provided for @resetToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetToDefaults;

  /// No description provided for @emptyStateHint.
  ///
  /// In en, this message translates to:
  /// **'No content'**
  String get emptyStateHint;

  /// No description provided for @tapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Tap to retry'**
  String get tapToRetry;

  /// No description provided for @loadingFailed.
  ///
  /// In en, this message translates to:
  /// **'Loading failed'**
  String get loadingFailed;

  /// No description provided for @operationInProgress.
  ///
  /// In en, this message translates to:
  /// **'Operation in progress...'**
  String get operationInProgress;

  /// No description provided for @noLocalModels.
  ///
  /// In en, this message translates to:
  /// **'No Local Models Yet'**
  String get noLocalModels;

  /// No description provided for @downloadOrImportHint.
  ///
  /// In en, this message translates to:
  /// **'You can download GGUF quantized models from the model market,\nor import existing local .gguf files.'**
  String get downloadOrImportHint;

  /// No description provided for @modelMarket.
  ///
  /// In en, this message translates to:
  /// **'Model Market'**
  String get modelMarket;

  /// No description provided for @loadedModel.
  ///
  /// In en, this message translates to:
  /// **'Loaded Model'**
  String get loadedModel;

  /// No description provided for @unloadModel.
  ///
  /// In en, this message translates to:
  /// **'Unload Model'**
  String get unloadModel;

  /// No description provided for @loadModel.
  ///
  /// In en, this message translates to:
  /// **'Load Model'**
  String get loadModel;

  /// No description provided for @modelLoaded.
  ///
  /// In en, this message translates to:
  /// **'Model loaded'**
  String get modelLoaded;

  /// No description provided for @modelUnloaded.
  ///
  /// In en, this message translates to:
  /// **'Model unloaded'**
  String get modelUnloaded;

  /// No description provided for @deleteModel.
  ///
  /// In en, this message translates to:
  /// **'Delete Model'**
  String get deleteModel;

  /// No description provided for @editModel.
  ///
  /// In en, this message translates to:
  /// **'Edit Model'**
  String get editModel;

  /// No description provided for @modelInfo.
  ///
  /// In en, this message translates to:
  /// **'Model Info'**
  String get modelInfo;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get fileSize;

  /// No description provided for @filePath.
  ///
  /// In en, this message translates to:
  /// **'File Path'**
  String get filePath;

  /// No description provided for @parameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get parameters;

  /// No description provided for @quantizationLevel.
  ///
  /// In en, this message translates to:
  /// **'Quantization Level'**
  String get quantizationLevel;

  /// No description provided for @unloading.
  ///
  /// In en, this message translates to:
  /// **'Unloading'**
  String get unloading;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get scanning;

  /// No description provided for @scanningModels.
  ///
  /// In en, this message translates to:
  /// **'Scanning models...'**
  String get scanningModels;

  /// No description provided for @remoteModels.
  ///
  /// In en, this message translates to:
  /// **'Remote Models'**
  String get remoteModels;

  /// No description provided for @editRemoteModel.
  ///
  /// In en, this message translates to:
  /// **'Edit Remote Model'**
  String get editRemoteModel;

  /// No description provided for @deleteRemoteModel.
  ///
  /// In en, this message translates to:
  /// **'Delete Remote Model'**
  String get deleteRemoteModel;

  /// No description provided for @remoteModelConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get remoteModelConnected;

  /// No description provided for @remoteModelDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get remoteModelDisconnected;

  /// No description provided for @noRemoteModels.
  ///
  /// In en, this message translates to:
  /// **'No Remote Models'**
  String get noRemoteModels;

  /// No description provided for @addRemoteModelHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a remote API model'**
  String get addRemoteModelHint;

  /// No description provided for @openai.
  ///
  /// In en, this message translates to:
  /// **'OpenAI'**
  String get openai;

  /// No description provided for @anthropic.
  ///
  /// In en, this message translates to:
  /// **'Anthropic'**
  String get anthropic;

  /// No description provided for @ollama.
  ///
  /// In en, this message translates to:
  /// **'Ollama'**
  String get ollama;

  /// No description provided for @selectKnowledgeBaseFolder.
  ///
  /// In en, this message translates to:
  /// **'Select Knowledge Base Folder'**
  String get selectKnowledgeBaseFolder;

  /// No description provided for @selectBackupFolder.
  ///
  /// In en, this message translates to:
  /// **'Select Backup Folder'**
  String get selectBackupFolder;

  /// No description provided for @selectLogFolder.
  ///
  /// In en, this message translates to:
  /// **'Select Log Folder'**
  String get selectLogFolder;

  /// No description provided for @aiFeatures.
  ///
  /// In en, this message translates to:
  /// **'AI Features'**
  String get aiFeatures;

  /// No description provided for @pluginManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage multimodal parsing plugins (OCR, ASR, TTS)'**
  String get pluginManagementDesc;

  /// No description provided for @skillCenterDesc.
  ///
  /// In en, this message translates to:
  /// **'Browse, manage, and create custom skills'**
  String get skillCenterDesc;

  /// No description provided for @storagePathConfigDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize model, knowledge base, backup storage locations'**
  String get storagePathConfigDesc;

  /// No description provided for @logManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'View and export application logs'**
  String get logManagementDesc;

  /// No description provided for @helpGuide.
  ///
  /// In en, this message translates to:
  /// **'Help & Guide'**
  String get helpGuide;

  /// No description provided for @userManualDesc.
  ///
  /// In en, this message translates to:
  /// **'Beginner\'s guide, model download tutorials'**
  String get userManualDesc;

  /// No description provided for @multimodalPluginsInfo.
  ///
  /// In en, this message translates to:
  /// **'Multimodal Plugins Info'**
  String get multimodalPluginsInfo;

  /// No description provided for @builtinPluginsInfo.
  ///
  /// In en, this message translates to:
  /// **'Built-in plugins: OCR (iOS Vision / Android ML Kit), video/audio extraction (System API)'**
  String get builtinPluginsInfo;

  /// No description provided for @downloadOnDemandInfo.
  ///
  /// In en, this message translates to:
  /// **'Download on demand: prompted when first using related features'**
  String get downloadOnDemandInfo;

  /// No description provided for @voiceSettingsIntegrationInfo.
  ///
  /// In en, this message translates to:
  /// **'Voice settings integration: ASR/TTS models shared with voice settings page'**
  String get voiceSettingsIntegrationInfo;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloading;

  /// No description provided for @downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// No description provided for @notDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Not downloaded'**
  String get notDownloaded;

  /// No description provided for @deletePlugin.
  ///
  /// In en, this message translates to:
  /// **'Delete Plugin'**
  String get deletePlugin;

  /// No description provided for @ocrPlugins.
  ///
  /// In en, this message translates to:
  /// **'Text Recognition (OCR)'**
  String get ocrPlugins;

  /// No description provided for @audioExtractorPlugins.
  ///
  /// In en, this message translates to:
  /// **'Video & Audio Extraction'**
  String get audioExtractorPlugins;

  /// No description provided for @voiceModelManagement.
  ///
  /// In en, this message translates to:
  /// **'Voice Model Management'**
  String get voiceModelManagement;

  /// No description provided for @voiceModelManagementHint.
  ///
  /// In en, this message translates to:
  /// **'ASR speech recognition models and TTS speech synthesis models are managed in Voice Settings. Go to Settings → Voice Settings to configure.'**
  String get voiceModelManagementHint;

  /// No description provided for @goToVoiceSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Voice Settings'**
  String get goToVoiceSettings;

  /// No description provided for @managedInSettings.
  ///
  /// In en, this message translates to:
  /// **'Managed in Settings'**
  String get managedInSettings;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelected;

  /// No description provided for @exportSelected.
  ///
  /// In en, this message translates to:
  /// **'Export Selected'**
  String get exportSelected;

  /// No description provided for @exportAll.
  ///
  /// In en, this message translates to:
  /// **'Export All'**
  String get exportAll;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @logCategory.
  ///
  /// In en, this message translates to:
  /// **'Log Category'**
  String get logCategory;

  /// No description provided for @loadingLogsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load logs'**
  String get loadingLogsFailed;

  /// No description provided for @loadingMoreLogsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load more logs'**
  String get loadingMoreLogsFailed;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @noLogsToExport.
  ///
  /// In en, this message translates to:
  /// **'No logs to export'**
  String get noLogsToExport;

  /// No description provided for @logsExported.
  ///
  /// In en, this message translates to:
  /// **'Logs exported'**
  String get logsExported;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deleteSuccess;

  /// No description provided for @noLogsToShow.
  ///
  /// In en, this message translates to:
  /// **'No logs'**
  String get noLogsToShow;

  /// No description provided for @logLevelError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get logLevelError;

  /// No description provided for @logLevelWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get logLevelWarning;

  /// No description provided for @logLevelInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get logLevelInfo;

  /// No description provided for @logLevelDebug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get logLevelDebug;

  /// No description provided for @whatIsLocalModel.
  ///
  /// In en, this message translates to:
  /// **'What is a Local Model?'**
  String get whatIsLocalModel;

  /// No description provided for @howToDownloadModel.
  ///
  /// In en, this message translates to:
  /// **'How to Download Models?'**
  String get howToDownloadModel;

  /// No description provided for @whatIsQuantization.
  ///
  /// In en, this message translates to:
  /// **'What are Quantized Models?'**
  String get whatIsQuantization;

  /// No description provided for @howToChooseModel.
  ///
  /// In en, this message translates to:
  /// **'How to Choose the Right Model?'**
  String get howToChooseModel;

  /// No description provided for @whatIsMmproj.
  ///
  /// In en, this message translates to:
  /// **'What is mmproj?'**
  String get whatIsMmproj;

  /// No description provided for @startUsing.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get startUsing;

  /// No description provided for @localModelDescription.
  ///
  /// In en, this message translates to:
  /// **'A local model means downloading AI model files (such as GGUF format) to your device and running them locally.'**
  String get localModelDescription;

  /// No description provided for @localModelAdvantages.
  ///
  /// In en, this message translates to:
  /// **'Advantages of Local Models'**
  String get localModelAdvantages;

  /// No description provided for @downloadModelIntro.
  ///
  /// In en, this message translates to:
  /// **'The app has a built-in model market where you can browse and download models.'**
  String get downloadModelIntro;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @featuredModels.
  ///
  /// In en, this message translates to:
  /// **'Featured Models'**
  String get featuredModels;

  /// No description provided for @trending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// No description provided for @trendingModels.
  ///
  /// In en, this message translates to:
  /// **'Trending Models'**
  String get trendingModels;

  /// No description provided for @suitableForLocal.
  ///
  /// In en, this message translates to:
  /// **'GGUF quantized models suitable for local deployment'**
  String get suitableForLocal;

  /// No description provided for @noRecommendedModels.
  ///
  /// In en, this message translates to:
  /// **'No recommended models'**
  String get noRecommendedModels;

  /// No description provided for @noTrendingModels.
  ///
  /// In en, this message translates to:
  /// **'No trending models'**
  String get noTrendingModels;

  /// No description provided for @loadTrendingFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load trending models'**
  String get loadTrendingFailed;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get searchFailed;

  /// No description provided for @ggufFiles.
  ///
  /// In en, this message translates to:
  /// **'GGUF Files'**
  String get ggufFiles;

  /// No description provided for @noGgufFilesHint.
  ///
  /// In en, this message translates to:
  /// **'No GGUF quantized files found. This model may not support local deployment.'**
  String get noGgufFilesHint;

  /// No description provided for @multimodalProjector.
  ///
  /// In en, this message translates to:
  /// **'Multimodal Projector (mmproj)'**
  String get multimodalProjector;

  /// No description provided for @mmprojHint.
  ///
  /// In en, this message translates to:
  /// **'Required for image/video understanding, needs to be downloaded together with GGUF model'**
  String get mmprojHint;

  /// No description provided for @modelIntro.
  ///
  /// In en, this message translates to:
  /// **'Model Introduction'**
  String get modelIntro;

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download Complete'**
  String get downloadComplete;

  /// No description provided for @loadLater.
  ///
  /// In en, this message translates to:
  /// **'Load Later'**
  String get loadLater;

  /// No description provided for @loadNow.
  ///
  /// In en, this message translates to:
  /// **'Load Now'**
  String get loadNow;

  /// No description provided for @loadingModel.
  ///
  /// In en, this message translates to:
  /// **'Loading model...'**
  String get loadingModel;

  /// No description provided for @modelLoadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Model Loaded Successfully'**
  String get modelLoadSuccess;

  /// No description provided for @modelReadyToChat.
  ///
  /// In en, this message translates to:
  /// **'{name} has been loaded and is ready for conversation.'**
  String modelReadyToChat(String name);

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start Chat'**
  String get startChat;

  /// No description provided for @modelLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Model load failed'**
  String get modelLoadFailed;

  /// No description provided for @modelAddedToList.
  ///
  /// In en, this message translates to:
  /// **'{name} has been added to model list'**
  String modelAddedToList(String name);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @chineseOptimized.
  ///
  /// In en, this message translates to:
  /// **'Chinese Optimized'**
  String get chineseOptimized;

  /// No description provided for @codeGeneration.
  ///
  /// In en, this message translates to:
  /// **'Code Generation'**
  String get codeGeneration;

  /// No description provided for @mathReasoning.
  ///
  /// In en, this message translates to:
  /// **'Math Reasoning'**
  String get mathReasoning;

  /// No description provided for @generalChat.
  ///
  /// In en, this message translates to:
  /// **'General Chat'**
  String get generalChat;

  /// No description provided for @loadConfigHint.
  ///
  /// In en, this message translates to:
  /// **'Will load model with default config (CPU + 6 threads)'**
  String get loadConfigHint;

  /// No description provided for @deviceCompatibility.
  ///
  /// In en, this message translates to:
  /// **'Device Compatibility Issue'**
  String get deviceCompatibility;

  /// No description provided for @availableMemory.
  ///
  /// In en, this message translates to:
  /// **'Available Memory'**
  String get availableMemory;

  /// No description provided for @availableStorage.
  ///
  /// In en, this message translates to:
  /// **'Available Storage'**
  String get availableStorage;

  /// No description provided for @storageRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage Required'**
  String get storageRequired;

  /// No description provided for @memoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Memory Required'**
  String get memoryRequired;

  /// No description provided for @parameterCount.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get parameterCount;

  /// No description provided for @quantFormat.
  ///
  /// In en, this message translates to:
  /// **'Quantization Format'**
  String get quantFormat;

  /// No description provided for @deviceNotMeetMin.
  ///
  /// In en, this message translates to:
  /// **'Device does not meet minimum requirements'**
  String get deviceNotMeetMin;

  /// No description provided for @forceDownloadWarning.
  ///
  /// In en, this message translates to:
  /// **'Force download may result in model unable to load or slow performance.'**
  String get forceDownloadWarning;

  /// No description provided for @tipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tipsTitle;

  /// No description provided for @visionSupport.
  ///
  /// In en, this message translates to:
  /// **'Multimodal Support (Vision)'**
  String get visionSupport;

  /// No description provided for @visionSupportHint.
  ///
  /// In en, this message translates to:
  /// **'This model supports image/video understanding. Enabling will also download mmproj projector file.'**
  String get visionSupportHint;

  /// No description provided for @enableVisionSupport.
  ///
  /// In en, this message translates to:
  /// **'Enable Vision Support'**
  String get enableVisionSupport;

  /// No description provided for @lowMemoryVisionWarning.
  ///
  /// In en, this message translates to:
  /// **'Low memory (<16GB), Vision not recommended'**
  String get lowMemoryVisionWarning;

  /// No description provided for @startDownload.
  ///
  /// In en, this message translates to:
  /// **'Start Download'**
  String get startDownload;

  /// No description provided for @stillDownload.
  ///
  /// In en, this message translates to:
  /// **'Download Anyway'**
  String get stillDownload;

  /// No description provided for @detectingCompatibility.
  ///
  /// In en, this message translates to:
  /// **'Detecting device compatibility...'**
  String get detectingCompatibility;

  /// No description provided for @multimodal.
  ///
  /// In en, this message translates to:
  /// **'Multimodal'**
  String get multimodal;

  /// No description provided for @mmprojAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'mmproj projector file already exists, skipping download'**
  String get mmprojAlreadyExists;

  /// No description provided for @mmprojDownloadComplete.
  ///
  /// In en, this message translates to:
  /// **'mmproj projector file download complete'**
  String get mmprojDownloadComplete;

  /// No description provided for @mmprojDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'mmproj download failed'**
  String get mmprojDownloadFailed;

  /// No description provided for @createDownloadTaskFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create download task'**
  String get createDownloadTaskFailed;

  /// No description provided for @downloadStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start download'**
  String get downloadStartFailed;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String downloadFailed(String error);

  /// No description provided for @modelDownloadedToLocal.
  ///
  /// In en, this message translates to:
  /// **'Model has been successfully downloaded locally.'**
  String get modelDownloadedToLocal;

  /// No description provided for @ramRequired.
  ///
  /// In en, this message translates to:
  /// **'RAM Required'**
  String get ramRequired;

  /// No description provided for @exceedsCurrentConfig.
  ///
  /// In en, this message translates to:
  /// **'Exceeds current configuration: {reasons}'**
  String exceedsCurrentConfig(String reasons);

  /// No description provided for @downloadModelHint.
  ///
  /// In en, this message translates to:
  /// **'After download, the model will be automatically registered. You can view and load it in Model Management.'**
  String get downloadModelHint;

  /// No description provided for @downloadAnywayHint.
  ///
  /// In en, this message translates to:
  /// **'You can still try to download, but it may not work properly.'**
  String get downloadAnywayHint;

  /// No description provided for @loadConfigChinese.
  ///
  /// In en, this message translates to:
  /// **'Will load with Chinese model config (CPU + 8 threads)'**
  String get loadConfigChinese;

  /// No description provided for @loadConfigCode.
  ///
  /// In en, this message translates to:
  /// **'Will load with code model config (CPU + 4 threads, 4096 context)'**
  String get loadConfigCode;

  /// No description provided for @loadConfigReasoning.
  ///
  /// In en, this message translates to:
  /// **'Will load with reasoning model config (CPU + 8 threads, 8192 context)'**
  String get loadConfigReasoning;

  /// No description provided for @mmprojInfo.
  ///
  /// In en, this message translates to:
  /// **'This model supports image/video understanding. mmproj is a required component for image-to-text.\n\n⚠️ Note: If memory is limited (<16GB), loading mmproj is not recommended as it uses additional memory.'**
  String get mmprojInfo;
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
