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
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
    createdAt,
    updatedAt,
  );
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
}
