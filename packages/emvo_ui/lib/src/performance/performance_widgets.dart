import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget that prevents unnecessary repaints.
class RepaintBoundaryWrapper extends StatelessWidget {
  final Widget child;
  final String debugName;

  const RepaintBoundaryWrapper({
    super.key,
    required this.child,
    this.debugName = '',
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: child,
    );
  }
}

/// Lazy load heavy widgets.
class LazyLoadWrapper extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final Duration delay;

  const LazyLoadWrapper({
    super.key,
    required this.builder,
    this.delay = const Duration(milliseconds: 100),
  });

  @override
  State<LazyLoadWrapper> createState() => _LazyLoadWrapperState();
}

class _LazyLoadWrapperState extends State<LazyLoadWrapper> {
  bool _shouldBuild = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _shouldBuild = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldBuild) {
      return const SizedBox.shrink();
    }
    return widget.builder(context);
  }
}

/// Cache expensive async-driven widget builds with Riverpod provider state.
class CachedWidget<T> extends ConsumerWidget {
  final ProviderListenable<AsyncValue<T>> provider;
  final Widget Function(BuildContext, T) builder;
  final Widget? loading;
  final Widget Function(Object?, StackTrace?)? error;

  const CachedWidget({
    super.key,
    required this.provider,
    required this.builder,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(provider);

    return asyncValue.when(
      data: (data) => builder(context, data),
      loading:
          () => loading ?? const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          error?.call(err, stack) ?? Center(child: Text('Error: $err')),
    );
  }
}

/// Optimized list that keeps cells alive and minimizes repaints.
class OptimizedListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double? cacheExtent;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.cacheExtent,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      cacheExtent: cacheExtent,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _KeepAliveListItem(
          child: RepaintBoundaryWrapper(
            child: itemBuilder(context, items[index], index),
          ),
        );
      },
    );
  }
}

class _KeepAliveListItem extends StatefulWidget {
  final Widget child;

  const _KeepAliveListItem({required this.child});

  @override
  State<_KeepAliveListItem> createState() => _KeepAliveListItemState();
}

class _KeepAliveListItemState extends State<_KeepAliveListItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
