abstract class IPluginEngine {
  Future<void> registerSkill(SkillDefinition skill);
  Future<void> unregisterSkill(String skillId);
  Future<ToolResult> executeTool(String toolName, Map<String, dynamic> parameters);
  Future<void> enableSkill(String sessionId, String skillId);
  Future<void> disableSkill(String sessionId, String skillId);
  Future<List<SkillDefinition>> getAvailableSkills();
}

class SkillDefinition {
  final String id;
  final String name;
  final String description;
  final SkillType type;
  final Map<String, dynamic> schema;
  final String? executionCode;

  const SkillDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.schema,
    this.executionCode,
  });
}

enum SkillType {
  builtin,
  custom,
  mcp,
}

class ToolResult {
  final bool success;
  final dynamic output;
  final String? error;

  const ToolResult({
    required this.success,
    this.output,
    this.error,
  });
}

class MCPServiceConfig {
  final String name;
  final String transport; // 'stdio', 'http', 'websocket'
  final Map<String, dynamic> config;

  const MCPServiceConfig({
    required this.name,
    required this.transport,
    required this.config,
  });
}
