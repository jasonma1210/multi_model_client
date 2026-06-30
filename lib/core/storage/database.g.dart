// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemPromptMeta = const VerificationMeta(
    'systemPrompt',
  );
  @override
  late final GeneratedColumn<String> systemPrompt = GeneratedColumn<String>(
    'system_prompt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inferenceParamsMeta = const VerificationMeta(
    'inferenceParams',
  );
  @override
  late final GeneratedColumn<String> inferenceParams = GeneratedColumn<String>(
    'inference_params',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _enableGlobalMemoryMeta =
      const VerificationMeta('enableGlobalMemory');
  @override
  late final GeneratedColumn<bool> enableGlobalMemory = GeneratedColumn<bool>(
    'enable_global_memory',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_global_memory" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _enableVideoUnderstandingMeta =
      const VerificationMeta('enableVideoUnderstanding');
  @override
  late final GeneratedColumn<bool> enableVideoUnderstanding =
      GeneratedColumn<bool>(
        'enable_video_understanding',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("enable_video_understanding" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _enabledMcpServerIdsMeta =
      const VerificationMeta('enabledMcpServerIds');
  @override
  late final GeneratedColumn<String> enabledMcpServerIds =
      GeneratedColumn<String>(
        'enabled_mcp_server_ids',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _enableWebSearchMeta = const VerificationMeta(
    'enableWebSearch',
  );
  @override
  late final GeneratedColumn<bool> enableWebSearch = GeneratedColumn<bool>(
    'enable_web_search',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_web_search" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _enableVoiceInputMeta = const VerificationMeta(
    'enableVoiceInput',
  );
  @override
  late final GeneratedColumn<bool> enableVoiceInput = GeneratedColumn<bool>(
    'enable_voice_input',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_voice_input" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _enableVoiceOutputMeta = const VerificationMeta(
    'enableVoiceOutput',
  );
  @override
  late final GeneratedColumn<bool> enableVoiceOutput = GeneratedColumn<bool>(
    'enable_voice_output',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_voice_output" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _enabledSkillMeta = const VerificationMeta(
    'enabledSkill',
  );
  @override
  late final GeneratedColumn<String> enabledSkill = GeneratedColumn<String>(
    'enabled_skill',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enableCameraMeta = const VerificationMeta(
    'enableCamera',
  );
  @override
  late final GeneratedColumn<bool> enableCamera = GeneratedColumn<bool>(
    'enable_camera',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_camera" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _enableFileUploadMeta = const VerificationMeta(
    'enableFileUpload',
  );
  @override
  late final GeneratedColumn<bool> enableFileUpload = GeneratedColumn<bool>(
    'enable_file_upload',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_file_upload" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _enabledKnowledgeBaseIdMeta =
      const VerificationMeta('enabledKnowledgeBaseId');
  @override
  late final GeneratedColumn<String> enabledKnowledgeBaseId =
      GeneratedColumn<String>(
        'enabled_knowledge_base_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isSpiritMeta = const VerificationMeta(
    'isSpirit',
  );
  @override
  late final GeneratedColumn<bool> isSpirit = GeneratedColumn<bool>(
    'is_spirit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_spirit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    folderId,
    modelId,
    systemPrompt,
    inferenceParams,
    isPinned,
    isArchived,
    enableGlobalMemory,
    enableVideoUnderstanding,
    enabledMcpServerIds,
    enableWebSearch,
    enableVoiceInput,
    enableVoiceOutput,
    enabledSkill,
    enableCamera,
    enableFileUpload,
    enabledKnowledgeBaseId,
    isSpirit,
    projectId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('system_prompt')) {
      context.handle(
        _systemPromptMeta,
        systemPrompt.isAcceptableOrUnknown(
          data['system_prompt']!,
          _systemPromptMeta,
        ),
      );
    }
    if (data.containsKey('inference_params')) {
      context.handle(
        _inferenceParamsMeta,
        inferenceParams.isAcceptableOrUnknown(
          data['inference_params']!,
          _inferenceParamsMeta,
        ),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('enable_global_memory')) {
      context.handle(
        _enableGlobalMemoryMeta,
        enableGlobalMemory.isAcceptableOrUnknown(
          data['enable_global_memory']!,
          _enableGlobalMemoryMeta,
        ),
      );
    }
    if (data.containsKey('enable_video_understanding')) {
      context.handle(
        _enableVideoUnderstandingMeta,
        enableVideoUnderstanding.isAcceptableOrUnknown(
          data['enable_video_understanding']!,
          _enableVideoUnderstandingMeta,
        ),
      );
    }
    if (data.containsKey('enabled_mcp_server_ids')) {
      context.handle(
        _enabledMcpServerIdsMeta,
        enabledMcpServerIds.isAcceptableOrUnknown(
          data['enabled_mcp_server_ids']!,
          _enabledMcpServerIdsMeta,
        ),
      );
    }
    if (data.containsKey('enable_web_search')) {
      context.handle(
        _enableWebSearchMeta,
        enableWebSearch.isAcceptableOrUnknown(
          data['enable_web_search']!,
          _enableWebSearchMeta,
        ),
      );
    }
    if (data.containsKey('enable_voice_input')) {
      context.handle(
        _enableVoiceInputMeta,
        enableVoiceInput.isAcceptableOrUnknown(
          data['enable_voice_input']!,
          _enableVoiceInputMeta,
        ),
      );
    }
    if (data.containsKey('enable_voice_output')) {
      context.handle(
        _enableVoiceOutputMeta,
        enableVoiceOutput.isAcceptableOrUnknown(
          data['enable_voice_output']!,
          _enableVoiceOutputMeta,
        ),
      );
    }
    if (data.containsKey('enabled_skill')) {
      context.handle(
        _enabledSkillMeta,
        enabledSkill.isAcceptableOrUnknown(
          data['enabled_skill']!,
          _enabledSkillMeta,
        ),
      );
    }
    if (data.containsKey('enable_camera')) {
      context.handle(
        _enableCameraMeta,
        enableCamera.isAcceptableOrUnknown(
          data['enable_camera']!,
          _enableCameraMeta,
        ),
      );
    }
    if (data.containsKey('enable_file_upload')) {
      context.handle(
        _enableFileUploadMeta,
        enableFileUpload.isAcceptableOrUnknown(
          data['enable_file_upload']!,
          _enableFileUploadMeta,
        ),
      );
    }
    if (data.containsKey('enabled_knowledge_base_id')) {
      context.handle(
        _enabledKnowledgeBaseIdMeta,
        enabledKnowledgeBaseId.isAcceptableOrUnknown(
          data['enabled_knowledge_base_id']!,
          _enabledKnowledgeBaseIdMeta,
        ),
      );
    }
    if (data.containsKey('is_spirit')) {
      context.handle(
        _isSpiritMeta,
        isSpirit.isAcceptableOrUnknown(data['is_spirit']!, _isSpiritMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      systemPrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_prompt'],
      ),
      inferenceParams: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inference_params'],
      ),
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      enableGlobalMemory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_global_memory'],
      )!,
      enableVideoUnderstanding: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_video_understanding'],
      )!,
      enabledMcpServerIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enabled_mcp_server_ids'],
      ),
      enableWebSearch: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_web_search'],
      )!,
      enableVoiceInput: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_voice_input'],
      )!,
      enableVoiceOutput: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_voice_output'],
      )!,
      enabledSkill: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enabled_skill'],
      ),
      enableCamera: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_camera'],
      )!,
      enableFileUpload: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_file_upload'],
      )!,
      enabledKnowledgeBaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enabled_knowledge_base_id'],
      ),
      isSpirit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_spirit'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final String name;
  final String? folderId;
  final String modelId;
  final String? systemPrompt;
  final String? inferenceParams;
  final bool isPinned;
  final bool isArchived;
  final bool enableGlobalMemory;
  final bool enableVideoUnderstanding;
  final String? enabledMcpServerIds;
  final bool enableWebSearch;
  final bool enableVoiceInput;
  final bool enableVoiceOutput;
  final String? enabledSkill;
  final bool enableCamera;
  final bool enableFileUpload;
  final String? enabledKnowledgeBaseId;
  final bool isSpirit;
  final String? projectId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Session({
    required this.id,
    required this.name,
    this.folderId,
    required this.modelId,
    this.systemPrompt,
    this.inferenceParams,
    required this.isPinned,
    required this.isArchived,
    required this.enableGlobalMemory,
    required this.enableVideoUnderstanding,
    this.enabledMcpServerIds,
    required this.enableWebSearch,
    required this.enableVoiceInput,
    required this.enableVoiceOutput,
    this.enabledSkill,
    required this.enableCamera,
    required this.enableFileUpload,
    this.enabledKnowledgeBaseId,
    required this.isSpirit,
    this.projectId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    map['model_id'] = Variable<String>(modelId);
    if (!nullToAbsent || systemPrompt != null) {
      map['system_prompt'] = Variable<String>(systemPrompt);
    }
    if (!nullToAbsent || inferenceParams != null) {
      map['inference_params'] = Variable<String>(inferenceParams);
    }
    map['is_pinned'] = Variable<bool>(isPinned);
    map['is_archived'] = Variable<bool>(isArchived);
    map['enable_global_memory'] = Variable<bool>(enableGlobalMemory);
    map['enable_video_understanding'] = Variable<bool>(
      enableVideoUnderstanding,
    );
    if (!nullToAbsent || enabledMcpServerIds != null) {
      map['enabled_mcp_server_ids'] = Variable<String>(enabledMcpServerIds);
    }
    map['enable_web_search'] = Variable<bool>(enableWebSearch);
    map['enable_voice_input'] = Variable<bool>(enableVoiceInput);
    map['enable_voice_output'] = Variable<bool>(enableVoiceOutput);
    if (!nullToAbsent || enabledSkill != null) {
      map['enabled_skill'] = Variable<String>(enabledSkill);
    }
    map['enable_camera'] = Variable<bool>(enableCamera);
    map['enable_file_upload'] = Variable<bool>(enableFileUpload);
    if (!nullToAbsent || enabledKnowledgeBaseId != null) {
      map['enabled_knowledge_base_id'] = Variable<String>(
        enabledKnowledgeBaseId,
      );
    }
    map['is_spirit'] = Variable<bool>(isSpirit);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      name: Value(name),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      modelId: Value(modelId),
      systemPrompt: systemPrompt == null && nullToAbsent
          ? const Value.absent()
          : Value(systemPrompt),
      inferenceParams: inferenceParams == null && nullToAbsent
          ? const Value.absent()
          : Value(inferenceParams),
      isPinned: Value(isPinned),
      isArchived: Value(isArchived),
      enableGlobalMemory: Value(enableGlobalMemory),
      enableVideoUnderstanding: Value(enableVideoUnderstanding),
      enabledMcpServerIds: enabledMcpServerIds == null && nullToAbsent
          ? const Value.absent()
          : Value(enabledMcpServerIds),
      enableWebSearch: Value(enableWebSearch),
      enableVoiceInput: Value(enableVoiceInput),
      enableVoiceOutput: Value(enableVoiceOutput),
      enabledSkill: enabledSkill == null && nullToAbsent
          ? const Value.absent()
          : Value(enabledSkill),
      enableCamera: Value(enableCamera),
      enableFileUpload: Value(enableFileUpload),
      enabledKnowledgeBaseId: enabledKnowledgeBaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(enabledKnowledgeBaseId),
      isSpirit: Value(isSpirit),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      modelId: serializer.fromJson<String>(json['modelId']),
      systemPrompt: serializer.fromJson<String?>(json['systemPrompt']),
      inferenceParams: serializer.fromJson<String?>(json['inferenceParams']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      enableGlobalMemory: serializer.fromJson<bool>(json['enableGlobalMemory']),
      enableVideoUnderstanding: serializer.fromJson<bool>(
        json['enableVideoUnderstanding'],
      ),
      enabledMcpServerIds: serializer.fromJson<String?>(
        json['enabledMcpServerIds'],
      ),
      enableWebSearch: serializer.fromJson<bool>(json['enableWebSearch']),
      enableVoiceInput: serializer.fromJson<bool>(json['enableVoiceInput']),
      enableVoiceOutput: serializer.fromJson<bool>(json['enableVoiceOutput']),
      enabledSkill: serializer.fromJson<String?>(json['enabledSkill']),
      enableCamera: serializer.fromJson<bool>(json['enableCamera']),
      enableFileUpload: serializer.fromJson<bool>(json['enableFileUpload']),
      enabledKnowledgeBaseId: serializer.fromJson<String?>(
        json['enabledKnowledgeBaseId'],
      ),
      isSpirit: serializer.fromJson<bool>(json['isSpirit']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'folderId': serializer.toJson<String?>(folderId),
      'modelId': serializer.toJson<String>(modelId),
      'systemPrompt': serializer.toJson<String?>(systemPrompt),
      'inferenceParams': serializer.toJson<String?>(inferenceParams),
      'isPinned': serializer.toJson<bool>(isPinned),
      'isArchived': serializer.toJson<bool>(isArchived),
      'enableGlobalMemory': serializer.toJson<bool>(enableGlobalMemory),
      'enableVideoUnderstanding': serializer.toJson<bool>(
        enableVideoUnderstanding,
      ),
      'enabledMcpServerIds': serializer.toJson<String?>(enabledMcpServerIds),
      'enableWebSearch': serializer.toJson<bool>(enableWebSearch),
      'enableVoiceInput': serializer.toJson<bool>(enableVoiceInput),
      'enableVoiceOutput': serializer.toJson<bool>(enableVoiceOutput),
      'enabledSkill': serializer.toJson<String?>(enabledSkill),
      'enableCamera': serializer.toJson<bool>(enableCamera),
      'enableFileUpload': serializer.toJson<bool>(enableFileUpload),
      'enabledKnowledgeBaseId': serializer.toJson<String?>(
        enabledKnowledgeBaseId,
      ),
      'isSpirit': serializer.toJson<bool>(isSpirit),
      'projectId': serializer.toJson<String?>(projectId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Session copyWith({
    String? id,
    String? name,
    Value<String?> folderId = const Value.absent(),
    String? modelId,
    Value<String?> systemPrompt = const Value.absent(),
    Value<String?> inferenceParams = const Value.absent(),
    bool? isPinned,
    bool? isArchived,
    bool? enableGlobalMemory,
    bool? enableVideoUnderstanding,
    Value<String?> enabledMcpServerIds = const Value.absent(),
    bool? enableWebSearch,
    bool? enableVoiceInput,
    bool? enableVoiceOutput,
    Value<String?> enabledSkill = const Value.absent(),
    bool? enableCamera,
    bool? enableFileUpload,
    Value<String?> enabledKnowledgeBaseId = const Value.absent(),
    bool? isSpirit,
    Value<String?> projectId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Session(
    id: id ?? this.id,
    name: name ?? this.name,
    folderId: folderId.present ? folderId.value : this.folderId,
    modelId: modelId ?? this.modelId,
    systemPrompt: systemPrompt.present ? systemPrompt.value : this.systemPrompt,
    inferenceParams: inferenceParams.present
        ? inferenceParams.value
        : this.inferenceParams,
    isPinned: isPinned ?? this.isPinned,
    isArchived: isArchived ?? this.isArchived,
    enableGlobalMemory: enableGlobalMemory ?? this.enableGlobalMemory,
    enableVideoUnderstanding:
        enableVideoUnderstanding ?? this.enableVideoUnderstanding,
    enabledMcpServerIds: enabledMcpServerIds.present
        ? enabledMcpServerIds.value
        : this.enabledMcpServerIds,
    enableWebSearch: enableWebSearch ?? this.enableWebSearch,
    enableVoiceInput: enableVoiceInput ?? this.enableVoiceInput,
    enableVoiceOutput: enableVoiceOutput ?? this.enableVoiceOutput,
    enabledSkill: enabledSkill.present ? enabledSkill.value : this.enabledSkill,
    enableCamera: enableCamera ?? this.enableCamera,
    enableFileUpload: enableFileUpload ?? this.enableFileUpload,
    enabledKnowledgeBaseId: enabledKnowledgeBaseId.present
        ? enabledKnowledgeBaseId.value
        : this.enabledKnowledgeBaseId,
    isSpirit: isSpirit ?? this.isSpirit,
    projectId: projectId.present ? projectId.value : this.projectId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      systemPrompt: data.systemPrompt.present
          ? data.systemPrompt.value
          : this.systemPrompt,
      inferenceParams: data.inferenceParams.present
          ? data.inferenceParams.value
          : this.inferenceParams,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      enableGlobalMemory: data.enableGlobalMemory.present
          ? data.enableGlobalMemory.value
          : this.enableGlobalMemory,
      enableVideoUnderstanding: data.enableVideoUnderstanding.present
          ? data.enableVideoUnderstanding.value
          : this.enableVideoUnderstanding,
      enabledMcpServerIds: data.enabledMcpServerIds.present
          ? data.enabledMcpServerIds.value
          : this.enabledMcpServerIds,
      enableWebSearch: data.enableWebSearch.present
          ? data.enableWebSearch.value
          : this.enableWebSearch,
      enableVoiceInput: data.enableVoiceInput.present
          ? data.enableVoiceInput.value
          : this.enableVoiceInput,
      enableVoiceOutput: data.enableVoiceOutput.present
          ? data.enableVoiceOutput.value
          : this.enableVoiceOutput,
      enabledSkill: data.enabledSkill.present
          ? data.enabledSkill.value
          : this.enabledSkill,
      enableCamera: data.enableCamera.present
          ? data.enableCamera.value
          : this.enableCamera,
      enableFileUpload: data.enableFileUpload.present
          ? data.enableFileUpload.value
          : this.enableFileUpload,
      enabledKnowledgeBaseId: data.enabledKnowledgeBaseId.present
          ? data.enabledKnowledgeBaseId.value
          : this.enabledKnowledgeBaseId,
      isSpirit: data.isSpirit.present ? data.isSpirit.value : this.isSpirit,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('folderId: $folderId, ')
          ..write('modelId: $modelId, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('inferenceParams: $inferenceParams, ')
          ..write('isPinned: $isPinned, ')
          ..write('isArchived: $isArchived, ')
          ..write('enableGlobalMemory: $enableGlobalMemory, ')
          ..write('enableVideoUnderstanding: $enableVideoUnderstanding, ')
          ..write('enabledMcpServerIds: $enabledMcpServerIds, ')
          ..write('enableWebSearch: $enableWebSearch, ')
          ..write('enableVoiceInput: $enableVoiceInput, ')
          ..write('enableVoiceOutput: $enableVoiceOutput, ')
          ..write('enabledSkill: $enabledSkill, ')
          ..write('enableCamera: $enableCamera, ')
          ..write('enableFileUpload: $enableFileUpload, ')
          ..write('enabledKnowledgeBaseId: $enabledKnowledgeBaseId, ')
          ..write('isSpirit: $isSpirit, ')
          ..write('projectId: $projectId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    folderId,
    modelId,
    systemPrompt,
    inferenceParams,
    isPinned,
    isArchived,
    enableGlobalMemory,
    enableVideoUnderstanding,
    enabledMcpServerIds,
    enableWebSearch,
    enableVoiceInput,
    enableVoiceOutput,
    enabledSkill,
    enableCamera,
    enableFileUpload,
    enabledKnowledgeBaseId,
    isSpirit,
    projectId,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.name == this.name &&
          other.folderId == this.folderId &&
          other.modelId == this.modelId &&
          other.systemPrompt == this.systemPrompt &&
          other.inferenceParams == this.inferenceParams &&
          other.isPinned == this.isPinned &&
          other.isArchived == this.isArchived &&
          other.enableGlobalMemory == this.enableGlobalMemory &&
          other.enableVideoUnderstanding == this.enableVideoUnderstanding &&
          other.enabledMcpServerIds == this.enabledMcpServerIds &&
          other.enableWebSearch == this.enableWebSearch &&
          other.enableVoiceInput == this.enableVoiceInput &&
          other.enableVoiceOutput == this.enableVoiceOutput &&
          other.enabledSkill == this.enabledSkill &&
          other.enableCamera == this.enableCamera &&
          other.enableFileUpload == this.enableFileUpload &&
          other.enabledKnowledgeBaseId == this.enabledKnowledgeBaseId &&
          other.isSpirit == this.isSpirit &&
          other.projectId == this.projectId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> folderId;
  final Value<String> modelId;
  final Value<String?> systemPrompt;
  final Value<String?> inferenceParams;
  final Value<bool> isPinned;
  final Value<bool> isArchived;
  final Value<bool> enableGlobalMemory;
  final Value<bool> enableVideoUnderstanding;
  final Value<String?> enabledMcpServerIds;
  final Value<bool> enableWebSearch;
  final Value<bool> enableVoiceInput;
  final Value<bool> enableVoiceOutput;
  final Value<String?> enabledSkill;
  final Value<bool> enableCamera;
  final Value<bool> enableFileUpload;
  final Value<String?> enabledKnowledgeBaseId;
  final Value<bool> isSpirit;
  final Value<String?> projectId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.folderId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.inferenceParams = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.enableGlobalMemory = const Value.absent(),
    this.enableVideoUnderstanding = const Value.absent(),
    this.enabledMcpServerIds = const Value.absent(),
    this.enableWebSearch = const Value.absent(),
    this.enableVoiceInput = const Value.absent(),
    this.enableVoiceOutput = const Value.absent(),
    this.enabledSkill = const Value.absent(),
    this.enableCamera = const Value.absent(),
    this.enableFileUpload = const Value.absent(),
    this.enabledKnowledgeBaseId = const Value.absent(),
    this.isSpirit = const Value.absent(),
    this.projectId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String name,
    this.folderId = const Value.absent(),
    required String modelId,
    this.systemPrompt = const Value.absent(),
    this.inferenceParams = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.enableGlobalMemory = const Value.absent(),
    this.enableVideoUnderstanding = const Value.absent(),
    this.enabledMcpServerIds = const Value.absent(),
    this.enableWebSearch = const Value.absent(),
    this.enableVoiceInput = const Value.absent(),
    this.enableVoiceOutput = const Value.absent(),
    this.enabledSkill = const Value.absent(),
    this.enableCamera = const Value.absent(),
    this.enableFileUpload = const Value.absent(),
    this.enabledKnowledgeBaseId = const Value.absent(),
    this.isSpirit = const Value.absent(),
    this.projectId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       modelId = Value(modelId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? folderId,
    Expression<String>? modelId,
    Expression<String>? systemPrompt,
    Expression<String>? inferenceParams,
    Expression<bool>? isPinned,
    Expression<bool>? isArchived,
    Expression<bool>? enableGlobalMemory,
    Expression<bool>? enableVideoUnderstanding,
    Expression<String>? enabledMcpServerIds,
    Expression<bool>? enableWebSearch,
    Expression<bool>? enableVoiceInput,
    Expression<bool>? enableVoiceOutput,
    Expression<String>? enabledSkill,
    Expression<bool>? enableCamera,
    Expression<bool>? enableFileUpload,
    Expression<String>? enabledKnowledgeBaseId,
    Expression<bool>? isSpirit,
    Expression<String>? projectId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (folderId != null) 'folder_id': folderId,
      if (modelId != null) 'model_id': modelId,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
      if (inferenceParams != null) 'inference_params': inferenceParams,
      if (isPinned != null) 'is_pinned': isPinned,
      if (isArchived != null) 'is_archived': isArchived,
      if (enableGlobalMemory != null)
        'enable_global_memory': enableGlobalMemory,
      if (enableVideoUnderstanding != null)
        'enable_video_understanding': enableVideoUnderstanding,
      if (enabledMcpServerIds != null)
        'enabled_mcp_server_ids': enabledMcpServerIds,
      if (enableWebSearch != null) 'enable_web_search': enableWebSearch,
      if (enableVoiceInput != null) 'enable_voice_input': enableVoiceInput,
      if (enableVoiceOutput != null) 'enable_voice_output': enableVoiceOutput,
      if (enabledSkill != null) 'enabled_skill': enabledSkill,
      if (enableCamera != null) 'enable_camera': enableCamera,
      if (enableFileUpload != null) 'enable_file_upload': enableFileUpload,
      if (enabledKnowledgeBaseId != null)
        'enabled_knowledge_base_id': enabledKnowledgeBaseId,
      if (isSpirit != null) 'is_spirit': isSpirit,
      if (projectId != null) 'project_id': projectId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? folderId,
    Value<String>? modelId,
    Value<String?>? systemPrompt,
    Value<String?>? inferenceParams,
    Value<bool>? isPinned,
    Value<bool>? isArchived,
    Value<bool>? enableGlobalMemory,
    Value<bool>? enableVideoUnderstanding,
    Value<String?>? enabledMcpServerIds,
    Value<bool>? enableWebSearch,
    Value<bool>? enableVoiceInput,
    Value<bool>? enableVoiceOutput,
    Value<String?>? enabledSkill,
    Value<bool>? enableCamera,
    Value<bool>? enableFileUpload,
    Value<String?>? enabledKnowledgeBaseId,
    Value<bool>? isSpirit,
    Value<String?>? projectId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      folderId: folderId ?? this.folderId,
      modelId: modelId ?? this.modelId,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      inferenceParams: inferenceParams ?? this.inferenceParams,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      enableGlobalMemory: enableGlobalMemory ?? this.enableGlobalMemory,
      enableVideoUnderstanding:
          enableVideoUnderstanding ?? this.enableVideoUnderstanding,
      enabledMcpServerIds: enabledMcpServerIds ?? this.enabledMcpServerIds,
      enableWebSearch: enableWebSearch ?? this.enableWebSearch,
      enableVoiceInput: enableVoiceInput ?? this.enableVoiceInput,
      enableVoiceOutput: enableVoiceOutput ?? this.enableVoiceOutput,
      enabledSkill: enabledSkill ?? this.enabledSkill,
      enableCamera: enableCamera ?? this.enableCamera,
      enableFileUpload: enableFileUpload ?? this.enableFileUpload,
      enabledKnowledgeBaseId:
          enabledKnowledgeBaseId ?? this.enabledKnowledgeBaseId,
      isSpirit: isSpirit ?? this.isSpirit,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (systemPrompt.present) {
      map['system_prompt'] = Variable<String>(systemPrompt.value);
    }
    if (inferenceParams.present) {
      map['inference_params'] = Variable<String>(inferenceParams.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (enableGlobalMemory.present) {
      map['enable_global_memory'] = Variable<bool>(enableGlobalMemory.value);
    }
    if (enableVideoUnderstanding.present) {
      map['enable_video_understanding'] = Variable<bool>(
        enableVideoUnderstanding.value,
      );
    }
    if (enabledMcpServerIds.present) {
      map['enabled_mcp_server_ids'] = Variable<String>(
        enabledMcpServerIds.value,
      );
    }
    if (enableWebSearch.present) {
      map['enable_web_search'] = Variable<bool>(enableWebSearch.value);
    }
    if (enableVoiceInput.present) {
      map['enable_voice_input'] = Variable<bool>(enableVoiceInput.value);
    }
    if (enableVoiceOutput.present) {
      map['enable_voice_output'] = Variable<bool>(enableVoiceOutput.value);
    }
    if (enabledSkill.present) {
      map['enabled_skill'] = Variable<String>(enabledSkill.value);
    }
    if (enableCamera.present) {
      map['enable_camera'] = Variable<bool>(enableCamera.value);
    }
    if (enableFileUpload.present) {
      map['enable_file_upload'] = Variable<bool>(enableFileUpload.value);
    }
    if (enabledKnowledgeBaseId.present) {
      map['enabled_knowledge_base_id'] = Variable<String>(
        enabledKnowledgeBaseId.value,
      );
    }
    if (isSpirit.present) {
      map['is_spirit'] = Variable<bool>(isSpirit.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('folderId: $folderId, ')
          ..write('modelId: $modelId, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('inferenceParams: $inferenceParams, ')
          ..write('isPinned: $isPinned, ')
          ..write('isArchived: $isArchived, ')
          ..write('enableGlobalMemory: $enableGlobalMemory, ')
          ..write('enableVideoUnderstanding: $enableVideoUnderstanding, ')
          ..write('enabledMcpServerIds: $enabledMcpServerIds, ')
          ..write('enableWebSearch: $enableWebSearch, ')
          ..write('enableVoiceInput: $enableVoiceInput, ')
          ..write('enableVoiceOutput: $enableVoiceOutput, ')
          ..write('enabledSkill: $enabledSkill, ')
          ..write('enableCamera: $enableCamera, ')
          ..write('enableFileUpload: $enableFileUpload, ')
          ..write('enabledKnowledgeBaseId: $enabledKnowledgeBaseId, ')
          ..write('isSpirit: $isSpirit, ')
          ..write('projectId: $projectId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
  );
  static const VerificationMeta _hasImagesMeta = const VerificationMeta(
    'hasImages',
  );
  @override
  late final GeneratedColumn<bool> hasImages = GeneratedColumn<bool>(
    'has_images',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_images" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tokenCountMeta = const VerificationMeta(
    'tokenCount',
  );
  @override
  late final GeneratedColumn<int> tokenCount = GeneratedColumn<int>(
    'token_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toolCallInfoMeta = const VerificationMeta(
    'toolCallInfo',
  );
  @override
  late final GeneratedColumn<String> toolCallInfo = GeneratedColumn<String>(
    'tool_call_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thinkingMeta = const VerificationMeta(
    'thinking',
  );
  @override
  late final GeneratedColumn<String> thinking = GeneratedColumn<String>(
    'thinking',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thinkingTokensMeta = const VerificationMeta(
    'thinkingTokens',
  );
  @override
  late final GeneratedColumn<int> thinkingTokens = GeneratedColumn<int>(
    'thinking_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _showThinkingMeta = const VerificationMeta(
    'showThinking',
  );
  @override
  late final GeneratedColumn<bool> showThinking = GeneratedColumn<bool>(
    'show_thinking',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_thinking" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    role,
    content,
    type,
    hasImages,
    tokenCount,
    toolCallInfo,
    thinking,
    thinkingTokens,
    showThinking,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('has_images')) {
      context.handle(
        _hasImagesMeta,
        hasImages.isAcceptableOrUnknown(data['has_images']!, _hasImagesMeta),
      );
    }
    if (data.containsKey('token_count')) {
      context.handle(
        _tokenCountMeta,
        tokenCount.isAcceptableOrUnknown(data['token_count']!, _tokenCountMeta),
      );
    }
    if (data.containsKey('tool_call_info')) {
      context.handle(
        _toolCallInfoMeta,
        toolCallInfo.isAcceptableOrUnknown(
          data['tool_call_info']!,
          _toolCallInfoMeta,
        ),
      );
    }
    if (data.containsKey('thinking')) {
      context.handle(
        _thinkingMeta,
        thinking.isAcceptableOrUnknown(data['thinking']!, _thinkingMeta),
      );
    }
    if (data.containsKey('thinking_tokens')) {
      context.handle(
        _thinkingTokensMeta,
        thinkingTokens.isAcceptableOrUnknown(
          data['thinking_tokens']!,
          _thinkingTokensMeta,
        ),
      );
    }
    if (data.containsKey('show_thinking')) {
      context.handle(
        _showThinkingMeta,
        showThinking.isAcceptableOrUnknown(
          data['show_thinking']!,
          _showThinkingMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      hasImages: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_images'],
      )!,
      tokenCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}token_count'],
      ),
      toolCallInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_call_info'],
      ),
      thinking: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thinking'],
      ),
      thinkingTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}thinking_tokens'],
      )!,
      showThinking: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_thinking'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String sessionId;
  final String role;
  final String content;
  final String type;
  final bool hasImages;
  final int? tokenCount;
  final String? toolCallInfo;
  final String? thinking;
  final int thinkingTokens;
  final bool showThinking;
  final DateTime createdAt;
  const Message({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.type,
    required this.hasImages,
    this.tokenCount,
    this.toolCallInfo,
    this.thinking,
    required this.thinkingTokens,
    required this.showThinking,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['type'] = Variable<String>(type);
    map['has_images'] = Variable<bool>(hasImages);
    if (!nullToAbsent || tokenCount != null) {
      map['token_count'] = Variable<int>(tokenCount);
    }
    if (!nullToAbsent || toolCallInfo != null) {
      map['tool_call_info'] = Variable<String>(toolCallInfo);
    }
    if (!nullToAbsent || thinking != null) {
      map['thinking'] = Variable<String>(thinking);
    }
    map['thinking_tokens'] = Variable<int>(thinkingTokens);
    map['show_thinking'] = Variable<bool>(showThinking);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      role: Value(role),
      content: Value(content),
      type: Value(type),
      hasImages: Value(hasImages),
      tokenCount: tokenCount == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenCount),
      toolCallInfo: toolCallInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(toolCallInfo),
      thinking: thinking == null && nullToAbsent
          ? const Value.absent()
          : Value(thinking),
      thinkingTokens: Value(thinkingTokens),
      showThinking: Value(showThinking),
      createdAt: Value(createdAt),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      type: serializer.fromJson<String>(json['type']),
      hasImages: serializer.fromJson<bool>(json['hasImages']),
      tokenCount: serializer.fromJson<int?>(json['tokenCount']),
      toolCallInfo: serializer.fromJson<String?>(json['toolCallInfo']),
      thinking: serializer.fromJson<String?>(json['thinking']),
      thinkingTokens: serializer.fromJson<int>(json['thinkingTokens']),
      showThinking: serializer.fromJson<bool>(json['showThinking']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'type': serializer.toJson<String>(type),
      'hasImages': serializer.toJson<bool>(hasImages),
      'tokenCount': serializer.toJson<int?>(tokenCount),
      'toolCallInfo': serializer.toJson<String?>(toolCallInfo),
      'thinking': serializer.toJson<String?>(thinking),
      'thinkingTokens': serializer.toJson<int>(thinkingTokens),
      'showThinking': serializer.toJson<bool>(showThinking),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Message copyWith({
    String? id,
    String? sessionId,
    String? role,
    String? content,
    String? type,
    bool? hasImages,
    Value<int?> tokenCount = const Value.absent(),
    Value<String?> toolCallInfo = const Value.absent(),
    Value<String?> thinking = const Value.absent(),
    int? thinkingTokens,
    bool? showThinking,
    DateTime? createdAt,
  }) => Message(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    role: role ?? this.role,
    content: content ?? this.content,
    type: type ?? this.type,
    hasImages: hasImages ?? this.hasImages,
    tokenCount: tokenCount.present ? tokenCount.value : this.tokenCount,
    toolCallInfo: toolCallInfo.present ? toolCallInfo.value : this.toolCallInfo,
    thinking: thinking.present ? thinking.value : this.thinking,
    thinkingTokens: thinkingTokens ?? this.thinkingTokens,
    showThinking: showThinking ?? this.showThinking,
    createdAt: createdAt ?? this.createdAt,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      type: data.type.present ? data.type.value : this.type,
      hasImages: data.hasImages.present ? data.hasImages.value : this.hasImages,
      tokenCount: data.tokenCount.present
          ? data.tokenCount.value
          : this.tokenCount,
      toolCallInfo: data.toolCallInfo.present
          ? data.toolCallInfo.value
          : this.toolCallInfo,
      thinking: data.thinking.present ? data.thinking.value : this.thinking,
      thinkingTokens: data.thinkingTokens.present
          ? data.thinkingTokens.value
          : this.thinkingTokens,
      showThinking: data.showThinking.present
          ? data.showThinking.value
          : this.showThinking,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('hasImages: $hasImages, ')
          ..write('tokenCount: $tokenCount, ')
          ..write('toolCallInfo: $toolCallInfo, ')
          ..write('thinking: $thinking, ')
          ..write('thinkingTokens: $thinkingTokens, ')
          ..write('showThinking: $showThinking, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    role,
    content,
    type,
    hasImages,
    tokenCount,
    toolCallInfo,
    thinking,
    thinkingTokens,
    showThinking,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.role == this.role &&
          other.content == this.content &&
          other.type == this.type &&
          other.hasImages == this.hasImages &&
          other.tokenCount == this.tokenCount &&
          other.toolCallInfo == this.toolCallInfo &&
          other.thinking == this.thinking &&
          other.thinkingTokens == this.thinkingTokens &&
          other.showThinking == this.showThinking &&
          other.createdAt == this.createdAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> role;
  final Value<String> content;
  final Value<String> type;
  final Value<bool> hasImages;
  final Value<int?> tokenCount;
  final Value<String?> toolCallInfo;
  final Value<String?> thinking;
  final Value<int> thinkingTokens;
  final Value<bool> showThinking;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.type = const Value.absent(),
    this.hasImages = const Value.absent(),
    this.tokenCount = const Value.absent(),
    this.toolCallInfo = const Value.absent(),
    this.thinking = const Value.absent(),
    this.thinkingTokens = const Value.absent(),
    this.showThinking = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String sessionId,
    required String role,
    required String content,
    this.type = const Value.absent(),
    this.hasImages = const Value.absent(),
    this.tokenCount = const Value.absent(),
    this.toolCallInfo = const Value.absent(),
    this.thinking = const Value.absent(),
    this.thinkingTokens = const Value.absent(),
    this.showThinking = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       role = Value(role),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? type,
    Expression<bool>? hasImages,
    Expression<int>? tokenCount,
    Expression<String>? toolCallInfo,
    Expression<String>? thinking,
    Expression<int>? thinkingTokens,
    Expression<bool>? showThinking,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (type != null) 'type': type,
      if (hasImages != null) 'has_images': hasImages,
      if (tokenCount != null) 'token_count': tokenCount,
      if (toolCallInfo != null) 'tool_call_info': toolCallInfo,
      if (thinking != null) 'thinking': thinking,
      if (thinkingTokens != null) 'thinking_tokens': thinkingTokens,
      if (showThinking != null) 'show_thinking': showThinking,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? role,
    Value<String>? content,
    Value<String>? type,
    Value<bool>? hasImages,
    Value<int?>? tokenCount,
    Value<String?>? toolCallInfo,
    Value<String?>? thinking,
    Value<int>? thinkingTokens,
    Value<bool>? showThinking,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      type: type ?? this.type,
      hasImages: hasImages ?? this.hasImages,
      tokenCount: tokenCount ?? this.tokenCount,
      toolCallInfo: toolCallInfo ?? this.toolCallInfo,
      thinking: thinking ?? this.thinking,
      thinkingTokens: thinkingTokens ?? this.thinkingTokens,
      showThinking: showThinking ?? this.showThinking,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (hasImages.present) {
      map['has_images'] = Variable<bool>(hasImages.value);
    }
    if (tokenCount.present) {
      map['token_count'] = Variable<int>(tokenCount.value);
    }
    if (toolCallInfo.present) {
      map['tool_call_info'] = Variable<String>(toolCallInfo.value);
    }
    if (thinking.present) {
      map['thinking'] = Variable<String>(thinking.value);
    }
    if (thinkingTokens.present) {
      map['thinking_tokens'] = Variable<int>(thinkingTokens.value);
    }
    if (showThinking.present) {
      map['show_thinking'] = Variable<bool>(showThinking.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('hasImages: $hasImages, ')
          ..write('tokenCount: $tokenCount, ')
          ..write('toolCallInfo: $toolCallInfo, ')
          ..write('thinking: $thinking, ')
          ..write('thinkingTokens: $thinkingTokens, ')
          ..write('showThinking: $showThinking, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModelsTable extends Models with TableInfo<$ModelsTable, Model> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _apiConfigMeta = const VerificationMeta(
    'apiConfig',
  );
  @override
  late final GeneratedColumn<String> apiConfig = GeneratedColumn<String>(
    'api_config',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capabilitiesMeta = const VerificationMeta(
    'capabilities',
  );
  @override
  late final GeneratedColumn<String> capabilities = GeneratedColumn<String>(
    'capabilities',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultParamsMeta = const VerificationMeta(
    'defaultParams',
  );
  @override
  late final GeneratedColumn<String> defaultParams = GeneratedColumn<String>(
    'default_params',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMultimodalMeta = const VerificationMeta(
    'isMultimodal',
  );
  @override
  late final GeneratedColumn<bool> isMultimodal = GeneratedColumn<bool>(
    'is_multimodal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_multimodal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _mmprojPathMeta = const VerificationMeta(
    'mmprojPath',
  );
  @override
  late final GeneratedColumn<String> mmprojPath = GeneratedColumn<String>(
    'mmproj_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mmprojFileNameMeta = const VerificationMeta(
    'mmprojFileName',
  );
  @override
  late final GeneratedColumn<String> mmprojFileName = GeneratedColumn<String>(
    'mmproj_file_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isLoadedMeta = const VerificationMeta(
    'isLoaded',
  );
  @override
  late final GeneratedColumn<bool> isLoaded = GeneratedColumn<bool>(
    'is_loaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_loaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _downloadStatusMeta = const VerificationMeta(
    'downloadStatus',
  );
  @override
  late final GeneratedColumn<String> downloadStatus = GeneratedColumn<String>(
    'download_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _thinkingModeMeta = const VerificationMeta(
    'thinkingMode',
  );
  @override
  late final GeneratedColumn<String> thinkingMode = GeneratedColumn<String>(
    'thinking_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('adaptive'),
  );
  static const VerificationMeta _thinkingBudgetMeta = const VerificationMeta(
    'thinkingBudget',
  );
  @override
  late final GeneratedColumn<int> thinkingBudget = GeneratedColumn<int>(
    'thinking_budget',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supportsThinkingMeta = const VerificationMeta(
    'supportsThinking',
  );
  @override
  late final GeneratedColumn<bool> supportsThinking = GeneratedColumn<bool>(
    'supports_thinking',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("supports_thinking" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _minThinkingBudgetMeta = const VerificationMeta(
    'minThinkingBudget',
  );
  @override
  late final GeneratedColumn<int> minThinkingBudget = GeneratedColumn<int>(
    'min_thinking_budget',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1024),
  );
  static const VerificationMeta _maxThinkingBudgetMeta = const VerificationMeta(
    'maxThinkingBudget',
  );
  @override
  late final GeneratedColumn<int> maxThinkingBudget = GeneratedColumn<int>(
    'max_thinking_budget',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100000),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    source,
    path,
    apiConfig,
    capabilities,
    defaultParams,
    isMultimodal,
    mmprojPath,
    mmprojFileName,
    isLoaded,
    downloadStatus,
    thinkingMode,
    thinkingBudget,
    supportsThinking,
    minThinkingBudget,
    maxThinkingBudget,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'models';
  @override
  VerificationContext validateIntegrity(
    Insertable<Model> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    }
    if (data.containsKey('api_config')) {
      context.handle(
        _apiConfigMeta,
        apiConfig.isAcceptableOrUnknown(data['api_config']!, _apiConfigMeta),
      );
    }
    if (data.containsKey('capabilities')) {
      context.handle(
        _capabilitiesMeta,
        capabilities.isAcceptableOrUnknown(
          data['capabilities']!,
          _capabilitiesMeta,
        ),
      );
    }
    if (data.containsKey('default_params')) {
      context.handle(
        _defaultParamsMeta,
        defaultParams.isAcceptableOrUnknown(
          data['default_params']!,
          _defaultParamsMeta,
        ),
      );
    }
    if (data.containsKey('is_multimodal')) {
      context.handle(
        _isMultimodalMeta,
        isMultimodal.isAcceptableOrUnknown(
          data['is_multimodal']!,
          _isMultimodalMeta,
        ),
      );
    }
    if (data.containsKey('mmproj_path')) {
      context.handle(
        _mmprojPathMeta,
        mmprojPath.isAcceptableOrUnknown(data['mmproj_path']!, _mmprojPathMeta),
      );
    }
    if (data.containsKey('mmproj_file_name')) {
      context.handle(
        _mmprojFileNameMeta,
        mmprojFileName.isAcceptableOrUnknown(
          data['mmproj_file_name']!,
          _mmprojFileNameMeta,
        ),
      );
    }
    if (data.containsKey('is_loaded')) {
      context.handle(
        _isLoadedMeta,
        isLoaded.isAcceptableOrUnknown(data['is_loaded']!, _isLoadedMeta),
      );
    }
    if (data.containsKey('download_status')) {
      context.handle(
        _downloadStatusMeta,
        downloadStatus.isAcceptableOrUnknown(
          data['download_status']!,
          _downloadStatusMeta,
        ),
      );
    }
    if (data.containsKey('thinking_mode')) {
      context.handle(
        _thinkingModeMeta,
        thinkingMode.isAcceptableOrUnknown(
          data['thinking_mode']!,
          _thinkingModeMeta,
        ),
      );
    }
    if (data.containsKey('thinking_budget')) {
      context.handle(
        _thinkingBudgetMeta,
        thinkingBudget.isAcceptableOrUnknown(
          data['thinking_budget']!,
          _thinkingBudgetMeta,
        ),
      );
    }
    if (data.containsKey('supports_thinking')) {
      context.handle(
        _supportsThinkingMeta,
        supportsThinking.isAcceptableOrUnknown(
          data['supports_thinking']!,
          _supportsThinkingMeta,
        ),
      );
    }
    if (data.containsKey('min_thinking_budget')) {
      context.handle(
        _minThinkingBudgetMeta,
        minThinkingBudget.isAcceptableOrUnknown(
          data['min_thinking_budget']!,
          _minThinkingBudgetMeta,
        ),
      );
    }
    if (data.containsKey('max_thinking_budget')) {
      context.handle(
        _maxThinkingBudgetMeta,
        maxThinkingBudget.isAcceptableOrUnknown(
          data['max_thinking_budget']!,
          _maxThinkingBudgetMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Model map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Model(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      ),
      apiConfig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_config'],
      ),
      capabilities: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capabilities'],
      ),
      defaultParams: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_params'],
      ),
      isMultimodal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_multimodal'],
      )!,
      mmprojPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mmproj_path'],
      ),
      mmprojFileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mmproj_file_name'],
      ),
      isLoaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_loaded'],
      )!,
      downloadStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_status'],
      )!,
      thinkingMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thinking_mode'],
      )!,
      thinkingBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}thinking_budget'],
      ),
      supportsThinking: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}supports_thinking'],
      )!,
      minThinkingBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_thinking_budget'],
      )!,
      maxThinkingBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_thinking_budget'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ModelsTable createAlias(String alias) {
    return $ModelsTable(attachedDatabase, alias);
  }
}

class Model extends DataClass implements Insertable<Model> {
  final String id;
  final String name;
  final String type;
  final String source;
  final String? path;
  final String? apiConfig;
  final String? capabilities;
  final String? defaultParams;
  final bool isMultimodal;
  final String? mmprojPath;
  final String? mmprojFileName;
  final bool isLoaded;
  final String downloadStatus;
  final String thinkingMode;
  final int? thinkingBudget;
  final bool supportsThinking;
  final int minThinkingBudget;
  final int maxThinkingBudget;
  final DateTime createdAt;
  const Model({
    required this.id,
    required this.name,
    required this.type,
    required this.source,
    this.path,
    this.apiConfig,
    this.capabilities,
    this.defaultParams,
    required this.isMultimodal,
    this.mmprojPath,
    this.mmprojFileName,
    required this.isLoaded,
    required this.downloadStatus,
    required this.thinkingMode,
    this.thinkingBudget,
    required this.supportsThinking,
    required this.minThinkingBudget,
    required this.maxThinkingBudget,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    if (!nullToAbsent || apiConfig != null) {
      map['api_config'] = Variable<String>(apiConfig);
    }
    if (!nullToAbsent || capabilities != null) {
      map['capabilities'] = Variable<String>(capabilities);
    }
    if (!nullToAbsent || defaultParams != null) {
      map['default_params'] = Variable<String>(defaultParams);
    }
    map['is_multimodal'] = Variable<bool>(isMultimodal);
    if (!nullToAbsent || mmprojPath != null) {
      map['mmproj_path'] = Variable<String>(mmprojPath);
    }
    if (!nullToAbsent || mmprojFileName != null) {
      map['mmproj_file_name'] = Variable<String>(mmprojFileName);
    }
    map['is_loaded'] = Variable<bool>(isLoaded);
    map['download_status'] = Variable<String>(downloadStatus);
    map['thinking_mode'] = Variable<String>(thinkingMode);
    if (!nullToAbsent || thinkingBudget != null) {
      map['thinking_budget'] = Variable<int>(thinkingBudget);
    }
    map['supports_thinking'] = Variable<bool>(supportsThinking);
    map['min_thinking_budget'] = Variable<int>(minThinkingBudget);
    map['max_thinking_budget'] = Variable<int>(maxThinkingBudget);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ModelsCompanion toCompanion(bool nullToAbsent) {
    return ModelsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      source: Value(source),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      apiConfig: apiConfig == null && nullToAbsent
          ? const Value.absent()
          : Value(apiConfig),
      capabilities: capabilities == null && nullToAbsent
          ? const Value.absent()
          : Value(capabilities),
      defaultParams: defaultParams == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultParams),
      isMultimodal: Value(isMultimodal),
      mmprojPath: mmprojPath == null && nullToAbsent
          ? const Value.absent()
          : Value(mmprojPath),
      mmprojFileName: mmprojFileName == null && nullToAbsent
          ? const Value.absent()
          : Value(mmprojFileName),
      isLoaded: Value(isLoaded),
      downloadStatus: Value(downloadStatus),
      thinkingMode: Value(thinkingMode),
      thinkingBudget: thinkingBudget == null && nullToAbsent
          ? const Value.absent()
          : Value(thinkingBudget),
      supportsThinking: Value(supportsThinking),
      minThinkingBudget: Value(minThinkingBudget),
      maxThinkingBudget: Value(maxThinkingBudget),
      createdAt: Value(createdAt),
    );
  }

  factory Model.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Model(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      source: serializer.fromJson<String>(json['source']),
      path: serializer.fromJson<String?>(json['path']),
      apiConfig: serializer.fromJson<String?>(json['apiConfig']),
      capabilities: serializer.fromJson<String?>(json['capabilities']),
      defaultParams: serializer.fromJson<String?>(json['defaultParams']),
      isMultimodal: serializer.fromJson<bool>(json['isMultimodal']),
      mmprojPath: serializer.fromJson<String?>(json['mmprojPath']),
      mmprojFileName: serializer.fromJson<String?>(json['mmprojFileName']),
      isLoaded: serializer.fromJson<bool>(json['isLoaded']),
      downloadStatus: serializer.fromJson<String>(json['downloadStatus']),
      thinkingMode: serializer.fromJson<String>(json['thinkingMode']),
      thinkingBudget: serializer.fromJson<int?>(json['thinkingBudget']),
      supportsThinking: serializer.fromJson<bool>(json['supportsThinking']),
      minThinkingBudget: serializer.fromJson<int>(json['minThinkingBudget']),
      maxThinkingBudget: serializer.fromJson<int>(json['maxThinkingBudget']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'source': serializer.toJson<String>(source),
      'path': serializer.toJson<String?>(path),
      'apiConfig': serializer.toJson<String?>(apiConfig),
      'capabilities': serializer.toJson<String?>(capabilities),
      'defaultParams': serializer.toJson<String?>(defaultParams),
      'isMultimodal': serializer.toJson<bool>(isMultimodal),
      'mmprojPath': serializer.toJson<String?>(mmprojPath),
      'mmprojFileName': serializer.toJson<String?>(mmprojFileName),
      'isLoaded': serializer.toJson<bool>(isLoaded),
      'downloadStatus': serializer.toJson<String>(downloadStatus),
      'thinkingMode': serializer.toJson<String>(thinkingMode),
      'thinkingBudget': serializer.toJson<int?>(thinkingBudget),
      'supportsThinking': serializer.toJson<bool>(supportsThinking),
      'minThinkingBudget': serializer.toJson<int>(minThinkingBudget),
      'maxThinkingBudget': serializer.toJson<int>(maxThinkingBudget),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Model copyWith({
    String? id,
    String? name,
    String? type,
    String? source,
    Value<String?> path = const Value.absent(),
    Value<String?> apiConfig = const Value.absent(),
    Value<String?> capabilities = const Value.absent(),
    Value<String?> defaultParams = const Value.absent(),
    bool? isMultimodal,
    Value<String?> mmprojPath = const Value.absent(),
    Value<String?> mmprojFileName = const Value.absent(),
    bool? isLoaded,
    String? downloadStatus,
    String? thinkingMode,
    Value<int?> thinkingBudget = const Value.absent(),
    bool? supportsThinking,
    int? minThinkingBudget,
    int? maxThinkingBudget,
    DateTime? createdAt,
  }) => Model(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    source: source ?? this.source,
    path: path.present ? path.value : this.path,
    apiConfig: apiConfig.present ? apiConfig.value : this.apiConfig,
    capabilities: capabilities.present ? capabilities.value : this.capabilities,
    defaultParams: defaultParams.present
        ? defaultParams.value
        : this.defaultParams,
    isMultimodal: isMultimodal ?? this.isMultimodal,
    mmprojPath: mmprojPath.present ? mmprojPath.value : this.mmprojPath,
    mmprojFileName: mmprojFileName.present
        ? mmprojFileName.value
        : this.mmprojFileName,
    isLoaded: isLoaded ?? this.isLoaded,
    downloadStatus: downloadStatus ?? this.downloadStatus,
    thinkingMode: thinkingMode ?? this.thinkingMode,
    thinkingBudget: thinkingBudget.present
        ? thinkingBudget.value
        : this.thinkingBudget,
    supportsThinking: supportsThinking ?? this.supportsThinking,
    minThinkingBudget: minThinkingBudget ?? this.minThinkingBudget,
    maxThinkingBudget: maxThinkingBudget ?? this.maxThinkingBudget,
    createdAt: createdAt ?? this.createdAt,
  );
  Model copyWithCompanion(ModelsCompanion data) {
    return Model(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      source: data.source.present ? data.source.value : this.source,
      path: data.path.present ? data.path.value : this.path,
      apiConfig: data.apiConfig.present ? data.apiConfig.value : this.apiConfig,
      capabilities: data.capabilities.present
          ? data.capabilities.value
          : this.capabilities,
      defaultParams: data.defaultParams.present
          ? data.defaultParams.value
          : this.defaultParams,
      isMultimodal: data.isMultimodal.present
          ? data.isMultimodal.value
          : this.isMultimodal,
      mmprojPath: data.mmprojPath.present
          ? data.mmprojPath.value
          : this.mmprojPath,
      mmprojFileName: data.mmprojFileName.present
          ? data.mmprojFileName.value
          : this.mmprojFileName,
      isLoaded: data.isLoaded.present ? data.isLoaded.value : this.isLoaded,
      downloadStatus: data.downloadStatus.present
          ? data.downloadStatus.value
          : this.downloadStatus,
      thinkingMode: data.thinkingMode.present
          ? data.thinkingMode.value
          : this.thinkingMode,
      thinkingBudget: data.thinkingBudget.present
          ? data.thinkingBudget.value
          : this.thinkingBudget,
      supportsThinking: data.supportsThinking.present
          ? data.supportsThinking.value
          : this.supportsThinking,
      minThinkingBudget: data.minThinkingBudget.present
          ? data.minThinkingBudget.value
          : this.minThinkingBudget,
      maxThinkingBudget: data.maxThinkingBudget.present
          ? data.maxThinkingBudget.value
          : this.maxThinkingBudget,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Model(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('source: $source, ')
          ..write('path: $path, ')
          ..write('apiConfig: $apiConfig, ')
          ..write('capabilities: $capabilities, ')
          ..write('defaultParams: $defaultParams, ')
          ..write('isMultimodal: $isMultimodal, ')
          ..write('mmprojPath: $mmprojPath, ')
          ..write('mmprojFileName: $mmprojFileName, ')
          ..write('isLoaded: $isLoaded, ')
          ..write('downloadStatus: $downloadStatus, ')
          ..write('thinkingMode: $thinkingMode, ')
          ..write('thinkingBudget: $thinkingBudget, ')
          ..write('supportsThinking: $supportsThinking, ')
          ..write('minThinkingBudget: $minThinkingBudget, ')
          ..write('maxThinkingBudget: $maxThinkingBudget, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    source,
    path,
    apiConfig,
    capabilities,
    defaultParams,
    isMultimodal,
    mmprojPath,
    mmprojFileName,
    isLoaded,
    downloadStatus,
    thinkingMode,
    thinkingBudget,
    supportsThinking,
    minThinkingBudget,
    maxThinkingBudget,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Model &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.source == this.source &&
          other.path == this.path &&
          other.apiConfig == this.apiConfig &&
          other.capabilities == this.capabilities &&
          other.defaultParams == this.defaultParams &&
          other.isMultimodal == this.isMultimodal &&
          other.mmprojPath == this.mmprojPath &&
          other.mmprojFileName == this.mmprojFileName &&
          other.isLoaded == this.isLoaded &&
          other.downloadStatus == this.downloadStatus &&
          other.thinkingMode == this.thinkingMode &&
          other.thinkingBudget == this.thinkingBudget &&
          other.supportsThinking == this.supportsThinking &&
          other.minThinkingBudget == this.minThinkingBudget &&
          other.maxThinkingBudget == this.maxThinkingBudget &&
          other.createdAt == this.createdAt);
}

class ModelsCompanion extends UpdateCompanion<Model> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> source;
  final Value<String?> path;
  final Value<String?> apiConfig;
  final Value<String?> capabilities;
  final Value<String?> defaultParams;
  final Value<bool> isMultimodal;
  final Value<String?> mmprojPath;
  final Value<String?> mmprojFileName;
  final Value<bool> isLoaded;
  final Value<String> downloadStatus;
  final Value<String> thinkingMode;
  final Value<int?> thinkingBudget;
  final Value<bool> supportsThinking;
  final Value<int> minThinkingBudget;
  final Value<int> maxThinkingBudget;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ModelsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.source = const Value.absent(),
    this.path = const Value.absent(),
    this.apiConfig = const Value.absent(),
    this.capabilities = const Value.absent(),
    this.defaultParams = const Value.absent(),
    this.isMultimodal = const Value.absent(),
    this.mmprojPath = const Value.absent(),
    this.mmprojFileName = const Value.absent(),
    this.isLoaded = const Value.absent(),
    this.downloadStatus = const Value.absent(),
    this.thinkingMode = const Value.absent(),
    this.thinkingBudget = const Value.absent(),
    this.supportsThinking = const Value.absent(),
    this.minThinkingBudget = const Value.absent(),
    this.maxThinkingBudget = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModelsCompanion.insert({
    required String id,
    required String name,
    required String type,
    required String source,
    this.path = const Value.absent(),
    this.apiConfig = const Value.absent(),
    this.capabilities = const Value.absent(),
    this.defaultParams = const Value.absent(),
    this.isMultimodal = const Value.absent(),
    this.mmprojPath = const Value.absent(),
    this.mmprojFileName = const Value.absent(),
    this.isLoaded = const Value.absent(),
    this.downloadStatus = const Value.absent(),
    this.thinkingMode = const Value.absent(),
    this.thinkingBudget = const Value.absent(),
    this.supportsThinking = const Value.absent(),
    this.minThinkingBudget = const Value.absent(),
    this.maxThinkingBudget = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       source = Value(source),
       createdAt = Value(createdAt);
  static Insertable<Model> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? source,
    Expression<String>? path,
    Expression<String>? apiConfig,
    Expression<String>? capabilities,
    Expression<String>? defaultParams,
    Expression<bool>? isMultimodal,
    Expression<String>? mmprojPath,
    Expression<String>? mmprojFileName,
    Expression<bool>? isLoaded,
    Expression<String>? downloadStatus,
    Expression<String>? thinkingMode,
    Expression<int>? thinkingBudget,
    Expression<bool>? supportsThinking,
    Expression<int>? minThinkingBudget,
    Expression<int>? maxThinkingBudget,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (source != null) 'source': source,
      if (path != null) 'path': path,
      if (apiConfig != null) 'api_config': apiConfig,
      if (capabilities != null) 'capabilities': capabilities,
      if (defaultParams != null) 'default_params': defaultParams,
      if (isMultimodal != null) 'is_multimodal': isMultimodal,
      if (mmprojPath != null) 'mmproj_path': mmprojPath,
      if (mmprojFileName != null) 'mmproj_file_name': mmprojFileName,
      if (isLoaded != null) 'is_loaded': isLoaded,
      if (downloadStatus != null) 'download_status': downloadStatus,
      if (thinkingMode != null) 'thinking_mode': thinkingMode,
      if (thinkingBudget != null) 'thinking_budget': thinkingBudget,
      if (supportsThinking != null) 'supports_thinking': supportsThinking,
      if (minThinkingBudget != null) 'min_thinking_budget': minThinkingBudget,
      if (maxThinkingBudget != null) 'max_thinking_budget': maxThinkingBudget,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModelsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String>? source,
    Value<String?>? path,
    Value<String?>? apiConfig,
    Value<String?>? capabilities,
    Value<String?>? defaultParams,
    Value<bool>? isMultimodal,
    Value<String?>? mmprojPath,
    Value<String?>? mmprojFileName,
    Value<bool>? isLoaded,
    Value<String>? downloadStatus,
    Value<String>? thinkingMode,
    Value<int?>? thinkingBudget,
    Value<bool>? supportsThinking,
    Value<int>? minThinkingBudget,
    Value<int>? maxThinkingBudget,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ModelsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      source: source ?? this.source,
      path: path ?? this.path,
      apiConfig: apiConfig ?? this.apiConfig,
      capabilities: capabilities ?? this.capabilities,
      defaultParams: defaultParams ?? this.defaultParams,
      isMultimodal: isMultimodal ?? this.isMultimodal,
      mmprojPath: mmprojPath ?? this.mmprojPath,
      mmprojFileName: mmprojFileName ?? this.mmprojFileName,
      isLoaded: isLoaded ?? this.isLoaded,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      thinkingMode: thinkingMode ?? this.thinkingMode,
      thinkingBudget: thinkingBudget ?? this.thinkingBudget,
      supportsThinking: supportsThinking ?? this.supportsThinking,
      minThinkingBudget: minThinkingBudget ?? this.minThinkingBudget,
      maxThinkingBudget: maxThinkingBudget ?? this.maxThinkingBudget,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (apiConfig.present) {
      map['api_config'] = Variable<String>(apiConfig.value);
    }
    if (capabilities.present) {
      map['capabilities'] = Variable<String>(capabilities.value);
    }
    if (defaultParams.present) {
      map['default_params'] = Variable<String>(defaultParams.value);
    }
    if (isMultimodal.present) {
      map['is_multimodal'] = Variable<bool>(isMultimodal.value);
    }
    if (mmprojPath.present) {
      map['mmproj_path'] = Variable<String>(mmprojPath.value);
    }
    if (mmprojFileName.present) {
      map['mmproj_file_name'] = Variable<String>(mmprojFileName.value);
    }
    if (isLoaded.present) {
      map['is_loaded'] = Variable<bool>(isLoaded.value);
    }
    if (downloadStatus.present) {
      map['download_status'] = Variable<String>(downloadStatus.value);
    }
    if (thinkingMode.present) {
      map['thinking_mode'] = Variable<String>(thinkingMode.value);
    }
    if (thinkingBudget.present) {
      map['thinking_budget'] = Variable<int>(thinkingBudget.value);
    }
    if (supportsThinking.present) {
      map['supports_thinking'] = Variable<bool>(supportsThinking.value);
    }
    if (minThinkingBudget.present) {
      map['min_thinking_budget'] = Variable<int>(minThinkingBudget.value);
    }
    if (maxThinkingBudget.present) {
      map['max_thinking_budget'] = Variable<int>(maxThinkingBudget.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModelsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('source: $source, ')
          ..write('path: $path, ')
          ..write('apiConfig: $apiConfig, ')
          ..write('capabilities: $capabilities, ')
          ..write('defaultParams: $defaultParams, ')
          ..write('isMultimodal: $isMultimodal, ')
          ..write('mmprojPath: $mmprojPath, ')
          ..write('mmprojFileName: $mmprojFileName, ')
          ..write('isLoaded: $isLoaded, ')
          ..write('downloadStatus: $downloadStatus, ')
          ..write('thinkingMode: $thinkingMode, ')
          ..write('thinkingBudget: $thinkingBudget, ')
          ..write('supportsThinking: $supportsThinking, ')
          ..write('minThinkingBudget: $minThinkingBudget, ')
          ..write('maxThinkingBudget: $maxThinkingBudget, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoriesTable extends Memories with TableInfo<$MemoriesTable, Memory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTagsMeta = const VerificationMeta(
    'entityTags',
  );
  @override
  late final GeneratedColumn<String> entityTags = GeneratedColumn<String>(
    'entity_tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _isGlobalMeta = const VerificationMeta(
    'isGlobal',
  );
  @override
  late final GeneratedColumn<bool> isGlobal = GeneratedColumn<bool>(
    'is_global',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_global" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _embeddingMeta = const VerificationMeta(
    'embedding',
  );
  @override
  late final GeneratedColumn<String> embedding = GeneratedColumn<String>(
    'embedding',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>(
        'last_accessed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    type,
    content,
    entityTags,
    weight,
    isGlobal,
    isArchived,
    embedding,
    createdAt,
    updatedAt,
    lastAccessedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Memory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('entity_tags')) {
      context.handle(
        _entityTagsMeta,
        entityTags.isAcceptableOrUnknown(data['entity_tags']!, _entityTagsMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('is_global')) {
      context.handle(
        _isGlobalMeta,
        isGlobal.isAcceptableOrUnknown(data['is_global']!, _isGlobalMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('embedding')) {
      context.handle(
        _embeddingMeta,
        embedding.isAcceptableOrUnknown(data['embedding']!, _embeddingMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Memory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Memory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      entityTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_tags'],
      ),
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      isGlobal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_global'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      embedding: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embedding'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_accessed_at'],
      ),
    );
  }

  @override
  $MemoriesTable createAlias(String alias) {
    return $MemoriesTable(attachedDatabase, alias);
  }
}

class Memory extends DataClass implements Insertable<Memory> {
  final String id;
  final String? sessionId;
  final String type;
  final String content;
  final String? entityTags;
  final double weight;
  final bool isGlobal;
  final bool isArchived;
  final String? embedding;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastAccessedAt;
  const Memory({
    required this.id,
    this.sessionId,
    required this.type,
    required this.content,
    this.entityTags,
    required this.weight,
    required this.isGlobal,
    required this.isArchived,
    this.embedding,
    required this.createdAt,
    required this.updatedAt,
    this.lastAccessedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['type'] = Variable<String>(type);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || entityTags != null) {
      map['entity_tags'] = Variable<String>(entityTags);
    }
    map['weight'] = Variable<double>(weight);
    map['is_global'] = Variable<bool>(isGlobal);
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || embedding != null) {
      map['embedding'] = Variable<String>(embedding);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastAccessedAt != null) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    }
    return map;
  }

  MemoriesCompanion toCompanion(bool nullToAbsent) {
    return MemoriesCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      type: Value(type),
      content: Value(content),
      entityTags: entityTags == null && nullToAbsent
          ? const Value.absent()
          : Value(entityTags),
      weight: Value(weight),
      isGlobal: Value(isGlobal),
      isArchived: Value(isArchived),
      embedding: embedding == null && nullToAbsent
          ? const Value.absent()
          : Value(embedding),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastAccessedAt: lastAccessedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccessedAt),
    );
  }

  factory Memory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Memory(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      type: serializer.fromJson<String>(json['type']),
      content: serializer.fromJson<String>(json['content']),
      entityTags: serializer.fromJson<String?>(json['entityTags']),
      weight: serializer.fromJson<double>(json['weight']),
      isGlobal: serializer.fromJson<bool>(json['isGlobal']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      embedding: serializer.fromJson<String?>(json['embedding']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastAccessedAt: serializer.fromJson<DateTime?>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String?>(sessionId),
      'type': serializer.toJson<String>(type),
      'content': serializer.toJson<String>(content),
      'entityTags': serializer.toJson<String?>(entityTags),
      'weight': serializer.toJson<double>(weight),
      'isGlobal': serializer.toJson<bool>(isGlobal),
      'isArchived': serializer.toJson<bool>(isArchived),
      'embedding': serializer.toJson<String?>(embedding),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastAccessedAt': serializer.toJson<DateTime?>(lastAccessedAt),
    };
  }

  Memory copyWith({
    String? id,
    Value<String?> sessionId = const Value.absent(),
    String? type,
    String? content,
    Value<String?> entityTags = const Value.absent(),
    double? weight,
    bool? isGlobal,
    bool? isArchived,
    Value<String?> embedding = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastAccessedAt = const Value.absent(),
  }) => Memory(
    id: id ?? this.id,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    type: type ?? this.type,
    content: content ?? this.content,
    entityTags: entityTags.present ? entityTags.value : this.entityTags,
    weight: weight ?? this.weight,
    isGlobal: isGlobal ?? this.isGlobal,
    isArchived: isArchived ?? this.isArchived,
    embedding: embedding.present ? embedding.value : this.embedding,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastAccessedAt: lastAccessedAt.present
        ? lastAccessedAt.value
        : this.lastAccessedAt,
  );
  Memory copyWithCompanion(MemoriesCompanion data) {
    return Memory(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      type: data.type.present ? data.type.value : this.type,
      content: data.content.present ? data.content.value : this.content,
      entityTags: data.entityTags.present
          ? data.entityTags.value
          : this.entityTags,
      weight: data.weight.present ? data.weight.value : this.weight,
      isGlobal: data.isGlobal.present ? data.isGlobal.value : this.isGlobal,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      embedding: data.embedding.present ? data.embedding.value : this.embedding,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Memory(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('entityTags: $entityTags, ')
          ..write('weight: $weight, ')
          ..write('isGlobal: $isGlobal, ')
          ..write('isArchived: $isArchived, ')
          ..write('embedding: $embedding, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    type,
    content,
    entityTags,
    weight,
    isGlobal,
    isArchived,
    embedding,
    createdAt,
    updatedAt,
    lastAccessedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Memory &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.type == this.type &&
          other.content == this.content &&
          other.entityTags == this.entityTags &&
          other.weight == this.weight &&
          other.isGlobal == this.isGlobal &&
          other.isArchived == this.isArchived &&
          other.embedding == this.embedding &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class MemoriesCompanion extends UpdateCompanion<Memory> {
  final Value<String> id;
  final Value<String?> sessionId;
  final Value<String> type;
  final Value<String> content;
  final Value<String?> entityTags;
  final Value<double> weight;
  final Value<bool> isGlobal;
  final Value<bool> isArchived;
  final Value<String?> embedding;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastAccessedAt;
  final Value<int> rowid;
  const MemoriesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.entityTags = const Value.absent(),
    this.weight = const Value.absent(),
    this.isGlobal = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.embedding = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoriesCompanion.insert({
    required String id,
    this.sessionId = const Value.absent(),
    required String type,
    required String content,
    this.entityTags = const Value.absent(),
    this.weight = const Value.absent(),
    this.isGlobal = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.embedding = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       content = Value(content),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Memory> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? type,
    Expression<String>? content,
    Expression<String>? entityTags,
    Expression<double>? weight,
    Expression<bool>? isGlobal,
    Expression<bool>? isArchived,
    Expression<String>? embedding,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastAccessedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (entityTags != null) 'entity_tags': entityTags,
      if (weight != null) 'weight': weight,
      if (isGlobal != null) 'is_global': isGlobal,
      if (isArchived != null) 'is_archived': isArchived,
      if (embedding != null) 'embedding': embedding,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoriesCompanion copyWith({
    Value<String>? id,
    Value<String?>? sessionId,
    Value<String>? type,
    Value<String>? content,
    Value<String?>? entityTags,
    Value<double>? weight,
    Value<bool>? isGlobal,
    Value<bool>? isArchived,
    Value<String?>? embedding,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastAccessedAt,
    Value<int>? rowid,
  }) {
    return MemoriesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      content: content ?? this.content,
      entityTags: entityTags ?? this.entityTags,
      weight: weight ?? this.weight,
      isGlobal: isGlobal ?? this.isGlobal,
      isArchived: isArchived ?? this.isArchived,
      embedding: embedding ?? this.embedding,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (entityTags.present) {
      map['entity_tags'] = Variable<String>(entityTags.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (isGlobal.present) {
      map['is_global'] = Variable<bool>(isGlobal.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (embedding.present) {
      map['embedding'] = Variable<String>(embedding.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoriesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('entityTags: $entityTags, ')
          ..write('weight: $weight, ')
          ..write('isGlobal: $isGlobal, ')
          ..write('isArchived: $isArchived, ')
          ..write('embedding: $embedding, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KnowledgeBasesTable extends KnowledgeBases
    with TableInfo<$KnowledgeBasesTable, KnowledgeBase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KnowledgeBasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _documentCountMeta = const VerificationMeta(
    'documentCount',
  );
  @override
  late final GeneratedColumn<int> documentCount = GeneratedColumn<int>(
    'document_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isGlobalMeta = const VerificationMeta(
    'isGlobal',
  );
  @override
  late final GeneratedColumn<bool> isGlobal = GeneratedColumn<bool>(
    'is_global',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_global" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    documentCount,
    sessionId,
    isGlobal,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'knowledge_bases';
  @override
  VerificationContext validateIntegrity(
    Insertable<KnowledgeBase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('document_count')) {
      context.handle(
        _documentCountMeta,
        documentCount.isAcceptableOrUnknown(
          data['document_count']!,
          _documentCountMeta,
        ),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('is_global')) {
      context.handle(
        _isGlobalMeta,
        isGlobal.isAcceptableOrUnknown(data['is_global']!, _isGlobalMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KnowledgeBase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KnowledgeBase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      documentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}document_count'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      isGlobal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_global'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $KnowledgeBasesTable createAlias(String alias) {
    return $KnowledgeBasesTable(attachedDatabase, alias);
  }
}

class KnowledgeBase extends DataClass implements Insertable<KnowledgeBase> {
  final String id;
  final String name;
  final String? description;
  final int documentCount;
  final String? sessionId;
  final bool isGlobal;
  final DateTime createdAt;
  final DateTime updatedAt;
  const KnowledgeBase({
    required this.id,
    required this.name,
    this.description,
    required this.documentCount,
    this.sessionId,
    required this.isGlobal,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['document_count'] = Variable<int>(documentCount);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['is_global'] = Variable<bool>(isGlobal);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  KnowledgeBasesCompanion toCompanion(bool nullToAbsent) {
    return KnowledgeBasesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      documentCount: Value(documentCount),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      isGlobal: Value(isGlobal),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory KnowledgeBase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KnowledgeBase(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      documentCount: serializer.fromJson<int>(json['documentCount']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      isGlobal: serializer.fromJson<bool>(json['isGlobal']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'documentCount': serializer.toJson<int>(documentCount),
      'sessionId': serializer.toJson<String?>(sessionId),
      'isGlobal': serializer.toJson<bool>(isGlobal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  KnowledgeBase copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    int? documentCount,
    Value<String?> sessionId = const Value.absent(),
    bool? isGlobal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => KnowledgeBase(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    documentCount: documentCount ?? this.documentCount,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    isGlobal: isGlobal ?? this.isGlobal,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  KnowledgeBase copyWithCompanion(KnowledgeBasesCompanion data) {
    return KnowledgeBase(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      documentCount: data.documentCount.present
          ? data.documentCount.value
          : this.documentCount,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      isGlobal: data.isGlobal.present ? data.isGlobal.value : this.isGlobal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KnowledgeBase(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('documentCount: $documentCount, ')
          ..write('sessionId: $sessionId, ')
          ..write('isGlobal: $isGlobal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    documentCount,
    sessionId,
    isGlobal,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KnowledgeBase &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.documentCount == this.documentCount &&
          other.sessionId == this.sessionId &&
          other.isGlobal == this.isGlobal &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class KnowledgeBasesCompanion extends UpdateCompanion<KnowledgeBase> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> documentCount;
  final Value<String?> sessionId;
  final Value<bool> isGlobal;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const KnowledgeBasesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.documentCount = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.isGlobal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KnowledgeBasesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.documentCount = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.isGlobal = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<KnowledgeBase> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? documentCount,
    Expression<String>? sessionId,
    Expression<bool>? isGlobal,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (documentCount != null) 'document_count': documentCount,
      if (sessionId != null) 'session_id': sessionId,
      if (isGlobal != null) 'is_global': isGlobal,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KnowledgeBasesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? documentCount,
    Value<String?>? sessionId,
    Value<bool>? isGlobal,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return KnowledgeBasesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      documentCount: documentCount ?? this.documentCount,
      sessionId: sessionId ?? this.sessionId,
      isGlobal: isGlobal ?? this.isGlobal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (documentCount.present) {
      map['document_count'] = Variable<int>(documentCount.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (isGlobal.present) {
      map['is_global'] = Variable<bool>(isGlobal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KnowledgeBasesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('documentCount: $documentCount, ')
          ..write('sessionId: $sessionId, ')
          ..write('isGlobal: $isGlobal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, Document> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _knowledgeBaseIdMeta = const VerificationMeta(
    'knowledgeBaseId',
  );
  @override
  late final GeneratedColumn<String> knowledgeBaseId = GeneratedColumn<String>(
    'knowledge_base_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileTypeMeta = const VerificationMeta(
    'fileType',
  );
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
    'file_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chunkCountMeta = const VerificationMeta(
    'chunkCount',
  );
  @override
  late final GeneratedColumn<int> chunkCount = GeneratedColumn<int>(
    'chunk_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    knowledgeBaseId,
    fileName,
    filePath,
    fileType,
    fileSize,
    chunkCount,
    status,
    errorMessage,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<Document> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('knowledge_base_id')) {
      context.handle(
        _knowledgeBaseIdMeta,
        knowledgeBaseId.isAcceptableOrUnknown(
          data['knowledge_base_id']!,
          _knowledgeBaseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_knowledgeBaseIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_type')) {
      context.handle(
        _fileTypeMeta,
        fileType.isAcceptableOrUnknown(data['file_type']!, _fileTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileTypeMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('chunk_count')) {
      context.handle(
        _chunkCountMeta,
        chunkCount.isAcceptableOrUnknown(data['chunk_count']!, _chunkCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Document map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Document(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      knowledgeBaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}knowledge_base_id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      fileType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_type'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      chunkCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }
}

class Document extends DataClass implements Insertable<Document> {
  final String id;
  final String knowledgeBaseId;
  final String fileName;
  final String filePath;
  final String fileType;
  final int fileSize;
  final int chunkCount;
  final String status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Document({
    required this.id,
    required this.knowledgeBaseId,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.chunkCount,
    required this.status,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['knowledge_base_id'] = Variable<String>(knowledgeBaseId);
    map['file_name'] = Variable<String>(fileName);
    map['file_path'] = Variable<String>(filePath);
    map['file_type'] = Variable<String>(fileType);
    map['file_size'] = Variable<int>(fileSize);
    map['chunk_count'] = Variable<int>(chunkCount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      knowledgeBaseId: Value(knowledgeBaseId),
      fileName: Value(fileName),
      filePath: Value(filePath),
      fileType: Value(fileType),
      fileSize: Value(fileSize),
      chunkCount: Value(chunkCount),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Document.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Document(
      id: serializer.fromJson<String>(json['id']),
      knowledgeBaseId: serializer.fromJson<String>(json['knowledgeBaseId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileType: serializer.fromJson<String>(json['fileType']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      chunkCount: serializer.fromJson<int>(json['chunkCount']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'knowledgeBaseId': serializer.toJson<String>(knowledgeBaseId),
      'fileName': serializer.toJson<String>(fileName),
      'filePath': serializer.toJson<String>(filePath),
      'fileType': serializer.toJson<String>(fileType),
      'fileSize': serializer.toJson<int>(fileSize),
      'chunkCount': serializer.toJson<int>(chunkCount),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Document copyWith({
    String? id,
    String? knowledgeBaseId,
    String? fileName,
    String? filePath,
    String? fileType,
    int? fileSize,
    int? chunkCount,
    String? status,
    Value<String?> errorMessage = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Document(
    id: id ?? this.id,
    knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
    fileName: fileName ?? this.fileName,
    filePath: filePath ?? this.filePath,
    fileType: fileType ?? this.fileType,
    fileSize: fileSize ?? this.fileSize,
    chunkCount: chunkCount ?? this.chunkCount,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Document copyWithCompanion(DocumentsCompanion data) {
    return Document(
      id: data.id.present ? data.id.value : this.id,
      knowledgeBaseId: data.knowledgeBaseId.present
          ? data.knowledgeBaseId.value
          : this.knowledgeBaseId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      chunkCount: data.chunkCount.present
          ? data.chunkCount.value
          : this.chunkCount,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Document(')
          ..write('id: $id, ')
          ..write('knowledgeBaseId: $knowledgeBaseId, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('fileType: $fileType, ')
          ..write('fileSize: $fileSize, ')
          ..write('chunkCount: $chunkCount, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    knowledgeBaseId,
    fileName,
    filePath,
    fileType,
    fileSize,
    chunkCount,
    status,
    errorMessage,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Document &&
          other.id == this.id &&
          other.knowledgeBaseId == this.knowledgeBaseId &&
          other.fileName == this.fileName &&
          other.filePath == this.filePath &&
          other.fileType == this.fileType &&
          other.fileSize == this.fileSize &&
          other.chunkCount == this.chunkCount &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DocumentsCompanion extends UpdateCompanion<Document> {
  final Value<String> id;
  final Value<String> knowledgeBaseId;
  final Value<String> fileName;
  final Value<String> filePath;
  final Value<String> fileType;
  final Value<int> fileSize;
  final Value<int> chunkCount;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.knowledgeBaseId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.chunkCount = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    required String knowledgeBaseId,
    required String fileName,
    required String filePath,
    required String fileType,
    required int fileSize,
    this.chunkCount = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       knowledgeBaseId = Value(knowledgeBaseId),
       fileName = Value(fileName),
       filePath = Value(filePath),
       fileType = Value(fileType),
       fileSize = Value(fileSize),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Document> custom({
    Expression<String>? id,
    Expression<String>? knowledgeBaseId,
    Expression<String>? fileName,
    Expression<String>? filePath,
    Expression<String>? fileType,
    Expression<int>? fileSize,
    Expression<int>? chunkCount,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (knowledgeBaseId != null) 'knowledge_base_id': knowledgeBaseId,
      if (fileName != null) 'file_name': fileName,
      if (filePath != null) 'file_path': filePath,
      if (fileType != null) 'file_type': fileType,
      if (fileSize != null) 'file_size': fileSize,
      if (chunkCount != null) 'chunk_count': chunkCount,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith({
    Value<String>? id,
    Value<String>? knowledgeBaseId,
    Value<String>? fileName,
    Value<String>? filePath,
    Value<String>? fileType,
    Value<int>? fileSize,
    Value<int>? chunkCount,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DocumentsCompanion(
      id: id ?? this.id,
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      chunkCount: chunkCount ?? this.chunkCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (knowledgeBaseId.present) {
      map['knowledge_base_id'] = Variable<String>(knowledgeBaseId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(fileType.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (chunkCount.present) {
      map['chunk_count'] = Variable<int>(chunkCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('knowledgeBaseId: $knowledgeBaseId, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('fileType: $fileType, ')
          ..write('fileSize: $fileSize, ')
          ..write('chunkCount: $chunkCount, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentChunksTable extends DocumentChunks
    with TableInfo<$DocumentChunksTable, DocumentChunk> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentChunksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _knowledgeBaseIdMeta = const VerificationMeta(
    'knowledgeBaseId',
  );
  @override
  late final GeneratedColumn<String> knowledgeBaseId = GeneratedColumn<String>(
    'knowledge_base_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chunkIndexMeta = const VerificationMeta(
    'chunkIndex',
  );
  @override
  late final GeneratedColumn<int> chunkIndex = GeneratedColumn<int>(
    'chunk_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorMeta = const VerificationMeta('vector');
  @override
  late final GeneratedColumn<String> vector = GeneratedColumn<String>(
    'vector',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    knowledgeBaseId,
    documentId,
    content,
    chunkIndex,
    vector,
    metadata,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_chunks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentChunk> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('knowledge_base_id')) {
      context.handle(
        _knowledgeBaseIdMeta,
        knowledgeBaseId.isAcceptableOrUnknown(
          data['knowledge_base_id']!,
          _knowledgeBaseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_knowledgeBaseIdMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('chunk_index')) {
      context.handle(
        _chunkIndexMeta,
        chunkIndex.isAcceptableOrUnknown(data['chunk_index']!, _chunkIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_chunkIndexMeta);
    }
    if (data.containsKey('vector')) {
      context.handle(
        _vectorMeta,
        vector.isAcceptableOrUnknown(data['vector']!, _vectorMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentChunk map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentChunk(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      knowledgeBaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}knowledge_base_id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      chunkIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_index'],
      )!,
      vector: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vector'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DocumentChunksTable createAlias(String alias) {
    return $DocumentChunksTable(attachedDatabase, alias);
  }
}

class DocumentChunk extends DataClass implements Insertable<DocumentChunk> {
  final String id;
  final String knowledgeBaseId;
  final String documentId;
  final String content;
  final int chunkIndex;
  final String? vector;
  final String? metadata;
  final DateTime createdAt;
  const DocumentChunk({
    required this.id,
    required this.knowledgeBaseId,
    required this.documentId,
    required this.content,
    required this.chunkIndex,
    this.vector,
    this.metadata,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['knowledge_base_id'] = Variable<String>(knowledgeBaseId);
    map['document_id'] = Variable<String>(documentId);
    map['content'] = Variable<String>(content);
    map['chunk_index'] = Variable<int>(chunkIndex);
    if (!nullToAbsent || vector != null) {
      map['vector'] = Variable<String>(vector);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DocumentChunksCompanion toCompanion(bool nullToAbsent) {
    return DocumentChunksCompanion(
      id: Value(id),
      knowledgeBaseId: Value(knowledgeBaseId),
      documentId: Value(documentId),
      content: Value(content),
      chunkIndex: Value(chunkIndex),
      vector: vector == null && nullToAbsent
          ? const Value.absent()
          : Value(vector),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      createdAt: Value(createdAt),
    );
  }

  factory DocumentChunk.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentChunk(
      id: serializer.fromJson<String>(json['id']),
      knowledgeBaseId: serializer.fromJson<String>(json['knowledgeBaseId']),
      documentId: serializer.fromJson<String>(json['documentId']),
      content: serializer.fromJson<String>(json['content']),
      chunkIndex: serializer.fromJson<int>(json['chunkIndex']),
      vector: serializer.fromJson<String?>(json['vector']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'knowledgeBaseId': serializer.toJson<String>(knowledgeBaseId),
      'documentId': serializer.toJson<String>(documentId),
      'content': serializer.toJson<String>(content),
      'chunkIndex': serializer.toJson<int>(chunkIndex),
      'vector': serializer.toJson<String?>(vector),
      'metadata': serializer.toJson<String?>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DocumentChunk copyWith({
    String? id,
    String? knowledgeBaseId,
    String? documentId,
    String? content,
    int? chunkIndex,
    Value<String?> vector = const Value.absent(),
    Value<String?> metadata = const Value.absent(),
    DateTime? createdAt,
  }) => DocumentChunk(
    id: id ?? this.id,
    knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
    documentId: documentId ?? this.documentId,
    content: content ?? this.content,
    chunkIndex: chunkIndex ?? this.chunkIndex,
    vector: vector.present ? vector.value : this.vector,
    metadata: metadata.present ? metadata.value : this.metadata,
    createdAt: createdAt ?? this.createdAt,
  );
  DocumentChunk copyWithCompanion(DocumentChunksCompanion data) {
    return DocumentChunk(
      id: data.id.present ? data.id.value : this.id,
      knowledgeBaseId: data.knowledgeBaseId.present
          ? data.knowledgeBaseId.value
          : this.knowledgeBaseId,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      content: data.content.present ? data.content.value : this.content,
      chunkIndex: data.chunkIndex.present
          ? data.chunkIndex.value
          : this.chunkIndex,
      vector: data.vector.present ? data.vector.value : this.vector,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentChunk(')
          ..write('id: $id, ')
          ..write('knowledgeBaseId: $knowledgeBaseId, ')
          ..write('documentId: $documentId, ')
          ..write('content: $content, ')
          ..write('chunkIndex: $chunkIndex, ')
          ..write('vector: $vector, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    knowledgeBaseId,
    documentId,
    content,
    chunkIndex,
    vector,
    metadata,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentChunk &&
          other.id == this.id &&
          other.knowledgeBaseId == this.knowledgeBaseId &&
          other.documentId == this.documentId &&
          other.content == this.content &&
          other.chunkIndex == this.chunkIndex &&
          other.vector == this.vector &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt);
}

class DocumentChunksCompanion extends UpdateCompanion<DocumentChunk> {
  final Value<String> id;
  final Value<String> knowledgeBaseId;
  final Value<String> documentId;
  final Value<String> content;
  final Value<int> chunkIndex;
  final Value<String?> vector;
  final Value<String?> metadata;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DocumentChunksCompanion({
    this.id = const Value.absent(),
    this.knowledgeBaseId = const Value.absent(),
    this.documentId = const Value.absent(),
    this.content = const Value.absent(),
    this.chunkIndex = const Value.absent(),
    this.vector = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentChunksCompanion.insert({
    required String id,
    required String knowledgeBaseId,
    required String documentId,
    required String content,
    required int chunkIndex,
    this.vector = const Value.absent(),
    this.metadata = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       knowledgeBaseId = Value(knowledgeBaseId),
       documentId = Value(documentId),
       content = Value(content),
       chunkIndex = Value(chunkIndex),
       createdAt = Value(createdAt);
  static Insertable<DocumentChunk> custom({
    Expression<String>? id,
    Expression<String>? knowledgeBaseId,
    Expression<String>? documentId,
    Expression<String>? content,
    Expression<int>? chunkIndex,
    Expression<String>? vector,
    Expression<String>? metadata,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (knowledgeBaseId != null) 'knowledge_base_id': knowledgeBaseId,
      if (documentId != null) 'document_id': documentId,
      if (content != null) 'content': content,
      if (chunkIndex != null) 'chunk_index': chunkIndex,
      if (vector != null) 'vector': vector,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentChunksCompanion copyWith({
    Value<String>? id,
    Value<String>? knowledgeBaseId,
    Value<String>? documentId,
    Value<String>? content,
    Value<int>? chunkIndex,
    Value<String?>? vector,
    Value<String?>? metadata,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DocumentChunksCompanion(
      id: id ?? this.id,
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      documentId: documentId ?? this.documentId,
      content: content ?? this.content,
      chunkIndex: chunkIndex ?? this.chunkIndex,
      vector: vector ?? this.vector,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (knowledgeBaseId.present) {
      map['knowledge_base_id'] = Variable<String>(knowledgeBaseId.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (chunkIndex.present) {
      map['chunk_index'] = Variable<int>(chunkIndex.value);
    }
    if (vector.present) {
      map['vector'] = Variable<String>(vector.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentChunksCompanion(')
          ..write('id: $id, ')
          ..write('knowledgeBaseId: $knowledgeBaseId, ')
          ..write('documentId: $documentId, ')
          ..write('content: $content, ')
          ..write('chunkIndex: $chunkIndex, ')
          ..write('vector: $vector, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PromptTemplatesTable extends PromptTemplates
    with TableInfo<$PromptTemplatesTable, PromptTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromptTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variablesMeta = const VerificationMeta(
    'variables',
  );
  @override
  late final GeneratedColumn<String> variables = GeneratedColumn<String>(
    'variables',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('general'),
  );
  static const VerificationMeta _isGlobalMeta = const VerificationMeta(
    'isGlobal',
  );
  @override
  late final GeneratedColumn<bool> isGlobal = GeneratedColumn<bool>(
    'is_global',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_global" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isBuiltinMeta = const VerificationMeta(
    'isBuiltin',
  );
  @override
  late final GeneratedColumn<bool> isBuiltin = GeneratedColumn<bool>(
    'is_builtin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_builtin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    content,
    variables,
    category,
    isGlobal,
    isBuiltin,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prompt_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<PromptTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('variables')) {
      context.handle(
        _variablesMeta,
        variables.isAcceptableOrUnknown(data['variables']!, _variablesMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('is_global')) {
      context.handle(
        _isGlobalMeta,
        isGlobal.isAcceptableOrUnknown(data['is_global']!, _isGlobalMeta),
      );
    }
    if (data.containsKey('is_builtin')) {
      context.handle(
        _isBuiltinMeta,
        isBuiltin.isAcceptableOrUnknown(data['is_builtin']!, _isBuiltinMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PromptTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PromptTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      variables: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variables'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      isGlobal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_global'],
      )!,
      isBuiltin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_builtin'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PromptTemplatesTable createAlias(String alias) {
    return $PromptTemplatesTable(attachedDatabase, alias);
  }
}

class PromptTemplate extends DataClass implements Insertable<PromptTemplate> {
  final String id;
  final String name;
  final String content;
  final String? variables;
  final String category;
  final bool isGlobal;
  final bool isBuiltin;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PromptTemplate({
    required this.id,
    required this.name,
    required this.content,
    this.variables,
    required this.category,
    required this.isGlobal,
    required this.isBuiltin,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || variables != null) {
      map['variables'] = Variable<String>(variables);
    }
    map['category'] = Variable<String>(category);
    map['is_global'] = Variable<bool>(isGlobal);
    map['is_builtin'] = Variable<bool>(isBuiltin);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PromptTemplatesCompanion toCompanion(bool nullToAbsent) {
    return PromptTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      content: Value(content),
      variables: variables == null && nullToAbsent
          ? const Value.absent()
          : Value(variables),
      category: Value(category),
      isGlobal: Value(isGlobal),
      isBuiltin: Value(isBuiltin),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PromptTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PromptTemplate(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      content: serializer.fromJson<String>(json['content']),
      variables: serializer.fromJson<String?>(json['variables']),
      category: serializer.fromJson<String>(json['category']),
      isGlobal: serializer.fromJson<bool>(json['isGlobal']),
      isBuiltin: serializer.fromJson<bool>(json['isBuiltin']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'content': serializer.toJson<String>(content),
      'variables': serializer.toJson<String?>(variables),
      'category': serializer.toJson<String>(category),
      'isGlobal': serializer.toJson<bool>(isGlobal),
      'isBuiltin': serializer.toJson<bool>(isBuiltin),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PromptTemplate copyWith({
    String? id,
    String? name,
    String? content,
    Value<String?> variables = const Value.absent(),
    String? category,
    bool? isGlobal,
    bool? isBuiltin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PromptTemplate(
    id: id ?? this.id,
    name: name ?? this.name,
    content: content ?? this.content,
    variables: variables.present ? variables.value : this.variables,
    category: category ?? this.category,
    isGlobal: isGlobal ?? this.isGlobal,
    isBuiltin: isBuiltin ?? this.isBuiltin,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PromptTemplate copyWithCompanion(PromptTemplatesCompanion data) {
    return PromptTemplate(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      content: data.content.present ? data.content.value : this.content,
      variables: data.variables.present ? data.variables.value : this.variables,
      category: data.category.present ? data.category.value : this.category,
      isGlobal: data.isGlobal.present ? data.isGlobal.value : this.isGlobal,
      isBuiltin: data.isBuiltin.present ? data.isBuiltin.value : this.isBuiltin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PromptTemplate(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('variables: $variables, ')
          ..write('category: $category, ')
          ..write('isGlobal: $isGlobal, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    content,
    variables,
    category,
    isGlobal,
    isBuiltin,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PromptTemplate &&
          other.id == this.id &&
          other.name == this.name &&
          other.content == this.content &&
          other.variables == this.variables &&
          other.category == this.category &&
          other.isGlobal == this.isGlobal &&
          other.isBuiltin == this.isBuiltin &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PromptTemplatesCompanion extends UpdateCompanion<PromptTemplate> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> content;
  final Value<String?> variables;
  final Value<String> category;
  final Value<bool> isGlobal;
  final Value<bool> isBuiltin;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PromptTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.content = const Value.absent(),
    this.variables = const Value.absent(),
    this.category = const Value.absent(),
    this.isGlobal = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromptTemplatesCompanion.insert({
    required String id,
    required String name,
    required String content,
    this.variables = const Value.absent(),
    this.category = const Value.absent(),
    this.isGlobal = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       content = Value(content),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PromptTemplate> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? content,
    Expression<String>? variables,
    Expression<String>? category,
    Expression<bool>? isGlobal,
    Expression<bool>? isBuiltin,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (content != null) 'content': content,
      if (variables != null) 'variables': variables,
      if (category != null) 'category': category,
      if (isGlobal != null) 'is_global': isGlobal,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromptTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? content,
    Value<String?>? variables,
    Value<String>? category,
    Value<bool>? isGlobal,
    Value<bool>? isBuiltin,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PromptTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
      variables: variables ?? this.variables,
      category: category ?? this.category,
      isGlobal: isGlobal ?? this.isGlobal,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (variables.present) {
      map['variables'] = Variable<String>(variables.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isGlobal.present) {
      map['is_global'] = Variable<bool>(isGlobal.value);
    }
    if (isBuiltin.present) {
      map['is_builtin'] = Variable<bool>(isBuiltin.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromptTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('variables: $variables, ')
          ..write('category: $category, ')
          ..write('isGlobal: $isGlobal, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionPromptsTable extends SessionPrompts
    with TableInfo<$SessionPromptsTable, SessionPrompt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionPromptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promptContentMeta = const VerificationMeta(
    'promptContent',
  );
  @override
  late final GeneratedColumn<String> promptContent = GeneratedColumn<String>(
    'prompt_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variablesMeta = const VerificationMeta(
    'variables',
  );
  @override
  late final GeneratedColumn<String> variables = GeneratedColumn<String>(
    'variables',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    templateId,
    promptContent,
    variables,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_prompts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionPrompt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('prompt_content')) {
      context.handle(
        _promptContentMeta,
        promptContent.isAcceptableOrUnknown(
          data['prompt_content']!,
          _promptContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_promptContentMeta);
    }
    if (data.containsKey('variables')) {
      context.handle(
        _variablesMeta,
        variables.isAcceptableOrUnknown(data['variables']!, _variablesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionPrompt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionPrompt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      ),
      promptContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_content'],
      )!,
      variables: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variables'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SessionPromptsTable createAlias(String alias) {
    return $SessionPromptsTable(attachedDatabase, alias);
  }
}

class SessionPrompt extends DataClass implements Insertable<SessionPrompt> {
  final String id;
  final String sessionId;
  final String? templateId;
  final String promptContent;
  final String? variables;
  final DateTime createdAt;
  const SessionPrompt({
    required this.id,
    required this.sessionId,
    this.templateId,
    required this.promptContent,
    this.variables,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<String>(templateId);
    }
    map['prompt_content'] = Variable<String>(promptContent);
    if (!nullToAbsent || variables != null) {
      map['variables'] = Variable<String>(variables);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SessionPromptsCompanion toCompanion(bool nullToAbsent) {
    return SessionPromptsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      promptContent: Value(promptContent),
      variables: variables == null && nullToAbsent
          ? const Value.absent()
          : Value(variables),
      createdAt: Value(createdAt),
    );
  }

  factory SessionPrompt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionPrompt(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      templateId: serializer.fromJson<String?>(json['templateId']),
      promptContent: serializer.fromJson<String>(json['promptContent']),
      variables: serializer.fromJson<String?>(json['variables']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'templateId': serializer.toJson<String?>(templateId),
      'promptContent': serializer.toJson<String>(promptContent),
      'variables': serializer.toJson<String?>(variables),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SessionPrompt copyWith({
    String? id,
    String? sessionId,
    Value<String?> templateId = const Value.absent(),
    String? promptContent,
    Value<String?> variables = const Value.absent(),
    DateTime? createdAt,
  }) => SessionPrompt(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    templateId: templateId.present ? templateId.value : this.templateId,
    promptContent: promptContent ?? this.promptContent,
    variables: variables.present ? variables.value : this.variables,
    createdAt: createdAt ?? this.createdAt,
  );
  SessionPrompt copyWithCompanion(SessionPromptsCompanion data) {
    return SessionPrompt(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      promptContent: data.promptContent.present
          ? data.promptContent.value
          : this.promptContent,
      variables: data.variables.present ? data.variables.value : this.variables,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionPrompt(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('templateId: $templateId, ')
          ..write('promptContent: $promptContent, ')
          ..write('variables: $variables, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    templateId,
    promptContent,
    variables,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionPrompt &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.templateId == this.templateId &&
          other.promptContent == this.promptContent &&
          other.variables == this.variables &&
          other.createdAt == this.createdAt);
}

class SessionPromptsCompanion extends UpdateCompanion<SessionPrompt> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String?> templateId;
  final Value<String> promptContent;
  final Value<String?> variables;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SessionPromptsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.templateId = const Value.absent(),
    this.promptContent = const Value.absent(),
    this.variables = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionPromptsCompanion.insert({
    required String id,
    required String sessionId,
    this.templateId = const Value.absent(),
    required String promptContent,
    this.variables = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       promptContent = Value(promptContent),
       createdAt = Value(createdAt);
  static Insertable<SessionPrompt> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? templateId,
    Expression<String>? promptContent,
    Expression<String>? variables,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (templateId != null) 'template_id': templateId,
      if (promptContent != null) 'prompt_content': promptContent,
      if (variables != null) 'variables': variables,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionPromptsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String?>? templateId,
    Value<String>? promptContent,
    Value<String?>? variables,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SessionPromptsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      templateId: templateId ?? this.templateId,
      promptContent: promptContent ?? this.promptContent,
      variables: variables ?? this.variables,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (promptContent.present) {
      map['prompt_content'] = Variable<String>(promptContent.value);
    }
    if (variables.present) {
      map['variables'] = Variable<String>(variables.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionPromptsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('templateId: $templateId, ')
          ..write('promptContent: $promptContent, ')
          ..write('variables: $variables, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadTasksTable extends DownloadTasks
    with TableInfo<$DownloadTasksTable, DownloadTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savePathMeta = const VerificationMeta(
    'savePath',
  );
  @override
  late final GeneratedColumn<String> savePath = GeneratedColumn<String>(
    'save_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _downloadedBytesMeta = const VerificationMeta(
    'downloadedBytes',
  );
  @override
  late final GeneratedColumn<int> downloadedBytes = GeneratedColumn<int>(
    'downloaded_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantLevelMeta = const VerificationMeta(
    'quantLevel',
  );
  @override
  late final GeneratedColumn<String> quantLevel = GeneratedColumn<String>(
    'quant_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modelId,
    url,
    savePath,
    status,
    progress,
    totalBytes,
    downloadedBytes,
    source,
    quantLevel,
    metadata,
    error,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('save_path')) {
      context.handle(
        _savePathMeta,
        savePath.isAcceptableOrUnknown(data['save_path']!, _savePathMeta),
      );
    } else if (isInserting) {
      context.missing(_savePathMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('downloaded_bytes')) {
      context.handle(
        _downloadedBytesMeta,
        downloadedBytes.isAcceptableOrUnknown(
          data['downloaded_bytes']!,
          _downloadedBytesMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('quant_level')) {
      context.handle(
        _quantLevelMeta,
        quantLevel.isAcceptableOrUnknown(data['quant_level']!, _quantLevelMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      savePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_path'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      )!,
      downloadedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_bytes'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      quantLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quant_level'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $DownloadTasksTable createAlias(String alias) {
    return $DownloadTasksTable(attachedDatabase, alias);
  }
}

class DownloadTask extends DataClass implements Insertable<DownloadTask> {
  final String id;
  final String modelId;
  final String url;
  final String savePath;
  final String status;
  final int progress;
  final int totalBytes;
  final int downloadedBytes;
  final String source;
  final String? quantLevel;
  final String? metadata;
  final String? error;
  final DateTime createdAt;
  final DateTime? completedAt;
  const DownloadTask({
    required this.id,
    required this.modelId,
    required this.url,
    required this.savePath,
    required this.status,
    required this.progress,
    required this.totalBytes,
    required this.downloadedBytes,
    required this.source,
    this.quantLevel,
    this.metadata,
    this.error,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['model_id'] = Variable<String>(modelId);
    map['url'] = Variable<String>(url);
    map['save_path'] = Variable<String>(savePath);
    map['status'] = Variable<String>(status);
    map['progress'] = Variable<int>(progress);
    map['total_bytes'] = Variable<int>(totalBytes);
    map['downloaded_bytes'] = Variable<int>(downloadedBytes);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || quantLevel != null) {
      map['quant_level'] = Variable<String>(quantLevel);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  DownloadTasksCompanion toCompanion(bool nullToAbsent) {
    return DownloadTasksCompanion(
      id: Value(id),
      modelId: Value(modelId),
      url: Value(url),
      savePath: Value(savePath),
      status: Value(status),
      progress: Value(progress),
      totalBytes: Value(totalBytes),
      downloadedBytes: Value(downloadedBytes),
      source: Value(source),
      quantLevel: quantLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(quantLevel),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory DownloadTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadTask(
      id: serializer.fromJson<String>(json['id']),
      modelId: serializer.fromJson<String>(json['modelId']),
      url: serializer.fromJson<String>(json['url']),
      savePath: serializer.fromJson<String>(json['savePath']),
      status: serializer.fromJson<String>(json['status']),
      progress: serializer.fromJson<int>(json['progress']),
      totalBytes: serializer.fromJson<int>(json['totalBytes']),
      downloadedBytes: serializer.fromJson<int>(json['downloadedBytes']),
      source: serializer.fromJson<String>(json['source']),
      quantLevel: serializer.fromJson<String?>(json['quantLevel']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      error: serializer.fromJson<String?>(json['error']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'modelId': serializer.toJson<String>(modelId),
      'url': serializer.toJson<String>(url),
      'savePath': serializer.toJson<String>(savePath),
      'status': serializer.toJson<String>(status),
      'progress': serializer.toJson<int>(progress),
      'totalBytes': serializer.toJson<int>(totalBytes),
      'downloadedBytes': serializer.toJson<int>(downloadedBytes),
      'source': serializer.toJson<String>(source),
      'quantLevel': serializer.toJson<String?>(quantLevel),
      'metadata': serializer.toJson<String?>(metadata),
      'error': serializer.toJson<String?>(error),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  DownloadTask copyWith({
    String? id,
    String? modelId,
    String? url,
    String? savePath,
    String? status,
    int? progress,
    int? totalBytes,
    int? downloadedBytes,
    String? source,
    Value<String?> quantLevel = const Value.absent(),
    Value<String?> metadata = const Value.absent(),
    Value<String?> error = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => DownloadTask(
    id: id ?? this.id,
    modelId: modelId ?? this.modelId,
    url: url ?? this.url,
    savePath: savePath ?? this.savePath,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    totalBytes: totalBytes ?? this.totalBytes,
    downloadedBytes: downloadedBytes ?? this.downloadedBytes,
    source: source ?? this.source,
    quantLevel: quantLevel.present ? quantLevel.value : this.quantLevel,
    metadata: metadata.present ? metadata.value : this.metadata,
    error: error.present ? error.value : this.error,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  DownloadTask copyWithCompanion(DownloadTasksCompanion data) {
    return DownloadTask(
      id: data.id.present ? data.id.value : this.id,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      url: data.url.present ? data.url.value : this.url,
      savePath: data.savePath.present ? data.savePath.value : this.savePath,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      downloadedBytes: data.downloadedBytes.present
          ? data.downloadedBytes.value
          : this.downloadedBytes,
      source: data.source.present ? data.source.value : this.source,
      quantLevel: data.quantLevel.present
          ? data.quantLevel.value
          : this.quantLevel,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      error: data.error.present ? data.error.value : this.error,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTask(')
          ..write('id: $id, ')
          ..write('modelId: $modelId, ')
          ..write('url: $url, ')
          ..write('savePath: $savePath, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('source: $source, ')
          ..write('quantLevel: $quantLevel, ')
          ..write('metadata: $metadata, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modelId,
    url,
    savePath,
    status,
    progress,
    totalBytes,
    downloadedBytes,
    source,
    quantLevel,
    metadata,
    error,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTask &&
          other.id == this.id &&
          other.modelId == this.modelId &&
          other.url == this.url &&
          other.savePath == this.savePath &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.totalBytes == this.totalBytes &&
          other.downloadedBytes == this.downloadedBytes &&
          other.source == this.source &&
          other.quantLevel == this.quantLevel &&
          other.metadata == this.metadata &&
          other.error == this.error &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class DownloadTasksCompanion extends UpdateCompanion<DownloadTask> {
  final Value<String> id;
  final Value<String> modelId;
  final Value<String> url;
  final Value<String> savePath;
  final Value<String> status;
  final Value<int> progress;
  final Value<int> totalBytes;
  final Value<int> downloadedBytes;
  final Value<String> source;
  final Value<String?> quantLevel;
  final Value<String?> metadata;
  final Value<String?> error;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const DownloadTasksCompanion({
    this.id = const Value.absent(),
    this.modelId = const Value.absent(),
    this.url = const Value.absent(),
    this.savePath = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.source = const Value.absent(),
    this.quantLevel = const Value.absent(),
    this.metadata = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadTasksCompanion.insert({
    required String id,
    required String modelId,
    required String url,
    required String savePath,
    required String status,
    this.progress = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    required String source,
    this.quantLevel = const Value.absent(),
    this.metadata = const Value.absent(),
    this.error = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       modelId = Value(modelId),
       url = Value(url),
       savePath = Value(savePath),
       status = Value(status),
       source = Value(source),
       createdAt = Value(createdAt);
  static Insertable<DownloadTask> custom({
    Expression<String>? id,
    Expression<String>? modelId,
    Expression<String>? url,
    Expression<String>? savePath,
    Expression<String>? status,
    Expression<int>? progress,
    Expression<int>? totalBytes,
    Expression<int>? downloadedBytes,
    Expression<String>? source,
    Expression<String>? quantLevel,
    Expression<String>? metadata,
    Expression<String>? error,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modelId != null) 'model_id': modelId,
      if (url != null) 'url': url,
      if (savePath != null) 'save_path': savePath,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (downloadedBytes != null) 'downloaded_bytes': downloadedBytes,
      if (source != null) 'source': source,
      if (quantLevel != null) 'quant_level': quantLevel,
      if (metadata != null) 'metadata': metadata,
      if (error != null) 'error': error,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadTasksCompanion copyWith({
    Value<String>? id,
    Value<String>? modelId,
    Value<String>? url,
    Value<String>? savePath,
    Value<String>? status,
    Value<int>? progress,
    Value<int>? totalBytes,
    Value<int>? downloadedBytes,
    Value<String>? source,
    Value<String?>? quantLevel,
    Value<String?>? metadata,
    Value<String?>? error,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return DownloadTasksCompanion(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      url: url ?? this.url,
      savePath: savePath ?? this.savePath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      source: source ?? this.source,
      quantLevel: quantLevel ?? this.quantLevel,
      metadata: metadata ?? this.metadata,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (savePath.present) {
      map['save_path'] = Variable<String>(savePath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (downloadedBytes.present) {
      map['downloaded_bytes'] = Variable<int>(downloadedBytes.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (quantLevel.present) {
      map['quant_level'] = Variable<String>(quantLevel.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTasksCompanion(')
          ..write('id: $id, ')
          ..write('modelId: $modelId, ')
          ..write('url: $url, ')
          ..write('savePath: $savePath, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('source: $source, ')
          ..write('quantLevel: $quantLevel, ')
          ..write('metadata: $metadata, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $McpServerConfigsTable extends McpServerConfigs
    with TableInfo<$McpServerConfigsTable, McpServerConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $McpServerConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commandMeta = const VerificationMeta(
    'command',
  );
  @override
  late final GeneratedColumn<String> command = GeneratedColumn<String>(
    'command',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _argsMeta = const VerificationMeta('args');
  @override
  late final GeneratedColumn<String> args = GeneratedColumn<String>(
    'args',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _envMeta = const VerificationMeta('env');
  @override
  late final GeneratedColumn<String> env = GeneratedColumn<String>(
    'env',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isAutoStartMeta = const VerificationMeta(
    'isAutoStart',
  );
  @override
  late final GeneratedColumn<bool> isAutoStart = GeneratedColumn<bool>(
    'is_auto_start',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_auto_start" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastConnectedTimeMeta = const VerificationMeta(
    'lastConnectedTime',
  );
  @override
  late final GeneratedColumn<DateTime> lastConnectedTime =
      GeneratedColumn<DateTime>(
        'last_connected_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    name,
    type,
    command,
    args,
    env,
    isEnabled,
    isAutoStart,
    lastError,
    lastConnectedTime,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mcp_server_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<McpServerConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('command')) {
      context.handle(
        _commandMeta,
        command.isAcceptableOrUnknown(data['command']!, _commandMeta),
      );
    } else if (isInserting) {
      context.missing(_commandMeta);
    }
    if (data.containsKey('args')) {
      context.handle(
        _argsMeta,
        args.isAcceptableOrUnknown(data['args']!, _argsMeta),
      );
    }
    if (data.containsKey('env')) {
      context.handle(
        _envMeta,
        env.isAcceptableOrUnknown(data['env']!, _envMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('is_auto_start')) {
      context.handle(
        _isAutoStartMeta,
        isAutoStart.isAcceptableOrUnknown(
          data['is_auto_start']!,
          _isAutoStartMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('last_connected_time')) {
      context.handle(
        _lastConnectedTimeMeta,
        lastConnectedTime.isAcceptableOrUnknown(
          data['last_connected_time']!,
          _lastConnectedTimeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  McpServerConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return McpServerConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      command: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command'],
      )!,
      args: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}args'],
      ),
      env: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}env'],
      ),
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      isAutoStart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_auto_start'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      lastConnectedTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_connected_time'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $McpServerConfigsTable createAlias(String alias) {
    return $McpServerConfigsTable(attachedDatabase, alias);
  }
}

class McpServerConfig extends DataClass implements Insertable<McpServerConfig> {
  final String id;
  final String serverId;
  final String name;
  final String type;
  final String command;
  final String? args;
  final String? env;
  final bool isEnabled;
  final bool isAutoStart;
  final String? lastError;
  final DateTime? lastConnectedTime;
  final DateTime createdAt;
  const McpServerConfig({
    required this.id,
    required this.serverId,
    required this.name,
    required this.type,
    required this.command,
    this.args,
    this.env,
    required this.isEnabled,
    required this.isAutoStart,
    this.lastError,
    this.lastConnectedTime,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['server_id'] = Variable<String>(serverId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['command'] = Variable<String>(command);
    if (!nullToAbsent || args != null) {
      map['args'] = Variable<String>(args);
    }
    if (!nullToAbsent || env != null) {
      map['env'] = Variable<String>(env);
    }
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['is_auto_start'] = Variable<bool>(isAutoStart);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || lastConnectedTime != null) {
      map['last_connected_time'] = Variable<DateTime>(lastConnectedTime);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  McpServerConfigsCompanion toCompanion(bool nullToAbsent) {
    return McpServerConfigsCompanion(
      id: Value(id),
      serverId: Value(serverId),
      name: Value(name),
      type: Value(type),
      command: Value(command),
      args: args == null && nullToAbsent ? const Value.absent() : Value(args),
      env: env == null && nullToAbsent ? const Value.absent() : Value(env),
      isEnabled: Value(isEnabled),
      isAutoStart: Value(isAutoStart),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      lastConnectedTime: lastConnectedTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastConnectedTime),
      createdAt: Value(createdAt),
    );
  }

  factory McpServerConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return McpServerConfig(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String>(json['serverId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      command: serializer.fromJson<String>(json['command']),
      args: serializer.fromJson<String?>(json['args']),
      env: serializer.fromJson<String?>(json['env']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      isAutoStart: serializer.fromJson<bool>(json['isAutoStart']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      lastConnectedTime: serializer.fromJson<DateTime?>(
        json['lastConnectedTime'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String>(serverId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'command': serializer.toJson<String>(command),
      'args': serializer.toJson<String?>(args),
      'env': serializer.toJson<String?>(env),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'isAutoStart': serializer.toJson<bool>(isAutoStart),
      'lastError': serializer.toJson<String?>(lastError),
      'lastConnectedTime': serializer.toJson<DateTime?>(lastConnectedTime),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  McpServerConfig copyWith({
    String? id,
    String? serverId,
    String? name,
    String? type,
    String? command,
    Value<String?> args = const Value.absent(),
    Value<String?> env = const Value.absent(),
    bool? isEnabled,
    bool? isAutoStart,
    Value<String?> lastError = const Value.absent(),
    Value<DateTime?> lastConnectedTime = const Value.absent(),
    DateTime? createdAt,
  }) => McpServerConfig(
    id: id ?? this.id,
    serverId: serverId ?? this.serverId,
    name: name ?? this.name,
    type: type ?? this.type,
    command: command ?? this.command,
    args: args.present ? args.value : this.args,
    env: env.present ? env.value : this.env,
    isEnabled: isEnabled ?? this.isEnabled,
    isAutoStart: isAutoStart ?? this.isAutoStart,
    lastError: lastError.present ? lastError.value : this.lastError,
    lastConnectedTime: lastConnectedTime.present
        ? lastConnectedTime.value
        : this.lastConnectedTime,
    createdAt: createdAt ?? this.createdAt,
  );
  McpServerConfig copyWithCompanion(McpServerConfigsCompanion data) {
    return McpServerConfig(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      command: data.command.present ? data.command.value : this.command,
      args: data.args.present ? data.args.value : this.args,
      env: data.env.present ? data.env.value : this.env,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      isAutoStart: data.isAutoStart.present
          ? data.isAutoStart.value
          : this.isAutoStart,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      lastConnectedTime: data.lastConnectedTime.present
          ? data.lastConnectedTime.value
          : this.lastConnectedTime,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('McpServerConfig(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('command: $command, ')
          ..write('args: $args, ')
          ..write('env: $env, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('isAutoStart: $isAutoStart, ')
          ..write('lastError: $lastError, ')
          ..write('lastConnectedTime: $lastConnectedTime, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    name,
    type,
    command,
    args,
    env,
    isEnabled,
    isAutoStart,
    lastError,
    lastConnectedTime,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is McpServerConfig &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.name == this.name &&
          other.type == this.type &&
          other.command == this.command &&
          other.args == this.args &&
          other.env == this.env &&
          other.isEnabled == this.isEnabled &&
          other.isAutoStart == this.isAutoStart &&
          other.lastError == this.lastError &&
          other.lastConnectedTime == this.lastConnectedTime &&
          other.createdAt == this.createdAt);
}

class McpServerConfigsCompanion extends UpdateCompanion<McpServerConfig> {
  final Value<String> id;
  final Value<String> serverId;
  final Value<String> name;
  final Value<String> type;
  final Value<String> command;
  final Value<String?> args;
  final Value<String?> env;
  final Value<bool> isEnabled;
  final Value<bool> isAutoStart;
  final Value<String?> lastError;
  final Value<DateTime?> lastConnectedTime;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const McpServerConfigsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.command = const Value.absent(),
    this.args = const Value.absent(),
    this.env = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.isAutoStart = const Value.absent(),
    this.lastError = const Value.absent(),
    this.lastConnectedTime = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  McpServerConfigsCompanion.insert({
    required String id,
    required String serverId,
    required String name,
    required String type,
    required String command,
    this.args = const Value.absent(),
    this.env = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.isAutoStart = const Value.absent(),
    this.lastError = const Value.absent(),
    this.lastConnectedTime = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       serverId = Value(serverId),
       name = Value(name),
       type = Value(type),
       command = Value(command),
       createdAt = Value(createdAt);
  static Insertable<McpServerConfig> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? command,
    Expression<String>? args,
    Expression<String>? env,
    Expression<bool>? isEnabled,
    Expression<bool>? isAutoStart,
    Expression<String>? lastError,
    Expression<DateTime>? lastConnectedTime,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (command != null) 'command': command,
      if (args != null) 'args': args,
      if (env != null) 'env': env,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (isAutoStart != null) 'is_auto_start': isAutoStart,
      if (lastError != null) 'last_error': lastError,
      if (lastConnectedTime != null) 'last_connected_time': lastConnectedTime,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  McpServerConfigsCompanion copyWith({
    Value<String>? id,
    Value<String>? serverId,
    Value<String>? name,
    Value<String>? type,
    Value<String>? command,
    Value<String?>? args,
    Value<String?>? env,
    Value<bool>? isEnabled,
    Value<bool>? isAutoStart,
    Value<String?>? lastError,
    Value<DateTime?>? lastConnectedTime,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return McpServerConfigsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      type: type ?? this.type,
      command: command ?? this.command,
      args: args ?? this.args,
      env: env ?? this.env,
      isEnabled: isEnabled ?? this.isEnabled,
      isAutoStart: isAutoStart ?? this.isAutoStart,
      lastError: lastError ?? this.lastError,
      lastConnectedTime: lastConnectedTime ?? this.lastConnectedTime,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (command.present) {
      map['command'] = Variable<String>(command.value);
    }
    if (args.present) {
      map['args'] = Variable<String>(args.value);
    }
    if (env.present) {
      map['env'] = Variable<String>(env.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (isAutoStart.present) {
      map['is_auto_start'] = Variable<bool>(isAutoStart.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (lastConnectedTime.present) {
      map['last_connected_time'] = Variable<DateTime>(lastConnectedTime.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('McpServerConfigsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('command: $command, ')
          ..write('args: $args, ')
          ..write('env: $env, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('isAutoStart: $isAutoStart, ')
          ..write('lastError: $lastError, ')
          ..write('lastConnectedTime: $lastConnectedTime, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#007AFF'),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('folder'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    color,
    icon,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final String id;
  final String name;
  final String color;
  final String icon;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Folder({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['icon'] = Variable<String>(icon);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      icon: Value(icon),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      icon: serializer.fromJson<String>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'icon': serializer.toJson<String>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Folder copyWith({
    String? id,
    String? name,
    String? color,
    String? icon,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Folder(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    icon: icon ?? this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, color, icon, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> color;
  final Value<String> icon;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoldersCompanion.insert({
    required String id,
    required String name,
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Folder> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoldersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? color,
    Value<String>? icon,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppLogsTable extends AppLogs with TableInfo<$AppLogsTable, AppLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stackTraceMeta = const VerificationMeta(
    'stackTrace',
  );
  @override
  late final GeneratedColumn<String> stackTrace = GeneratedColumn<String>(
    'stack_trace',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceInfoMeta = const VerificationMeta(
    'deviceInfo',
  );
  @override
  late final GeneratedColumn<String> deviceInfo = GeneratedColumn<String>(
    'device_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    level,
    category,
    title,
    message,
    stackTrace,
    deviceInfo,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('stack_trace')) {
      context.handle(
        _stackTraceMeta,
        stackTrace.isAcceptableOrUnknown(data['stack_trace']!, _stackTraceMeta),
      );
    }
    if (data.containsKey('device_info')) {
      context.handle(
        _deviceInfoMeta,
        deviceInfo.isAcceptableOrUnknown(data['device_info']!, _deviceInfoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      stackTrace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stack_trace'],
      ),
      deviceInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_info'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AppLogsTable createAlias(String alias) {
    return $AppLogsTable(attachedDatabase, alias);
  }
}

class AppLog extends DataClass implements Insertable<AppLog> {
  final String id;
  final String level;
  final String category;
  final String title;
  final String message;
  final String? stackTrace;
  final String? deviceInfo;
  final DateTime createdAt;
  const AppLog({
    required this.id,
    required this.level,
    required this.category,
    required this.title,
    required this.message,
    this.stackTrace,
    this.deviceInfo,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['level'] = Variable<String>(level);
    map['category'] = Variable<String>(category);
    map['title'] = Variable<String>(title);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || stackTrace != null) {
      map['stack_trace'] = Variable<String>(stackTrace);
    }
    if (!nullToAbsent || deviceInfo != null) {
      map['device_info'] = Variable<String>(deviceInfo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AppLogsCompanion toCompanion(bool nullToAbsent) {
    return AppLogsCompanion(
      id: Value(id),
      level: Value(level),
      category: Value(category),
      title: Value(title),
      message: Value(message),
      stackTrace: stackTrace == null && nullToAbsent
          ? const Value.absent()
          : Value(stackTrace),
      deviceInfo: deviceInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceInfo),
      createdAt: Value(createdAt),
    );
  }

  factory AppLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppLog(
      id: serializer.fromJson<String>(json['id']),
      level: serializer.fromJson<String>(json['level']),
      category: serializer.fromJson<String>(json['category']),
      title: serializer.fromJson<String>(json['title']),
      message: serializer.fromJson<String>(json['message']),
      stackTrace: serializer.fromJson<String?>(json['stackTrace']),
      deviceInfo: serializer.fromJson<String?>(json['deviceInfo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'level': serializer.toJson<String>(level),
      'category': serializer.toJson<String>(category),
      'title': serializer.toJson<String>(title),
      'message': serializer.toJson<String>(message),
      'stackTrace': serializer.toJson<String?>(stackTrace),
      'deviceInfo': serializer.toJson<String?>(deviceInfo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AppLog copyWith({
    String? id,
    String? level,
    String? category,
    String? title,
    String? message,
    Value<String?> stackTrace = const Value.absent(),
    Value<String?> deviceInfo = const Value.absent(),
    DateTime? createdAt,
  }) => AppLog(
    id: id ?? this.id,
    level: level ?? this.level,
    category: category ?? this.category,
    title: title ?? this.title,
    message: message ?? this.message,
    stackTrace: stackTrace.present ? stackTrace.value : this.stackTrace,
    deviceInfo: deviceInfo.present ? deviceInfo.value : this.deviceInfo,
    createdAt: createdAt ?? this.createdAt,
  );
  AppLog copyWithCompanion(AppLogsCompanion data) {
    return AppLog(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      category: data.category.present ? data.category.value : this.category,
      title: data.title.present ? data.title.value : this.title,
      message: data.message.present ? data.message.value : this.message,
      stackTrace: data.stackTrace.present
          ? data.stackTrace.value
          : this.stackTrace,
      deviceInfo: data.deviceInfo.present
          ? data.deviceInfo.value
          : this.deviceInfo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppLog(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('stackTrace: $stackTrace, ')
          ..write('deviceInfo: $deviceInfo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    level,
    category,
    title,
    message,
    stackTrace,
    deviceInfo,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLog &&
          other.id == this.id &&
          other.level == this.level &&
          other.category == this.category &&
          other.title == this.title &&
          other.message == this.message &&
          other.stackTrace == this.stackTrace &&
          other.deviceInfo == this.deviceInfo &&
          other.createdAt == this.createdAt);
}

class AppLogsCompanion extends UpdateCompanion<AppLog> {
  final Value<String> id;
  final Value<String> level;
  final Value<String> category;
  final Value<String> title;
  final Value<String> message;
  final Value<String?> stackTrace;
  final Value<String?> deviceInfo;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AppLogsCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.category = const Value.absent(),
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.stackTrace = const Value.absent(),
    this.deviceInfo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppLogsCompanion.insert({
    required String id,
    required String level,
    required String category,
    required String title,
    required String message,
    this.stackTrace = const Value.absent(),
    this.deviceInfo = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       level = Value(level),
       category = Value(category),
       title = Value(title),
       message = Value(message),
       createdAt = Value(createdAt);
  static Insertable<AppLog> custom({
    Expression<String>? id,
    Expression<String>? level,
    Expression<String>? category,
    Expression<String>? title,
    Expression<String>? message,
    Expression<String>? stackTrace,
    Expression<String>? deviceInfo,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (category != null) 'category': category,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (stackTrace != null) 'stack_trace': stackTrace,
      if (deviceInfo != null) 'device_info': deviceInfo,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? level,
    Value<String>? category,
    Value<String>? title,
    Value<String>? message,
    Value<String?>? stackTrace,
    Value<String?>? deviceInfo,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AppLogsCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      category: category ?? this.category,
      title: title ?? this.title,
      message: message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (stackTrace.present) {
      map['stack_trace'] = Variable<String>(stackTrace.value);
    }
    if (deviceInfo.present) {
      map['device_info'] = Variable<String>(deviceInfo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppLogsCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('stackTrace: $stackTrace, ')
          ..write('deviceInfo: $deviceInfo, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionSummariesTable extends SessionSummaries
    with TableInfo<$SessionSummariesTable, SessionSummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionSummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _systemPromptMeta = const VerificationMeta(
    'systemPrompt',
  );
  @override
  late final GeneratedColumn<String> systemPrompt = GeneratedColumn<String>(
    'system_prompt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMessagesJsonMeta =
      const VerificationMeta('activeMessagesJson');
  @override
  late final GeneratedColumn<String> activeMessagesJson =
      GeneratedColumn<String>(
        'active_messages_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _maxContextTokensMeta = const VerificationMeta(
    'maxContextTokens',
  );
  @override
  late final GeneratedColumn<int> maxContextTokens = GeneratedColumn<int>(
    'max_context_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(32768),
  );
  static const VerificationMeta _compressionCountMeta = const VerificationMeta(
    'compressionCount',
  );
  @override
  late final GeneratedColumn<int> compressionCount = GeneratedColumn<int>(
    'compression_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    summary,
    systemPrompt,
    activeMessagesJson,
    maxContextTokens,
    compressionCount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionSummary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('system_prompt')) {
      context.handle(
        _systemPromptMeta,
        systemPrompt.isAcceptableOrUnknown(
          data['system_prompt']!,
          _systemPromptMeta,
        ),
      );
    }
    if (data.containsKey('active_messages_json')) {
      context.handle(
        _activeMessagesJsonMeta,
        activeMessagesJson.isAcceptableOrUnknown(
          data['active_messages_json']!,
          _activeMessagesJsonMeta,
        ),
      );
    }
    if (data.containsKey('max_context_tokens')) {
      context.handle(
        _maxContextTokensMeta,
        maxContextTokens.isAcceptableOrUnknown(
          data['max_context_tokens']!,
          _maxContextTokensMeta,
        ),
      );
    }
    if (data.containsKey('compression_count')) {
      context.handle(
        _compressionCountMeta,
        compressionCount.isAcceptableOrUnknown(
          data['compression_count']!,
          _compressionCountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  SessionSummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionSummary(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      systemPrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_prompt'],
      ),
      activeMessagesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_messages_json'],
      ),
      maxContextTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_context_tokens'],
      )!,
      compressionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}compression_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionSummariesTable createAlias(String alias) {
    return $SessionSummariesTable(attachedDatabase, alias);
  }
}

class SessionSummary extends DataClass implements Insertable<SessionSummary> {
  final String sessionId;
  final String summary;
  final String? systemPrompt;
  final String? activeMessagesJson;
  final int maxContextTokens;
  final int compressionCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SessionSummary({
    required this.sessionId,
    required this.summary,
    this.systemPrompt,
    this.activeMessagesJson,
    required this.maxContextTokens,
    required this.compressionCount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['summary'] = Variable<String>(summary);
    if (!nullToAbsent || systemPrompt != null) {
      map['system_prompt'] = Variable<String>(systemPrompt);
    }
    if (!nullToAbsent || activeMessagesJson != null) {
      map['active_messages_json'] = Variable<String>(activeMessagesJson);
    }
    map['max_context_tokens'] = Variable<int>(maxContextTokens);
    map['compression_count'] = Variable<int>(compressionCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionSummariesCompanion toCompanion(bool nullToAbsent) {
    return SessionSummariesCompanion(
      sessionId: Value(sessionId),
      summary: Value(summary),
      systemPrompt: systemPrompt == null && nullToAbsent
          ? const Value.absent()
          : Value(systemPrompt),
      activeMessagesJson: activeMessagesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(activeMessagesJson),
      maxContextTokens: Value(maxContextTokens),
      compressionCount: Value(compressionCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionSummary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionSummary(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      summary: serializer.fromJson<String>(json['summary']),
      systemPrompt: serializer.fromJson<String?>(json['systemPrompt']),
      activeMessagesJson: serializer.fromJson<String?>(
        json['activeMessagesJson'],
      ),
      maxContextTokens: serializer.fromJson<int>(json['maxContextTokens']),
      compressionCount: serializer.fromJson<int>(json['compressionCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'summary': serializer.toJson<String>(summary),
      'systemPrompt': serializer.toJson<String?>(systemPrompt),
      'activeMessagesJson': serializer.toJson<String?>(activeMessagesJson),
      'maxContextTokens': serializer.toJson<int>(maxContextTokens),
      'compressionCount': serializer.toJson<int>(compressionCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SessionSummary copyWith({
    String? sessionId,
    String? summary,
    Value<String?> systemPrompt = const Value.absent(),
    Value<String?> activeMessagesJson = const Value.absent(),
    int? maxContextTokens,
    int? compressionCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SessionSummary(
    sessionId: sessionId ?? this.sessionId,
    summary: summary ?? this.summary,
    systemPrompt: systemPrompt.present ? systemPrompt.value : this.systemPrompt,
    activeMessagesJson: activeMessagesJson.present
        ? activeMessagesJson.value
        : this.activeMessagesJson,
    maxContextTokens: maxContextTokens ?? this.maxContextTokens,
    compressionCount: compressionCount ?? this.compressionCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionSummary copyWithCompanion(SessionSummariesCompanion data) {
    return SessionSummary(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      summary: data.summary.present ? data.summary.value : this.summary,
      systemPrompt: data.systemPrompt.present
          ? data.systemPrompt.value
          : this.systemPrompt,
      activeMessagesJson: data.activeMessagesJson.present
          ? data.activeMessagesJson.value
          : this.activeMessagesJson,
      maxContextTokens: data.maxContextTokens.present
          ? data.maxContextTokens.value
          : this.maxContextTokens,
      compressionCount: data.compressionCount.present
          ? data.compressionCount.value
          : this.compressionCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionSummary(')
          ..write('sessionId: $sessionId, ')
          ..write('summary: $summary, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('activeMessagesJson: $activeMessagesJson, ')
          ..write('maxContextTokens: $maxContextTokens, ')
          ..write('compressionCount: $compressionCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    summary,
    systemPrompt,
    activeMessagesJson,
    maxContextTokens,
    compressionCount,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionSummary &&
          other.sessionId == this.sessionId &&
          other.summary == this.summary &&
          other.systemPrompt == this.systemPrompt &&
          other.activeMessagesJson == this.activeMessagesJson &&
          other.maxContextTokens == this.maxContextTokens &&
          other.compressionCount == this.compressionCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SessionSummariesCompanion extends UpdateCompanion<SessionSummary> {
  final Value<String> sessionId;
  final Value<String> summary;
  final Value<String?> systemPrompt;
  final Value<String?> activeMessagesJson;
  final Value<int> maxContextTokens;
  final Value<int> compressionCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionSummariesCompanion({
    this.sessionId = const Value.absent(),
    this.summary = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.activeMessagesJson = const Value.absent(),
    this.maxContextTokens = const Value.absent(),
    this.compressionCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionSummariesCompanion.insert({
    required String sessionId,
    this.summary = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.activeMessagesJson = const Value.absent(),
    this.maxContextTokens = const Value.absent(),
    this.compressionCount = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SessionSummary> custom({
    Expression<String>? sessionId,
    Expression<String>? summary,
    Expression<String>? systemPrompt,
    Expression<String>? activeMessagesJson,
    Expression<int>? maxContextTokens,
    Expression<int>? compressionCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (summary != null) 'summary': summary,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
      if (activeMessagesJson != null)
        'active_messages_json': activeMessagesJson,
      if (maxContextTokens != null) 'max_context_tokens': maxContextTokens,
      if (compressionCount != null) 'compression_count': compressionCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionSummariesCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? summary,
    Value<String?>? systemPrompt,
    Value<String?>? activeMessagesJson,
    Value<int>? maxContextTokens,
    Value<int>? compressionCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionSummariesCompanion(
      sessionId: sessionId ?? this.sessionId,
      summary: summary ?? this.summary,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      activeMessagesJson: activeMessagesJson ?? this.activeMessagesJson,
      maxContextTokens: maxContextTokens ?? this.maxContextTokens,
      compressionCount: compressionCount ?? this.compressionCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (systemPrompt.present) {
      map['system_prompt'] = Variable<String>(systemPrompt.value);
    }
    if (activeMessagesJson.present) {
      map['active_messages_json'] = Variable<String>(activeMessagesJson.value);
    }
    if (maxContextTokens.present) {
      map['max_context_tokens'] = Variable<int>(maxContextTokens.value);
    }
    if (compressionCount.present) {
      map['compression_count'] = Variable<int>(compressionCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionSummariesCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('summary: $summary, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('activeMessagesJson: $activeMessagesJson, ')
          ..write('maxContextTokens: $maxContextTokens, ')
          ..write('compressionCount: $compressionCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PluginRegistriesTable extends PluginRegistries
    with TableInfo<$PluginRegistriesTable, PluginRegistry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PluginRegistriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repositoryMeta = const VerificationMeta(
    'repository',
  );
  @override
  late final GeneratedColumn<String> repository = GeneratedColumn<String>(
    'repository',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryPointMeta = const VerificationMeta(
    'entryPoint',
  );
  @override
  late final GeneratedColumn<String> entryPoint = GeneratedColumn<String>(
    'entry_point',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('lib/main.dart'),
  );
  static const VerificationMeta _installPathMeta = const VerificationMeta(
    'installPath',
  );
  @override
  late final GeneratedColumn<String> installPath = GeneratedColumn<String>(
    'install_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _permissionsMeta = const VerificationMeta(
    'permissions',
  );
  @override
  late final GeneratedColumn<String> permissions = GeneratedColumn<String>(
    'permissions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _configMeta = const VerificationMeta('config');
  @override
  late final GeneratedColumn<String> config = GeneratedColumn<String>(
    'config',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('installed'),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    version,
    author,
    description,
    repository,
    entryPoint,
    installPath,
    permissions,
    config,
    status,
    errorMessage,
    installedAt,
    updatedAt,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plugin_registries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PluginRegistry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('repository')) {
      context.handle(
        _repositoryMeta,
        repository.isAcceptableOrUnknown(data['repository']!, _repositoryMeta),
      );
    }
    if (data.containsKey('entry_point')) {
      context.handle(
        _entryPointMeta,
        entryPoint.isAcceptableOrUnknown(data['entry_point']!, _entryPointMeta),
      );
    }
    if (data.containsKey('install_path')) {
      context.handle(
        _installPathMeta,
        installPath.isAcceptableOrUnknown(
          data['install_path']!,
          _installPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installPathMeta);
    }
    if (data.containsKey('permissions')) {
      context.handle(
        _permissionsMeta,
        permissions.isAcceptableOrUnknown(
          data['permissions']!,
          _permissionsMeta,
        ),
      );
    }
    if (data.containsKey('config')) {
      context.handle(
        _configMeta,
        config.isAcceptableOrUnknown(data['config']!, _configMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PluginRegistry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PluginRegistry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      repository: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repository'],
      ),
      entryPoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_point'],
      )!,
      installPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}install_path'],
      )!,
      permissions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permissions'],
      ),
      config: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
    );
  }

  @override
  $PluginRegistriesTable createAlias(String alias) {
    return $PluginRegistriesTable(attachedDatabase, alias);
  }
}

class PluginRegistry extends DataClass implements Insertable<PluginRegistry> {
  final String id;
  final String name;
  final String version;
  final String? author;
  final String? description;
  final String? repository;
  final String entryPoint;
  final String installPath;
  final String? permissions;
  final String? config;
  final String status;
  final String? errorMessage;
  final DateTime installedAt;
  final DateTime? updatedAt;
  final DateTime? lastUsedAt;
  const PluginRegistry({
    required this.id,
    required this.name,
    required this.version,
    this.author,
    this.description,
    this.repository,
    required this.entryPoint,
    required this.installPath,
    this.permissions,
    this.config,
    required this.status,
    this.errorMessage,
    required this.installedAt,
    this.updatedAt,
    this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['version'] = Variable<String>(version);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || repository != null) {
      map['repository'] = Variable<String>(repository);
    }
    map['entry_point'] = Variable<String>(entryPoint);
    map['install_path'] = Variable<String>(installPath);
    if (!nullToAbsent || permissions != null) {
      map['permissions'] = Variable<String>(permissions);
    }
    if (!nullToAbsent || config != null) {
      map['config'] = Variable<String>(config);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['installed_at'] = Variable<DateTime>(installedAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    return map;
  }

  PluginRegistriesCompanion toCompanion(bool nullToAbsent) {
    return PluginRegistriesCompanion(
      id: Value(id),
      name: Value(name),
      version: Value(version),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      repository: repository == null && nullToAbsent
          ? const Value.absent()
          : Value(repository),
      entryPoint: Value(entryPoint),
      installPath: Value(installPath),
      permissions: permissions == null && nullToAbsent
          ? const Value.absent()
          : Value(permissions),
      config: config == null && nullToAbsent
          ? const Value.absent()
          : Value(config),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      installedAt: Value(installedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
    );
  }

  factory PluginRegistry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PluginRegistry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      version: serializer.fromJson<String>(json['version']),
      author: serializer.fromJson<String?>(json['author']),
      description: serializer.fromJson<String?>(json['description']),
      repository: serializer.fromJson<String?>(json['repository']),
      entryPoint: serializer.fromJson<String>(json['entryPoint']),
      installPath: serializer.fromJson<String>(json['installPath']),
      permissions: serializer.fromJson<String?>(json['permissions']),
      config: serializer.fromJson<String?>(json['config']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'version': serializer.toJson<String>(version),
      'author': serializer.toJson<String?>(author),
      'description': serializer.toJson<String?>(description),
      'repository': serializer.toJson<String?>(repository),
      'entryPoint': serializer.toJson<String>(entryPoint),
      'installPath': serializer.toJson<String>(installPath),
      'permissions': serializer.toJson<String?>(permissions),
      'config': serializer.toJson<String?>(config),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'installedAt': serializer.toJson<DateTime>(installedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
    };
  }

  PluginRegistry copyWith({
    String? id,
    String? name,
    String? version,
    Value<String?> author = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> repository = const Value.absent(),
    String? entryPoint,
    String? installPath,
    Value<String?> permissions = const Value.absent(),
    Value<String?> config = const Value.absent(),
    String? status,
    Value<String?> errorMessage = const Value.absent(),
    DateTime? installedAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> lastUsedAt = const Value.absent(),
  }) => PluginRegistry(
    id: id ?? this.id,
    name: name ?? this.name,
    version: version ?? this.version,
    author: author.present ? author.value : this.author,
    description: description.present ? description.value : this.description,
    repository: repository.present ? repository.value : this.repository,
    entryPoint: entryPoint ?? this.entryPoint,
    installPath: installPath ?? this.installPath,
    permissions: permissions.present ? permissions.value : this.permissions,
    config: config.present ? config.value : this.config,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    installedAt: installedAt ?? this.installedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
  );
  PluginRegistry copyWithCompanion(PluginRegistriesCompanion data) {
    return PluginRegistry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      version: data.version.present ? data.version.value : this.version,
      author: data.author.present ? data.author.value : this.author,
      description: data.description.present
          ? data.description.value
          : this.description,
      repository: data.repository.present
          ? data.repository.value
          : this.repository,
      entryPoint: data.entryPoint.present
          ? data.entryPoint.value
          : this.entryPoint,
      installPath: data.installPath.present
          ? data.installPath.value
          : this.installPath,
      permissions: data.permissions.present
          ? data.permissions.value
          : this.permissions,
      config: data.config.present ? data.config.value : this.config,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PluginRegistry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('author: $author, ')
          ..write('description: $description, ')
          ..write('repository: $repository, ')
          ..write('entryPoint: $entryPoint, ')
          ..write('installPath: $installPath, ')
          ..write('permissions: $permissions, ')
          ..write('config: $config, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('installedAt: $installedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    version,
    author,
    description,
    repository,
    entryPoint,
    installPath,
    permissions,
    config,
    status,
    errorMessage,
    installedAt,
    updatedAt,
    lastUsedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PluginRegistry &&
          other.id == this.id &&
          other.name == this.name &&
          other.version == this.version &&
          other.author == this.author &&
          other.description == this.description &&
          other.repository == this.repository &&
          other.entryPoint == this.entryPoint &&
          other.installPath == this.installPath &&
          other.permissions == this.permissions &&
          other.config == this.config &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.installedAt == this.installedAt &&
          other.updatedAt == this.updatedAt &&
          other.lastUsedAt == this.lastUsedAt);
}

class PluginRegistriesCompanion extends UpdateCompanion<PluginRegistry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> version;
  final Value<String?> author;
  final Value<String?> description;
  final Value<String?> repository;
  final Value<String> entryPoint;
  final Value<String> installPath;
  final Value<String?> permissions;
  final Value<String?> config;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<DateTime> installedAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> lastUsedAt;
  final Value<int> rowid;
  const PluginRegistriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.version = const Value.absent(),
    this.author = const Value.absent(),
    this.description = const Value.absent(),
    this.repository = const Value.absent(),
    this.entryPoint = const Value.absent(),
    this.installPath = const Value.absent(),
    this.permissions = const Value.absent(),
    this.config = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PluginRegistriesCompanion.insert({
    required String id,
    required String name,
    required String version,
    this.author = const Value.absent(),
    this.description = const Value.absent(),
    this.repository = const Value.absent(),
    this.entryPoint = const Value.absent(),
    required String installPath,
    this.permissions = const Value.absent(),
    this.config = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    required DateTime installedAt,
    this.updatedAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       version = Value(version),
       installPath = Value(installPath),
       installedAt = Value(installedAt);
  static Insertable<PluginRegistry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? version,
    Expression<String>? author,
    Expression<String>? description,
    Expression<String>? repository,
    Expression<String>? entryPoint,
    Expression<String>? installPath,
    Expression<String>? permissions,
    Expression<String>? config,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<DateTime>? installedAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (version != null) 'version': version,
      if (author != null) 'author': author,
      if (description != null) 'description': description,
      if (repository != null) 'repository': repository,
      if (entryPoint != null) 'entry_point': entryPoint,
      if (installPath != null) 'install_path': installPath,
      if (permissions != null) 'permissions': permissions,
      if (config != null) 'config': config,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (installedAt != null) 'installed_at': installedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PluginRegistriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? version,
    Value<String?>? author,
    Value<String?>? description,
    Value<String?>? repository,
    Value<String>? entryPoint,
    Value<String>? installPath,
    Value<String?>? permissions,
    Value<String?>? config,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<DateTime>? installedAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? lastUsedAt,
    Value<int>? rowid,
  }) {
    return PluginRegistriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      author: author ?? this.author,
      description: description ?? this.description,
      repository: repository ?? this.repository,
      entryPoint: entryPoint ?? this.entryPoint,
      installPath: installPath ?? this.installPath,
      permissions: permissions ?? this.permissions,
      config: config ?? this.config,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      installedAt: installedAt ?? this.installedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (repository.present) {
      map['repository'] = Variable<String>(repository.value);
    }
    if (entryPoint.present) {
      map['entry_point'] = Variable<String>(entryPoint.value);
    }
    if (installPath.present) {
      map['install_path'] = Variable<String>(installPath.value);
    }
    if (permissions.present) {
      map['permissions'] = Variable<String>(permissions.value);
    }
    if (config.present) {
      map['config'] = Variable<String>(config.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PluginRegistriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('author: $author, ')
          ..write('description: $description, ')
          ..write('repository: $repository, ')
          ..write('entryPoint: $entryPoint, ')
          ..write('installPath: $installPath, ')
          ..write('permissions: $permissions, ')
          ..write('config: $config, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('installedAt: $installedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionResourcesTable extends SessionResources
    with TableInfo<$SessionResourcesTable, SessionResource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionResourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceTypeMeta = const VerificationMeta(
    'resourceType',
  );
  @override
  late final GeneratedColumn<String> resourceType = GeneratedColumn<String>(
    'resource_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<String> resourceId = GeneratedColumn<String>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configMeta = const VerificationMeta('config');
  @override
  late final GeneratedColumn<String> config = GeneratedColumn<String>(
    'config',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    resourceType,
    resourceId,
    config,
    isEnabled,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_resources';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionResource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('resource_type')) {
      context.handle(
        _resourceTypeMeta,
        resourceType.isAcceptableOrUnknown(
          data['resource_type']!,
          _resourceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resourceTypeMeta);
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('config')) {
      context.handle(
        _configMeta,
        config.isAcceptableOrUnknown(data['config']!, _configMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, resourceType, resourceId};
  @override
  SessionResource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionResource(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      resourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_type'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_id'],
      )!,
      config: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config'],
      ),
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionResourcesTable createAlias(String alias) {
    return $SessionResourcesTable(attachedDatabase, alias);
  }
}

class SessionResource extends DataClass implements Insertable<SessionResource> {
  final String sessionId;
  final String resourceType;
  final String resourceId;
  final String? config;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SessionResource({
    required this.sessionId,
    required this.resourceType,
    required this.resourceId,
    this.config,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['resource_type'] = Variable<String>(resourceType);
    map['resource_id'] = Variable<String>(resourceId);
    if (!nullToAbsent || config != null) {
      map['config'] = Variable<String>(config);
    }
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionResourcesCompanion toCompanion(bool nullToAbsent) {
    return SessionResourcesCompanion(
      sessionId: Value(sessionId),
      resourceType: Value(resourceType),
      resourceId: Value(resourceId),
      config: config == null && nullToAbsent
          ? const Value.absent()
          : Value(config),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionResource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionResource(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      resourceType: serializer.fromJson<String>(json['resourceType']),
      resourceId: serializer.fromJson<String>(json['resourceId']),
      config: serializer.fromJson<String?>(json['config']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'resourceType': serializer.toJson<String>(resourceType),
      'resourceId': serializer.toJson<String>(resourceId),
      'config': serializer.toJson<String?>(config),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SessionResource copyWith({
    String? sessionId,
    String? resourceType,
    String? resourceId,
    Value<String?> config = const Value.absent(),
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SessionResource(
    sessionId: sessionId ?? this.sessionId,
    resourceType: resourceType ?? this.resourceType,
    resourceId: resourceId ?? this.resourceId,
    config: config.present ? config.value : this.config,
    isEnabled: isEnabled ?? this.isEnabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionResource copyWithCompanion(SessionResourcesCompanion data) {
    return SessionResource(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      resourceType: data.resourceType.present
          ? data.resourceType.value
          : this.resourceType,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      config: data.config.present ? data.config.value : this.config,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionResource(')
          ..write('sessionId: $sessionId, ')
          ..write('resourceType: $resourceType, ')
          ..write('resourceId: $resourceId, ')
          ..write('config: $config, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    resourceType,
    resourceId,
    config,
    isEnabled,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionResource &&
          other.sessionId == this.sessionId &&
          other.resourceType == this.resourceType &&
          other.resourceId == this.resourceId &&
          other.config == this.config &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SessionResourcesCompanion extends UpdateCompanion<SessionResource> {
  final Value<String> sessionId;
  final Value<String> resourceType;
  final Value<String> resourceId;
  final Value<String?> config;
  final Value<bool> isEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionResourcesCompanion({
    this.sessionId = const Value.absent(),
    this.resourceType = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.config = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionResourcesCompanion.insert({
    required String sessionId,
    required String resourceType,
    required String resourceId,
    this.config = const Value.absent(),
    this.isEnabled = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       resourceType = Value(resourceType),
       resourceId = Value(resourceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SessionResource> custom({
    Expression<String>? sessionId,
    Expression<String>? resourceType,
    Expression<String>? resourceId,
    Expression<String>? config,
    Expression<bool>? isEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (resourceType != null) 'resource_type': resourceType,
      if (resourceId != null) 'resource_id': resourceId,
      if (config != null) 'config': config,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionResourcesCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? resourceType,
    Value<String>? resourceId,
    Value<String?>? config,
    Value<bool>? isEnabled,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionResourcesCompanion(
      sessionId: sessionId ?? this.sessionId,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
      config: config ?? this.config,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (resourceType.present) {
      map['resource_type'] = Variable<String>(resourceType.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<String>(resourceId.value);
    }
    if (config.present) {
      map['config'] = Variable<String>(config.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionResourcesCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('resourceType: $resourceType, ')
          ..write('resourceId: $resourceId, ')
          ..write('config: $config, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkflowDefinitionsTable extends WorkflowDefinitions
    with TableInfo<$WorkflowDefinitionsTable, WorkflowDefinitionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkflowDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _definitionJsonMeta = const VerificationMeta(
    'definitionJson',
  );
  @override
  late final GeneratedColumn<String> definitionJson = GeneratedColumn<String>(
    'definition_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _triggerTypeMeta = const VerificationMeta(
    'triggerType',
  );
  @override
  late final GeneratedColumn<String> triggerType = GeneratedColumn<String>(
    'trigger_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _triggerConfigMeta = const VerificationMeta(
    'triggerConfig',
  );
  @override
  late final GeneratedColumn<String> triggerConfig = GeneratedColumn<String>(
    'trigger_config',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    version,
    definitionJson,
    tags,
    isEnabled,
    triggerType,
    triggerConfig,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workflow_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkflowDefinitionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('definition_json')) {
      context.handle(
        _definitionJsonMeta,
        definitionJson.isAcceptableOrUnknown(
          data['definition_json']!,
          _definitionJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_definitionJsonMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('trigger_type')) {
      context.handle(
        _triggerTypeMeta,
        triggerType.isAcceptableOrUnknown(
          data['trigger_type']!,
          _triggerTypeMeta,
        ),
      );
    }
    if (data.containsKey('trigger_config')) {
      context.handle(
        _triggerConfigMeta,
        triggerConfig.isAcceptableOrUnknown(
          data['trigger_config']!,
          _triggerConfigMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkflowDefinitionRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkflowDefinitionRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      definitionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition_json'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      triggerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_type'],
      )!,
      triggerConfig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_config'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkflowDefinitionsTable createAlias(String alias) {
    return $WorkflowDefinitionsTable(attachedDatabase, alias);
  }
}

class WorkflowDefinitionRecord extends DataClass
    implements Insertable<WorkflowDefinitionRecord> {
  final String id;
  final String name;
  final String? description;
  final int version;
  final String definitionJson;
  final String? tags;
  final bool isEnabled;
  final String triggerType;
  final String? triggerConfig;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WorkflowDefinitionRecord({
    required this.id,
    required this.name,
    this.description,
    required this.version,
    required this.definitionJson,
    this.tags,
    required this.isEnabled,
    required this.triggerType,
    this.triggerConfig,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['version'] = Variable<int>(version);
    map['definition_json'] = Variable<String>(definitionJson);
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['trigger_type'] = Variable<String>(triggerType);
    if (!nullToAbsent || triggerConfig != null) {
      map['trigger_config'] = Variable<String>(triggerConfig);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkflowDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return WorkflowDefinitionsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      version: Value(version),
      definitionJson: Value(definitionJson),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      isEnabled: Value(isEnabled),
      triggerType: Value(triggerType),
      triggerConfig: triggerConfig == null && nullToAbsent
          ? const Value.absent()
          : Value(triggerConfig),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkflowDefinitionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkflowDefinitionRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      version: serializer.fromJson<int>(json['version']),
      definitionJson: serializer.fromJson<String>(json['definitionJson']),
      tags: serializer.fromJson<String?>(json['tags']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      triggerType: serializer.fromJson<String>(json['triggerType']),
      triggerConfig: serializer.fromJson<String?>(json['triggerConfig']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'version': serializer.toJson<int>(version),
      'definitionJson': serializer.toJson<String>(definitionJson),
      'tags': serializer.toJson<String?>(tags),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'triggerType': serializer.toJson<String>(triggerType),
      'triggerConfig': serializer.toJson<String?>(triggerConfig),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WorkflowDefinitionRecord copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    int? version,
    String? definitionJson,
    Value<String?> tags = const Value.absent(),
    bool? isEnabled,
    String? triggerType,
    Value<String?> triggerConfig = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WorkflowDefinitionRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    version: version ?? this.version,
    definitionJson: definitionJson ?? this.definitionJson,
    tags: tags.present ? tags.value : this.tags,
    isEnabled: isEnabled ?? this.isEnabled,
    triggerType: triggerType ?? this.triggerType,
    triggerConfig: triggerConfig.present
        ? triggerConfig.value
        : this.triggerConfig,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkflowDefinitionRecord copyWithCompanion(
    WorkflowDefinitionsCompanion data,
  ) {
    return WorkflowDefinitionRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      version: data.version.present ? data.version.value : this.version,
      definitionJson: data.definitionJson.present
          ? data.definitionJson.value
          : this.definitionJson,
      tags: data.tags.present ? data.tags.value : this.tags,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      triggerType: data.triggerType.present
          ? data.triggerType.value
          : this.triggerType,
      triggerConfig: data.triggerConfig.present
          ? data.triggerConfig.value
          : this.triggerConfig,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkflowDefinitionRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('version: $version, ')
          ..write('definitionJson: $definitionJson, ')
          ..write('tags: $tags, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('triggerType: $triggerType, ')
          ..write('triggerConfig: $triggerConfig, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    version,
    definitionJson,
    tags,
    isEnabled,
    triggerType,
    triggerConfig,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkflowDefinitionRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.version == this.version &&
          other.definitionJson == this.definitionJson &&
          other.tags == this.tags &&
          other.isEnabled == this.isEnabled &&
          other.triggerType == this.triggerType &&
          other.triggerConfig == this.triggerConfig &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkflowDefinitionsCompanion
    extends UpdateCompanion<WorkflowDefinitionRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> version;
  final Value<String> definitionJson;
  final Value<String?> tags;
  final Value<bool> isEnabled;
  final Value<String> triggerType;
  final Value<String?> triggerConfig;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkflowDefinitionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.version = const Value.absent(),
    this.definitionJson = const Value.absent(),
    this.tags = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.triggerType = const Value.absent(),
    this.triggerConfig = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkflowDefinitionsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.version = const Value.absent(),
    required String definitionJson,
    this.tags = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.triggerType = const Value.absent(),
    this.triggerConfig = const Value.absent(),
    this.createdBy = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       definitionJson = Value(definitionJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WorkflowDefinitionRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? version,
    Expression<String>? definitionJson,
    Expression<String>? tags,
    Expression<bool>? isEnabled,
    Expression<String>? triggerType,
    Expression<String>? triggerConfig,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (version != null) 'version': version,
      if (definitionJson != null) 'definition_json': definitionJson,
      if (tags != null) 'tags': tags,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (triggerType != null) 'trigger_type': triggerType,
      if (triggerConfig != null) 'trigger_config': triggerConfig,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkflowDefinitionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? version,
    Value<String>? definitionJson,
    Value<String?>? tags,
    Value<bool>? isEnabled,
    Value<String>? triggerType,
    Value<String?>? triggerConfig,
    Value<String?>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkflowDefinitionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      definitionJson: definitionJson ?? this.definitionJson,
      tags: tags ?? this.tags,
      isEnabled: isEnabled ?? this.isEnabled,
      triggerType: triggerType ?? this.triggerType,
      triggerConfig: triggerConfig ?? this.triggerConfig,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (definitionJson.present) {
      map['definition_json'] = Variable<String>(definitionJson.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (triggerType.present) {
      map['trigger_type'] = Variable<String>(triggerType.value);
    }
    if (triggerConfig.present) {
      map['trigger_config'] = Variable<String>(triggerConfig.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkflowDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('version: $version, ')
          ..write('definitionJson: $definitionJson, ')
          ..write('tags: $tags, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('triggerType: $triggerType, ')
          ..write('triggerConfig: $triggerConfig, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkflowExecutionsTable extends WorkflowExecutions
    with TableInfo<$WorkflowExecutionsTable, WorkflowExecutionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkflowExecutionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instanceIdMeta = const VerificationMeta(
    'instanceId',
  );
  @override
  late final GeneratedColumn<String> instanceId = GeneratedColumn<String>(
    'instance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workflowIdMeta = const VerificationMeta(
    'workflowId',
  );
  @override
  late final GeneratedColumn<String> workflowId = GeneratedColumn<String>(
    'workflow_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputVariablesJsonMeta =
      const VerificationMeta('inputVariablesJson');
  @override
  late final GeneratedColumn<String> inputVariablesJson =
      GeneratedColumn<String>(
        'input_variables_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _outputVariablesJsonMeta =
      const VerificationMeta('outputVariablesJson');
  @override
  late final GeneratedColumn<String> outputVariablesJson =
      GeneratedColumn<String>(
        'output_variables_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nodeStatesJsonMeta = const VerificationMeta(
    'nodeStatesJson',
  );
  @override
  late final GeneratedColumn<String> nodeStatesJson = GeneratedColumn<String>(
    'node_states_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    instanceId,
    workflowId,
    status,
    inputVariablesJson,
    outputVariablesJson,
    nodeStatesJson,
    errorMessage,
    startTime,
    endTime,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workflow_executions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkflowExecutionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instance_id')) {
      context.handle(
        _instanceIdMeta,
        instanceId.isAcceptableOrUnknown(data['instance_id']!, _instanceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_instanceIdMeta);
    }
    if (data.containsKey('workflow_id')) {
      context.handle(
        _workflowIdMeta,
        workflowId.isAcceptableOrUnknown(data['workflow_id']!, _workflowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workflowIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('input_variables_json')) {
      context.handle(
        _inputVariablesJsonMeta,
        inputVariablesJson.isAcceptableOrUnknown(
          data['input_variables_json']!,
          _inputVariablesJsonMeta,
        ),
      );
    }
    if (data.containsKey('output_variables_json')) {
      context.handle(
        _outputVariablesJsonMeta,
        outputVariablesJson.isAcceptableOrUnknown(
          data['output_variables_json']!,
          _outputVariablesJsonMeta,
        ),
      );
    }
    if (data.containsKey('node_states_json')) {
      context.handle(
        _nodeStatesJsonMeta,
        nodeStatesJson.isAcceptableOrUnknown(
          data['node_states_json']!,
          _nodeStatesJsonMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {instanceId};
  @override
  WorkflowExecutionRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkflowExecutionRecord(
      instanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_id'],
      )!,
      workflowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workflow_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      inputVariablesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_variables_json'],
      ),
      outputVariablesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output_variables_json'],
      ),
      nodeStatesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_states_json'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WorkflowExecutionsTable createAlias(String alias) {
    return $WorkflowExecutionsTable(attachedDatabase, alias);
  }
}

class WorkflowExecutionRecord extends DataClass
    implements Insertable<WorkflowExecutionRecord> {
  final String instanceId;
  final String workflowId;
  final String status;
  final String? inputVariablesJson;
  final String? outputVariablesJson;
  final String? nodeStatesJson;
  final String? errorMessage;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;
  const WorkflowExecutionRecord({
    required this.instanceId,
    required this.workflowId,
    required this.status,
    this.inputVariablesJson,
    this.outputVariablesJson,
    this.nodeStatesJson,
    this.errorMessage,
    this.startTime,
    this.endTime,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instance_id'] = Variable<String>(instanceId);
    map['workflow_id'] = Variable<String>(workflowId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || inputVariablesJson != null) {
      map['input_variables_json'] = Variable<String>(inputVariablesJson);
    }
    if (!nullToAbsent || outputVariablesJson != null) {
      map['output_variables_json'] = Variable<String>(outputVariablesJson);
    }
    if (!nullToAbsent || nodeStatesJson != null) {
      map['node_states_json'] = Variable<String>(nodeStatesJson);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<DateTime>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WorkflowExecutionsCompanion toCompanion(bool nullToAbsent) {
    return WorkflowExecutionsCompanion(
      instanceId: Value(instanceId),
      workflowId: Value(workflowId),
      status: Value(status),
      inputVariablesJson: inputVariablesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(inputVariablesJson),
      outputVariablesJson: outputVariablesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(outputVariablesJson),
      nodeStatesJson: nodeStatesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(nodeStatesJson),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      createdAt: Value(createdAt),
    );
  }

  factory WorkflowExecutionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkflowExecutionRecord(
      instanceId: serializer.fromJson<String>(json['instanceId']),
      workflowId: serializer.fromJson<String>(json['workflowId']),
      status: serializer.fromJson<String>(json['status']),
      inputVariablesJson: serializer.fromJson<String?>(
        json['inputVariablesJson'],
      ),
      outputVariablesJson: serializer.fromJson<String?>(
        json['outputVariablesJson'],
      ),
      nodeStatesJson: serializer.fromJson<String?>(json['nodeStatesJson']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      startTime: serializer.fromJson<DateTime?>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instanceId': serializer.toJson<String>(instanceId),
      'workflowId': serializer.toJson<String>(workflowId),
      'status': serializer.toJson<String>(status),
      'inputVariablesJson': serializer.toJson<String?>(inputVariablesJson),
      'outputVariablesJson': serializer.toJson<String?>(outputVariablesJson),
      'nodeStatesJson': serializer.toJson<String?>(nodeStatesJson),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'startTime': serializer.toJson<DateTime?>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WorkflowExecutionRecord copyWith({
    String? instanceId,
    String? workflowId,
    String? status,
    Value<String?> inputVariablesJson = const Value.absent(),
    Value<String?> outputVariablesJson = const Value.absent(),
    Value<String?> nodeStatesJson = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    Value<DateTime?> startTime = const Value.absent(),
    Value<DateTime?> endTime = const Value.absent(),
    DateTime? createdAt,
  }) => WorkflowExecutionRecord(
    instanceId: instanceId ?? this.instanceId,
    workflowId: workflowId ?? this.workflowId,
    status: status ?? this.status,
    inputVariablesJson: inputVariablesJson.present
        ? inputVariablesJson.value
        : this.inputVariablesJson,
    outputVariablesJson: outputVariablesJson.present
        ? outputVariablesJson.value
        : this.outputVariablesJson,
    nodeStatesJson: nodeStatesJson.present
        ? nodeStatesJson.value
        : this.nodeStatesJson,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    startTime: startTime.present ? startTime.value : this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    createdAt: createdAt ?? this.createdAt,
  );
  WorkflowExecutionRecord copyWithCompanion(WorkflowExecutionsCompanion data) {
    return WorkflowExecutionRecord(
      instanceId: data.instanceId.present
          ? data.instanceId.value
          : this.instanceId,
      workflowId: data.workflowId.present
          ? data.workflowId.value
          : this.workflowId,
      status: data.status.present ? data.status.value : this.status,
      inputVariablesJson: data.inputVariablesJson.present
          ? data.inputVariablesJson.value
          : this.inputVariablesJson,
      outputVariablesJson: data.outputVariablesJson.present
          ? data.outputVariablesJson.value
          : this.outputVariablesJson,
      nodeStatesJson: data.nodeStatesJson.present
          ? data.nodeStatesJson.value
          : this.nodeStatesJson,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkflowExecutionRecord(')
          ..write('instanceId: $instanceId, ')
          ..write('workflowId: $workflowId, ')
          ..write('status: $status, ')
          ..write('inputVariablesJson: $inputVariablesJson, ')
          ..write('outputVariablesJson: $outputVariablesJson, ')
          ..write('nodeStatesJson: $nodeStatesJson, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    instanceId,
    workflowId,
    status,
    inputVariablesJson,
    outputVariablesJson,
    nodeStatesJson,
    errorMessage,
    startTime,
    endTime,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkflowExecutionRecord &&
          other.instanceId == this.instanceId &&
          other.workflowId == this.workflowId &&
          other.status == this.status &&
          other.inputVariablesJson == this.inputVariablesJson &&
          other.outputVariablesJson == this.outputVariablesJson &&
          other.nodeStatesJson == this.nodeStatesJson &&
          other.errorMessage == this.errorMessage &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.createdAt == this.createdAt);
}

class WorkflowExecutionsCompanion
    extends UpdateCompanion<WorkflowExecutionRecord> {
  final Value<String> instanceId;
  final Value<String> workflowId;
  final Value<String> status;
  final Value<String?> inputVariablesJson;
  final Value<String?> outputVariablesJson;
  final Value<String?> nodeStatesJson;
  final Value<String?> errorMessage;
  final Value<DateTime?> startTime;
  final Value<DateTime?> endTime;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WorkflowExecutionsCompanion({
    this.instanceId = const Value.absent(),
    this.workflowId = const Value.absent(),
    this.status = const Value.absent(),
    this.inputVariablesJson = const Value.absent(),
    this.outputVariablesJson = const Value.absent(),
    this.nodeStatesJson = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkflowExecutionsCompanion.insert({
    required String instanceId,
    required String workflowId,
    required String status,
    this.inputVariablesJson = const Value.absent(),
    this.outputVariablesJson = const Value.absent(),
    this.nodeStatesJson = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : instanceId = Value(instanceId),
       workflowId = Value(workflowId),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<WorkflowExecutionRecord> custom({
    Expression<String>? instanceId,
    Expression<String>? workflowId,
    Expression<String>? status,
    Expression<String>? inputVariablesJson,
    Expression<String>? outputVariablesJson,
    Expression<String>? nodeStatesJson,
    Expression<String>? errorMessage,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instanceId != null) 'instance_id': instanceId,
      if (workflowId != null) 'workflow_id': workflowId,
      if (status != null) 'status': status,
      if (inputVariablesJson != null)
        'input_variables_json': inputVariablesJson,
      if (outputVariablesJson != null)
        'output_variables_json': outputVariablesJson,
      if (nodeStatesJson != null) 'node_states_json': nodeStatesJson,
      if (errorMessage != null) 'error_message': errorMessage,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkflowExecutionsCompanion copyWith({
    Value<String>? instanceId,
    Value<String>? workflowId,
    Value<String>? status,
    Value<String?>? inputVariablesJson,
    Value<String?>? outputVariablesJson,
    Value<String?>? nodeStatesJson,
    Value<String?>? errorMessage,
    Value<DateTime?>? startTime,
    Value<DateTime?>? endTime,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WorkflowExecutionsCompanion(
      instanceId: instanceId ?? this.instanceId,
      workflowId: workflowId ?? this.workflowId,
      status: status ?? this.status,
      inputVariablesJson: inputVariablesJson ?? this.inputVariablesJson,
      outputVariablesJson: outputVariablesJson ?? this.outputVariablesJson,
      nodeStatesJson: nodeStatesJson ?? this.nodeStatesJson,
      errorMessage: errorMessage ?? this.errorMessage,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instanceId.present) {
      map['instance_id'] = Variable<String>(instanceId.value);
    }
    if (workflowId.present) {
      map['workflow_id'] = Variable<String>(workflowId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (inputVariablesJson.present) {
      map['input_variables_json'] = Variable<String>(inputVariablesJson.value);
    }
    if (outputVariablesJson.present) {
      map['output_variables_json'] = Variable<String>(
        outputVariablesJson.value,
      );
    }
    if (nodeStatesJson.present) {
      map['node_states_json'] = Variable<String>(nodeStatesJson.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkflowExecutionsCompanion(')
          ..write('instanceId: $instanceId, ')
          ..write('workflowId: $workflowId, ')
          ..write('status: $status, ')
          ..write('inputVariablesJson: $inputVariablesJson, ')
          ..write('outputVariablesJson: $outputVariablesJson, ')
          ..write('nodeStatesJson: $nodeStatesJson, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkflowLogsTable extends WorkflowLogs
    with TableInfo<$WorkflowLogsTable, WorkflowLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkflowLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instanceIdMeta = const VerificationMeta(
    'instanceId',
  );
  @override
  late final GeneratedColumn<String> instanceId = GeneratedColumn<String>(
    'instance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<String> nodeId = GeneratedColumn<String>(
    'node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataJsonMeta = const VerificationMeta(
    'dataJson',
  );
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
    'data_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    instanceId,
    nodeId,
    level,
    message,
    dataJson,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workflow_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkflowLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('instance_id')) {
      context.handle(
        _instanceIdMeta,
        instanceId.isAcceptableOrUnknown(data['instance_id']!, _instanceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_instanceIdMeta);
    }
    if (data.containsKey('node_id')) {
      context.handle(
        _nodeIdMeta,
        nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeIdMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('data_json')) {
      context.handle(
        _dataJsonMeta,
        dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkflowLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkflowLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      instanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_id'],
      )!,
      nodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      dataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_json'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $WorkflowLogsTable createAlias(String alias) {
    return $WorkflowLogsTable(attachedDatabase, alias);
  }
}

class WorkflowLog extends DataClass implements Insertable<WorkflowLog> {
  final String id;
  final String instanceId;
  final String nodeId;
  final String level;
  final String message;
  final String? dataJson;
  final DateTime timestamp;
  const WorkflowLog({
    required this.id,
    required this.instanceId,
    required this.nodeId,
    required this.level,
    required this.message,
    this.dataJson,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['instance_id'] = Variable<String>(instanceId);
    map['node_id'] = Variable<String>(nodeId);
    map['level'] = Variable<String>(level);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || dataJson != null) {
      map['data_json'] = Variable<String>(dataJson);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  WorkflowLogsCompanion toCompanion(bool nullToAbsent) {
    return WorkflowLogsCompanion(
      id: Value(id),
      instanceId: Value(instanceId),
      nodeId: Value(nodeId),
      level: Value(level),
      message: Value(message),
      dataJson: dataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(dataJson),
      timestamp: Value(timestamp),
    );
  }

  factory WorkflowLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkflowLog(
      id: serializer.fromJson<String>(json['id']),
      instanceId: serializer.fromJson<String>(json['instanceId']),
      nodeId: serializer.fromJson<String>(json['nodeId']),
      level: serializer.fromJson<String>(json['level']),
      message: serializer.fromJson<String>(json['message']),
      dataJson: serializer.fromJson<String?>(json['dataJson']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'instanceId': serializer.toJson<String>(instanceId),
      'nodeId': serializer.toJson<String>(nodeId),
      'level': serializer.toJson<String>(level),
      'message': serializer.toJson<String>(message),
      'dataJson': serializer.toJson<String?>(dataJson),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  WorkflowLog copyWith({
    String? id,
    String? instanceId,
    String? nodeId,
    String? level,
    String? message,
    Value<String?> dataJson = const Value.absent(),
    DateTime? timestamp,
  }) => WorkflowLog(
    id: id ?? this.id,
    instanceId: instanceId ?? this.instanceId,
    nodeId: nodeId ?? this.nodeId,
    level: level ?? this.level,
    message: message ?? this.message,
    dataJson: dataJson.present ? dataJson.value : this.dataJson,
    timestamp: timestamp ?? this.timestamp,
  );
  WorkflowLog copyWithCompanion(WorkflowLogsCompanion data) {
    return WorkflowLog(
      id: data.id.present ? data.id.value : this.id,
      instanceId: data.instanceId.present
          ? data.instanceId.value
          : this.instanceId,
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      level: data.level.present ? data.level.value : this.level,
      message: data.message.present ? data.message.value : this.message,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkflowLog(')
          ..write('id: $id, ')
          ..write('instanceId: $instanceId, ')
          ..write('nodeId: $nodeId, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('dataJson: $dataJson, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, instanceId, nodeId, level, message, dataJson, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkflowLog &&
          other.id == this.id &&
          other.instanceId == this.instanceId &&
          other.nodeId == this.nodeId &&
          other.level == this.level &&
          other.message == this.message &&
          other.dataJson == this.dataJson &&
          other.timestamp == this.timestamp);
}

class WorkflowLogsCompanion extends UpdateCompanion<WorkflowLog> {
  final Value<String> id;
  final Value<String> instanceId;
  final Value<String> nodeId;
  final Value<String> level;
  final Value<String> message;
  final Value<String?> dataJson;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const WorkflowLogsCompanion({
    this.id = const Value.absent(),
    this.instanceId = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.level = const Value.absent(),
    this.message = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkflowLogsCompanion.insert({
    required String id,
    required String instanceId,
    required String nodeId,
    required String level,
    required String message,
    this.dataJson = const Value.absent(),
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       instanceId = Value(instanceId),
       nodeId = Value(nodeId),
       level = Value(level),
       message = Value(message),
       timestamp = Value(timestamp);
  static Insertable<WorkflowLog> custom({
    Expression<String>? id,
    Expression<String>? instanceId,
    Expression<String>? nodeId,
    Expression<String>? level,
    Expression<String>? message,
    Expression<String>? dataJson,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (instanceId != null) 'instance_id': instanceId,
      if (nodeId != null) 'node_id': nodeId,
      if (level != null) 'level': level,
      if (message != null) 'message': message,
      if (dataJson != null) 'data_json': dataJson,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkflowLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? instanceId,
    Value<String>? nodeId,
    Value<String>? level,
    Value<String>? message,
    Value<String?>? dataJson,
    Value<DateTime>? timestamp,
    Value<int>? rowid,
  }) {
    return WorkflowLogsCompanion(
      id: id ?? this.id,
      instanceId: instanceId ?? this.instanceId,
      nodeId: nodeId ?? this.nodeId,
      level: level ?? this.level,
      message: message ?? this.message,
      dataJson: dataJson ?? this.dataJson,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (instanceId.present) {
      map['instance_id'] = Variable<String>(instanceId.value);
    }
    if (nodeId.present) {
      map['node_id'] = Variable<String>(nodeId.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkflowLogsCompanion(')
          ..write('id: $id, ')
          ..write('instanceId: $instanceId, ')
          ..write('nodeId: $nodeId, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('dataJson: $dataJson, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('📁'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#6750A4'),
  );
  static const VerificationMeta _systemPromptMeta = const VerificationMeta(
    'systemPrompt',
  );
  @override
  late final GeneratedColumn<String> systemPrompt = GeneratedColumn<String>(
    'system_prompt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _knowledgeBaseIdMeta = const VerificationMeta(
    'knowledgeBaseId',
  );
  @override
  late final GeneratedColumn<String> knowledgeBaseId = GeneratedColumn<String>(
    'knowledge_base_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mcpServersMeta = const VerificationMeta(
    'mcpServers',
  );
  @override
  late final GeneratedColumn<String> mcpServers = GeneratedColumn<String>(
    'mcp_servers',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultModelConfigIdMeta =
      const VerificationMeta('defaultModelConfigId');
  @override
  late final GeneratedColumn<String> defaultModelConfigId =
      GeneratedColumn<String>(
        'default_model_config_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.7),
  );
  static const VerificationMeta _maxContextMessagesMeta =
      const VerificationMeta('maxContextMessages');
  @override
  late final GeneratedColumn<int> maxContextMessages = GeneratedColumn<int>(
    'max_context_messages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    icon,
    color,
    systemPrompt,
    knowledgeBaseId,
    mcpServers,
    defaultModelConfigId,
    temperature,
    maxContextMessages,
    sortOrder,
    isArchived,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('system_prompt')) {
      context.handle(
        _systemPromptMeta,
        systemPrompt.isAcceptableOrUnknown(
          data['system_prompt']!,
          _systemPromptMeta,
        ),
      );
    }
    if (data.containsKey('knowledge_base_id')) {
      context.handle(
        _knowledgeBaseIdMeta,
        knowledgeBaseId.isAcceptableOrUnknown(
          data['knowledge_base_id']!,
          _knowledgeBaseIdMeta,
        ),
      );
    }
    if (data.containsKey('mcp_servers')) {
      context.handle(
        _mcpServersMeta,
        mcpServers.isAcceptableOrUnknown(data['mcp_servers']!, _mcpServersMeta),
      );
    }
    if (data.containsKey('default_model_config_id')) {
      context.handle(
        _defaultModelConfigIdMeta,
        defaultModelConfigId.isAcceptableOrUnknown(
          data['default_model_config_id']!,
          _defaultModelConfigIdMeta,
        ),
      );
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    }
    if (data.containsKey('max_context_messages')) {
      context.handle(
        _maxContextMessagesMeta,
        maxContextMessages.isAcceptableOrUnknown(
          data['max_context_messages']!,
          _maxContextMessagesMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      systemPrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_prompt'],
      ),
      knowledgeBaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}knowledge_base_id'],
      ),
      mcpServers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mcp_servers'],
      ),
      defaultModelConfigId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_model_config_id'],
      ),
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature'],
      )!,
      maxContextMessages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_context_messages'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final String color;
  final String? systemPrompt;
  final String? knowledgeBaseId;
  final String? mcpServers;
  final String? defaultModelConfigId;
  final double temperature;
  final int maxContextMessages;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    this.systemPrompt,
    this.knowledgeBaseId,
    this.mcpServers,
    this.defaultModelConfigId,
    required this.temperature,
    required this.maxContextMessages,
    required this.sortOrder,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || systemPrompt != null) {
      map['system_prompt'] = Variable<String>(systemPrompt);
    }
    if (!nullToAbsent || knowledgeBaseId != null) {
      map['knowledge_base_id'] = Variable<String>(knowledgeBaseId);
    }
    if (!nullToAbsent || mcpServers != null) {
      map['mcp_servers'] = Variable<String>(mcpServers);
    }
    if (!nullToAbsent || defaultModelConfigId != null) {
      map['default_model_config_id'] = Variable<String>(defaultModelConfigId);
    }
    map['temperature'] = Variable<double>(temperature);
    map['max_context_messages'] = Variable<int>(maxContextMessages);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      icon: Value(icon),
      color: Value(color),
      systemPrompt: systemPrompt == null && nullToAbsent
          ? const Value.absent()
          : Value(systemPrompt),
      knowledgeBaseId: knowledgeBaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(knowledgeBaseId),
      mcpServers: mcpServers == null && nullToAbsent
          ? const Value.absent()
          : Value(mcpServers),
      defaultModelConfigId: defaultModelConfigId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultModelConfigId),
      temperature: Value(temperature),
      maxContextMessages: Value(maxContextMessages),
      sortOrder: Value(sortOrder),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      systemPrompt: serializer.fromJson<String?>(json['systemPrompt']),
      knowledgeBaseId: serializer.fromJson<String?>(json['knowledgeBaseId']),
      mcpServers: serializer.fromJson<String?>(json['mcpServers']),
      defaultModelConfigId: serializer.fromJson<String?>(
        json['defaultModelConfigId'],
      ),
      temperature: serializer.fromJson<double>(json['temperature']),
      maxContextMessages: serializer.fromJson<int>(json['maxContextMessages']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'systemPrompt': serializer.toJson<String?>(systemPrompt),
      'knowledgeBaseId': serializer.toJson<String?>(knowledgeBaseId),
      'mcpServers': serializer.toJson<String?>(mcpServers),
      'defaultModelConfigId': serializer.toJson<String?>(defaultModelConfigId),
      'temperature': serializer.toJson<double>(temperature),
      'maxContextMessages': serializer.toJson<int>(maxContextMessages),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Project copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? icon,
    String? color,
    Value<String?> systemPrompt = const Value.absent(),
    Value<String?> knowledgeBaseId = const Value.absent(),
    Value<String?> mcpServers = const Value.absent(),
    Value<String?> defaultModelConfigId = const Value.absent(),
    double? temperature,
    int? maxContextMessages,
    int? sortOrder,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    systemPrompt: systemPrompt.present ? systemPrompt.value : this.systemPrompt,
    knowledgeBaseId: knowledgeBaseId.present
        ? knowledgeBaseId.value
        : this.knowledgeBaseId,
    mcpServers: mcpServers.present ? mcpServers.value : this.mcpServers,
    defaultModelConfigId: defaultModelConfigId.present
        ? defaultModelConfigId.value
        : this.defaultModelConfigId,
    temperature: temperature ?? this.temperature,
    maxContextMessages: maxContextMessages ?? this.maxContextMessages,
    sortOrder: sortOrder ?? this.sortOrder,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      systemPrompt: data.systemPrompt.present
          ? data.systemPrompt.value
          : this.systemPrompt,
      knowledgeBaseId: data.knowledgeBaseId.present
          ? data.knowledgeBaseId.value
          : this.knowledgeBaseId,
      mcpServers: data.mcpServers.present
          ? data.mcpServers.value
          : this.mcpServers,
      defaultModelConfigId: data.defaultModelConfigId.present
          ? data.defaultModelConfigId.value
          : this.defaultModelConfigId,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      maxContextMessages: data.maxContextMessages.present
          ? data.maxContextMessages.value
          : this.maxContextMessages,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('knowledgeBaseId: $knowledgeBaseId, ')
          ..write('mcpServers: $mcpServers, ')
          ..write('defaultModelConfigId: $defaultModelConfigId, ')
          ..write('temperature: $temperature, ')
          ..write('maxContextMessages: $maxContextMessages, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    icon,
    color,
    systemPrompt,
    knowledgeBaseId,
    mcpServers,
    defaultModelConfigId,
    temperature,
    maxContextMessages,
    sortOrder,
    isArchived,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.systemPrompt == this.systemPrompt &&
          other.knowledgeBaseId == this.knowledgeBaseId &&
          other.mcpServers == this.mcpServers &&
          other.defaultModelConfigId == this.defaultModelConfigId &&
          other.temperature == this.temperature &&
          other.maxContextMessages == this.maxContextMessages &&
          other.sortOrder == this.sortOrder &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> icon;
  final Value<String> color;
  final Value<String?> systemPrompt;
  final Value<String?> knowledgeBaseId;
  final Value<String?> mcpServers;
  final Value<String?> defaultModelConfigId;
  final Value<double> temperature;
  final Value<int> maxContextMessages;
  final Value<int> sortOrder;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.knowledgeBaseId = const Value.absent(),
    this.mcpServers = const Value.absent(),
    this.defaultModelConfigId = const Value.absent(),
    this.temperature = const Value.absent(),
    this.maxContextMessages = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.knowledgeBaseId = const Value.absent(),
    this.mcpServers = const Value.absent(),
    this.defaultModelConfigId = const Value.absent(),
    this.temperature = const Value.absent(),
    this.maxContextMessages = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<String>? systemPrompt,
    Expression<String>? knowledgeBaseId,
    Expression<String>? mcpServers,
    Expression<String>? defaultModelConfigId,
    Expression<double>? temperature,
    Expression<int>? maxContextMessages,
    Expression<int>? sortOrder,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
      if (knowledgeBaseId != null) 'knowledge_base_id': knowledgeBaseId,
      if (mcpServers != null) 'mcp_servers': mcpServers,
      if (defaultModelConfigId != null)
        'default_model_config_id': defaultModelConfigId,
      if (temperature != null) 'temperature': temperature,
      if (maxContextMessages != null)
        'max_context_messages': maxContextMessages,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? icon,
    Value<String>? color,
    Value<String?>? systemPrompt,
    Value<String?>? knowledgeBaseId,
    Value<String?>? mcpServers,
    Value<String?>? defaultModelConfigId,
    Value<double>? temperature,
    Value<int>? maxContextMessages,
    Value<int>? sortOrder,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      mcpServers: mcpServers ?? this.mcpServers,
      defaultModelConfigId: defaultModelConfigId ?? this.defaultModelConfigId,
      temperature: temperature ?? this.temperature,
      maxContextMessages: maxContextMessages ?? this.maxContextMessages,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (systemPrompt.present) {
      map['system_prompt'] = Variable<String>(systemPrompt.value);
    }
    if (knowledgeBaseId.present) {
      map['knowledge_base_id'] = Variable<String>(knowledgeBaseId.value);
    }
    if (mcpServers.present) {
      map['mcp_servers'] = Variable<String>(mcpServers.value);
    }
    if (defaultModelConfigId.present) {
      map['default_model_config_id'] = Variable<String>(
        defaultModelConfigId.value,
      );
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (maxContextMessages.present) {
      map['max_context_messages'] = Variable<int>(maxContextMessages.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('knowledgeBaseId: $knowledgeBaseId, ')
          ..write('mcpServers: $mcpServers, ')
          ..write('defaultModelConfigId: $defaultModelConfigId, ')
          ..write('temperature: $temperature, ')
          ..write('maxContextMessages: $maxContextMessages, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResearchReportsTable extends ResearchReports
    with TableInfo<$ResearchReportsTable, ResearchReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResearchReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _totalStepsMeta = const VerificationMeta(
    'totalSteps',
  );
  @override
  late final GeneratedColumn<int> totalSteps = GeneratedColumn<int>(
    'total_steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedStepsMeta = const VerificationMeta(
    'completedSteps',
  );
  @override
  late final GeneratedColumn<int> completedSteps = GeneratedColumn<int>(
    'completed_steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalTokensMeta = const VerificationMeta(
    'totalTokens',
  );
  @override
  late final GeneratedColumn<int> totalTokens = GeneratedColumn<int>(
    'total_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _inputTokensMeta = const VerificationMeta(
    'inputTokens',
  );
  @override
  late final GeneratedColumn<int> inputTokens = GeneratedColumn<int>(
    'input_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _outputTokensMeta = const VerificationMeta(
    'outputTokens',
  );
  @override
  late final GeneratedColumn<int> outputTokens = GeneratedColumn<int>(
    'output_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _thinkingTokensMeta = const VerificationMeta(
    'thinkingTokens',
  );
  @override
  late final GeneratedColumn<int> thinkingTokens = GeneratedColumn<int>(
    'thinking_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _modelConfigIdMeta = const VerificationMeta(
    'modelConfigId',
  );
  @override
  late final GeneratedColumn<String> modelConfigId = GeneratedColumn<String>(
    'model_config_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledSourcesMeta = const VerificationMeta(
    'enabledSources',
  );
  @override
  late final GeneratedColumn<String> enabledSources = GeneratedColumn<String>(
    'enabled_sources',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    query,
    title,
    summary,
    status,
    totalSteps,
    completedSteps,
    totalTokens,
    inputTokens,
    outputTokens,
    thinkingTokens,
    modelConfigId,
    enabledSources,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'research_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResearchReport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('total_steps')) {
      context.handle(
        _totalStepsMeta,
        totalSteps.isAcceptableOrUnknown(data['total_steps']!, _totalStepsMeta),
      );
    }
    if (data.containsKey('completed_steps')) {
      context.handle(
        _completedStepsMeta,
        completedSteps.isAcceptableOrUnknown(
          data['completed_steps']!,
          _completedStepsMeta,
        ),
      );
    }
    if (data.containsKey('total_tokens')) {
      context.handle(
        _totalTokensMeta,
        totalTokens.isAcceptableOrUnknown(
          data['total_tokens']!,
          _totalTokensMeta,
        ),
      );
    }
    if (data.containsKey('input_tokens')) {
      context.handle(
        _inputTokensMeta,
        inputTokens.isAcceptableOrUnknown(
          data['input_tokens']!,
          _inputTokensMeta,
        ),
      );
    }
    if (data.containsKey('output_tokens')) {
      context.handle(
        _outputTokensMeta,
        outputTokens.isAcceptableOrUnknown(
          data['output_tokens']!,
          _outputTokensMeta,
        ),
      );
    }
    if (data.containsKey('thinking_tokens')) {
      context.handle(
        _thinkingTokensMeta,
        thinkingTokens.isAcceptableOrUnknown(
          data['thinking_tokens']!,
          _thinkingTokensMeta,
        ),
      );
    }
    if (data.containsKey('model_config_id')) {
      context.handle(
        _modelConfigIdMeta,
        modelConfigId.isAcceptableOrUnknown(
          data['model_config_id']!,
          _modelConfigIdMeta,
        ),
      );
    }
    if (data.containsKey('enabled_sources')) {
      context.handle(
        _enabledSourcesMeta,
        enabledSources.isAcceptableOrUnknown(
          data['enabled_sources']!,
          _enabledSourcesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResearchReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResearchReport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      totalSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_steps'],
      )!,
      completedSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_steps'],
      )!,
      totalTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_tokens'],
      )!,
      inputTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}input_tokens'],
      )!,
      outputTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}output_tokens'],
      )!,
      thinkingTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}thinking_tokens'],
      )!,
      modelConfigId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_config_id'],
      ),
      enabledSources: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enabled_sources'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $ResearchReportsTable createAlias(String alias) {
    return $ResearchReportsTable(attachedDatabase, alias);
  }
}

class ResearchReport extends DataClass implements Insertable<ResearchReport> {
  final String id;
  final String? sessionId;
  final String query;
  final String title;
  final String? summary;
  final String status;
  final int totalSteps;
  final int completedSteps;
  final int totalTokens;
  final int inputTokens;
  final int outputTokens;
  final int thinkingTokens;
  final String? modelConfigId;
  final String? enabledSources;
  final DateTime createdAt;
  final DateTime? completedAt;
  const ResearchReport({
    required this.id,
    this.sessionId,
    required this.query,
    required this.title,
    this.summary,
    required this.status,
    required this.totalSteps,
    required this.completedSteps,
    required this.totalTokens,
    required this.inputTokens,
    required this.outputTokens,
    required this.thinkingTokens,
    this.modelConfigId,
    this.enabledSources,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['query'] = Variable<String>(query);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    map['status'] = Variable<String>(status);
    map['total_steps'] = Variable<int>(totalSteps);
    map['completed_steps'] = Variable<int>(completedSteps);
    map['total_tokens'] = Variable<int>(totalTokens);
    map['input_tokens'] = Variable<int>(inputTokens);
    map['output_tokens'] = Variable<int>(outputTokens);
    map['thinking_tokens'] = Variable<int>(thinkingTokens);
    if (!nullToAbsent || modelConfigId != null) {
      map['model_config_id'] = Variable<String>(modelConfigId);
    }
    if (!nullToAbsent || enabledSources != null) {
      map['enabled_sources'] = Variable<String>(enabledSources);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  ResearchReportsCompanion toCompanion(bool nullToAbsent) {
    return ResearchReportsCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      query: Value(query),
      title: Value(title),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      status: Value(status),
      totalSteps: Value(totalSteps),
      completedSteps: Value(completedSteps),
      totalTokens: Value(totalTokens),
      inputTokens: Value(inputTokens),
      outputTokens: Value(outputTokens),
      thinkingTokens: Value(thinkingTokens),
      modelConfigId: modelConfigId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelConfigId),
      enabledSources: enabledSources == null && nullToAbsent
          ? const Value.absent()
          : Value(enabledSources),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory ResearchReport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResearchReport(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      query: serializer.fromJson<String>(json['query']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String?>(json['summary']),
      status: serializer.fromJson<String>(json['status']),
      totalSteps: serializer.fromJson<int>(json['totalSteps']),
      completedSteps: serializer.fromJson<int>(json['completedSteps']),
      totalTokens: serializer.fromJson<int>(json['totalTokens']),
      inputTokens: serializer.fromJson<int>(json['inputTokens']),
      outputTokens: serializer.fromJson<int>(json['outputTokens']),
      thinkingTokens: serializer.fromJson<int>(json['thinkingTokens']),
      modelConfigId: serializer.fromJson<String?>(json['modelConfigId']),
      enabledSources: serializer.fromJson<String?>(json['enabledSources']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String?>(sessionId),
      'query': serializer.toJson<String>(query),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String?>(summary),
      'status': serializer.toJson<String>(status),
      'totalSteps': serializer.toJson<int>(totalSteps),
      'completedSteps': serializer.toJson<int>(completedSteps),
      'totalTokens': serializer.toJson<int>(totalTokens),
      'inputTokens': serializer.toJson<int>(inputTokens),
      'outputTokens': serializer.toJson<int>(outputTokens),
      'thinkingTokens': serializer.toJson<int>(thinkingTokens),
      'modelConfigId': serializer.toJson<String?>(modelConfigId),
      'enabledSources': serializer.toJson<String?>(enabledSources),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  ResearchReport copyWith({
    String? id,
    Value<String?> sessionId = const Value.absent(),
    String? query,
    String? title,
    Value<String?> summary = const Value.absent(),
    String? status,
    int? totalSteps,
    int? completedSteps,
    int? totalTokens,
    int? inputTokens,
    int? outputTokens,
    int? thinkingTokens,
    Value<String?> modelConfigId = const Value.absent(),
    Value<String?> enabledSources = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => ResearchReport(
    id: id ?? this.id,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    query: query ?? this.query,
    title: title ?? this.title,
    summary: summary.present ? summary.value : this.summary,
    status: status ?? this.status,
    totalSteps: totalSteps ?? this.totalSteps,
    completedSteps: completedSteps ?? this.completedSteps,
    totalTokens: totalTokens ?? this.totalTokens,
    inputTokens: inputTokens ?? this.inputTokens,
    outputTokens: outputTokens ?? this.outputTokens,
    thinkingTokens: thinkingTokens ?? this.thinkingTokens,
    modelConfigId: modelConfigId.present
        ? modelConfigId.value
        : this.modelConfigId,
    enabledSources: enabledSources.present
        ? enabledSources.value
        : this.enabledSources,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  ResearchReport copyWithCompanion(ResearchReportsCompanion data) {
    return ResearchReport(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      query: data.query.present ? data.query.value : this.query,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      status: data.status.present ? data.status.value : this.status,
      totalSteps: data.totalSteps.present
          ? data.totalSteps.value
          : this.totalSteps,
      completedSteps: data.completedSteps.present
          ? data.completedSteps.value
          : this.completedSteps,
      totalTokens: data.totalTokens.present
          ? data.totalTokens.value
          : this.totalTokens,
      inputTokens: data.inputTokens.present
          ? data.inputTokens.value
          : this.inputTokens,
      outputTokens: data.outputTokens.present
          ? data.outputTokens.value
          : this.outputTokens,
      thinkingTokens: data.thinkingTokens.present
          ? data.thinkingTokens.value
          : this.thinkingTokens,
      modelConfigId: data.modelConfigId.present
          ? data.modelConfigId.value
          : this.modelConfigId,
      enabledSources: data.enabledSources.present
          ? data.enabledSources.value
          : this.enabledSources,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResearchReport(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('query: $query, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('status: $status, ')
          ..write('totalSteps: $totalSteps, ')
          ..write('completedSteps: $completedSteps, ')
          ..write('totalTokens: $totalTokens, ')
          ..write('inputTokens: $inputTokens, ')
          ..write('outputTokens: $outputTokens, ')
          ..write('thinkingTokens: $thinkingTokens, ')
          ..write('modelConfigId: $modelConfigId, ')
          ..write('enabledSources: $enabledSources, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    query,
    title,
    summary,
    status,
    totalSteps,
    completedSteps,
    totalTokens,
    inputTokens,
    outputTokens,
    thinkingTokens,
    modelConfigId,
    enabledSources,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResearchReport &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.query == this.query &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.status == this.status &&
          other.totalSteps == this.totalSteps &&
          other.completedSteps == this.completedSteps &&
          other.totalTokens == this.totalTokens &&
          other.inputTokens == this.inputTokens &&
          other.outputTokens == this.outputTokens &&
          other.thinkingTokens == this.thinkingTokens &&
          other.modelConfigId == this.modelConfigId &&
          other.enabledSources == this.enabledSources &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class ResearchReportsCompanion extends UpdateCompanion<ResearchReport> {
  final Value<String> id;
  final Value<String?> sessionId;
  final Value<String> query;
  final Value<String> title;
  final Value<String?> summary;
  final Value<String> status;
  final Value<int> totalSteps;
  final Value<int> completedSteps;
  final Value<int> totalTokens;
  final Value<int> inputTokens;
  final Value<int> outputTokens;
  final Value<int> thinkingTokens;
  final Value<String?> modelConfigId;
  final Value<String?> enabledSources;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const ResearchReportsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.query = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.status = const Value.absent(),
    this.totalSteps = const Value.absent(),
    this.completedSteps = const Value.absent(),
    this.totalTokens = const Value.absent(),
    this.inputTokens = const Value.absent(),
    this.outputTokens = const Value.absent(),
    this.thinkingTokens = const Value.absent(),
    this.modelConfigId = const Value.absent(),
    this.enabledSources = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResearchReportsCompanion.insert({
    required String id,
    this.sessionId = const Value.absent(),
    required String query,
    required String title,
    this.summary = const Value.absent(),
    this.status = const Value.absent(),
    this.totalSteps = const Value.absent(),
    this.completedSteps = const Value.absent(),
    this.totalTokens = const Value.absent(),
    this.inputTokens = const Value.absent(),
    this.outputTokens = const Value.absent(),
    this.thinkingTokens = const Value.absent(),
    this.modelConfigId = const Value.absent(),
    this.enabledSources = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       query = Value(query),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<ResearchReport> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? query,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<String>? status,
    Expression<int>? totalSteps,
    Expression<int>? completedSteps,
    Expression<int>? totalTokens,
    Expression<int>? inputTokens,
    Expression<int>? outputTokens,
    Expression<int>? thinkingTokens,
    Expression<String>? modelConfigId,
    Expression<String>? enabledSources,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (query != null) 'query': query,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (status != null) 'status': status,
      if (totalSteps != null) 'total_steps': totalSteps,
      if (completedSteps != null) 'completed_steps': completedSteps,
      if (totalTokens != null) 'total_tokens': totalTokens,
      if (inputTokens != null) 'input_tokens': inputTokens,
      if (outputTokens != null) 'output_tokens': outputTokens,
      if (thinkingTokens != null) 'thinking_tokens': thinkingTokens,
      if (modelConfigId != null) 'model_config_id': modelConfigId,
      if (enabledSources != null) 'enabled_sources': enabledSources,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResearchReportsCompanion copyWith({
    Value<String>? id,
    Value<String?>? sessionId,
    Value<String>? query,
    Value<String>? title,
    Value<String?>? summary,
    Value<String>? status,
    Value<int>? totalSteps,
    Value<int>? completedSteps,
    Value<int>? totalTokens,
    Value<int>? inputTokens,
    Value<int>? outputTokens,
    Value<int>? thinkingTokens,
    Value<String?>? modelConfigId,
    Value<String?>? enabledSources,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return ResearchReportsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      query: query ?? this.query,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      totalSteps: totalSteps ?? this.totalSteps,
      completedSteps: completedSteps ?? this.completedSteps,
      totalTokens: totalTokens ?? this.totalTokens,
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      thinkingTokens: thinkingTokens ?? this.thinkingTokens,
      modelConfigId: modelConfigId ?? this.modelConfigId,
      enabledSources: enabledSources ?? this.enabledSources,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalSteps.present) {
      map['total_steps'] = Variable<int>(totalSteps.value);
    }
    if (completedSteps.present) {
      map['completed_steps'] = Variable<int>(completedSteps.value);
    }
    if (totalTokens.present) {
      map['total_tokens'] = Variable<int>(totalTokens.value);
    }
    if (inputTokens.present) {
      map['input_tokens'] = Variable<int>(inputTokens.value);
    }
    if (outputTokens.present) {
      map['output_tokens'] = Variable<int>(outputTokens.value);
    }
    if (thinkingTokens.present) {
      map['thinking_tokens'] = Variable<int>(thinkingTokens.value);
    }
    if (modelConfigId.present) {
      map['model_config_id'] = Variable<String>(modelConfigId.value);
    }
    if (enabledSources.present) {
      map['enabled_sources'] = Variable<String>(enabledSources.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResearchReportsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('query: $query, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('status: $status, ')
          ..write('totalSteps: $totalSteps, ')
          ..write('completedSteps: $completedSteps, ')
          ..write('totalTokens: $totalTokens, ')
          ..write('inputTokens: $inputTokens, ')
          ..write('outputTokens: $outputTokens, ')
          ..write('thinkingTokens: $thinkingTokens, ')
          ..write('modelConfigId: $modelConfigId, ')
          ..write('enabledSources: $enabledSources, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResearchStepsTable extends ResearchSteps
    with TableInfo<$ResearchStepsTable, ResearchStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResearchStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reportIdMeta = const VerificationMeta(
    'reportId',
  );
  @override
  late final GeneratedColumn<String> reportId = GeneratedColumn<String>(
    'report_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepIndexMeta = const VerificationMeta(
    'stepIndex',
  );
  @override
  late final GeneratedColumn<int> stepIndex = GeneratedColumn<int>(
    'step_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _searchQueryMeta = const VerificationMeta(
    'searchQuery',
  );
  @override
  late final GeneratedColumn<String> searchQuery = GeneratedColumn<String>(
    'search_query',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inputDataMeta = const VerificationMeta(
    'inputData',
  );
  @override
  late final GeneratedColumn<String> inputData = GeneratedColumn<String>(
    'input_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outputDataMeta = const VerificationMeta(
    'outputData',
  );
  @override
  late final GeneratedColumn<String> outputData = GeneratedColumn<String>(
    'output_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _tokensUsedMeta = const VerificationMeta(
    'tokensUsed',
  );
  @override
  late final GeneratedColumn<int> tokensUsed = GeneratedColumn<int>(
    'tokens_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reportId,
    stepIndex,
    type,
    title,
    description,
    searchQuery,
    inputData,
    outputData,
    status,
    tokensUsed,
    durationMs,
    errorMessage,
    startedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'research_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResearchStep> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('report_id')) {
      context.handle(
        _reportIdMeta,
        reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reportIdMeta);
    }
    if (data.containsKey('step_index')) {
      context.handle(
        _stepIndexMeta,
        stepIndex.isAcceptableOrUnknown(data['step_index']!, _stepIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_stepIndexMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('search_query')) {
      context.handle(
        _searchQueryMeta,
        searchQuery.isAcceptableOrUnknown(
          data['search_query']!,
          _searchQueryMeta,
        ),
      );
    }
    if (data.containsKey('input_data')) {
      context.handle(
        _inputDataMeta,
        inputData.isAcceptableOrUnknown(data['input_data']!, _inputDataMeta),
      );
    }
    if (data.containsKey('output_data')) {
      context.handle(
        _outputDataMeta,
        outputData.isAcceptableOrUnknown(data['output_data']!, _outputDataMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('tokens_used')) {
      context.handle(
        _tokensUsedMeta,
        tokensUsed.isAcceptableOrUnknown(data['tokens_used']!, _tokensUsedMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResearchStep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResearchStep(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      reportId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_id'],
      )!,
      stepIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_index'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      searchQuery: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_query'],
      ),
      inputData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_data'],
      ),
      outputData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output_data'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      tokensUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tokens_used'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $ResearchStepsTable createAlias(String alias) {
    return $ResearchStepsTable(attachedDatabase, alias);
  }
}

class ResearchStep extends DataClass implements Insertable<ResearchStep> {
  final String id;
  final String reportId;
  final int stepIndex;
  final String type;
  final String title;
  final String? description;
  final String? searchQuery;
  final String? inputData;
  final String? outputData;
  final String status;
  final int tokensUsed;
  final int? durationMs;
  final String? errorMessage;
  final DateTime? startedAt;
  final DateTime? completedAt;
  const ResearchStep({
    required this.id,
    required this.reportId,
    required this.stepIndex,
    required this.type,
    required this.title,
    this.description,
    this.searchQuery,
    this.inputData,
    this.outputData,
    required this.status,
    required this.tokensUsed,
    this.durationMs,
    this.errorMessage,
    this.startedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['report_id'] = Variable<String>(reportId);
    map['step_index'] = Variable<int>(stepIndex);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || searchQuery != null) {
      map['search_query'] = Variable<String>(searchQuery);
    }
    if (!nullToAbsent || inputData != null) {
      map['input_data'] = Variable<String>(inputData);
    }
    if (!nullToAbsent || outputData != null) {
      map['output_data'] = Variable<String>(outputData);
    }
    map['status'] = Variable<String>(status);
    map['tokens_used'] = Variable<int>(tokensUsed);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  ResearchStepsCompanion toCompanion(bool nullToAbsent) {
    return ResearchStepsCompanion(
      id: Value(id),
      reportId: Value(reportId),
      stepIndex: Value(stepIndex),
      type: Value(type),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      searchQuery: searchQuery == null && nullToAbsent
          ? const Value.absent()
          : Value(searchQuery),
      inputData: inputData == null && nullToAbsent
          ? const Value.absent()
          : Value(inputData),
      outputData: outputData == null && nullToAbsent
          ? const Value.absent()
          : Value(outputData),
      status: Value(status),
      tokensUsed: Value(tokensUsed),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory ResearchStep.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResearchStep(
      id: serializer.fromJson<String>(json['id']),
      reportId: serializer.fromJson<String>(json['reportId']),
      stepIndex: serializer.fromJson<int>(json['stepIndex']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      searchQuery: serializer.fromJson<String?>(json['searchQuery']),
      inputData: serializer.fromJson<String?>(json['inputData']),
      outputData: serializer.fromJson<String?>(json['outputData']),
      status: serializer.fromJson<String>(json['status']),
      tokensUsed: serializer.fromJson<int>(json['tokensUsed']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'reportId': serializer.toJson<String>(reportId),
      'stepIndex': serializer.toJson<int>(stepIndex),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'searchQuery': serializer.toJson<String?>(searchQuery),
      'inputData': serializer.toJson<String?>(inputData),
      'outputData': serializer.toJson<String?>(outputData),
      'status': serializer.toJson<String>(status),
      'tokensUsed': serializer.toJson<int>(tokensUsed),
      'durationMs': serializer.toJson<int?>(durationMs),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  ResearchStep copyWith({
    String? id,
    String? reportId,
    int? stepIndex,
    String? type,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> searchQuery = const Value.absent(),
    Value<String?> inputData = const Value.absent(),
    Value<String?> outputData = const Value.absent(),
    String? status,
    int? tokensUsed,
    Value<int?> durationMs = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
  }) => ResearchStep(
    id: id ?? this.id,
    reportId: reportId ?? this.reportId,
    stepIndex: stepIndex ?? this.stepIndex,
    type: type ?? this.type,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    searchQuery: searchQuery.present ? searchQuery.value : this.searchQuery,
    inputData: inputData.present ? inputData.value : this.inputData,
    outputData: outputData.present ? outputData.value : this.outputData,
    status: status ?? this.status,
    tokensUsed: tokensUsed ?? this.tokensUsed,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  ResearchStep copyWithCompanion(ResearchStepsCompanion data) {
    return ResearchStep(
      id: data.id.present ? data.id.value : this.id,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      stepIndex: data.stepIndex.present ? data.stepIndex.value : this.stepIndex,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      searchQuery: data.searchQuery.present
          ? data.searchQuery.value
          : this.searchQuery,
      inputData: data.inputData.present ? data.inputData.value : this.inputData,
      outputData: data.outputData.present
          ? data.outputData.value
          : this.outputData,
      status: data.status.present ? data.status.value : this.status,
      tokensUsed: data.tokensUsed.present
          ? data.tokensUsed.value
          : this.tokensUsed,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResearchStep(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('stepIndex: $stepIndex, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('searchQuery: $searchQuery, ')
          ..write('inputData: $inputData, ')
          ..write('outputData: $outputData, ')
          ..write('status: $status, ')
          ..write('tokensUsed: $tokensUsed, ')
          ..write('durationMs: $durationMs, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    reportId,
    stepIndex,
    type,
    title,
    description,
    searchQuery,
    inputData,
    outputData,
    status,
    tokensUsed,
    durationMs,
    errorMessage,
    startedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResearchStep &&
          other.id == this.id &&
          other.reportId == this.reportId &&
          other.stepIndex == this.stepIndex &&
          other.type == this.type &&
          other.title == this.title &&
          other.description == this.description &&
          other.searchQuery == this.searchQuery &&
          other.inputData == this.inputData &&
          other.outputData == this.outputData &&
          other.status == this.status &&
          other.tokensUsed == this.tokensUsed &&
          other.durationMs == this.durationMs &&
          other.errorMessage == this.errorMessage &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class ResearchStepsCompanion extends UpdateCompanion<ResearchStep> {
  final Value<String> id;
  final Value<String> reportId;
  final Value<int> stepIndex;
  final Value<String> type;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> searchQuery;
  final Value<String?> inputData;
  final Value<String?> outputData;
  final Value<String> status;
  final Value<int> tokensUsed;
  final Value<int?> durationMs;
  final Value<String?> errorMessage;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const ResearchStepsCompanion({
    this.id = const Value.absent(),
    this.reportId = const Value.absent(),
    this.stepIndex = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.searchQuery = const Value.absent(),
    this.inputData = const Value.absent(),
    this.outputData = const Value.absent(),
    this.status = const Value.absent(),
    this.tokensUsed = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResearchStepsCompanion.insert({
    required String id,
    required String reportId,
    required int stepIndex,
    required String type,
    required String title,
    this.description = const Value.absent(),
    this.searchQuery = const Value.absent(),
    this.inputData = const Value.absent(),
    this.outputData = const Value.absent(),
    this.status = const Value.absent(),
    this.tokensUsed = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       reportId = Value(reportId),
       stepIndex = Value(stepIndex),
       type = Value(type),
       title = Value(title);
  static Insertable<ResearchStep> custom({
    Expression<String>? id,
    Expression<String>? reportId,
    Expression<int>? stepIndex,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? searchQuery,
    Expression<String>? inputData,
    Expression<String>? outputData,
    Expression<String>? status,
    Expression<int>? tokensUsed,
    Expression<int>? durationMs,
    Expression<String>? errorMessage,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reportId != null) 'report_id': reportId,
      if (stepIndex != null) 'step_index': stepIndex,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (searchQuery != null) 'search_query': searchQuery,
      if (inputData != null) 'input_data': inputData,
      if (outputData != null) 'output_data': outputData,
      if (status != null) 'status': status,
      if (tokensUsed != null) 'tokens_used': tokensUsed,
      if (durationMs != null) 'duration_ms': durationMs,
      if (errorMessage != null) 'error_message': errorMessage,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResearchStepsCompanion copyWith({
    Value<String>? id,
    Value<String>? reportId,
    Value<int>? stepIndex,
    Value<String>? type,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? searchQuery,
    Value<String?>? inputData,
    Value<String?>? outputData,
    Value<String>? status,
    Value<int>? tokensUsed,
    Value<int?>? durationMs,
    Value<String?>? errorMessage,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return ResearchStepsCompanion(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      stepIndex: stepIndex ?? this.stepIndex,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      searchQuery: searchQuery ?? this.searchQuery,
      inputData: inputData ?? this.inputData,
      outputData: outputData ?? this.outputData,
      status: status ?? this.status,
      tokensUsed: tokensUsed ?? this.tokensUsed,
      durationMs: durationMs ?? this.durationMs,
      errorMessage: errorMessage ?? this.errorMessage,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<String>(reportId.value);
    }
    if (stepIndex.present) {
      map['step_index'] = Variable<int>(stepIndex.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (searchQuery.present) {
      map['search_query'] = Variable<String>(searchQuery.value);
    }
    if (inputData.present) {
      map['input_data'] = Variable<String>(inputData.value);
    }
    if (outputData.present) {
      map['output_data'] = Variable<String>(outputData.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (tokensUsed.present) {
      map['tokens_used'] = Variable<int>(tokensUsed.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResearchStepsCompanion(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('stepIndex: $stepIndex, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('searchQuery: $searchQuery, ')
          ..write('inputData: $inputData, ')
          ..write('outputData: $outputData, ')
          ..write('status: $status, ')
          ..write('tokensUsed: $tokensUsed, ')
          ..write('durationMs: $durationMs, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResearchCitationsTable extends ResearchCitations
    with TableInfo<$ResearchCitationsTable, ResearchCitation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResearchCitationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reportIdMeta = const VerificationMeta(
    'reportId',
  );
  @override
  late final GeneratedColumn<String> reportId = GeneratedColumn<String>(
    'report_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _citationIndexMeta = const VerificationMeta(
    'citationIndex',
  );
  @override
  late final GeneratedColumn<int> citationIndex = GeneratedColumn<int>(
    'citation_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snippetMeta = const VerificationMeta(
    'snippet',
  );
  @override
  late final GeneratedColumn<String> snippet = GeneratedColumn<String>(
    'snippet',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relevanceScoreMeta = const VerificationMeta(
    'relevanceScore',
  );
  @override
  late final GeneratedColumn<double> relevanceScore = GeneratedColumn<double>(
    'relevance_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reportId,
    citationIndex,
    sourceType,
    url,
    filePath,
    title,
    snippet,
    relevanceScore,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'research_citations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResearchCitation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('report_id')) {
      context.handle(
        _reportIdMeta,
        reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reportIdMeta);
    }
    if (data.containsKey('citation_index')) {
      context.handle(
        _citationIndexMeta,
        citationIndex.isAcceptableOrUnknown(
          data['citation_index']!,
          _citationIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_citationIndexMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('snippet')) {
      context.handle(
        _snippetMeta,
        snippet.isAcceptableOrUnknown(data['snippet']!, _snippetMeta),
      );
    }
    if (data.containsKey('relevance_score')) {
      context.handle(
        _relevanceScoreMeta,
        relevanceScore.isAcceptableOrUnknown(
          data['relevance_score']!,
          _relevanceScoreMeta,
        ),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResearchCitation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResearchCitation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      reportId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_id'],
      )!,
      citationIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}citation_index'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      snippet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snippet'],
      ),
      relevanceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}relevance_score'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      ),
    );
  }

  @override
  $ResearchCitationsTable createAlias(String alias) {
    return $ResearchCitationsTable(attachedDatabase, alias);
  }
}

class ResearchCitation extends DataClass
    implements Insertable<ResearchCitation> {
  final String id;
  final String reportId;
  final int citationIndex;
  final String sourceType;
  final String? url;
  final String? filePath;
  final String title;
  final String? snippet;
  final double? relevanceScore;
  final DateTime? fetchedAt;
  const ResearchCitation({
    required this.id,
    required this.reportId,
    required this.citationIndex,
    required this.sourceType,
    this.url,
    this.filePath,
    required this.title,
    this.snippet,
    this.relevanceScore,
    this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['report_id'] = Variable<String>(reportId);
    map['citation_index'] = Variable<int>(citationIndex);
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || snippet != null) {
      map['snippet'] = Variable<String>(snippet);
    }
    if (!nullToAbsent || relevanceScore != null) {
      map['relevance_score'] = Variable<double>(relevanceScore);
    }
    if (!nullToAbsent || fetchedAt != null) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt);
    }
    return map;
  }

  ResearchCitationsCompanion toCompanion(bool nullToAbsent) {
    return ResearchCitationsCompanion(
      id: Value(id),
      reportId: Value(reportId),
      citationIndex: Value(citationIndex),
      sourceType: Value(sourceType),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      title: Value(title),
      snippet: snippet == null && nullToAbsent
          ? const Value.absent()
          : Value(snippet),
      relevanceScore: relevanceScore == null && nullToAbsent
          ? const Value.absent()
          : Value(relevanceScore),
      fetchedAt: fetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(fetchedAt),
    );
  }

  factory ResearchCitation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResearchCitation(
      id: serializer.fromJson<String>(json['id']),
      reportId: serializer.fromJson<String>(json['reportId']),
      citationIndex: serializer.fromJson<int>(json['citationIndex']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      url: serializer.fromJson<String?>(json['url']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      title: serializer.fromJson<String>(json['title']),
      snippet: serializer.fromJson<String?>(json['snippet']),
      relevanceScore: serializer.fromJson<double?>(json['relevanceScore']),
      fetchedAt: serializer.fromJson<DateTime?>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'reportId': serializer.toJson<String>(reportId),
      'citationIndex': serializer.toJson<int>(citationIndex),
      'sourceType': serializer.toJson<String>(sourceType),
      'url': serializer.toJson<String?>(url),
      'filePath': serializer.toJson<String?>(filePath),
      'title': serializer.toJson<String>(title),
      'snippet': serializer.toJson<String?>(snippet),
      'relevanceScore': serializer.toJson<double?>(relevanceScore),
      'fetchedAt': serializer.toJson<DateTime?>(fetchedAt),
    };
  }

  ResearchCitation copyWith({
    String? id,
    String? reportId,
    int? citationIndex,
    String? sourceType,
    Value<String?> url = const Value.absent(),
    Value<String?> filePath = const Value.absent(),
    String? title,
    Value<String?> snippet = const Value.absent(),
    Value<double?> relevanceScore = const Value.absent(),
    Value<DateTime?> fetchedAt = const Value.absent(),
  }) => ResearchCitation(
    id: id ?? this.id,
    reportId: reportId ?? this.reportId,
    citationIndex: citationIndex ?? this.citationIndex,
    sourceType: sourceType ?? this.sourceType,
    url: url.present ? url.value : this.url,
    filePath: filePath.present ? filePath.value : this.filePath,
    title: title ?? this.title,
    snippet: snippet.present ? snippet.value : this.snippet,
    relevanceScore: relevanceScore.present
        ? relevanceScore.value
        : this.relevanceScore,
    fetchedAt: fetchedAt.present ? fetchedAt.value : this.fetchedAt,
  );
  ResearchCitation copyWithCompanion(ResearchCitationsCompanion data) {
    return ResearchCitation(
      id: data.id.present ? data.id.value : this.id,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      citationIndex: data.citationIndex.present
          ? data.citationIndex.value
          : this.citationIndex,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      url: data.url.present ? data.url.value : this.url,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      title: data.title.present ? data.title.value : this.title,
      snippet: data.snippet.present ? data.snippet.value : this.snippet,
      relevanceScore: data.relevanceScore.present
          ? data.relevanceScore.value
          : this.relevanceScore,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResearchCitation(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('citationIndex: $citationIndex, ')
          ..write('sourceType: $sourceType, ')
          ..write('url: $url, ')
          ..write('filePath: $filePath, ')
          ..write('title: $title, ')
          ..write('snippet: $snippet, ')
          ..write('relevanceScore: $relevanceScore, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    reportId,
    citationIndex,
    sourceType,
    url,
    filePath,
    title,
    snippet,
    relevanceScore,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResearchCitation &&
          other.id == this.id &&
          other.reportId == this.reportId &&
          other.citationIndex == this.citationIndex &&
          other.sourceType == this.sourceType &&
          other.url == this.url &&
          other.filePath == this.filePath &&
          other.title == this.title &&
          other.snippet == this.snippet &&
          other.relevanceScore == this.relevanceScore &&
          other.fetchedAt == this.fetchedAt);
}

class ResearchCitationsCompanion extends UpdateCompanion<ResearchCitation> {
  final Value<String> id;
  final Value<String> reportId;
  final Value<int> citationIndex;
  final Value<String> sourceType;
  final Value<String?> url;
  final Value<String?> filePath;
  final Value<String> title;
  final Value<String?> snippet;
  final Value<double?> relevanceScore;
  final Value<DateTime?> fetchedAt;
  final Value<int> rowid;
  const ResearchCitationsCompanion({
    this.id = const Value.absent(),
    this.reportId = const Value.absent(),
    this.citationIndex = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.url = const Value.absent(),
    this.filePath = const Value.absent(),
    this.title = const Value.absent(),
    this.snippet = const Value.absent(),
    this.relevanceScore = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResearchCitationsCompanion.insert({
    required String id,
    required String reportId,
    required int citationIndex,
    required String sourceType,
    this.url = const Value.absent(),
    this.filePath = const Value.absent(),
    required String title,
    this.snippet = const Value.absent(),
    this.relevanceScore = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       reportId = Value(reportId),
       citationIndex = Value(citationIndex),
       sourceType = Value(sourceType),
       title = Value(title);
  static Insertable<ResearchCitation> custom({
    Expression<String>? id,
    Expression<String>? reportId,
    Expression<int>? citationIndex,
    Expression<String>? sourceType,
    Expression<String>? url,
    Expression<String>? filePath,
    Expression<String>? title,
    Expression<String>? snippet,
    Expression<double>? relevanceScore,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reportId != null) 'report_id': reportId,
      if (citationIndex != null) 'citation_index': citationIndex,
      if (sourceType != null) 'source_type': sourceType,
      if (url != null) 'url': url,
      if (filePath != null) 'file_path': filePath,
      if (title != null) 'title': title,
      if (snippet != null) 'snippet': snippet,
      if (relevanceScore != null) 'relevance_score': relevanceScore,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResearchCitationsCompanion copyWith({
    Value<String>? id,
    Value<String>? reportId,
    Value<int>? citationIndex,
    Value<String>? sourceType,
    Value<String?>? url,
    Value<String?>? filePath,
    Value<String>? title,
    Value<String?>? snippet,
    Value<double?>? relevanceScore,
    Value<DateTime?>? fetchedAt,
    Value<int>? rowid,
  }) {
    return ResearchCitationsCompanion(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      citationIndex: citationIndex ?? this.citationIndex,
      sourceType: sourceType ?? this.sourceType,
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      snippet: snippet ?? this.snippet,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<String>(reportId.value);
    }
    if (citationIndex.present) {
      map['citation_index'] = Variable<int>(citationIndex.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (snippet.present) {
      map['snippet'] = Variable<String>(snippet.value);
    }
    if (relevanceScore.present) {
      map['relevance_score'] = Variable<double>(relevanceScore.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResearchCitationsCompanion(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('citationIndex: $citationIndex, ')
          ..write('sourceType: $sourceType, ')
          ..write('url: $url, ')
          ..write('filePath: $filePath, ')
          ..write('title: $title, ')
          ..write('snippet: $snippet, ')
          ..write('relevanceScore: $relevanceScore, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResearchSectionsTable extends ResearchSections
    with TableInfo<$ResearchSectionsTable, ResearchSection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResearchSectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reportIdMeta = const VerificationMeta(
    'reportId',
  );
  @override
  late final GeneratedColumn<String> reportId = GeneratedColumn<String>(
    'report_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIndexMeta = const VerificationMeta(
    'sectionIndex',
  );
  @override
  late final GeneratedColumn<int> sectionIndex = GeneratedColumn<int>(
    'section_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _citationIdsMeta = const VerificationMeta(
    'citationIds',
  );
  @override
  late final GeneratedColumn<String> citationIds = GeneratedColumn<String>(
    'citation_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reportId,
    sectionIndex,
    title,
    content,
    citationIds,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'research_sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResearchSection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('report_id')) {
      context.handle(
        _reportIdMeta,
        reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reportIdMeta);
    }
    if (data.containsKey('section_index')) {
      context.handle(
        _sectionIndexMeta,
        sectionIndex.isAcceptableOrUnknown(
          data['section_index']!,
          _sectionIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sectionIndexMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('citation_ids')) {
      context.handle(
        _citationIdsMeta,
        citationIds.isAcceptableOrUnknown(
          data['citation_ids']!,
          _citationIdsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResearchSection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResearchSection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      reportId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_id'],
      )!,
      sectionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}section_index'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      citationIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}citation_ids'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ResearchSectionsTable createAlias(String alias) {
    return $ResearchSectionsTable(attachedDatabase, alias);
  }
}

class ResearchSection extends DataClass implements Insertable<ResearchSection> {
  final String id;
  final String reportId;
  final int sectionIndex;
  final String title;
  final String content;
  final String? citationIds;
  final DateTime createdAt;
  const ResearchSection({
    required this.id,
    required this.reportId,
    required this.sectionIndex,
    required this.title,
    required this.content,
    this.citationIds,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['report_id'] = Variable<String>(reportId);
    map['section_index'] = Variable<int>(sectionIndex);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || citationIds != null) {
      map['citation_ids'] = Variable<String>(citationIds);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ResearchSectionsCompanion toCompanion(bool nullToAbsent) {
    return ResearchSectionsCompanion(
      id: Value(id),
      reportId: Value(reportId),
      sectionIndex: Value(sectionIndex),
      title: Value(title),
      content: Value(content),
      citationIds: citationIds == null && nullToAbsent
          ? const Value.absent()
          : Value(citationIds),
      createdAt: Value(createdAt),
    );
  }

  factory ResearchSection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResearchSection(
      id: serializer.fromJson<String>(json['id']),
      reportId: serializer.fromJson<String>(json['reportId']),
      sectionIndex: serializer.fromJson<int>(json['sectionIndex']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      citationIds: serializer.fromJson<String?>(json['citationIds']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'reportId': serializer.toJson<String>(reportId),
      'sectionIndex': serializer.toJson<int>(sectionIndex),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'citationIds': serializer.toJson<String?>(citationIds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ResearchSection copyWith({
    String? id,
    String? reportId,
    int? sectionIndex,
    String? title,
    String? content,
    Value<String?> citationIds = const Value.absent(),
    DateTime? createdAt,
  }) => ResearchSection(
    id: id ?? this.id,
    reportId: reportId ?? this.reportId,
    sectionIndex: sectionIndex ?? this.sectionIndex,
    title: title ?? this.title,
    content: content ?? this.content,
    citationIds: citationIds.present ? citationIds.value : this.citationIds,
    createdAt: createdAt ?? this.createdAt,
  );
  ResearchSection copyWithCompanion(ResearchSectionsCompanion data) {
    return ResearchSection(
      id: data.id.present ? data.id.value : this.id,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      sectionIndex: data.sectionIndex.present
          ? data.sectionIndex.value
          : this.sectionIndex,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      citationIds: data.citationIds.present
          ? data.citationIds.value
          : this.citationIds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResearchSection(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('sectionIndex: $sectionIndex, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('citationIds: $citationIds, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    reportId,
    sectionIndex,
    title,
    content,
    citationIds,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResearchSection &&
          other.id == this.id &&
          other.reportId == this.reportId &&
          other.sectionIndex == this.sectionIndex &&
          other.title == this.title &&
          other.content == this.content &&
          other.citationIds == this.citationIds &&
          other.createdAt == this.createdAt);
}

class ResearchSectionsCompanion extends UpdateCompanion<ResearchSection> {
  final Value<String> id;
  final Value<String> reportId;
  final Value<int> sectionIndex;
  final Value<String> title;
  final Value<String> content;
  final Value<String?> citationIds;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ResearchSectionsCompanion({
    this.id = const Value.absent(),
    this.reportId = const Value.absent(),
    this.sectionIndex = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.citationIds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResearchSectionsCompanion.insert({
    required String id,
    required String reportId,
    required int sectionIndex,
    required String title,
    required String content,
    this.citationIds = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       reportId = Value(reportId),
       sectionIndex = Value(sectionIndex),
       title = Value(title),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<ResearchSection> custom({
    Expression<String>? id,
    Expression<String>? reportId,
    Expression<int>? sectionIndex,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? citationIds,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reportId != null) 'report_id': reportId,
      if (sectionIndex != null) 'section_index': sectionIndex,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (citationIds != null) 'citation_ids': citationIds,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResearchSectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? reportId,
    Value<int>? sectionIndex,
    Value<String>? title,
    Value<String>? content,
    Value<String?>? citationIds,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ResearchSectionsCompanion(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      sectionIndex: sectionIndex ?? this.sectionIndex,
      title: title ?? this.title,
      content: content ?? this.content,
      citationIds: citationIds ?? this.citationIds,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<String>(reportId.value);
    }
    if (sectionIndex.present) {
      map['section_index'] = Variable<int>(sectionIndex.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (citationIds.present) {
      map['citation_ids'] = Variable<String>(citationIds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResearchSectionsCompanion(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('sectionIndex: $sectionIndex, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('citationIds: $citationIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThinkingTracesTable extends ThinkingTraces
    with TableInfo<$ThinkingTracesTable, ThinkingTrace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThinkingTracesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thinkingMeta = const VerificationMeta(
    'thinking',
  );
  @override
  late final GeneratedColumn<String> thinking = GeneratedColumn<String>(
    'thinking',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thinkingTokensMeta = const VerificationMeta(
    'thinkingTokens',
  );
  @override
  late final GeneratedColumn<int> thinkingTokens = GeneratedColumn<int>(
    'thinking_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _modelConfigIdMeta = const VerificationMeta(
    'modelConfigId',
  );
  @override
  late final GeneratedColumn<String> modelConfigId = GeneratedColumn<String>(
    'model_config_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    sessionId,
    thinking,
    thinkingTokens,
    modelConfigId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'thinking_traces';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThinkingTrace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('thinking')) {
      context.handle(
        _thinkingMeta,
        thinking.isAcceptableOrUnknown(data['thinking']!, _thinkingMeta),
      );
    } else if (isInserting) {
      context.missing(_thinkingMeta);
    }
    if (data.containsKey('thinking_tokens')) {
      context.handle(
        _thinkingTokensMeta,
        thinkingTokens.isAcceptableOrUnknown(
          data['thinking_tokens']!,
          _thinkingTokensMeta,
        ),
      );
    }
    if (data.containsKey('model_config_id')) {
      context.handle(
        _modelConfigIdMeta,
        modelConfigId.isAcceptableOrUnknown(
          data['model_config_id']!,
          _modelConfigIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ThinkingTrace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThinkingTrace(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      thinking: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thinking'],
      )!,
      thinkingTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}thinking_tokens'],
      )!,
      modelConfigId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_config_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ThinkingTracesTable createAlias(String alias) {
    return $ThinkingTracesTable(attachedDatabase, alias);
  }
}

class ThinkingTrace extends DataClass implements Insertable<ThinkingTrace> {
  final String id;
  final String messageId;
  final String sessionId;
  final String thinking;
  final int thinkingTokens;
  final String? modelConfigId;
  final DateTime createdAt;
  const ThinkingTrace({
    required this.id,
    required this.messageId,
    required this.sessionId,
    required this.thinking,
    required this.thinkingTokens,
    this.modelConfigId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['message_id'] = Variable<String>(messageId);
    map['session_id'] = Variable<String>(sessionId);
    map['thinking'] = Variable<String>(thinking);
    map['thinking_tokens'] = Variable<int>(thinkingTokens);
    if (!nullToAbsent || modelConfigId != null) {
      map['model_config_id'] = Variable<String>(modelConfigId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ThinkingTracesCompanion toCompanion(bool nullToAbsent) {
    return ThinkingTracesCompanion(
      id: Value(id),
      messageId: Value(messageId),
      sessionId: Value(sessionId),
      thinking: Value(thinking),
      thinkingTokens: Value(thinkingTokens),
      modelConfigId: modelConfigId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelConfigId),
      createdAt: Value(createdAt),
    );
  }

  factory ThinkingTrace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThinkingTrace(
      id: serializer.fromJson<String>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      thinking: serializer.fromJson<String>(json['thinking']),
      thinkingTokens: serializer.fromJson<int>(json['thinkingTokens']),
      modelConfigId: serializer.fromJson<String?>(json['modelConfigId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'messageId': serializer.toJson<String>(messageId),
      'sessionId': serializer.toJson<String>(sessionId),
      'thinking': serializer.toJson<String>(thinking),
      'thinkingTokens': serializer.toJson<int>(thinkingTokens),
      'modelConfigId': serializer.toJson<String?>(modelConfigId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ThinkingTrace copyWith({
    String? id,
    String? messageId,
    String? sessionId,
    String? thinking,
    int? thinkingTokens,
    Value<String?> modelConfigId = const Value.absent(),
    DateTime? createdAt,
  }) => ThinkingTrace(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    sessionId: sessionId ?? this.sessionId,
    thinking: thinking ?? this.thinking,
    thinkingTokens: thinkingTokens ?? this.thinkingTokens,
    modelConfigId: modelConfigId.present
        ? modelConfigId.value
        : this.modelConfigId,
    createdAt: createdAt ?? this.createdAt,
  );
  ThinkingTrace copyWithCompanion(ThinkingTracesCompanion data) {
    return ThinkingTrace(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      thinking: data.thinking.present ? data.thinking.value : this.thinking,
      thinkingTokens: data.thinkingTokens.present
          ? data.thinkingTokens.value
          : this.thinkingTokens,
      modelConfigId: data.modelConfigId.present
          ? data.modelConfigId.value
          : this.modelConfigId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThinkingTrace(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('sessionId: $sessionId, ')
          ..write('thinking: $thinking, ')
          ..write('thinkingTokens: $thinkingTokens, ')
          ..write('modelConfigId: $modelConfigId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messageId,
    sessionId,
    thinking,
    thinkingTokens,
    modelConfigId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThinkingTrace &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.sessionId == this.sessionId &&
          other.thinking == this.thinking &&
          other.thinkingTokens == this.thinkingTokens &&
          other.modelConfigId == this.modelConfigId &&
          other.createdAt == this.createdAt);
}

class ThinkingTracesCompanion extends UpdateCompanion<ThinkingTrace> {
  final Value<String> id;
  final Value<String> messageId;
  final Value<String> sessionId;
  final Value<String> thinking;
  final Value<int> thinkingTokens;
  final Value<String?> modelConfigId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ThinkingTracesCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.thinking = const Value.absent(),
    this.thinkingTokens = const Value.absent(),
    this.modelConfigId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThinkingTracesCompanion.insert({
    required String id,
    required String messageId,
    required String sessionId,
    required String thinking,
    this.thinkingTokens = const Value.absent(),
    this.modelConfigId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       messageId = Value(messageId),
       sessionId = Value(sessionId),
       thinking = Value(thinking),
       createdAt = Value(createdAt);
  static Insertable<ThinkingTrace> custom({
    Expression<String>? id,
    Expression<String>? messageId,
    Expression<String>? sessionId,
    Expression<String>? thinking,
    Expression<int>? thinkingTokens,
    Expression<String>? modelConfigId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (sessionId != null) 'session_id': sessionId,
      if (thinking != null) 'thinking': thinking,
      if (thinkingTokens != null) 'thinking_tokens': thinkingTokens,
      if (modelConfigId != null) 'model_config_id': modelConfigId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThinkingTracesCompanion copyWith({
    Value<String>? id,
    Value<String>? messageId,
    Value<String>? sessionId,
    Value<String>? thinking,
    Value<int>? thinkingTokens,
    Value<String?>? modelConfigId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ThinkingTracesCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      sessionId: sessionId ?? this.sessionId,
      thinking: thinking ?? this.thinking,
      thinkingTokens: thinkingTokens ?? this.thinkingTokens,
      modelConfigId: modelConfigId ?? this.modelConfigId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (thinking.present) {
      map['thinking'] = Variable<String>(thinking.value);
    }
    if (thinkingTokens.present) {
      map['thinking_tokens'] = Variable<int>(thinkingTokens.value);
    }
    if (modelConfigId.present) {
      map['model_config_id'] = Variable<String>(modelConfigId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThinkingTracesCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('sessionId: $sessionId, ')
          ..write('thinking: $thinking, ')
          ..write('thinkingTokens: $thinkingTokens, ')
          ..write('modelConfigId: $modelConfigId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PromptScenariosTable extends PromptScenarios
    with TableInfo<$PromptScenariosTable, PromptScenario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromptScenariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scenarioKeyMeta = const VerificationMeta(
    'scenarioKey',
  );
  @override
  late final GeneratedColumn<String> scenarioKey = GeneratedColumn<String>(
    'scenario_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _systemPromptMeta = const VerificationMeta(
    'systemPrompt',
  );
  @override
  late final GeneratedColumn<String> systemPrompt = GeneratedColumn<String>(
    'system_prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userPromptTemplateMeta =
      const VerificationMeta('userPromptTemplate');
  @override
  late final GeneratedColumn<String> userPromptTemplate =
      GeneratedColumn<String>(
        'user_prompt_template',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _variablesMeta = const VerificationMeta(
    'variables',
  );
  @override
  late final GeneratedColumn<String> variables = GeneratedColumn<String>(
    'variables',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isBuiltinMeta = const VerificationMeta(
    'isBuiltin',
  );
  @override
  late final GeneratedColumn<bool> isBuiltin = GeneratedColumn<bool>(
    'is_builtin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_builtin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scenarioKey,
    displayName,
    category,
    description,
    systemPrompt,
    userPromptTemplate,
    variables,
    sortOrder,
    isBuiltin,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prompt_scenarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<PromptScenario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scenario_key')) {
      context.handle(
        _scenarioKeyMeta,
        scenarioKey.isAcceptableOrUnknown(
          data['scenario_key']!,
          _scenarioKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scenarioKeyMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('system_prompt')) {
      context.handle(
        _systemPromptMeta,
        systemPrompt.isAcceptableOrUnknown(
          data['system_prompt']!,
          _systemPromptMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_systemPromptMeta);
    }
    if (data.containsKey('user_prompt_template')) {
      context.handle(
        _userPromptTemplateMeta,
        userPromptTemplate.isAcceptableOrUnknown(
          data['user_prompt_template']!,
          _userPromptTemplateMeta,
        ),
      );
    }
    if (data.containsKey('variables')) {
      context.handle(
        _variablesMeta,
        variables.isAcceptableOrUnknown(data['variables']!, _variablesMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_builtin')) {
      context.handle(
        _isBuiltinMeta,
        isBuiltin.isAcceptableOrUnknown(data['is_builtin']!, _isBuiltinMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PromptScenario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PromptScenario(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scenarioKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scenario_key'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      systemPrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_prompt'],
      )!,
      userPromptTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_prompt_template'],
      ),
      variables: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variables'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isBuiltin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_builtin'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PromptScenariosTable createAlias(String alias) {
    return $PromptScenariosTable(attachedDatabase, alias);
  }
}

class PromptScenario extends DataClass implements Insertable<PromptScenario> {
  final String id;
  final String scenarioKey;
  final String displayName;
  final String category;
  final String? description;
  final String systemPrompt;
  final String? userPromptTemplate;
  final String? variables;
  final int sortOrder;
  final bool isBuiltin;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PromptScenario({
    required this.id,
    required this.scenarioKey,
    required this.displayName,
    required this.category,
    this.description,
    required this.systemPrompt,
    this.userPromptTemplate,
    this.variables,
    required this.sortOrder,
    required this.isBuiltin,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scenario_key'] = Variable<String>(scenarioKey);
    map['display_name'] = Variable<String>(displayName);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['system_prompt'] = Variable<String>(systemPrompt);
    if (!nullToAbsent || userPromptTemplate != null) {
      map['user_prompt_template'] = Variable<String>(userPromptTemplate);
    }
    if (!nullToAbsent || variables != null) {
      map['variables'] = Variable<String>(variables);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_builtin'] = Variable<bool>(isBuiltin);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PromptScenariosCompanion toCompanion(bool nullToAbsent) {
    return PromptScenariosCompanion(
      id: Value(id),
      scenarioKey: Value(scenarioKey),
      displayName: Value(displayName),
      category: Value(category),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      systemPrompt: Value(systemPrompt),
      userPromptTemplate: userPromptTemplate == null && nullToAbsent
          ? const Value.absent()
          : Value(userPromptTemplate),
      variables: variables == null && nullToAbsent
          ? const Value.absent()
          : Value(variables),
      sortOrder: Value(sortOrder),
      isBuiltin: Value(isBuiltin),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PromptScenario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PromptScenario(
      id: serializer.fromJson<String>(json['id']),
      scenarioKey: serializer.fromJson<String>(json['scenarioKey']),
      displayName: serializer.fromJson<String>(json['displayName']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String?>(json['description']),
      systemPrompt: serializer.fromJson<String>(json['systemPrompt']),
      userPromptTemplate: serializer.fromJson<String?>(
        json['userPromptTemplate'],
      ),
      variables: serializer.fromJson<String?>(json['variables']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isBuiltin: serializer.fromJson<bool>(json['isBuiltin']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scenarioKey': serializer.toJson<String>(scenarioKey),
      'displayName': serializer.toJson<String>(displayName),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String?>(description),
      'systemPrompt': serializer.toJson<String>(systemPrompt),
      'userPromptTemplate': serializer.toJson<String?>(userPromptTemplate),
      'variables': serializer.toJson<String?>(variables),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isBuiltin': serializer.toJson<bool>(isBuiltin),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PromptScenario copyWith({
    String? id,
    String? scenarioKey,
    String? displayName,
    String? category,
    Value<String?> description = const Value.absent(),
    String? systemPrompt,
    Value<String?> userPromptTemplate = const Value.absent(),
    Value<String?> variables = const Value.absent(),
    int? sortOrder,
    bool? isBuiltin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PromptScenario(
    id: id ?? this.id,
    scenarioKey: scenarioKey ?? this.scenarioKey,
    displayName: displayName ?? this.displayName,
    category: category ?? this.category,
    description: description.present ? description.value : this.description,
    systemPrompt: systemPrompt ?? this.systemPrompt,
    userPromptTemplate: userPromptTemplate.present
        ? userPromptTemplate.value
        : this.userPromptTemplate,
    variables: variables.present ? variables.value : this.variables,
    sortOrder: sortOrder ?? this.sortOrder,
    isBuiltin: isBuiltin ?? this.isBuiltin,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PromptScenario copyWithCompanion(PromptScenariosCompanion data) {
    return PromptScenario(
      id: data.id.present ? data.id.value : this.id,
      scenarioKey: data.scenarioKey.present
          ? data.scenarioKey.value
          : this.scenarioKey,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      category: data.category.present ? data.category.value : this.category,
      description: data.description.present
          ? data.description.value
          : this.description,
      systemPrompt: data.systemPrompt.present
          ? data.systemPrompt.value
          : this.systemPrompt,
      userPromptTemplate: data.userPromptTemplate.present
          ? data.userPromptTemplate.value
          : this.userPromptTemplate,
      variables: data.variables.present ? data.variables.value : this.variables,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isBuiltin: data.isBuiltin.present ? data.isBuiltin.value : this.isBuiltin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PromptScenario(')
          ..write('id: $id, ')
          ..write('scenarioKey: $scenarioKey, ')
          ..write('displayName: $displayName, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('userPromptTemplate: $userPromptTemplate, ')
          ..write('variables: $variables, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scenarioKey,
    displayName,
    category,
    description,
    systemPrompt,
    userPromptTemplate,
    variables,
    sortOrder,
    isBuiltin,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PromptScenario &&
          other.id == this.id &&
          other.scenarioKey == this.scenarioKey &&
          other.displayName == this.displayName &&
          other.category == this.category &&
          other.description == this.description &&
          other.systemPrompt == this.systemPrompt &&
          other.userPromptTemplate == this.userPromptTemplate &&
          other.variables == this.variables &&
          other.sortOrder == this.sortOrder &&
          other.isBuiltin == this.isBuiltin &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PromptScenariosCompanion extends UpdateCompanion<PromptScenario> {
  final Value<String> id;
  final Value<String> scenarioKey;
  final Value<String> displayName;
  final Value<String> category;
  final Value<String?> description;
  final Value<String> systemPrompt;
  final Value<String?> userPromptTemplate;
  final Value<String?> variables;
  final Value<int> sortOrder;
  final Value<bool> isBuiltin;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PromptScenariosCompanion({
    this.id = const Value.absent(),
    this.scenarioKey = const Value.absent(),
    this.displayName = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.userPromptTemplate = const Value.absent(),
    this.variables = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromptScenariosCompanion.insert({
    required String id,
    required String scenarioKey,
    required String displayName,
    required String category,
    this.description = const Value.absent(),
    required String systemPrompt,
    this.userPromptTemplate = const Value.absent(),
    this.variables = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scenarioKey = Value(scenarioKey),
       displayName = Value(displayName),
       category = Value(category),
       systemPrompt = Value(systemPrompt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PromptScenario> custom({
    Expression<String>? id,
    Expression<String>? scenarioKey,
    Expression<String>? displayName,
    Expression<String>? category,
    Expression<String>? description,
    Expression<String>? systemPrompt,
    Expression<String>? userPromptTemplate,
    Expression<String>? variables,
    Expression<int>? sortOrder,
    Expression<bool>? isBuiltin,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scenarioKey != null) 'scenario_key': scenarioKey,
      if (displayName != null) 'display_name': displayName,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
      if (userPromptTemplate != null)
        'user_prompt_template': userPromptTemplate,
      if (variables != null) 'variables': variables,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromptScenariosCompanion copyWith({
    Value<String>? id,
    Value<String>? scenarioKey,
    Value<String>? displayName,
    Value<String>? category,
    Value<String?>? description,
    Value<String>? systemPrompt,
    Value<String?>? userPromptTemplate,
    Value<String?>? variables,
    Value<int>? sortOrder,
    Value<bool>? isBuiltin,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PromptScenariosCompanion(
      id: id ?? this.id,
      scenarioKey: scenarioKey ?? this.scenarioKey,
      displayName: displayName ?? this.displayName,
      category: category ?? this.category,
      description: description ?? this.description,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      userPromptTemplate: userPromptTemplate ?? this.userPromptTemplate,
      variables: variables ?? this.variables,
      sortOrder: sortOrder ?? this.sortOrder,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scenarioKey.present) {
      map['scenario_key'] = Variable<String>(scenarioKey.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (systemPrompt.present) {
      map['system_prompt'] = Variable<String>(systemPrompt.value);
    }
    if (userPromptTemplate.present) {
      map['user_prompt_template'] = Variable<String>(userPromptTemplate.value);
    }
    if (variables.present) {
      map['variables'] = Variable<String>(variables.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isBuiltin.present) {
      map['is_builtin'] = Variable<bool>(isBuiltin.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromptScenariosCompanion(')
          ..write('id: $id, ')
          ..write('scenarioKey: $scenarioKey, ')
          ..write('displayName: $displayName, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('userPromptTemplate: $userPromptTemplate, ')
          ..write('variables: $variables, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ModelsTable models = $ModelsTable(this);
  late final $MemoriesTable memories = $MemoriesTable(this);
  late final $KnowledgeBasesTable knowledgeBases = $KnowledgeBasesTable(this);
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final $DocumentChunksTable documentChunks = $DocumentChunksTable(this);
  late final $PromptTemplatesTable promptTemplates = $PromptTemplatesTable(
    this,
  );
  late final $SessionPromptsTable sessionPrompts = $SessionPromptsTable(this);
  late final $DownloadTasksTable downloadTasks = $DownloadTasksTable(this);
  late final $McpServerConfigsTable mcpServerConfigs = $McpServerConfigsTable(
    this,
  );
  late final $FoldersTable folders = $FoldersTable(this);
  late final $AppLogsTable appLogs = $AppLogsTable(this);
  late final $SessionSummariesTable sessionSummaries = $SessionSummariesTable(
    this,
  );
  late final $PluginRegistriesTable pluginRegistries = $PluginRegistriesTable(
    this,
  );
  late final $SessionResourcesTable sessionResources = $SessionResourcesTable(
    this,
  );
  late final $WorkflowDefinitionsTable workflowDefinitions =
      $WorkflowDefinitionsTable(this);
  late final $WorkflowExecutionsTable workflowExecutions =
      $WorkflowExecutionsTable(this);
  late final $WorkflowLogsTable workflowLogs = $WorkflowLogsTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $ResearchReportsTable researchReports = $ResearchReportsTable(
    this,
  );
  late final $ResearchStepsTable researchSteps = $ResearchStepsTable(this);
  late final $ResearchCitationsTable researchCitations =
      $ResearchCitationsTable(this);
  late final $ResearchSectionsTable researchSections = $ResearchSectionsTable(
    this,
  );
  late final $ThinkingTracesTable thinkingTraces = $ThinkingTracesTable(this);
  late final $PromptScenariosTable promptScenarios = $PromptScenariosTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessions,
    messages,
    models,
    memories,
    knowledgeBases,
    documents,
    documentChunks,
    promptTemplates,
    sessionPrompts,
    downloadTasks,
    mcpServerConfigs,
    folders,
    appLogs,
    sessionSummaries,
    pluginRegistries,
    sessionResources,
    workflowDefinitions,
    workflowExecutions,
    workflowLogs,
    projects,
    researchReports,
    researchSteps,
    researchCitations,
    researchSections,
    thinkingTraces,
    promptScenarios,
  ];
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String id,
      required String name,
      Value<String?> folderId,
      required String modelId,
      Value<String?> systemPrompt,
      Value<String?> inferenceParams,
      Value<bool> isPinned,
      Value<bool> isArchived,
      Value<bool> enableGlobalMemory,
      Value<bool> enableVideoUnderstanding,
      Value<String?> enabledMcpServerIds,
      Value<bool> enableWebSearch,
      Value<bool> enableVoiceInput,
      Value<bool> enableVoiceOutput,
      Value<String?> enabledSkill,
      Value<bool> enableCamera,
      Value<bool> enableFileUpload,
      Value<String?> enabledKnowledgeBaseId,
      Value<bool> isSpirit,
      Value<String?> projectId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> folderId,
      Value<String> modelId,
      Value<String?> systemPrompt,
      Value<String?> inferenceParams,
      Value<bool> isPinned,
      Value<bool> isArchived,
      Value<bool> enableGlobalMemory,
      Value<bool> enableVideoUnderstanding,
      Value<String?> enabledMcpServerIds,
      Value<bool> enableWebSearch,
      Value<bool> enableVoiceInput,
      Value<bool> enableVoiceOutput,
      Value<String?> enabledSkill,
      Value<bool> enableCamera,
      Value<bool> enableFileUpload,
      Value<String?> enabledKnowledgeBaseId,
      Value<bool> isSpirit,
      Value<String?> projectId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inferenceParams => $composableBuilder(
    column: $table.inferenceParams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableGlobalMemory => $composableBuilder(
    column: $table.enableGlobalMemory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableVideoUnderstanding => $composableBuilder(
    column: $table.enableVideoUnderstanding,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enabledMcpServerIds => $composableBuilder(
    column: $table.enabledMcpServerIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableWebSearch => $composableBuilder(
    column: $table.enableWebSearch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableVoiceInput => $composableBuilder(
    column: $table.enableVoiceInput,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableVoiceOutput => $composableBuilder(
    column: $table.enableVoiceOutput,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enabledSkill => $composableBuilder(
    column: $table.enabledSkill,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableCamera => $composableBuilder(
    column: $table.enableCamera,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableFileUpload => $composableBuilder(
    column: $table.enableFileUpload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enabledKnowledgeBaseId => $composableBuilder(
    column: $table.enabledKnowledgeBaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSpirit => $composableBuilder(
    column: $table.isSpirit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inferenceParams => $composableBuilder(
    column: $table.inferenceParams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableGlobalMemory => $composableBuilder(
    column: $table.enableGlobalMemory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableVideoUnderstanding => $composableBuilder(
    column: $table.enableVideoUnderstanding,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enabledMcpServerIds => $composableBuilder(
    column: $table.enabledMcpServerIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableWebSearch => $composableBuilder(
    column: $table.enableWebSearch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableVoiceInput => $composableBuilder(
    column: $table.enableVoiceInput,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableVoiceOutput => $composableBuilder(
    column: $table.enableVoiceOutput,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enabledSkill => $composableBuilder(
    column: $table.enabledSkill,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableCamera => $composableBuilder(
    column: $table.enableCamera,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableFileUpload => $composableBuilder(
    column: $table.enableFileUpload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enabledKnowledgeBaseId => $composableBuilder(
    column: $table.enabledKnowledgeBaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSpirit => $composableBuilder(
    column: $table.isSpirit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get inferenceParams => $composableBuilder(
    column: $table.inferenceParams,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableGlobalMemory => $composableBuilder(
    column: $table.enableGlobalMemory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableVideoUnderstanding => $composableBuilder(
    column: $table.enableVideoUnderstanding,
    builder: (column) => column,
  );

  GeneratedColumn<String> get enabledMcpServerIds => $composableBuilder(
    column: $table.enabledMcpServerIds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableWebSearch => $composableBuilder(
    column: $table.enableWebSearch,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableVoiceInput => $composableBuilder(
    column: $table.enableVoiceInput,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableVoiceOutput => $composableBuilder(
    column: $table.enableVoiceOutput,
    builder: (column) => column,
  );

  GeneratedColumn<String> get enabledSkill => $composableBuilder(
    column: $table.enabledSkill,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableCamera => $composableBuilder(
    column: $table.enableCamera,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableFileUpload => $composableBuilder(
    column: $table.enableFileUpload,
    builder: (column) => column,
  );

  GeneratedColumn<String> get enabledKnowledgeBaseId => $composableBuilder(
    column: $table.enabledKnowledgeBaseId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSpirit =>
      $composableBuilder(column: $table.isSpirit, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String?> systemPrompt = const Value.absent(),
                Value<String?> inferenceParams = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> enableGlobalMemory = const Value.absent(),
                Value<bool> enableVideoUnderstanding = const Value.absent(),
                Value<String?> enabledMcpServerIds = const Value.absent(),
                Value<bool> enableWebSearch = const Value.absent(),
                Value<bool> enableVoiceInput = const Value.absent(),
                Value<bool> enableVoiceOutput = const Value.absent(),
                Value<String?> enabledSkill = const Value.absent(),
                Value<bool> enableCamera = const Value.absent(),
                Value<bool> enableFileUpload = const Value.absent(),
                Value<String?> enabledKnowledgeBaseId = const Value.absent(),
                Value<bool> isSpirit = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                name: name,
                folderId: folderId,
                modelId: modelId,
                systemPrompt: systemPrompt,
                inferenceParams: inferenceParams,
                isPinned: isPinned,
                isArchived: isArchived,
                enableGlobalMemory: enableGlobalMemory,
                enableVideoUnderstanding: enableVideoUnderstanding,
                enabledMcpServerIds: enabledMcpServerIds,
                enableWebSearch: enableWebSearch,
                enableVoiceInput: enableVoiceInput,
                enableVoiceOutput: enableVoiceOutput,
                enabledSkill: enabledSkill,
                enableCamera: enableCamera,
                enableFileUpload: enableFileUpload,
                enabledKnowledgeBaseId: enabledKnowledgeBaseId,
                isSpirit: isSpirit,
                projectId: projectId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> folderId = const Value.absent(),
                required String modelId,
                Value<String?> systemPrompt = const Value.absent(),
                Value<String?> inferenceParams = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> enableGlobalMemory = const Value.absent(),
                Value<bool> enableVideoUnderstanding = const Value.absent(),
                Value<String?> enabledMcpServerIds = const Value.absent(),
                Value<bool> enableWebSearch = const Value.absent(),
                Value<bool> enableVoiceInput = const Value.absent(),
                Value<bool> enableVoiceOutput = const Value.absent(),
                Value<String?> enabledSkill = const Value.absent(),
                Value<bool> enableCamera = const Value.absent(),
                Value<bool> enableFileUpload = const Value.absent(),
                Value<String?> enabledKnowledgeBaseId = const Value.absent(),
                Value<bool> isSpirit = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                name: name,
                folderId: folderId,
                modelId: modelId,
                systemPrompt: systemPrompt,
                inferenceParams: inferenceParams,
                isPinned: isPinned,
                isArchived: isArchived,
                enableGlobalMemory: enableGlobalMemory,
                enableVideoUnderstanding: enableVideoUnderstanding,
                enabledMcpServerIds: enabledMcpServerIds,
                enableWebSearch: enableWebSearch,
                enableVoiceInput: enableVoiceInput,
                enableVoiceOutput: enableVoiceOutput,
                enabledSkill: enabledSkill,
                enableCamera: enableCamera,
                enableFileUpload: enableFileUpload,
                enabledKnowledgeBaseId: enabledKnowledgeBaseId,
                isSpirit: isSpirit,
                projectId: projectId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String id,
      required String sessionId,
      required String role,
      required String content,
      Value<String> type,
      Value<bool> hasImages,
      Value<int?> tokenCount,
      Value<String?> toolCallInfo,
      Value<String?> thinking,
      Value<int> thinkingTokens,
      Value<bool> showThinking,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> role,
      Value<String> content,
      Value<String> type,
      Value<bool> hasImages,
      Value<int?> tokenCount,
      Value<String?> toolCallInfo,
      Value<String?> thinking,
      Value<int> thinkingTokens,
      Value<bool> showThinking,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasImages => $composableBuilder(
    column: $table.hasImages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokenCount => $composableBuilder(
    column: $table.tokenCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolCallInfo => $composableBuilder(
    column: $table.toolCallInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thinking => $composableBuilder(
    column: $table.thinking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get thinkingTokens => $composableBuilder(
    column: $table.thinkingTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showThinking => $composableBuilder(
    column: $table.showThinking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasImages => $composableBuilder(
    column: $table.hasImages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokenCount => $composableBuilder(
    column: $table.tokenCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolCallInfo => $composableBuilder(
    column: $table.toolCallInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thinking => $composableBuilder(
    column: $table.thinking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get thinkingTokens => $composableBuilder(
    column: $table.thinkingTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showThinking => $composableBuilder(
    column: $table.showThinking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get hasImages =>
      $composableBuilder(column: $table.hasImages, builder: (column) => column);

  GeneratedColumn<int> get tokenCount => $composableBuilder(
    column: $table.tokenCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toolCallInfo => $composableBuilder(
    column: $table.toolCallInfo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thinking =>
      $composableBuilder(column: $table.thinking, builder: (column) => column);

  GeneratedColumn<int> get thinkingTokens => $composableBuilder(
    column: $table.thinkingTokens,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showThinking => $composableBuilder(
    column: $table.showThinking,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
          Message,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> hasImages = const Value.absent(),
                Value<int?> tokenCount = const Value.absent(),
                Value<String?> toolCallInfo = const Value.absent(),
                Value<String?> thinking = const Value.absent(),
                Value<int> thinkingTokens = const Value.absent(),
                Value<bool> showThinking = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                sessionId: sessionId,
                role: role,
                content: content,
                type: type,
                hasImages: hasImages,
                tokenCount: tokenCount,
                toolCallInfo: toolCallInfo,
                thinking: thinking,
                thinkingTokens: thinkingTokens,
                showThinking: showThinking,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String role,
                required String content,
                Value<String> type = const Value.absent(),
                Value<bool> hasImages = const Value.absent(),
                Value<int?> tokenCount = const Value.absent(),
                Value<String?> toolCallInfo = const Value.absent(),
                Value<String?> thinking = const Value.absent(),
                Value<int> thinkingTokens = const Value.absent(),
                Value<bool> showThinking = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                sessionId: sessionId,
                role: role,
                content: content,
                type: type,
                hasImages: hasImages,
                tokenCount: tokenCount,
                toolCallInfo: toolCallInfo,
                thinking: thinking,
                thinkingTokens: thinkingTokens,
                showThinking: showThinking,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
      Message,
      PrefetchHooks Function()
    >;
typedef $$ModelsTableCreateCompanionBuilder =
    ModelsCompanion Function({
      required String id,
      required String name,
      required String type,
      required String source,
      Value<String?> path,
      Value<String?> apiConfig,
      Value<String?> capabilities,
      Value<String?> defaultParams,
      Value<bool> isMultimodal,
      Value<String?> mmprojPath,
      Value<String?> mmprojFileName,
      Value<bool> isLoaded,
      Value<String> downloadStatus,
      Value<String> thinkingMode,
      Value<int?> thinkingBudget,
      Value<bool> supportsThinking,
      Value<int> minThinkingBudget,
      Value<int> maxThinkingBudget,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ModelsTableUpdateCompanionBuilder =
    ModelsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<String> source,
      Value<String?> path,
      Value<String?> apiConfig,
      Value<String?> capabilities,
      Value<String?> defaultParams,
      Value<bool> isMultimodal,
      Value<String?> mmprojPath,
      Value<String?> mmprojFileName,
      Value<bool> isLoaded,
      Value<String> downloadStatus,
      Value<String> thinkingMode,
      Value<int?> thinkingBudget,
      Value<bool> supportsThinking,
      Value<int> minThinkingBudget,
      Value<int> maxThinkingBudget,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ModelsTableFilterComposer
    extends Composer<_$AppDatabase, $ModelsTable> {
  $$ModelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiConfig => $composableBuilder(
    column: $table.apiConfig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capabilities => $composableBuilder(
    column: $table.capabilities,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultParams => $composableBuilder(
    column: $table.defaultParams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMultimodal => $composableBuilder(
    column: $table.isMultimodal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mmprojPath => $composableBuilder(
    column: $table.mmprojPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mmprojFileName => $composableBuilder(
    column: $table.mmprojFileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLoaded => $composableBuilder(
    column: $table.isLoaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadStatus => $composableBuilder(
    column: $table.downloadStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thinkingMode => $composableBuilder(
    column: $table.thinkingMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get thinkingBudget => $composableBuilder(
    column: $table.thinkingBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get supportsThinking => $composableBuilder(
    column: $table.supportsThinking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minThinkingBudget => $composableBuilder(
    column: $table.minThinkingBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxThinkingBudget => $composableBuilder(
    column: $table.maxThinkingBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $ModelsTable> {
  $$ModelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiConfig => $composableBuilder(
    column: $table.apiConfig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capabilities => $composableBuilder(
    column: $table.capabilities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultParams => $composableBuilder(
    column: $table.defaultParams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMultimodal => $composableBuilder(
    column: $table.isMultimodal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mmprojPath => $composableBuilder(
    column: $table.mmprojPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mmprojFileName => $composableBuilder(
    column: $table.mmprojFileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLoaded => $composableBuilder(
    column: $table.isLoaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadStatus => $composableBuilder(
    column: $table.downloadStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thinkingMode => $composableBuilder(
    column: $table.thinkingMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get thinkingBudget => $composableBuilder(
    column: $table.thinkingBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get supportsThinking => $composableBuilder(
    column: $table.supportsThinking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minThinkingBudget => $composableBuilder(
    column: $table.minThinkingBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxThinkingBudget => $composableBuilder(
    column: $table.maxThinkingBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModelsTable> {
  $$ModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get apiConfig =>
      $composableBuilder(column: $table.apiConfig, builder: (column) => column);

  GeneratedColumn<String> get capabilities => $composableBuilder(
    column: $table.capabilities,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultParams => $composableBuilder(
    column: $table.defaultParams,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMultimodal => $composableBuilder(
    column: $table.isMultimodal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mmprojPath => $composableBuilder(
    column: $table.mmprojPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mmprojFileName => $composableBuilder(
    column: $table.mmprojFileName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLoaded =>
      $composableBuilder(column: $table.isLoaded, builder: (column) => column);

  GeneratedColumn<String> get downloadStatus => $composableBuilder(
    column: $table.downloadStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thinkingMode => $composableBuilder(
    column: $table.thinkingMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get thinkingBudget => $composableBuilder(
    column: $table.thinkingBudget,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get supportsThinking => $composableBuilder(
    column: $table.supportsThinking,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minThinkingBudget => $composableBuilder(
    column: $table.minThinkingBudget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxThinkingBudget => $composableBuilder(
    column: $table.maxThinkingBudget,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ModelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ModelsTable,
          Model,
          $$ModelsTableFilterComposer,
          $$ModelsTableOrderingComposer,
          $$ModelsTableAnnotationComposer,
          $$ModelsTableCreateCompanionBuilder,
          $$ModelsTableUpdateCompanionBuilder,
          (Model, BaseReferences<_$AppDatabase, $ModelsTable, Model>),
          Model,
          PrefetchHooks Function()
        > {
  $$ModelsTableTableManager(_$AppDatabase db, $ModelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> path = const Value.absent(),
                Value<String?> apiConfig = const Value.absent(),
                Value<String?> capabilities = const Value.absent(),
                Value<String?> defaultParams = const Value.absent(),
                Value<bool> isMultimodal = const Value.absent(),
                Value<String?> mmprojPath = const Value.absent(),
                Value<String?> mmprojFileName = const Value.absent(),
                Value<bool> isLoaded = const Value.absent(),
                Value<String> downloadStatus = const Value.absent(),
                Value<String> thinkingMode = const Value.absent(),
                Value<int?> thinkingBudget = const Value.absent(),
                Value<bool> supportsThinking = const Value.absent(),
                Value<int> minThinkingBudget = const Value.absent(),
                Value<int> maxThinkingBudget = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModelsCompanion(
                id: id,
                name: name,
                type: type,
                source: source,
                path: path,
                apiConfig: apiConfig,
                capabilities: capabilities,
                defaultParams: defaultParams,
                isMultimodal: isMultimodal,
                mmprojPath: mmprojPath,
                mmprojFileName: mmprojFileName,
                isLoaded: isLoaded,
                downloadStatus: downloadStatus,
                thinkingMode: thinkingMode,
                thinkingBudget: thinkingBudget,
                supportsThinking: supportsThinking,
                minThinkingBudget: minThinkingBudget,
                maxThinkingBudget: maxThinkingBudget,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required String source,
                Value<String?> path = const Value.absent(),
                Value<String?> apiConfig = const Value.absent(),
                Value<String?> capabilities = const Value.absent(),
                Value<String?> defaultParams = const Value.absent(),
                Value<bool> isMultimodal = const Value.absent(),
                Value<String?> mmprojPath = const Value.absent(),
                Value<String?> mmprojFileName = const Value.absent(),
                Value<bool> isLoaded = const Value.absent(),
                Value<String> downloadStatus = const Value.absent(),
                Value<String> thinkingMode = const Value.absent(),
                Value<int?> thinkingBudget = const Value.absent(),
                Value<bool> supportsThinking = const Value.absent(),
                Value<int> minThinkingBudget = const Value.absent(),
                Value<int> maxThinkingBudget = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ModelsCompanion.insert(
                id: id,
                name: name,
                type: type,
                source: source,
                path: path,
                apiConfig: apiConfig,
                capabilities: capabilities,
                defaultParams: defaultParams,
                isMultimodal: isMultimodal,
                mmprojPath: mmprojPath,
                mmprojFileName: mmprojFileName,
                isLoaded: isLoaded,
                downloadStatus: downloadStatus,
                thinkingMode: thinkingMode,
                thinkingBudget: thinkingBudget,
                supportsThinking: supportsThinking,
                minThinkingBudget: minThinkingBudget,
                maxThinkingBudget: maxThinkingBudget,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ModelsTable,
      Model,
      $$ModelsTableFilterComposer,
      $$ModelsTableOrderingComposer,
      $$ModelsTableAnnotationComposer,
      $$ModelsTableCreateCompanionBuilder,
      $$ModelsTableUpdateCompanionBuilder,
      (Model, BaseReferences<_$AppDatabase, $ModelsTable, Model>),
      Model,
      PrefetchHooks Function()
    >;
typedef $$MemoriesTableCreateCompanionBuilder =
    MemoriesCompanion Function({
      required String id,
      Value<String?> sessionId,
      required String type,
      required String content,
      Value<String?> entityTags,
      Value<double> weight,
      Value<bool> isGlobal,
      Value<bool> isArchived,
      Value<String?> embedding,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> lastAccessedAt,
      Value<int> rowid,
    });
typedef $$MemoriesTableUpdateCompanionBuilder =
    MemoriesCompanion Function({
      Value<String> id,
      Value<String?> sessionId,
      Value<String> type,
      Value<String> content,
      Value<String?> entityTags,
      Value<double> weight,
      Value<bool> isGlobal,
      Value<bool> isArchived,
      Value<String?> embedding,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastAccessedAt,
      Value<int> rowid,
    });

class $$MemoriesTableFilterComposer
    extends Composer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityTags => $composableBuilder(
    column: $table.entityTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGlobal => $composableBuilder(
    column: $table.isGlobal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTags => $composableBuilder(
    column: $table.entityTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGlobal => $composableBuilder(
    column: $table.isGlobal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get entityTags => $composableBuilder(
    column: $table.entityTags,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<bool> get isGlobal =>
      $composableBuilder(column: $table.isGlobal, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get embedding =>
      $composableBuilder(column: $table.embedding, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );
}

class $$MemoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoriesTable,
          Memory,
          $$MemoriesTableFilterComposer,
          $$MemoriesTableOrderingComposer,
          $$MemoriesTableAnnotationComposer,
          $$MemoriesTableCreateCompanionBuilder,
          $$MemoriesTableUpdateCompanionBuilder,
          (Memory, BaseReferences<_$AppDatabase, $MemoriesTable, Memory>),
          Memory,
          PrefetchHooks Function()
        > {
  $$MemoriesTableTableManager(_$AppDatabase db, $MemoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> entityTags = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<bool> isGlobal = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String?> embedding = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastAccessedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoriesCompanion(
                id: id,
                sessionId: sessionId,
                type: type,
                content: content,
                entityTags: entityTags,
                weight: weight,
                isGlobal: isGlobal,
                isArchived: isArchived,
                embedding: embedding,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> sessionId = const Value.absent(),
                required String type,
                required String content,
                Value<String?> entityTags = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<bool> isGlobal = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String?> embedding = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> lastAccessedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoriesCompanion.insert(
                id: id,
                sessionId: sessionId,
                type: type,
                content: content,
                entityTags: entityTags,
                weight: weight,
                isGlobal: isGlobal,
                isArchived: isArchived,
                embedding: embedding,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoriesTable,
      Memory,
      $$MemoriesTableFilterComposer,
      $$MemoriesTableOrderingComposer,
      $$MemoriesTableAnnotationComposer,
      $$MemoriesTableCreateCompanionBuilder,
      $$MemoriesTableUpdateCompanionBuilder,
      (Memory, BaseReferences<_$AppDatabase, $MemoriesTable, Memory>),
      Memory,
      PrefetchHooks Function()
    >;
typedef $$KnowledgeBasesTableCreateCompanionBuilder =
    KnowledgeBasesCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<int> documentCount,
      Value<String?> sessionId,
      Value<bool> isGlobal,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$KnowledgeBasesTableUpdateCompanionBuilder =
    KnowledgeBasesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<int> documentCount,
      Value<String?> sessionId,
      Value<bool> isGlobal,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$KnowledgeBasesTableFilterComposer
    extends Composer<_$AppDatabase, $KnowledgeBasesTable> {
  $$KnowledgeBasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get documentCount => $composableBuilder(
    column: $table.documentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGlobal => $composableBuilder(
    column: $table.isGlobal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KnowledgeBasesTableOrderingComposer
    extends Composer<_$AppDatabase, $KnowledgeBasesTable> {
  $$KnowledgeBasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get documentCount => $composableBuilder(
    column: $table.documentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGlobal => $composableBuilder(
    column: $table.isGlobal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KnowledgeBasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KnowledgeBasesTable> {
  $$KnowledgeBasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get documentCount => $composableBuilder(
    column: $table.documentCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<bool> get isGlobal =>
      $composableBuilder(column: $table.isGlobal, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$KnowledgeBasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KnowledgeBasesTable,
          KnowledgeBase,
          $$KnowledgeBasesTableFilterComposer,
          $$KnowledgeBasesTableOrderingComposer,
          $$KnowledgeBasesTableAnnotationComposer,
          $$KnowledgeBasesTableCreateCompanionBuilder,
          $$KnowledgeBasesTableUpdateCompanionBuilder,
          (
            KnowledgeBase,
            BaseReferences<_$AppDatabase, $KnowledgeBasesTable, KnowledgeBase>,
          ),
          KnowledgeBase,
          PrefetchHooks Function()
        > {
  $$KnowledgeBasesTableTableManager(
    _$AppDatabase db,
    $KnowledgeBasesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KnowledgeBasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KnowledgeBasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KnowledgeBasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> documentCount = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<bool> isGlobal = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KnowledgeBasesCompanion(
                id: id,
                name: name,
                description: description,
                documentCount: documentCount,
                sessionId: sessionId,
                isGlobal: isGlobal,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int> documentCount = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<bool> isGlobal = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => KnowledgeBasesCompanion.insert(
                id: id,
                name: name,
                description: description,
                documentCount: documentCount,
                sessionId: sessionId,
                isGlobal: isGlobal,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KnowledgeBasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KnowledgeBasesTable,
      KnowledgeBase,
      $$KnowledgeBasesTableFilterComposer,
      $$KnowledgeBasesTableOrderingComposer,
      $$KnowledgeBasesTableAnnotationComposer,
      $$KnowledgeBasesTableCreateCompanionBuilder,
      $$KnowledgeBasesTableUpdateCompanionBuilder,
      (
        KnowledgeBase,
        BaseReferences<_$AppDatabase, $KnowledgeBasesTable, KnowledgeBase>,
      ),
      KnowledgeBase,
      PrefetchHooks Function()
    >;
typedef $$DocumentsTableCreateCompanionBuilder =
    DocumentsCompanion Function({
      required String id,
      required String knowledgeBaseId,
      required String fileName,
      required String filePath,
      required String fileType,
      required int fileSize,
      Value<int> chunkCount,
      Value<String> status,
      Value<String?> errorMessage,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DocumentsTableUpdateCompanionBuilder =
    DocumentsCompanion Function({
      Value<String> id,
      Value<String> knowledgeBaseId,
      Value<String> fileName,
      Value<String> filePath,
      Value<String> fileType,
      Value<int> fileSize,
      Value<int> chunkCount,
      Value<String> status,
      Value<String?> errorMessage,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get knowledgeBaseId => $composableBuilder(
    column: $table.knowledgeBaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunkCount => $composableBuilder(
    column: $table.chunkCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get knowledgeBaseId => $composableBuilder(
    column: $table.knowledgeBaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunkCount => $composableBuilder(
    column: $table.chunkCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get knowledgeBaseId => $composableBuilder(
    column: $table.knowledgeBaseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get chunkCount => $composableBuilder(
    column: $table.chunkCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentsTable,
          Document,
          $$DocumentsTableFilterComposer,
          $$DocumentsTableOrderingComposer,
          $$DocumentsTableAnnotationComposer,
          $$DocumentsTableCreateCompanionBuilder,
          $$DocumentsTableUpdateCompanionBuilder,
          (Document, BaseReferences<_$AppDatabase, $DocumentsTable, Document>),
          Document,
          PrefetchHooks Function()
        > {
  $$DocumentsTableTableManager(_$AppDatabase db, $DocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> knowledgeBaseId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> fileType = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<int> chunkCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion(
                id: id,
                knowledgeBaseId: knowledgeBaseId,
                fileName: fileName,
                filePath: filePath,
                fileType: fileType,
                fileSize: fileSize,
                chunkCount: chunkCount,
                status: status,
                errorMessage: errorMessage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String knowledgeBaseId,
                required String fileName,
                required String filePath,
                required String fileType,
                required int fileSize,
                Value<int> chunkCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion.insert(
                id: id,
                knowledgeBaseId: knowledgeBaseId,
                fileName: fileName,
                filePath: filePath,
                fileType: fileType,
                fileSize: fileSize,
                chunkCount: chunkCount,
                status: status,
                errorMessage: errorMessage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentsTable,
      Document,
      $$DocumentsTableFilterComposer,
      $$DocumentsTableOrderingComposer,
      $$DocumentsTableAnnotationComposer,
      $$DocumentsTableCreateCompanionBuilder,
      $$DocumentsTableUpdateCompanionBuilder,
      (Document, BaseReferences<_$AppDatabase, $DocumentsTable, Document>),
      Document,
      PrefetchHooks Function()
    >;
typedef $$DocumentChunksTableCreateCompanionBuilder =
    DocumentChunksCompanion Function({
      required String id,
      required String knowledgeBaseId,
      required String documentId,
      required String content,
      required int chunkIndex,
      Value<String?> vector,
      Value<String?> metadata,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DocumentChunksTableUpdateCompanionBuilder =
    DocumentChunksCompanion Function({
      Value<String> id,
      Value<String> knowledgeBaseId,
      Value<String> documentId,
      Value<String> content,
      Value<int> chunkIndex,
      Value<String?> vector,
      Value<String?> metadata,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$DocumentChunksTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentChunksTable> {
  $$DocumentChunksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get knowledgeBaseId => $composableBuilder(
    column: $table.knowledgeBaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunkIndex => $composableBuilder(
    column: $table.chunkIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DocumentChunksTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentChunksTable> {
  $$DocumentChunksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get knowledgeBaseId => $composableBuilder(
    column: $table.knowledgeBaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunkIndex => $composableBuilder(
    column: $table.chunkIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentChunksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentChunksTable> {
  $$DocumentChunksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get knowledgeBaseId => $composableBuilder(
    column: $table.knowledgeBaseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get chunkIndex => $composableBuilder(
    column: $table.chunkIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vector =>
      $composableBuilder(column: $table.vector, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DocumentChunksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentChunksTable,
          DocumentChunk,
          $$DocumentChunksTableFilterComposer,
          $$DocumentChunksTableOrderingComposer,
          $$DocumentChunksTableAnnotationComposer,
          $$DocumentChunksTableCreateCompanionBuilder,
          $$DocumentChunksTableUpdateCompanionBuilder,
          (
            DocumentChunk,
            BaseReferences<_$AppDatabase, $DocumentChunksTable, DocumentChunk>,
          ),
          DocumentChunk,
          PrefetchHooks Function()
        > {
  $$DocumentChunksTableTableManager(
    _$AppDatabase db,
    $DocumentChunksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentChunksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentChunksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentChunksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> knowledgeBaseId = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> chunkIndex = const Value.absent(),
                Value<String?> vector = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentChunksCompanion(
                id: id,
                knowledgeBaseId: knowledgeBaseId,
                documentId: documentId,
                content: content,
                chunkIndex: chunkIndex,
                vector: vector,
                metadata: metadata,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String knowledgeBaseId,
                required String documentId,
                required String content,
                required int chunkIndex,
                Value<String?> vector = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DocumentChunksCompanion.insert(
                id: id,
                knowledgeBaseId: knowledgeBaseId,
                documentId: documentId,
                content: content,
                chunkIndex: chunkIndex,
                vector: vector,
                metadata: metadata,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DocumentChunksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentChunksTable,
      DocumentChunk,
      $$DocumentChunksTableFilterComposer,
      $$DocumentChunksTableOrderingComposer,
      $$DocumentChunksTableAnnotationComposer,
      $$DocumentChunksTableCreateCompanionBuilder,
      $$DocumentChunksTableUpdateCompanionBuilder,
      (
        DocumentChunk,
        BaseReferences<_$AppDatabase, $DocumentChunksTable, DocumentChunk>,
      ),
      DocumentChunk,
      PrefetchHooks Function()
    >;
typedef $$PromptTemplatesTableCreateCompanionBuilder =
    PromptTemplatesCompanion Function({
      required String id,
      required String name,
      required String content,
      Value<String?> variables,
      Value<String> category,
      Value<bool> isGlobal,
      Value<bool> isBuiltin,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PromptTemplatesTableUpdateCompanionBuilder =
    PromptTemplatesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> content,
      Value<String?> variables,
      Value<String> category,
      Value<bool> isGlobal,
      Value<bool> isBuiltin,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PromptTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $PromptTemplatesTable> {
  $$PromptTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variables => $composableBuilder(
    column: $table.variables,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGlobal => $composableBuilder(
    column: $table.isGlobal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PromptTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PromptTemplatesTable> {
  $$PromptTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variables => $composableBuilder(
    column: $table.variables,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGlobal => $composableBuilder(
    column: $table.isGlobal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PromptTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromptTemplatesTable> {
  $$PromptTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get variables =>
      $composableBuilder(column: $table.variables, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isGlobal =>
      $composableBuilder(column: $table.isGlobal, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltin =>
      $composableBuilder(column: $table.isBuiltin, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PromptTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PromptTemplatesTable,
          PromptTemplate,
          $$PromptTemplatesTableFilterComposer,
          $$PromptTemplatesTableOrderingComposer,
          $$PromptTemplatesTableAnnotationComposer,
          $$PromptTemplatesTableCreateCompanionBuilder,
          $$PromptTemplatesTableUpdateCompanionBuilder,
          (
            PromptTemplate,
            BaseReferences<
              _$AppDatabase,
              $PromptTemplatesTable,
              PromptTemplate
            >,
          ),
          PromptTemplate,
          PrefetchHooks Function()
        > {
  $$PromptTemplatesTableTableManager(
    _$AppDatabase db,
    $PromptTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromptTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromptTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromptTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> variables = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> isGlobal = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PromptTemplatesCompanion(
                id: id,
                name: name,
                content: content,
                variables: variables,
                category: category,
                isGlobal: isGlobal,
                isBuiltin: isBuiltin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String content,
                Value<String?> variables = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> isGlobal = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PromptTemplatesCompanion.insert(
                id: id,
                name: name,
                content: content,
                variables: variables,
                category: category,
                isGlobal: isGlobal,
                isBuiltin: isBuiltin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PromptTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PromptTemplatesTable,
      PromptTemplate,
      $$PromptTemplatesTableFilterComposer,
      $$PromptTemplatesTableOrderingComposer,
      $$PromptTemplatesTableAnnotationComposer,
      $$PromptTemplatesTableCreateCompanionBuilder,
      $$PromptTemplatesTableUpdateCompanionBuilder,
      (
        PromptTemplate,
        BaseReferences<_$AppDatabase, $PromptTemplatesTable, PromptTemplate>,
      ),
      PromptTemplate,
      PrefetchHooks Function()
    >;
typedef $$SessionPromptsTableCreateCompanionBuilder =
    SessionPromptsCompanion Function({
      required String id,
      required String sessionId,
      Value<String?> templateId,
      required String promptContent,
      Value<String?> variables,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SessionPromptsTableUpdateCompanionBuilder =
    SessionPromptsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String?> templateId,
      Value<String> promptContent,
      Value<String?> variables,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SessionPromptsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionPromptsTable> {
  $$SessionPromptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promptContent => $composableBuilder(
    column: $table.promptContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variables => $composableBuilder(
    column: $table.variables,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionPromptsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionPromptsTable> {
  $$SessionPromptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptContent => $composableBuilder(
    column: $table.promptContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variables => $composableBuilder(
    column: $table.variables,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionPromptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionPromptsTable> {
  $$SessionPromptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get promptContent => $composableBuilder(
    column: $table.promptContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get variables =>
      $composableBuilder(column: $table.variables, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SessionPromptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionPromptsTable,
          SessionPrompt,
          $$SessionPromptsTableFilterComposer,
          $$SessionPromptsTableOrderingComposer,
          $$SessionPromptsTableAnnotationComposer,
          $$SessionPromptsTableCreateCompanionBuilder,
          $$SessionPromptsTableUpdateCompanionBuilder,
          (
            SessionPrompt,
            BaseReferences<_$AppDatabase, $SessionPromptsTable, SessionPrompt>,
          ),
          SessionPrompt,
          PrefetchHooks Function()
        > {
  $$SessionPromptsTableTableManager(
    _$AppDatabase db,
    $SessionPromptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionPromptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionPromptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionPromptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                Value<String> promptContent = const Value.absent(),
                Value<String?> variables = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionPromptsCompanion(
                id: id,
                sessionId: sessionId,
                templateId: templateId,
                promptContent: promptContent,
                variables: variables,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                Value<String?> templateId = const Value.absent(),
                required String promptContent,
                Value<String?> variables = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionPromptsCompanion.insert(
                id: id,
                sessionId: sessionId,
                templateId: templateId,
                promptContent: promptContent,
                variables: variables,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionPromptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionPromptsTable,
      SessionPrompt,
      $$SessionPromptsTableFilterComposer,
      $$SessionPromptsTableOrderingComposer,
      $$SessionPromptsTableAnnotationComposer,
      $$SessionPromptsTableCreateCompanionBuilder,
      $$SessionPromptsTableUpdateCompanionBuilder,
      (
        SessionPrompt,
        BaseReferences<_$AppDatabase, $SessionPromptsTable, SessionPrompt>,
      ),
      SessionPrompt,
      PrefetchHooks Function()
    >;
typedef $$DownloadTasksTableCreateCompanionBuilder =
    DownloadTasksCompanion Function({
      required String id,
      required String modelId,
      required String url,
      required String savePath,
      required String status,
      Value<int> progress,
      Value<int> totalBytes,
      Value<int> downloadedBytes,
      required String source,
      Value<String?> quantLevel,
      Value<String?> metadata,
      Value<String?> error,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$DownloadTasksTableUpdateCompanionBuilder =
    DownloadTasksCompanion Function({
      Value<String> id,
      Value<String> modelId,
      Value<String> url,
      Value<String> savePath,
      Value<String> status,
      Value<int> progress,
      Value<int> totalBytes,
      Value<int> downloadedBytes,
      Value<String> source,
      Value<String?> quantLevel,
      Value<String?> metadata,
      Value<String?> error,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$DownloadTasksTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get savePath => $composableBuilder(
    column: $table.savePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantLevel => $composableBuilder(
    column: $table.quantLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get savePath => $composableBuilder(
    column: $table.savePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantLevel => $composableBuilder(
    column: $table.quantLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get savePath =>
      $composableBuilder(column: $table.savePath, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get quantLevel => $composableBuilder(
    column: $table.quantLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$DownloadTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadTasksTable,
          DownloadTask,
          $$DownloadTasksTableFilterComposer,
          $$DownloadTasksTableOrderingComposer,
          $$DownloadTasksTableAnnotationComposer,
          $$DownloadTasksTableCreateCompanionBuilder,
          $$DownloadTasksTableUpdateCompanionBuilder,
          (
            DownloadTask,
            BaseReferences<_$AppDatabase, $DownloadTasksTable, DownloadTask>,
          ),
          DownloadTask,
          PrefetchHooks Function()
        > {
  $$DownloadTasksTableTableManager(_$AppDatabase db, $DownloadTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> savePath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<int> totalBytes = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> quantLevel = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadTasksCompanion(
                id: id,
                modelId: modelId,
                url: url,
                savePath: savePath,
                status: status,
                progress: progress,
                totalBytes: totalBytes,
                downloadedBytes: downloadedBytes,
                source: source,
                quantLevel: quantLevel,
                metadata: metadata,
                error: error,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String modelId,
                required String url,
                required String savePath,
                required String status,
                Value<int> progress = const Value.absent(),
                Value<int> totalBytes = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                required String source,
                Value<String?> quantLevel = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<String?> error = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadTasksCompanion.insert(
                id: id,
                modelId: modelId,
                url: url,
                savePath: savePath,
                status: status,
                progress: progress,
                totalBytes: totalBytes,
                downloadedBytes: downloadedBytes,
                source: source,
                quantLevel: quantLevel,
                metadata: metadata,
                error: error,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadTasksTable,
      DownloadTask,
      $$DownloadTasksTableFilterComposer,
      $$DownloadTasksTableOrderingComposer,
      $$DownloadTasksTableAnnotationComposer,
      $$DownloadTasksTableCreateCompanionBuilder,
      $$DownloadTasksTableUpdateCompanionBuilder,
      (
        DownloadTask,
        BaseReferences<_$AppDatabase, $DownloadTasksTable, DownloadTask>,
      ),
      DownloadTask,
      PrefetchHooks Function()
    >;
typedef $$McpServerConfigsTableCreateCompanionBuilder =
    McpServerConfigsCompanion Function({
      required String id,
      required String serverId,
      required String name,
      required String type,
      required String command,
      Value<String?> args,
      Value<String?> env,
      Value<bool> isEnabled,
      Value<bool> isAutoStart,
      Value<String?> lastError,
      Value<DateTime?> lastConnectedTime,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$McpServerConfigsTableUpdateCompanionBuilder =
    McpServerConfigsCompanion Function({
      Value<String> id,
      Value<String> serverId,
      Value<String> name,
      Value<String> type,
      Value<String> command,
      Value<String?> args,
      Value<String?> env,
      Value<bool> isEnabled,
      Value<bool> isAutoStart,
      Value<String?> lastError,
      Value<DateTime?> lastConnectedTime,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$McpServerConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $McpServerConfigsTable> {
  $$McpServerConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get command => $composableBuilder(
    column: $table.command,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get args => $composableBuilder(
    column: $table.args,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get env => $composableBuilder(
    column: $table.env,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAutoStart => $composableBuilder(
    column: $table.isAutoStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastConnectedTime => $composableBuilder(
    column: $table.lastConnectedTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$McpServerConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $McpServerConfigsTable> {
  $$McpServerConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get command => $composableBuilder(
    column: $table.command,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get args => $composableBuilder(
    column: $table.args,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get env => $composableBuilder(
    column: $table.env,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAutoStart => $composableBuilder(
    column: $table.isAutoStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastConnectedTime => $composableBuilder(
    column: $table.lastConnectedTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$McpServerConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $McpServerConfigsTable> {
  $$McpServerConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get command =>
      $composableBuilder(column: $table.command, builder: (column) => column);

  GeneratedColumn<String> get args =>
      $composableBuilder(column: $table.args, builder: (column) => column);

  GeneratedColumn<String> get env =>
      $composableBuilder(column: $table.env, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<bool> get isAutoStart => $composableBuilder(
    column: $table.isAutoStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get lastConnectedTime => $composableBuilder(
    column: $table.lastConnectedTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$McpServerConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $McpServerConfigsTable,
          McpServerConfig,
          $$McpServerConfigsTableFilterComposer,
          $$McpServerConfigsTableOrderingComposer,
          $$McpServerConfigsTableAnnotationComposer,
          $$McpServerConfigsTableCreateCompanionBuilder,
          $$McpServerConfigsTableUpdateCompanionBuilder,
          (
            McpServerConfig,
            BaseReferences<
              _$AppDatabase,
              $McpServerConfigsTable,
              McpServerConfig
            >,
          ),
          McpServerConfig,
          PrefetchHooks Function()
        > {
  $$McpServerConfigsTableTableManager(
    _$AppDatabase db,
    $McpServerConfigsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$McpServerConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$McpServerConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$McpServerConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> serverId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> command = const Value.absent(),
                Value<String?> args = const Value.absent(),
                Value<String?> env = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<bool> isAutoStart = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> lastConnectedTime = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => McpServerConfigsCompanion(
                id: id,
                serverId: serverId,
                name: name,
                type: type,
                command: command,
                args: args,
                env: env,
                isEnabled: isEnabled,
                isAutoStart: isAutoStart,
                lastError: lastError,
                lastConnectedTime: lastConnectedTime,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String serverId,
                required String name,
                required String type,
                required String command,
                Value<String?> args = const Value.absent(),
                Value<String?> env = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<bool> isAutoStart = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> lastConnectedTime = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => McpServerConfigsCompanion.insert(
                id: id,
                serverId: serverId,
                name: name,
                type: type,
                command: command,
                args: args,
                env: env,
                isEnabled: isEnabled,
                isAutoStart: isAutoStart,
                lastError: lastError,
                lastConnectedTime: lastConnectedTime,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$McpServerConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $McpServerConfigsTable,
      McpServerConfig,
      $$McpServerConfigsTableFilterComposer,
      $$McpServerConfigsTableOrderingComposer,
      $$McpServerConfigsTableAnnotationComposer,
      $$McpServerConfigsTableCreateCompanionBuilder,
      $$McpServerConfigsTableUpdateCompanionBuilder,
      (
        McpServerConfig,
        BaseReferences<_$AppDatabase, $McpServerConfigsTable, McpServerConfig>,
      ),
      McpServerConfig,
      PrefetchHooks Function()
    >;
typedef $$FoldersTableCreateCompanionBuilder =
    FoldersCompanion Function({
      required String id,
      required String name,
      Value<String> color,
      Value<String> icon,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FoldersTableUpdateCompanionBuilder =
    FoldersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> color,
      Value<String> icon,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, BaseReferences<_$AppDatabase, $FoldersTable, Folder>),
          Folder,
          PrefetchHooks Function()
        > {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                name: name,
                color: color,
                icon: icon,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion.insert(
                id: id,
                name: name,
                color: color,
                icon: icon,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, BaseReferences<_$AppDatabase, $FoldersTable, Folder>),
      Folder,
      PrefetchHooks Function()
    >;
typedef $$AppLogsTableCreateCompanionBuilder =
    AppLogsCompanion Function({
      required String id,
      required String level,
      required String category,
      required String title,
      required String message,
      Value<String?> stackTrace,
      Value<String?> deviceInfo,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AppLogsTableUpdateCompanionBuilder =
    AppLogsCompanion Function({
      Value<String> id,
      Value<String> level,
      Value<String> category,
      Value<String> title,
      Value<String> message,
      Value<String?> stackTrace,
      Value<String?> deviceInfo,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AppLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AppLogsTable> {
  $$AppLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceInfo => $composableBuilder(
    column: $table.deviceInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppLogsTable> {
  $$AppLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceInfo => $composableBuilder(
    column: $table.deviceInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppLogsTable> {
  $$AppLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceInfo => $composableBuilder(
    column: $table.deviceInfo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AppLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppLogsTable,
          AppLog,
          $$AppLogsTableFilterComposer,
          $$AppLogsTableOrderingComposer,
          $$AppLogsTableAnnotationComposer,
          $$AppLogsTableCreateCompanionBuilder,
          $$AppLogsTableUpdateCompanionBuilder,
          (AppLog, BaseReferences<_$AppDatabase, $AppLogsTable, AppLog>),
          AppLog,
          PrefetchHooks Function()
        > {
  $$AppLogsTableTableManager(_$AppDatabase db, $AppLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String?> stackTrace = const Value.absent(),
                Value<String?> deviceInfo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppLogsCompanion(
                id: id,
                level: level,
                category: category,
                title: title,
                message: message,
                stackTrace: stackTrace,
                deviceInfo: deviceInfo,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String level,
                required String category,
                required String title,
                required String message,
                Value<String?> stackTrace = const Value.absent(),
                Value<String?> deviceInfo = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AppLogsCompanion.insert(
                id: id,
                level: level,
                category: category,
                title: title,
                message: message,
                stackTrace: stackTrace,
                deviceInfo: deviceInfo,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppLogsTable,
      AppLog,
      $$AppLogsTableFilterComposer,
      $$AppLogsTableOrderingComposer,
      $$AppLogsTableAnnotationComposer,
      $$AppLogsTableCreateCompanionBuilder,
      $$AppLogsTableUpdateCompanionBuilder,
      (AppLog, BaseReferences<_$AppDatabase, $AppLogsTable, AppLog>),
      AppLog,
      PrefetchHooks Function()
    >;
typedef $$SessionSummariesTableCreateCompanionBuilder =
    SessionSummariesCompanion Function({
      required String sessionId,
      Value<String> summary,
      Value<String?> systemPrompt,
      Value<String?> activeMessagesJson,
      Value<int> maxContextTokens,
      Value<int> compressionCount,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SessionSummariesTableUpdateCompanionBuilder =
    SessionSummariesCompanion Function({
      Value<String> sessionId,
      Value<String> summary,
      Value<String?> systemPrompt,
      Value<String?> activeMessagesJson,
      Value<int> maxContextTokens,
      Value<int> compressionCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SessionSummariesTableFilterComposer
    extends Composer<_$AppDatabase, $SessionSummariesTable> {
  $$SessionSummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeMessagesJson => $composableBuilder(
    column: $table.activeMessagesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxContextTokens => $composableBuilder(
    column: $table.maxContextTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get compressionCount => $composableBuilder(
    column: $table.compressionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionSummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionSummariesTable> {
  $$SessionSummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeMessagesJson => $composableBuilder(
    column: $table.activeMessagesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxContextTokens => $composableBuilder(
    column: $table.maxContextTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get compressionCount => $composableBuilder(
    column: $table.compressionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionSummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionSummariesTable> {
  $$SessionSummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeMessagesJson => $composableBuilder(
    column: $table.activeMessagesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxContextTokens => $composableBuilder(
    column: $table.maxContextTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get compressionCount => $composableBuilder(
    column: $table.compressionCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionSummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionSummariesTable,
          SessionSummary,
          $$SessionSummariesTableFilterComposer,
          $$SessionSummariesTableOrderingComposer,
          $$SessionSummariesTableAnnotationComposer,
          $$SessionSummariesTableCreateCompanionBuilder,
          $$SessionSummariesTableUpdateCompanionBuilder,
          (
            SessionSummary,
            BaseReferences<
              _$AppDatabase,
              $SessionSummariesTable,
              SessionSummary
            >,
          ),
          SessionSummary,
          PrefetchHooks Function()
        > {
  $$SessionSummariesTableTableManager(
    _$AppDatabase db,
    $SessionSummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionSummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionSummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionSummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String?> systemPrompt = const Value.absent(),
                Value<String?> activeMessagesJson = const Value.absent(),
                Value<int> maxContextTokens = const Value.absent(),
                Value<int> compressionCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionSummariesCompanion(
                sessionId: sessionId,
                summary: summary,
                systemPrompt: systemPrompt,
                activeMessagesJson: activeMessagesJson,
                maxContextTokens: maxContextTokens,
                compressionCount: compressionCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                Value<String> summary = const Value.absent(),
                Value<String?> systemPrompt = const Value.absent(),
                Value<String?> activeMessagesJson = const Value.absent(),
                Value<int> maxContextTokens = const Value.absent(),
                Value<int> compressionCount = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionSummariesCompanion.insert(
                sessionId: sessionId,
                summary: summary,
                systemPrompt: systemPrompt,
                activeMessagesJson: activeMessagesJson,
                maxContextTokens: maxContextTokens,
                compressionCount: compressionCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionSummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionSummariesTable,
      SessionSummary,
      $$SessionSummariesTableFilterComposer,
      $$SessionSummariesTableOrderingComposer,
      $$SessionSummariesTableAnnotationComposer,
      $$SessionSummariesTableCreateCompanionBuilder,
      $$SessionSummariesTableUpdateCompanionBuilder,
      (
        SessionSummary,
        BaseReferences<_$AppDatabase, $SessionSummariesTable, SessionSummary>,
      ),
      SessionSummary,
      PrefetchHooks Function()
    >;
typedef $$PluginRegistriesTableCreateCompanionBuilder =
    PluginRegistriesCompanion Function({
      required String id,
      required String name,
      required String version,
      Value<String?> author,
      Value<String?> description,
      Value<String?> repository,
      Value<String> entryPoint,
      required String installPath,
      Value<String?> permissions,
      Value<String?> config,
      Value<String> status,
      Value<String?> errorMessage,
      required DateTime installedAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> lastUsedAt,
      Value<int> rowid,
    });
typedef $$PluginRegistriesTableUpdateCompanionBuilder =
    PluginRegistriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> version,
      Value<String?> author,
      Value<String?> description,
      Value<String?> repository,
      Value<String> entryPoint,
      Value<String> installPath,
      Value<String?> permissions,
      Value<String?> config,
      Value<String> status,
      Value<String?> errorMessage,
      Value<DateTime> installedAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> lastUsedAt,
      Value<int> rowid,
    });

class $$PluginRegistriesTableFilterComposer
    extends Composer<_$AppDatabase, $PluginRegistriesTable> {
  $$PluginRegistriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repository => $composableBuilder(
    column: $table.repository,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryPoint => $composableBuilder(
    column: $table.entryPoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get installPath => $composableBuilder(
    column: $table.installPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get config => $composableBuilder(
    column: $table.config,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PluginRegistriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PluginRegistriesTable> {
  $$PluginRegistriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repository => $composableBuilder(
    column: $table.repository,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryPoint => $composableBuilder(
    column: $table.entryPoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installPath => $composableBuilder(
    column: $table.installPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get config => $composableBuilder(
    column: $table.config,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PluginRegistriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PluginRegistriesTable> {
  $$PluginRegistriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repository => $composableBuilder(
    column: $table.repository,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryPoint => $composableBuilder(
    column: $table.entryPoint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get installPath => $composableBuilder(
    column: $table.installPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get config =>
      $composableBuilder(column: $table.config, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$PluginRegistriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PluginRegistriesTable,
          PluginRegistry,
          $$PluginRegistriesTableFilterComposer,
          $$PluginRegistriesTableOrderingComposer,
          $$PluginRegistriesTableAnnotationComposer,
          $$PluginRegistriesTableCreateCompanionBuilder,
          $$PluginRegistriesTableUpdateCompanionBuilder,
          (
            PluginRegistry,
            BaseReferences<
              _$AppDatabase,
              $PluginRegistriesTable,
              PluginRegistry
            >,
          ),
          PluginRegistry,
          PrefetchHooks Function()
        > {
  $$PluginRegistriesTableTableManager(
    _$AppDatabase db,
    $PluginRegistriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PluginRegistriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PluginRegistriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PluginRegistriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> repository = const Value.absent(),
                Value<String> entryPoint = const Value.absent(),
                Value<String> installPath = const Value.absent(),
                Value<String?> permissions = const Value.absent(),
                Value<String?> config = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PluginRegistriesCompanion(
                id: id,
                name: name,
                version: version,
                author: author,
                description: description,
                repository: repository,
                entryPoint: entryPoint,
                installPath: installPath,
                permissions: permissions,
                config: config,
                status: status,
                errorMessage: errorMessage,
                installedAt: installedAt,
                updatedAt: updatedAt,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String version,
                Value<String?> author = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> repository = const Value.absent(),
                Value<String> entryPoint = const Value.absent(),
                required String installPath,
                Value<String?> permissions = const Value.absent(),
                Value<String?> config = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                required DateTime installedAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PluginRegistriesCompanion.insert(
                id: id,
                name: name,
                version: version,
                author: author,
                description: description,
                repository: repository,
                entryPoint: entryPoint,
                installPath: installPath,
                permissions: permissions,
                config: config,
                status: status,
                errorMessage: errorMessage,
                installedAt: installedAt,
                updatedAt: updatedAt,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PluginRegistriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PluginRegistriesTable,
      PluginRegistry,
      $$PluginRegistriesTableFilterComposer,
      $$PluginRegistriesTableOrderingComposer,
      $$PluginRegistriesTableAnnotationComposer,
      $$PluginRegistriesTableCreateCompanionBuilder,
      $$PluginRegistriesTableUpdateCompanionBuilder,
      (
        PluginRegistry,
        BaseReferences<_$AppDatabase, $PluginRegistriesTable, PluginRegistry>,
      ),
      PluginRegistry,
      PrefetchHooks Function()
    >;
typedef $$SessionResourcesTableCreateCompanionBuilder =
    SessionResourcesCompanion Function({
      required String sessionId,
      required String resourceType,
      required String resourceId,
      Value<String?> config,
      Value<bool> isEnabled,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SessionResourcesTableUpdateCompanionBuilder =
    SessionResourcesCompanion Function({
      Value<String> sessionId,
      Value<String> resourceType,
      Value<String> resourceId,
      Value<String?> config,
      Value<bool> isEnabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SessionResourcesTableFilterComposer
    extends Composer<_$AppDatabase, $SessionResourcesTable> {
  $$SessionResourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceType => $composableBuilder(
    column: $table.resourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get config => $composableBuilder(
    column: $table.config,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionResourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionResourcesTable> {
  $$SessionResourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceType => $composableBuilder(
    column: $table.resourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get config => $composableBuilder(
    column: $table.config,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionResourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionResourcesTable> {
  $$SessionResourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get resourceType => $composableBuilder(
    column: $table.resourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get config =>
      $composableBuilder(column: $table.config, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionResourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionResourcesTable,
          SessionResource,
          $$SessionResourcesTableFilterComposer,
          $$SessionResourcesTableOrderingComposer,
          $$SessionResourcesTableAnnotationComposer,
          $$SessionResourcesTableCreateCompanionBuilder,
          $$SessionResourcesTableUpdateCompanionBuilder,
          (
            SessionResource,
            BaseReferences<
              _$AppDatabase,
              $SessionResourcesTable,
              SessionResource
            >,
          ),
          SessionResource,
          PrefetchHooks Function()
        > {
  $$SessionResourcesTableTableManager(
    _$AppDatabase db,
    $SessionResourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionResourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionResourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionResourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> resourceType = const Value.absent(),
                Value<String> resourceId = const Value.absent(),
                Value<String?> config = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionResourcesCompanion(
                sessionId: sessionId,
                resourceType: resourceType,
                resourceId: resourceId,
                config: config,
                isEnabled: isEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String resourceType,
                required String resourceId,
                Value<String?> config = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionResourcesCompanion.insert(
                sessionId: sessionId,
                resourceType: resourceType,
                resourceId: resourceId,
                config: config,
                isEnabled: isEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionResourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionResourcesTable,
      SessionResource,
      $$SessionResourcesTableFilterComposer,
      $$SessionResourcesTableOrderingComposer,
      $$SessionResourcesTableAnnotationComposer,
      $$SessionResourcesTableCreateCompanionBuilder,
      $$SessionResourcesTableUpdateCompanionBuilder,
      (
        SessionResource,
        BaseReferences<_$AppDatabase, $SessionResourcesTable, SessionResource>,
      ),
      SessionResource,
      PrefetchHooks Function()
    >;
typedef $$WorkflowDefinitionsTableCreateCompanionBuilder =
    WorkflowDefinitionsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<int> version,
      required String definitionJson,
      Value<String?> tags,
      Value<bool> isEnabled,
      Value<String> triggerType,
      Value<String?> triggerConfig,
      Value<String?> createdBy,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WorkflowDefinitionsTableUpdateCompanionBuilder =
    WorkflowDefinitionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<int> version,
      Value<String> definitionJson,
      Value<String?> tags,
      Value<bool> isEnabled,
      Value<String> triggerType,
      Value<String?> triggerConfig,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$WorkflowDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkflowDefinitionsTable> {
  $$WorkflowDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definitionJson => $composableBuilder(
    column: $table.definitionJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerType => $composableBuilder(
    column: $table.triggerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerConfig => $composableBuilder(
    column: $table.triggerConfig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkflowDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkflowDefinitionsTable> {
  $$WorkflowDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definitionJson => $composableBuilder(
    column: $table.definitionJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerType => $composableBuilder(
    column: $table.triggerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerConfig => $composableBuilder(
    column: $table.triggerConfig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkflowDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkflowDefinitionsTable> {
  $$WorkflowDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get definitionJson => $composableBuilder(
    column: $table.definitionJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<String> get triggerType => $composableBuilder(
    column: $table.triggerType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get triggerConfig => $composableBuilder(
    column: $table.triggerConfig,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WorkflowDefinitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkflowDefinitionsTable,
          WorkflowDefinitionRecord,
          $$WorkflowDefinitionsTableFilterComposer,
          $$WorkflowDefinitionsTableOrderingComposer,
          $$WorkflowDefinitionsTableAnnotationComposer,
          $$WorkflowDefinitionsTableCreateCompanionBuilder,
          $$WorkflowDefinitionsTableUpdateCompanionBuilder,
          (
            WorkflowDefinitionRecord,
            BaseReferences<
              _$AppDatabase,
              $WorkflowDefinitionsTable,
              WorkflowDefinitionRecord
            >,
          ),
          WorkflowDefinitionRecord,
          PrefetchHooks Function()
        > {
  $$WorkflowDefinitionsTableTableManager(
    _$AppDatabase db,
    $WorkflowDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkflowDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkflowDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkflowDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> definitionJson = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<String> triggerType = const Value.absent(),
                Value<String?> triggerConfig = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkflowDefinitionsCompanion(
                id: id,
                name: name,
                description: description,
                version: version,
                definitionJson: definitionJson,
                tags: tags,
                isEnabled: isEnabled,
                triggerType: triggerType,
                triggerConfig: triggerConfig,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int> version = const Value.absent(),
                required String definitionJson,
                Value<String?> tags = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<String> triggerType = const Value.absent(),
                Value<String?> triggerConfig = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkflowDefinitionsCompanion.insert(
                id: id,
                name: name,
                description: description,
                version: version,
                definitionJson: definitionJson,
                tags: tags,
                isEnabled: isEnabled,
                triggerType: triggerType,
                triggerConfig: triggerConfig,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkflowDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkflowDefinitionsTable,
      WorkflowDefinitionRecord,
      $$WorkflowDefinitionsTableFilterComposer,
      $$WorkflowDefinitionsTableOrderingComposer,
      $$WorkflowDefinitionsTableAnnotationComposer,
      $$WorkflowDefinitionsTableCreateCompanionBuilder,
      $$WorkflowDefinitionsTableUpdateCompanionBuilder,
      (
        WorkflowDefinitionRecord,
        BaseReferences<
          _$AppDatabase,
          $WorkflowDefinitionsTable,
          WorkflowDefinitionRecord
        >,
      ),
      WorkflowDefinitionRecord,
      PrefetchHooks Function()
    >;
typedef $$WorkflowExecutionsTableCreateCompanionBuilder =
    WorkflowExecutionsCompanion Function({
      required String instanceId,
      required String workflowId,
      required String status,
      Value<String?> inputVariablesJson,
      Value<String?> outputVariablesJson,
      Value<String?> nodeStatesJson,
      Value<String?> errorMessage,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$WorkflowExecutionsTableUpdateCompanionBuilder =
    WorkflowExecutionsCompanion Function({
      Value<String> instanceId,
      Value<String> workflowId,
      Value<String> status,
      Value<String?> inputVariablesJson,
      Value<String?> outputVariablesJson,
      Value<String?> nodeStatesJson,
      Value<String?> errorMessage,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$WorkflowExecutionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkflowExecutionsTable> {
  $$WorkflowExecutionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get instanceId => $composableBuilder(
    column: $table.instanceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workflowId => $composableBuilder(
    column: $table.workflowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputVariablesJson => $composableBuilder(
    column: $table.inputVariablesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outputVariablesJson => $composableBuilder(
    column: $table.outputVariablesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nodeStatesJson => $composableBuilder(
    column: $table.nodeStatesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkflowExecutionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkflowExecutionsTable> {
  $$WorkflowExecutionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get instanceId => $composableBuilder(
    column: $table.instanceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workflowId => $composableBuilder(
    column: $table.workflowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputVariablesJson => $composableBuilder(
    column: $table.inputVariablesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outputVariablesJson => $composableBuilder(
    column: $table.outputVariablesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nodeStatesJson => $composableBuilder(
    column: $table.nodeStatesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkflowExecutionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkflowExecutionsTable> {
  $$WorkflowExecutionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get instanceId => $composableBuilder(
    column: $table.instanceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workflowId => $composableBuilder(
    column: $table.workflowId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get inputVariablesJson => $composableBuilder(
    column: $table.inputVariablesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outputVariablesJson => $composableBuilder(
    column: $table.outputVariablesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nodeStatesJson => $composableBuilder(
    column: $table.nodeStatesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WorkflowExecutionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkflowExecutionsTable,
          WorkflowExecutionRecord,
          $$WorkflowExecutionsTableFilterComposer,
          $$WorkflowExecutionsTableOrderingComposer,
          $$WorkflowExecutionsTableAnnotationComposer,
          $$WorkflowExecutionsTableCreateCompanionBuilder,
          $$WorkflowExecutionsTableUpdateCompanionBuilder,
          (
            WorkflowExecutionRecord,
            BaseReferences<
              _$AppDatabase,
              $WorkflowExecutionsTable,
              WorkflowExecutionRecord
            >,
          ),
          WorkflowExecutionRecord,
          PrefetchHooks Function()
        > {
  $$WorkflowExecutionsTableTableManager(
    _$AppDatabase db,
    $WorkflowExecutionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkflowExecutionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkflowExecutionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkflowExecutionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> instanceId = const Value.absent(),
                Value<String> workflowId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> inputVariablesJson = const Value.absent(),
                Value<String?> outputVariablesJson = const Value.absent(),
                Value<String?> nodeStatesJson = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkflowExecutionsCompanion(
                instanceId: instanceId,
                workflowId: workflowId,
                status: status,
                inputVariablesJson: inputVariablesJson,
                outputVariablesJson: outputVariablesJson,
                nodeStatesJson: nodeStatesJson,
                errorMessage: errorMessage,
                startTime: startTime,
                endTime: endTime,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String instanceId,
                required String workflowId,
                required String status,
                Value<String?> inputVariablesJson = const Value.absent(),
                Value<String?> outputVariablesJson = const Value.absent(),
                Value<String?> nodeStatesJson = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkflowExecutionsCompanion.insert(
                instanceId: instanceId,
                workflowId: workflowId,
                status: status,
                inputVariablesJson: inputVariablesJson,
                outputVariablesJson: outputVariablesJson,
                nodeStatesJson: nodeStatesJson,
                errorMessage: errorMessage,
                startTime: startTime,
                endTime: endTime,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkflowExecutionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkflowExecutionsTable,
      WorkflowExecutionRecord,
      $$WorkflowExecutionsTableFilterComposer,
      $$WorkflowExecutionsTableOrderingComposer,
      $$WorkflowExecutionsTableAnnotationComposer,
      $$WorkflowExecutionsTableCreateCompanionBuilder,
      $$WorkflowExecutionsTableUpdateCompanionBuilder,
      (
        WorkflowExecutionRecord,
        BaseReferences<
          _$AppDatabase,
          $WorkflowExecutionsTable,
          WorkflowExecutionRecord
        >,
      ),
      WorkflowExecutionRecord,
      PrefetchHooks Function()
    >;
typedef $$WorkflowLogsTableCreateCompanionBuilder =
    WorkflowLogsCompanion Function({
      required String id,
      required String instanceId,
      required String nodeId,
      required String level,
      required String message,
      Value<String?> dataJson,
      required DateTime timestamp,
      Value<int> rowid,
    });
typedef $$WorkflowLogsTableUpdateCompanionBuilder =
    WorkflowLogsCompanion Function({
      Value<String> id,
      Value<String> instanceId,
      Value<String> nodeId,
      Value<String> level,
      Value<String> message,
      Value<String?> dataJson,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });

class $$WorkflowLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkflowLogsTable> {
  $$WorkflowLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instanceId => $composableBuilder(
    column: $table.instanceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkflowLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkflowLogsTable> {
  $$WorkflowLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instanceId => $composableBuilder(
    column: $table.instanceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkflowLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkflowLogsTable> {
  $$WorkflowLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get instanceId => $composableBuilder(
    column: $table.instanceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nodeId =>
      $composableBuilder(column: $table.nodeId, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$WorkflowLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkflowLogsTable,
          WorkflowLog,
          $$WorkflowLogsTableFilterComposer,
          $$WorkflowLogsTableOrderingComposer,
          $$WorkflowLogsTableAnnotationComposer,
          $$WorkflowLogsTableCreateCompanionBuilder,
          $$WorkflowLogsTableUpdateCompanionBuilder,
          (
            WorkflowLog,
            BaseReferences<_$AppDatabase, $WorkflowLogsTable, WorkflowLog>,
          ),
          WorkflowLog,
          PrefetchHooks Function()
        > {
  $$WorkflowLogsTableTableManager(_$AppDatabase db, $WorkflowLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkflowLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkflowLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkflowLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> instanceId = const Value.absent(),
                Value<String> nodeId = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String?> dataJson = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkflowLogsCompanion(
                id: id,
                instanceId: instanceId,
                nodeId: nodeId,
                level: level,
                message: message,
                dataJson: dataJson,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String instanceId,
                required String nodeId,
                required String level,
                required String message,
                Value<String?> dataJson = const Value.absent(),
                required DateTime timestamp,
                Value<int> rowid = const Value.absent(),
              }) => WorkflowLogsCompanion.insert(
                id: id,
                instanceId: instanceId,
                nodeId: nodeId,
                level: level,
                message: message,
                dataJson: dataJson,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkflowLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkflowLogsTable,
      WorkflowLog,
      $$WorkflowLogsTableFilterComposer,
      $$WorkflowLogsTableOrderingComposer,
      $$WorkflowLogsTableAnnotationComposer,
      $$WorkflowLogsTableCreateCompanionBuilder,
      $$WorkflowLogsTableUpdateCompanionBuilder,
      (
        WorkflowLog,
        BaseReferences<_$AppDatabase, $WorkflowLogsTable, WorkflowLog>,
      ),
      WorkflowLog,
      PrefetchHooks Function()
    >;
typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<String> icon,
      Value<String> color,
      Value<String?> systemPrompt,
      Value<String?> knowledgeBaseId,
      Value<String?> mcpServers,
      Value<String?> defaultModelConfigId,
      Value<double> temperature,
      Value<int> maxContextMessages,
      Value<int> sortOrder,
      Value<bool> isArchived,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String> icon,
      Value<String> color,
      Value<String?> systemPrompt,
      Value<String?> knowledgeBaseId,
      Value<String?> mcpServers,
      Value<String?> defaultModelConfigId,
      Value<double> temperature,
      Value<int> maxContextMessages,
      Value<int> sortOrder,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get knowledgeBaseId => $composableBuilder(
    column: $table.knowledgeBaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mcpServers => $composableBuilder(
    column: $table.mcpServers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultModelConfigId => $composableBuilder(
    column: $table.defaultModelConfigId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxContextMessages => $composableBuilder(
    column: $table.maxContextMessages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get knowledgeBaseId => $composableBuilder(
    column: $table.knowledgeBaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mcpServers => $composableBuilder(
    column: $table.mcpServers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultModelConfigId => $composableBuilder(
    column: $table.defaultModelConfigId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxContextMessages => $composableBuilder(
    column: $table.maxContextMessages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get knowledgeBaseId => $composableBuilder(
    column: $table.knowledgeBaseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mcpServers => $composableBuilder(
    column: $table.mcpServers,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultModelConfigId => $composableBuilder(
    column: $table.defaultModelConfigId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxContextMessages => $composableBuilder(
    column: $table.maxContextMessages,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
          Project,
          PrefetchHooks Function()
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String?> systemPrompt = const Value.absent(),
                Value<String?> knowledgeBaseId = const Value.absent(),
                Value<String?> mcpServers = const Value.absent(),
                Value<String?> defaultModelConfigId = const Value.absent(),
                Value<double> temperature = const Value.absent(),
                Value<int> maxContextMessages = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                description: description,
                icon: icon,
                color: color,
                systemPrompt: systemPrompt,
                knowledgeBaseId: knowledgeBaseId,
                mcpServers: mcpServers,
                defaultModelConfigId: defaultModelConfigId,
                temperature: temperature,
                maxContextMessages: maxContextMessages,
                sortOrder: sortOrder,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String?> systemPrompt = const Value.absent(),
                Value<String?> knowledgeBaseId = const Value.absent(),
                Value<String?> mcpServers = const Value.absent(),
                Value<String?> defaultModelConfigId = const Value.absent(),
                Value<double> temperature = const Value.absent(),
                Value<int> maxContextMessages = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                name: name,
                description: description,
                icon: icon,
                color: color,
                systemPrompt: systemPrompt,
                knowledgeBaseId: knowledgeBaseId,
                mcpServers: mcpServers,
                defaultModelConfigId: defaultModelConfigId,
                temperature: temperature,
                maxContextMessages: maxContextMessages,
                sortOrder: sortOrder,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
      Project,
      PrefetchHooks Function()
    >;
typedef $$ResearchReportsTableCreateCompanionBuilder =
    ResearchReportsCompanion Function({
      required String id,
      Value<String?> sessionId,
      required String query,
      required String title,
      Value<String?> summary,
      Value<String> status,
      Value<int> totalSteps,
      Value<int> completedSteps,
      Value<int> totalTokens,
      Value<int> inputTokens,
      Value<int> outputTokens,
      Value<int> thinkingTokens,
      Value<String?> modelConfigId,
      Value<String?> enabledSources,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$ResearchReportsTableUpdateCompanionBuilder =
    ResearchReportsCompanion Function({
      Value<String> id,
      Value<String?> sessionId,
      Value<String> query,
      Value<String> title,
      Value<String?> summary,
      Value<String> status,
      Value<int> totalSteps,
      Value<int> completedSteps,
      Value<int> totalTokens,
      Value<int> inputTokens,
      Value<int> outputTokens,
      Value<int> thinkingTokens,
      Value<String?> modelConfigId,
      Value<String?> enabledSources,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$ResearchReportsTableFilterComposer
    extends Composer<_$AppDatabase, $ResearchReportsTable> {
  $$ResearchReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSteps => $composableBuilder(
    column: $table.totalSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedSteps => $composableBuilder(
    column: $table.completedSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalTokens => $composableBuilder(
    column: $table.totalTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inputTokens => $composableBuilder(
    column: $table.inputTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get outputTokens => $composableBuilder(
    column: $table.outputTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get thinkingTokens => $composableBuilder(
    column: $table.thinkingTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelConfigId => $composableBuilder(
    column: $table.modelConfigId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enabledSources => $composableBuilder(
    column: $table.enabledSources,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResearchReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResearchReportsTable> {
  $$ResearchReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSteps => $composableBuilder(
    column: $table.totalSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedSteps => $composableBuilder(
    column: $table.completedSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalTokens => $composableBuilder(
    column: $table.totalTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inputTokens => $composableBuilder(
    column: $table.inputTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outputTokens => $composableBuilder(
    column: $table.outputTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get thinkingTokens => $composableBuilder(
    column: $table.thinkingTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelConfigId => $composableBuilder(
    column: $table.modelConfigId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enabledSources => $composableBuilder(
    column: $table.enabledSources,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResearchReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResearchReportsTable> {
  $$ResearchReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get totalSteps => $composableBuilder(
    column: $table.totalSteps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedSteps => $composableBuilder(
    column: $table.completedSteps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalTokens => $composableBuilder(
    column: $table.totalTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get inputTokens => $composableBuilder(
    column: $table.inputTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get outputTokens => $composableBuilder(
    column: $table.outputTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get thinkingTokens => $composableBuilder(
    column: $table.thinkingTokens,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelConfigId => $composableBuilder(
    column: $table.modelConfigId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get enabledSources => $composableBuilder(
    column: $table.enabledSources,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$ResearchReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResearchReportsTable,
          ResearchReport,
          $$ResearchReportsTableFilterComposer,
          $$ResearchReportsTableOrderingComposer,
          $$ResearchReportsTableAnnotationComposer,
          $$ResearchReportsTableCreateCompanionBuilder,
          $$ResearchReportsTableUpdateCompanionBuilder,
          (
            ResearchReport,
            BaseReferences<
              _$AppDatabase,
              $ResearchReportsTable,
              ResearchReport
            >,
          ),
          ResearchReport,
          PrefetchHooks Function()
        > {
  $$ResearchReportsTableTableManager(
    _$AppDatabase db,
    $ResearchReportsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResearchReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResearchReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResearchReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> totalSteps = const Value.absent(),
                Value<int> completedSteps = const Value.absent(),
                Value<int> totalTokens = const Value.absent(),
                Value<int> inputTokens = const Value.absent(),
                Value<int> outputTokens = const Value.absent(),
                Value<int> thinkingTokens = const Value.absent(),
                Value<String?> modelConfigId = const Value.absent(),
                Value<String?> enabledSources = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResearchReportsCompanion(
                id: id,
                sessionId: sessionId,
                query: query,
                title: title,
                summary: summary,
                status: status,
                totalSteps: totalSteps,
                completedSteps: completedSteps,
                totalTokens: totalTokens,
                inputTokens: inputTokens,
                outputTokens: outputTokens,
                thinkingTokens: thinkingTokens,
                modelConfigId: modelConfigId,
                enabledSources: enabledSources,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> sessionId = const Value.absent(),
                required String query,
                required String title,
                Value<String?> summary = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> totalSteps = const Value.absent(),
                Value<int> completedSteps = const Value.absent(),
                Value<int> totalTokens = const Value.absent(),
                Value<int> inputTokens = const Value.absent(),
                Value<int> outputTokens = const Value.absent(),
                Value<int> thinkingTokens = const Value.absent(),
                Value<String?> modelConfigId = const Value.absent(),
                Value<String?> enabledSources = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResearchReportsCompanion.insert(
                id: id,
                sessionId: sessionId,
                query: query,
                title: title,
                summary: summary,
                status: status,
                totalSteps: totalSteps,
                completedSteps: completedSteps,
                totalTokens: totalTokens,
                inputTokens: inputTokens,
                outputTokens: outputTokens,
                thinkingTokens: thinkingTokens,
                modelConfigId: modelConfigId,
                enabledSources: enabledSources,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResearchReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResearchReportsTable,
      ResearchReport,
      $$ResearchReportsTableFilterComposer,
      $$ResearchReportsTableOrderingComposer,
      $$ResearchReportsTableAnnotationComposer,
      $$ResearchReportsTableCreateCompanionBuilder,
      $$ResearchReportsTableUpdateCompanionBuilder,
      (
        ResearchReport,
        BaseReferences<_$AppDatabase, $ResearchReportsTable, ResearchReport>,
      ),
      ResearchReport,
      PrefetchHooks Function()
    >;
typedef $$ResearchStepsTableCreateCompanionBuilder =
    ResearchStepsCompanion Function({
      required String id,
      required String reportId,
      required int stepIndex,
      required String type,
      required String title,
      Value<String?> description,
      Value<String?> searchQuery,
      Value<String?> inputData,
      Value<String?> outputData,
      Value<String> status,
      Value<int> tokensUsed,
      Value<int?> durationMs,
      Value<String?> errorMessage,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$ResearchStepsTableUpdateCompanionBuilder =
    ResearchStepsCompanion Function({
      Value<String> id,
      Value<String> reportId,
      Value<int> stepIndex,
      Value<String> type,
      Value<String> title,
      Value<String?> description,
      Value<String?> searchQuery,
      Value<String?> inputData,
      Value<String?> outputData,
      Value<String> status,
      Value<int> tokensUsed,
      Value<int?> durationMs,
      Value<String?> errorMessage,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$ResearchStepsTableFilterComposer
    extends Composer<_$AppDatabase, $ResearchStepsTable> {
  $$ResearchStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportId => $composableBuilder(
    column: $table.reportId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stepIndex => $composableBuilder(
    column: $table.stepIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchQuery => $composableBuilder(
    column: $table.searchQuery,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputData => $composableBuilder(
    column: $table.inputData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outputData => $composableBuilder(
    column: $table.outputData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokensUsed => $composableBuilder(
    column: $table.tokensUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResearchStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResearchStepsTable> {
  $$ResearchStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportId => $composableBuilder(
    column: $table.reportId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stepIndex => $composableBuilder(
    column: $table.stepIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchQuery => $composableBuilder(
    column: $table.searchQuery,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputData => $composableBuilder(
    column: $table.inputData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outputData => $composableBuilder(
    column: $table.outputData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokensUsed => $composableBuilder(
    column: $table.tokensUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResearchStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResearchStepsTable> {
  $$ResearchStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reportId =>
      $composableBuilder(column: $table.reportId, builder: (column) => column);

  GeneratedColumn<int> get stepIndex =>
      $composableBuilder(column: $table.stepIndex, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get searchQuery => $composableBuilder(
    column: $table.searchQuery,
    builder: (column) => column,
  );

  GeneratedColumn<String> get inputData =>
      $composableBuilder(column: $table.inputData, builder: (column) => column);

  GeneratedColumn<String> get outputData => $composableBuilder(
    column: $table.outputData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get tokensUsed => $composableBuilder(
    column: $table.tokensUsed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$ResearchStepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResearchStepsTable,
          ResearchStep,
          $$ResearchStepsTableFilterComposer,
          $$ResearchStepsTableOrderingComposer,
          $$ResearchStepsTableAnnotationComposer,
          $$ResearchStepsTableCreateCompanionBuilder,
          $$ResearchStepsTableUpdateCompanionBuilder,
          (
            ResearchStep,
            BaseReferences<_$AppDatabase, $ResearchStepsTable, ResearchStep>,
          ),
          ResearchStep,
          PrefetchHooks Function()
        > {
  $$ResearchStepsTableTableManager(_$AppDatabase db, $ResearchStepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResearchStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResearchStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResearchStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> reportId = const Value.absent(),
                Value<int> stepIndex = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> searchQuery = const Value.absent(),
                Value<String?> inputData = const Value.absent(),
                Value<String?> outputData = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> tokensUsed = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResearchStepsCompanion(
                id: id,
                reportId: reportId,
                stepIndex: stepIndex,
                type: type,
                title: title,
                description: description,
                searchQuery: searchQuery,
                inputData: inputData,
                outputData: outputData,
                status: status,
                tokensUsed: tokensUsed,
                durationMs: durationMs,
                errorMessage: errorMessage,
                startedAt: startedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String reportId,
                required int stepIndex,
                required String type,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> searchQuery = const Value.absent(),
                Value<String?> inputData = const Value.absent(),
                Value<String?> outputData = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> tokensUsed = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResearchStepsCompanion.insert(
                id: id,
                reportId: reportId,
                stepIndex: stepIndex,
                type: type,
                title: title,
                description: description,
                searchQuery: searchQuery,
                inputData: inputData,
                outputData: outputData,
                status: status,
                tokensUsed: tokensUsed,
                durationMs: durationMs,
                errorMessage: errorMessage,
                startedAt: startedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResearchStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResearchStepsTable,
      ResearchStep,
      $$ResearchStepsTableFilterComposer,
      $$ResearchStepsTableOrderingComposer,
      $$ResearchStepsTableAnnotationComposer,
      $$ResearchStepsTableCreateCompanionBuilder,
      $$ResearchStepsTableUpdateCompanionBuilder,
      (
        ResearchStep,
        BaseReferences<_$AppDatabase, $ResearchStepsTable, ResearchStep>,
      ),
      ResearchStep,
      PrefetchHooks Function()
    >;
typedef $$ResearchCitationsTableCreateCompanionBuilder =
    ResearchCitationsCompanion Function({
      required String id,
      required String reportId,
      required int citationIndex,
      required String sourceType,
      Value<String?> url,
      Value<String?> filePath,
      required String title,
      Value<String?> snippet,
      Value<double?> relevanceScore,
      Value<DateTime?> fetchedAt,
      Value<int> rowid,
    });
typedef $$ResearchCitationsTableUpdateCompanionBuilder =
    ResearchCitationsCompanion Function({
      Value<String> id,
      Value<String> reportId,
      Value<int> citationIndex,
      Value<String> sourceType,
      Value<String?> url,
      Value<String?> filePath,
      Value<String> title,
      Value<String?> snippet,
      Value<double?> relevanceScore,
      Value<DateTime?> fetchedAt,
      Value<int> rowid,
    });

class $$ResearchCitationsTableFilterComposer
    extends Composer<_$AppDatabase, $ResearchCitationsTable> {
  $$ResearchCitationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportId => $composableBuilder(
    column: $table.reportId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get citationIndex => $composableBuilder(
    column: $table.citationIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snippet => $composableBuilder(
    column: $table.snippet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get relevanceScore => $composableBuilder(
    column: $table.relevanceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResearchCitationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResearchCitationsTable> {
  $$ResearchCitationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportId => $composableBuilder(
    column: $table.reportId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get citationIndex => $composableBuilder(
    column: $table.citationIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snippet => $composableBuilder(
    column: $table.snippet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get relevanceScore => $composableBuilder(
    column: $table.relevanceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResearchCitationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResearchCitationsTable> {
  $$ResearchCitationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reportId =>
      $composableBuilder(column: $table.reportId, builder: (column) => column);

  GeneratedColumn<int> get citationIndex => $composableBuilder(
    column: $table.citationIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get snippet =>
      $composableBuilder(column: $table.snippet, builder: (column) => column);

  GeneratedColumn<double> get relevanceScore => $composableBuilder(
    column: $table.relevanceScore,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ResearchCitationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResearchCitationsTable,
          ResearchCitation,
          $$ResearchCitationsTableFilterComposer,
          $$ResearchCitationsTableOrderingComposer,
          $$ResearchCitationsTableAnnotationComposer,
          $$ResearchCitationsTableCreateCompanionBuilder,
          $$ResearchCitationsTableUpdateCompanionBuilder,
          (
            ResearchCitation,
            BaseReferences<
              _$AppDatabase,
              $ResearchCitationsTable,
              ResearchCitation
            >,
          ),
          ResearchCitation,
          PrefetchHooks Function()
        > {
  $$ResearchCitationsTableTableManager(
    _$AppDatabase db,
    $ResearchCitationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResearchCitationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResearchCitationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResearchCitationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> reportId = const Value.absent(),
                Value<int> citationIndex = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> snippet = const Value.absent(),
                Value<double?> relevanceScore = const Value.absent(),
                Value<DateTime?> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResearchCitationsCompanion(
                id: id,
                reportId: reportId,
                citationIndex: citationIndex,
                sourceType: sourceType,
                url: url,
                filePath: filePath,
                title: title,
                snippet: snippet,
                relevanceScore: relevanceScore,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String reportId,
                required int citationIndex,
                required String sourceType,
                Value<String?> url = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                required String title,
                Value<String?> snippet = const Value.absent(),
                Value<double?> relevanceScore = const Value.absent(),
                Value<DateTime?> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResearchCitationsCompanion.insert(
                id: id,
                reportId: reportId,
                citationIndex: citationIndex,
                sourceType: sourceType,
                url: url,
                filePath: filePath,
                title: title,
                snippet: snippet,
                relevanceScore: relevanceScore,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResearchCitationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResearchCitationsTable,
      ResearchCitation,
      $$ResearchCitationsTableFilterComposer,
      $$ResearchCitationsTableOrderingComposer,
      $$ResearchCitationsTableAnnotationComposer,
      $$ResearchCitationsTableCreateCompanionBuilder,
      $$ResearchCitationsTableUpdateCompanionBuilder,
      (
        ResearchCitation,
        BaseReferences<
          _$AppDatabase,
          $ResearchCitationsTable,
          ResearchCitation
        >,
      ),
      ResearchCitation,
      PrefetchHooks Function()
    >;
typedef $$ResearchSectionsTableCreateCompanionBuilder =
    ResearchSectionsCompanion Function({
      required String id,
      required String reportId,
      required int sectionIndex,
      required String title,
      required String content,
      Value<String?> citationIds,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ResearchSectionsTableUpdateCompanionBuilder =
    ResearchSectionsCompanion Function({
      Value<String> id,
      Value<String> reportId,
      Value<int> sectionIndex,
      Value<String> title,
      Value<String> content,
      Value<String?> citationIds,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ResearchSectionsTableFilterComposer
    extends Composer<_$AppDatabase, $ResearchSectionsTable> {
  $$ResearchSectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportId => $composableBuilder(
    column: $table.reportId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sectionIndex => $composableBuilder(
    column: $table.sectionIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get citationIds => $composableBuilder(
    column: $table.citationIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResearchSectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResearchSectionsTable> {
  $$ResearchSectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportId => $composableBuilder(
    column: $table.reportId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sectionIndex => $composableBuilder(
    column: $table.sectionIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get citationIds => $composableBuilder(
    column: $table.citationIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResearchSectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResearchSectionsTable> {
  $$ResearchSectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reportId =>
      $composableBuilder(column: $table.reportId, builder: (column) => column);

  GeneratedColumn<int> get sectionIndex => $composableBuilder(
    column: $table.sectionIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get citationIds => $composableBuilder(
    column: $table.citationIds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ResearchSectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResearchSectionsTable,
          ResearchSection,
          $$ResearchSectionsTableFilterComposer,
          $$ResearchSectionsTableOrderingComposer,
          $$ResearchSectionsTableAnnotationComposer,
          $$ResearchSectionsTableCreateCompanionBuilder,
          $$ResearchSectionsTableUpdateCompanionBuilder,
          (
            ResearchSection,
            BaseReferences<
              _$AppDatabase,
              $ResearchSectionsTable,
              ResearchSection
            >,
          ),
          ResearchSection,
          PrefetchHooks Function()
        > {
  $$ResearchSectionsTableTableManager(
    _$AppDatabase db,
    $ResearchSectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResearchSectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResearchSectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResearchSectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> reportId = const Value.absent(),
                Value<int> sectionIndex = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> citationIds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResearchSectionsCompanion(
                id: id,
                reportId: reportId,
                sectionIndex: sectionIndex,
                title: title,
                content: content,
                citationIds: citationIds,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String reportId,
                required int sectionIndex,
                required String title,
                required String content,
                Value<String?> citationIds = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ResearchSectionsCompanion.insert(
                id: id,
                reportId: reportId,
                sectionIndex: sectionIndex,
                title: title,
                content: content,
                citationIds: citationIds,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResearchSectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResearchSectionsTable,
      ResearchSection,
      $$ResearchSectionsTableFilterComposer,
      $$ResearchSectionsTableOrderingComposer,
      $$ResearchSectionsTableAnnotationComposer,
      $$ResearchSectionsTableCreateCompanionBuilder,
      $$ResearchSectionsTableUpdateCompanionBuilder,
      (
        ResearchSection,
        BaseReferences<_$AppDatabase, $ResearchSectionsTable, ResearchSection>,
      ),
      ResearchSection,
      PrefetchHooks Function()
    >;
typedef $$ThinkingTracesTableCreateCompanionBuilder =
    ThinkingTracesCompanion Function({
      required String id,
      required String messageId,
      required String sessionId,
      required String thinking,
      Value<int> thinkingTokens,
      Value<String?> modelConfigId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ThinkingTracesTableUpdateCompanionBuilder =
    ThinkingTracesCompanion Function({
      Value<String> id,
      Value<String> messageId,
      Value<String> sessionId,
      Value<String> thinking,
      Value<int> thinkingTokens,
      Value<String?> modelConfigId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ThinkingTracesTableFilterComposer
    extends Composer<_$AppDatabase, $ThinkingTracesTable> {
  $$ThinkingTracesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thinking => $composableBuilder(
    column: $table.thinking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get thinkingTokens => $composableBuilder(
    column: $table.thinkingTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelConfigId => $composableBuilder(
    column: $table.modelConfigId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ThinkingTracesTableOrderingComposer
    extends Composer<_$AppDatabase, $ThinkingTracesTable> {
  $$ThinkingTracesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thinking => $composableBuilder(
    column: $table.thinking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get thinkingTokens => $composableBuilder(
    column: $table.thinkingTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelConfigId => $composableBuilder(
    column: $table.modelConfigId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThinkingTracesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThinkingTracesTable> {
  $$ThinkingTracesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get thinking =>
      $composableBuilder(column: $table.thinking, builder: (column) => column);

  GeneratedColumn<int> get thinkingTokens => $composableBuilder(
    column: $table.thinkingTokens,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelConfigId => $composableBuilder(
    column: $table.modelConfigId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ThinkingTracesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ThinkingTracesTable,
          ThinkingTrace,
          $$ThinkingTracesTableFilterComposer,
          $$ThinkingTracesTableOrderingComposer,
          $$ThinkingTracesTableAnnotationComposer,
          $$ThinkingTracesTableCreateCompanionBuilder,
          $$ThinkingTracesTableUpdateCompanionBuilder,
          (
            ThinkingTrace,
            BaseReferences<_$AppDatabase, $ThinkingTracesTable, ThinkingTrace>,
          ),
          ThinkingTrace,
          PrefetchHooks Function()
        > {
  $$ThinkingTracesTableTableManager(
    _$AppDatabase db,
    $ThinkingTracesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThinkingTracesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThinkingTracesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThinkingTracesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> thinking = const Value.absent(),
                Value<int> thinkingTokens = const Value.absent(),
                Value<String?> modelConfigId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThinkingTracesCompanion(
                id: id,
                messageId: messageId,
                sessionId: sessionId,
                thinking: thinking,
                thinkingTokens: thinkingTokens,
                modelConfigId: modelConfigId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String messageId,
                required String sessionId,
                required String thinking,
                Value<int> thinkingTokens = const Value.absent(),
                Value<String?> modelConfigId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ThinkingTracesCompanion.insert(
                id: id,
                messageId: messageId,
                sessionId: sessionId,
                thinking: thinking,
                thinkingTokens: thinkingTokens,
                modelConfigId: modelConfigId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThinkingTracesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ThinkingTracesTable,
      ThinkingTrace,
      $$ThinkingTracesTableFilterComposer,
      $$ThinkingTracesTableOrderingComposer,
      $$ThinkingTracesTableAnnotationComposer,
      $$ThinkingTracesTableCreateCompanionBuilder,
      $$ThinkingTracesTableUpdateCompanionBuilder,
      (
        ThinkingTrace,
        BaseReferences<_$AppDatabase, $ThinkingTracesTable, ThinkingTrace>,
      ),
      ThinkingTrace,
      PrefetchHooks Function()
    >;
typedef $$PromptScenariosTableCreateCompanionBuilder =
    PromptScenariosCompanion Function({
      required String id,
      required String scenarioKey,
      required String displayName,
      required String category,
      Value<String?> description,
      required String systemPrompt,
      Value<String?> userPromptTemplate,
      Value<String?> variables,
      Value<int> sortOrder,
      Value<bool> isBuiltin,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PromptScenariosTableUpdateCompanionBuilder =
    PromptScenariosCompanion Function({
      Value<String> id,
      Value<String> scenarioKey,
      Value<String> displayName,
      Value<String> category,
      Value<String?> description,
      Value<String> systemPrompt,
      Value<String?> userPromptTemplate,
      Value<String?> variables,
      Value<int> sortOrder,
      Value<bool> isBuiltin,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PromptScenariosTableFilterComposer
    extends Composer<_$AppDatabase, $PromptScenariosTable> {
  $$PromptScenariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scenarioKey => $composableBuilder(
    column: $table.scenarioKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userPromptTemplate => $composableBuilder(
    column: $table.userPromptTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variables => $composableBuilder(
    column: $table.variables,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PromptScenariosTableOrderingComposer
    extends Composer<_$AppDatabase, $PromptScenariosTable> {
  $$PromptScenariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scenarioKey => $composableBuilder(
    column: $table.scenarioKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userPromptTemplate => $composableBuilder(
    column: $table.userPromptTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variables => $composableBuilder(
    column: $table.variables,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PromptScenariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromptScenariosTable> {
  $$PromptScenariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scenarioKey => $composableBuilder(
    column: $table.scenarioKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userPromptTemplate => $composableBuilder(
    column: $table.userPromptTemplate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get variables =>
      $composableBuilder(column: $table.variables, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltin =>
      $composableBuilder(column: $table.isBuiltin, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PromptScenariosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PromptScenariosTable,
          PromptScenario,
          $$PromptScenariosTableFilterComposer,
          $$PromptScenariosTableOrderingComposer,
          $$PromptScenariosTableAnnotationComposer,
          $$PromptScenariosTableCreateCompanionBuilder,
          $$PromptScenariosTableUpdateCompanionBuilder,
          (
            PromptScenario,
            BaseReferences<
              _$AppDatabase,
              $PromptScenariosTable,
              PromptScenario
            >,
          ),
          PromptScenario,
          PrefetchHooks Function()
        > {
  $$PromptScenariosTableTableManager(
    _$AppDatabase db,
    $PromptScenariosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromptScenariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromptScenariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromptScenariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scenarioKey = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> systemPrompt = const Value.absent(),
                Value<String?> userPromptTemplate = const Value.absent(),
                Value<String?> variables = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PromptScenariosCompanion(
                id: id,
                scenarioKey: scenarioKey,
                displayName: displayName,
                category: category,
                description: description,
                systemPrompt: systemPrompt,
                userPromptTemplate: userPromptTemplate,
                variables: variables,
                sortOrder: sortOrder,
                isBuiltin: isBuiltin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String scenarioKey,
                required String displayName,
                required String category,
                Value<String?> description = const Value.absent(),
                required String systemPrompt,
                Value<String?> userPromptTemplate = const Value.absent(),
                Value<String?> variables = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PromptScenariosCompanion.insert(
                id: id,
                scenarioKey: scenarioKey,
                displayName: displayName,
                category: category,
                description: description,
                systemPrompt: systemPrompt,
                userPromptTemplate: userPromptTemplate,
                variables: variables,
                sortOrder: sortOrder,
                isBuiltin: isBuiltin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PromptScenariosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PromptScenariosTable,
      PromptScenario,
      $$PromptScenariosTableFilterComposer,
      $$PromptScenariosTableOrderingComposer,
      $$PromptScenariosTableAnnotationComposer,
      $$PromptScenariosTableCreateCompanionBuilder,
      $$PromptScenariosTableUpdateCompanionBuilder,
      (
        PromptScenario,
        BaseReferences<_$AppDatabase, $PromptScenariosTable, PromptScenario>,
      ),
      PromptScenario,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ModelsTableTableManager get models =>
      $$ModelsTableTableManager(_db, _db.models);
  $$MemoriesTableTableManager get memories =>
      $$MemoriesTableTableManager(_db, _db.memories);
  $$KnowledgeBasesTableTableManager get knowledgeBases =>
      $$KnowledgeBasesTableTableManager(_db, _db.knowledgeBases);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $$DocumentChunksTableTableManager get documentChunks =>
      $$DocumentChunksTableTableManager(_db, _db.documentChunks);
  $$PromptTemplatesTableTableManager get promptTemplates =>
      $$PromptTemplatesTableTableManager(_db, _db.promptTemplates);
  $$SessionPromptsTableTableManager get sessionPrompts =>
      $$SessionPromptsTableTableManager(_db, _db.sessionPrompts);
  $$DownloadTasksTableTableManager get downloadTasks =>
      $$DownloadTasksTableTableManager(_db, _db.downloadTasks);
  $$McpServerConfigsTableTableManager get mcpServerConfigs =>
      $$McpServerConfigsTableTableManager(_db, _db.mcpServerConfigs);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$AppLogsTableTableManager get appLogs =>
      $$AppLogsTableTableManager(_db, _db.appLogs);
  $$SessionSummariesTableTableManager get sessionSummaries =>
      $$SessionSummariesTableTableManager(_db, _db.sessionSummaries);
  $$PluginRegistriesTableTableManager get pluginRegistries =>
      $$PluginRegistriesTableTableManager(_db, _db.pluginRegistries);
  $$SessionResourcesTableTableManager get sessionResources =>
      $$SessionResourcesTableTableManager(_db, _db.sessionResources);
  $$WorkflowDefinitionsTableTableManager get workflowDefinitions =>
      $$WorkflowDefinitionsTableTableManager(_db, _db.workflowDefinitions);
  $$WorkflowExecutionsTableTableManager get workflowExecutions =>
      $$WorkflowExecutionsTableTableManager(_db, _db.workflowExecutions);
  $$WorkflowLogsTableTableManager get workflowLogs =>
      $$WorkflowLogsTableTableManager(_db, _db.workflowLogs);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$ResearchReportsTableTableManager get researchReports =>
      $$ResearchReportsTableTableManager(_db, _db.researchReports);
  $$ResearchStepsTableTableManager get researchSteps =>
      $$ResearchStepsTableTableManager(_db, _db.researchSteps);
  $$ResearchCitationsTableTableManager get researchCitations =>
      $$ResearchCitationsTableTableManager(_db, _db.researchCitations);
  $$ResearchSectionsTableTableManager get researchSections =>
      $$ResearchSectionsTableTableManager(_db, _db.researchSections);
  $$ThinkingTracesTableTableManager get thinkingTraces =>
      $$ThinkingTracesTableTableManager(_db, _db.thinkingTraces);
  $$PromptScenariosTableTableManager get promptScenarios =>
      $$PromptScenariosTableTableManager(_db, _db.promptScenarios);
}
