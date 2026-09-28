import 'package:flutter/material.dart';

import 'package:lays_rating/models/feedback.dart';
import 'package:lays_rating/models/feedback_item.dart';
import 'package:lays_rating/services/feedback_service.dart';
import 'feedback_details_page.dart';

class AdminFeedbackPage extends StatefulWidget {
  const AdminFeedbackPage({super.key});

  @override
  State<AdminFeedbackPage> createState() => _AdminFeedbackPageState();
}

class _AdminFeedbackPageState extends State<AdminFeedbackPage> {
  List<FeedbackItem> _items = [];
  int _unreadCount = 0;
  bool _isLoading = true;
  String? _error;

  FeedbackType? _filterType;
  bool? _filterRead;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await FeedbackService.getList(
        type: _filterType,
        isRead: _filterRead,
      );
      if (!mounted) return;
      setState(() {
        _items = data.items;
        _unreadCount = data.unreadCount;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('AdminFeedbackPage._load error: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось загрузить сообщения';
        _isLoading = false;
      });
    }
  }

  Future<void> _openDetails(FeedbackItem item) async {
    final updated = await Navigator.push<FeedbackItem>(
      context,
      MaterialPageRoute(
        builder: (_) => FeedbackDetailsPage(item: item),
      ),
    );

    if (updated == null || !mounted) return;

    // Обновляем элемент в списке
    setState(() {
      final idx = _items.indexWhere((f) => f.id == updated.id);
      if (idx != -1) {
        final wasUnread = !_items[idx].isRead;
        _items[idx] = updated;
        if (wasUnread && updated.isRead && _unreadCount > 0) {
          _unreadCount--;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Обратная связь'),
        actions: [
          IconButton(
            onPressed: _openFilterSheet,
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Фильтры',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _load,
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('Пока нет сообщений'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return _FeedbackTile(
            item: _items[index],
            onTap: () => _openDetails(_items[index]),
          );
        },
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    // Простой bottom sheet с фильтрами по типу и прочитанности
    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(
        initialType: _filterType,
        initialRead: _filterRead,
      ),
    );

    if (result == null || !mounted) return;
    setState(() {
      _filterType = result.type;
      _filterRead = result.isRead;
    });
    await _load();
  }
}

class _FilterResult {
  const _FilterResult({this.type, this.isRead});
  final FeedbackType? type;
  final bool? isRead;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({this.initialType, this.initialRead});

  final FeedbackType? initialType;
  final bool? initialRead;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  FeedbackType? _type;
  bool? _isRead;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _isRead = widget.initialRead;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Center(
              child: Text(
                'Фильтры',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Тип
            const _SectionLabel('Тип'),
            const SizedBox(height: 6),
            _buildTypeGrid(),

            const SizedBox(height: 8),

            // Статус
            const _SectionLabel('Статус'),
            const SizedBox(height: 6),
            _buildStatusRow(),

            const SizedBox(height: 20),

            // Кнопки
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, const _FilterResult());
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Сбросить'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        _FilterResult(type: _type, isRead: _isRead),
                      );
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Применить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeGrid() {
    final allSelected = _type == null;
    final types = FeedbackType.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // «Все» — на всю ширину
        _SelectableChip(
          label: 'Все',
          emoji: '🗂️',
          selected: allSelected,
          onTap: () => setState(() => _type = null),
        ),
        const SizedBox(height: 6),

        // Типы — сетка 2×3
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 6.0;
            final itemWidth = (constraints.maxWidth - spacing) / 2;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: types.map((t) {
                final selected = _type == t;
                return SizedBox(
                  width: itemWidth,
                  child: _SelectableChip(
                    label: t.label,
                    emoji: t.emoji,
                    selected: selected,
                    onTap: () => setState(() => _type = t),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // Статус: сетка 3 в ряд (короткие), а не Wrap
  Widget _buildStatusRow() {
    final items = <_StatusChipData>[
      const _StatusChipData(label: 'Все', value: null),
      const _StatusChipData(label: 'Непрочитанные', value: false),
      const _StatusChipData(label: 'Прочитанные', value: true),
    ];

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: _SelectableChip(
              label: items[i].label,
              selected: _isRead == items[i].value,
              onTap: () => setState(() => _isRead = items[i].value),
            ),
          ),
        ],
      ],
    );
  }
}

// ===== Хелперы =====

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }
}

class _FilterChipData {
  const _FilterChipData({
    required this.label,
    required this.emoji,
    this.type,
  });
  final String label;
  final String emoji;
  final FeedbackType? type;
}

class _StatusChipData {
  const _StatusChipData({required this.label, required this.value});
  final String label;
  final bool? value;
}

// ===== Универсальная «плитка-чип» =====

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.emoji,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackTile extends StatelessWidget {
  const _FeedbackTile({required this.item, required this.onTap});

  final FeedbackItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: item.isRead
              ? colorScheme.surfaceContainerHighest
              : colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          item.type.emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ),
      title: Text(
        item.title.isEmpty ? item.type.label : item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: item.isRead ? FontWeight.w500 : FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          '@${item.user.username} • ${item.type.label}',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: item.isRead
          ? Icon(
              Icons.done_all_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            )
          : Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
      onTap: onTap,
    );
  }
}