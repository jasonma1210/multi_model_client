import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 统一状态组件库
/// 提供 Loading、Error、Success、Empty 状态的标准化展示

/// 加载状态组件
class LoadingState extends StatelessWidget {
  /// 自定义加载文本
  final String? message;
  
  /// 是否显示骨架屏（替代旋转指示器）
  final bool useSkeleton;
  
  /// 骨架屏行数
  final int skeletonLines;
  
  const LoadingState({
    super.key,
    this.message,
    this.useSkeleton = false,
    this.skeletonLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (useSkeleton) {
      return _buildSkeleton(theme);
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSkeleton(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: skeletonLines,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _SkeletonLine(
          width: index == skeletonLines - 1 ? 120.0 : null,
          theme: theme,
        ),
      ),
    );
  }
}

/// 骨架屏单行
class _SkeletonLine extends StatelessWidget {
  final double? width;
  final ThemeData theme;
  
  const _SkeletonLine({this.width, required this.theme});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// 错误状态组件
class ErrorState extends StatelessWidget {
  /// 错误标题
  final String title;
  
  /// 错误描述
  final String? message;
  
  /// 错误图标
  final IconData icon;
  
  /// 重试回调
  final VoidCallback? onRetry;
  
  const ErrorState({
    super.key,
    this.title = '出错了',
    this.message,
    this.icon = Icons.error_outline_rounded,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 成功状态组件
class SuccessState extends StatelessWidget {
  /// 成功消息
  final String message;
  
  /// 成功图标
  final IconData icon;
  
  /// 是否自动消失
  final Duration? autoDismiss;
  
  /// 消失回调
  final VoidCallback? onDismiss;
  
  const SuccessState({
    super.key,
    this.message = '操作成功',
    this.icon = Icons.check_circle_outline_rounded,
    this.autoDismiss,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 自动消失处理
    if (autoDismiss != null) {
      Future.delayed(autoDismiss!, () {
        if (onDismiss != null) {
          onDismiss!();
        }
      });
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 空状态组件
class AppEmptyState extends StatelessWidget {
  /// 空状态图标
  final IconData icon;
  
  /// 标题
  final String title;
  
  /// 描述文本
  final String? description;
  
  /// 操作按钮文本
  final String? actionLabel;
  
  /// 操作按钮回调
  final VoidCallback? onAction;
  
  const AppEmptyState({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 10),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 根据状态类型自动渲染对应的状态组件
class StateWrapper<T> extends StatelessWidget {
  /// 数据加载状态
  final AsyncValue<T> state;
  
  /// 加载中显示的自定义组件
  final Widget? loading;
  
  /// 错误时显示的自定义组件
  final Widget? error;
  
  /// 数据为空时显示的自定义组件
  final Widget? empty;
  
  /// 数据成功时显示的组件构建器
  final Widget Function(T data) builder;
  
  /// 错误重试回调
  final VoidCallback? onRetry;
  
  const StateWrapper({
    super.key,
    required this.state,
    this.loading,
    this.error,
    this.empty,
    required this.builder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return state.when(
      data: (data) {
        if (data == null || (data is List && data.isEmpty)) {
          return empty ?? AppEmptyState(
            title: '暂无数据',
            onAction: onRetry,
          );
        }
        return builder(data);
      },
      loading: () => loading ?? const LoadingState(),
      error: (e, _) => error ?? ErrorState(
        message: e.toString(),
        onRetry: onRetry,
      ),
    );
  }
}

/// 统一状态组件的便捷构造器
class UnifiedStateWidget extends StatelessWidget {
  /// 状态类型
  final UnifiedStateType type;
  
  /// 自定义消息
  final String? message;
  
  /// 图标
  final IconData? icon;
  
  /// 操作回调
  final VoidCallback? onAction;
  
  /// 操作按钮文本
  final String? actionLabel;
  
  const UnifiedStateWidget({
    super.key,
    required this.type,
    this.message,
    this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case UnifiedStateType.loading:
        return LoadingState(message: message);
      case UnifiedStateType.error:
        return ErrorState(
          message: message,
          icon: icon ?? Icons.error_outline_rounded,
          onRetry: onAction,
        );
      case UnifiedStateType.success:
        return SuccessState(
          message: message ?? '操作成功',
          icon: icon ?? Icons.check_circle_outline_rounded,
        );
      case UnifiedStateType.empty:
        return AppEmptyState(
          title: message ?? '暂无数据',
          icon: icon ?? Icons.inbox_rounded,
          actionLabel: actionLabel,
          onAction: onAction,
        );
    }
  }
}

/// 统一状态类型枚举
enum UnifiedStateType {
  loading,
  error,
  success,
  empty,
}