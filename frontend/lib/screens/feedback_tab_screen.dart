import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/feedbacks/feedback_dto.dart';
import 'package:frontend/models/feedbacks/teacher_reply_model.dart';
import 'package:frontend/providers/service_providers.dart';

enum FeedbackScopeFilter { all, exam, question }

enum FeedbackSortOrder { newest, oldest }

class FeedbackTabScreen extends ConsumerStatefulWidget {
  final int? examId;
  final int? questionId;
  final String? questionContent;
  final String? examContent;
  final bool isTeacher;

  const FeedbackTabScreen({
    super.key,
    this.examId,
    this.questionId,
    this.questionContent,
    this.examContent,
    this.isTeacher = false,
  });

  @override
  ConsumerState<FeedbackTabScreen> createState() => _FeedbackTabScreenState();
}

class _FeedbackTabScreenState extends ConsumerState<FeedbackTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FeedbackDto> _allFeedbacks = [];
  bool _isLoading = true;
  String? _error;

  FeedbackScopeFilter _scopeFilter = FeedbackScopeFilter.all;
  FeedbackSortOrder _sortOrder = FeedbackSortOrder.newest;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    setState(() => _isLoading = true);
    try {
      final feedbackService = ref.read(feedbackServiceProvider);
      List<FeedbackDto> feedbacks = [];
      if (widget.questionId != null) {
        feedbacks = await feedbackService.getFeedbacksForQuestion(
          widget.questionId!,
        );
      } else if (widget.examId != null) {
        feedbacks = await feedbackService.getFeedbacksForExam(widget.examId!);
      }
      setState(() {
        _allFeedbacks = feedbacks;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<FeedbackDto> visible = (!_isLoading && _error == null)
        ? _applyFilterAndSort(_allFeedbacks)
        : const <FeedbackDto>[];
    final pendingVisible = visible
        .where((f) => (f.status).toUpperCase() == 'PENDING')
        .toList(growable: false);
    final reviewedVisible = visible
        .where((f) => (f.status).toUpperCase() != 'PENDING')
        .toList(growable: false);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đánh giá và góp ý',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            if (widget.examContent != null)
              Text(
                widget.examContent!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        bottom: PreferredSize(
          // TabBar default height is kTextTabBarHeight (48). We also add
          // vertical margin (8 + 8) on the container.
          preferredSize: const Size.fromHeight(kTextTabBarHeight + 16),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: colorScheme.onPrimary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Chưa phản hồi'),
                      if (pendingVisible.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${pendingVisible.length}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Đã phản hồi'),
                      if (reviewedVisible.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${reviewedVisible.length}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : Column(
              children: [
                _buildFilterBar(context),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _FeedbackList(
                        feedbacks: pendingVisible,
                        isTeacher: widget.isTeacher,
                        questionContent: widget.questionContent,
                        onReplyAdded: _loadFeedbacks,
                        emptyIcon: Icons.hourglass_empty_rounded,
                        emptyTitle: 'Chưa có đánh giá mới',
                        emptySubtitle:
                            'Các đánh giá chờ phản hồi sẽ hiển thị ở đây',
                      ),
                      _FeedbackList(
                        feedbacks: reviewedVisible,
                        isTeacher: widget.isTeacher,
                        questionContent: widget.questionContent,
                        onReplyAdded: _loadFeedbacks,
                        emptyIcon: Icons.check_circle_outline_rounded,
                        emptyTitle: 'Chưa có phản hồi nào',
                        emptySubtitle:
                            'Các đánh giá đã được phản hồi sẽ hiển thị ở đây',
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _scopeChip(
                    context,
                    label: 'Tất cả',
                    value: FeedbackScopeFilter.all,
                  ),
                  const SizedBox(width: 8),
                  _scopeChip(
                    context,
                    label: 'Bài thi',
                    value: FeedbackScopeFilter.exam,
                  ),
                  const SizedBox(width: 8),
                  _scopeChip(
                    context,
                    label: 'Câu hỏi',
                    value: FeedbackScopeFilter.question,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          PopupMenuButton<FeedbackSortOrder>(
            initialValue: _sortOrder,
            position: PopupMenuPosition.under,
            offset: const Offset(0, 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) => setState(() => _sortOrder = value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: FeedbackSortOrder.newest,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.south_rounded,
                      size: 14,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    const Text('Mới nhất'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: FeedbackSortOrder.oldest,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.north_rounded,
                      size: 14,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    const Text('Cũ nhất'),
                  ],
                ),
              ),
            ],
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _sortOrder == FeedbackSortOrder.newest
                        ? Icons.south_rounded
                        : Icons.north_rounded,
                    size: 14,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _sortOrder == FeedbackSortOrder.newest ? 'Mới' : 'Cũ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scopeChip(
    BuildContext context, {
    required String label,
    required FeedbackScopeFilter value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = _scopeFilter == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _scopeFilter = value),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
      ),
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.35,
      ),
      side: BorderSide(
        color: selected
            ? Colors.transparent
            : colorScheme.outlineVariant.withValues(alpha: 0.4),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }

  bool _isQuestionFeedback(FeedbackDto feedback) {
    return feedback.questionContent != null &&
        feedback.questionContent!.trim().isNotEmpty;
  }

  List<FeedbackDto> _applyFilterAndSort(List<FeedbackDto> feedbacks) {
    Iterable<FeedbackDto> result = feedbacks;

    switch (_scopeFilter) {
      case FeedbackScopeFilter.all:
        break;
      case FeedbackScopeFilter.exam:
        result = result.where((f) => !_isQuestionFeedback(f));
        break;
      case FeedbackScopeFilter.question:
        result = result.where(_isQuestionFeedback);
        break;
    }

    final list = result.toList(growable: false);
    list.sort((a, b) {
      final cmp = a.createdAt.compareTo(b.createdAt);
      return _sortOrder == FeedbackSortOrder.newest ? -cmp : cmp;
    });

    return list;
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Không thể tải dữ liệu',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadFeedbacks,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackList extends ConsumerWidget {
  final List<FeedbackDto> feedbacks;
  final bool isTeacher;
  final String? questionContent;
  final VoidCallback? onReplyAdded;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  const _FeedbackList({
    required this.feedbacks,
    required this.isTeacher,
    this.questionContent,
    this.onReplyAdded,
    this.emptyIcon = Icons.feedback_outlined,
    this.emptyTitle = 'Không có đánh giá',
    this.emptySubtitle = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (feedbacks.isEmpty) {
      return _buildEmptyState(context);
    }

    // Group feedbacks by question
    final Map<String, List<FeedbackDto>> groupedFeedbacks = {};
    final List<FeedbackDto> examFeedbacks = [];

    for (final feedback in feedbacks) {
      final String? effectiveQuestionContent =
          (feedback.questionContent != null &&
              feedback.questionContent!.trim().isNotEmpty)
          ? feedback.questionContent
          : (questionContent != null && questionContent!.trim().isNotEmpty)
          ? questionContent
          : null;

      if (effectiveQuestionContent != null) {
        // Group by question content
        if (!groupedFeedbacks.containsKey(effectiveQuestionContent)) {
          groupedFeedbacks[effectiveQuestionContent] = [];
        }
        groupedFeedbacks[effectiveQuestionContent]!.add(feedback);
      } else {
        // Exam-level feedback (no question)
        examFeedbacks.add(feedback);
      }
    }

    // Create list of items (grouped + individual)
    final List<Widget> items = [];

    // Add grouped question feedbacks
    groupedFeedbacks.forEach((questionContent, feedbackList) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _QuestionFeedbackGroup(
            questionContent: questionContent,
            feedbacks: feedbackList,
            isTeacher: isTeacher,
            onReplyAdded: onReplyAdded,
          ),
        ),
      );
    });

    // Add individual exam feedbacks
    for (final feedback in examFeedbacks) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _FeedbackItem(
            feedback: feedback,
            isTeacher: isTeacher,
            effectiveQuestionContent: null,
            onReplyAdded: onReplyAdded,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onReplyAdded?.call(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                emptyIcon,
                size: 48,
                color: colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              emptyTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionFeedbackGroup extends ConsumerWidget {
  final String questionContent;
  final List<FeedbackDto> feedbacks;
  final bool isTeacher;
  final VoidCallback? onReplyAdded;

  const _QuestionFeedbackGroup({
    required this.questionContent,
    required this.feedbacks,
    required this.isTeacher,
    this.onReplyAdded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.quiz_rounded,
                    size: 20,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        questionContent,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple.shade700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${feedbacks.length} đánh giá',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.deepPurple.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Feedbacks list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: feedbacks.length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                height: 1,
              ),
            ),
            itemBuilder: (context, index) {
              return _FeedbackItem(
                feedback: feedbacks[index],
                isTeacher: isTeacher,
                effectiveQuestionContent: null, // Already shown in header
                onReplyAdded: onReplyAdded,
                isCompact: true, // Compact mode within group
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeedbackItem extends ConsumerStatefulWidget {
  final FeedbackDto feedback;
  final bool isTeacher;
  final String? effectiveQuestionContent;
  final VoidCallback? onReplyAdded;
  final bool isCompact;

  const _FeedbackItem({
    required this.feedback,
    required this.isTeacher,
    this.effectiveQuestionContent,
    this.onReplyAdded,
    this.isCompact = false,
  });

  @override
  ConsumerState<_FeedbackItem> createState() => _FeedbackItemState();
}

class _FeedbackItemState extends ConsumerState<_FeedbackItem> {
  bool _isReplying = false;
  final _replyController = TextEditingController();
  String _selectedStatus = 'REVIEWED';
  bool _isSending = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isQuestionFeedback = widget.effectiveQuestionContent != null;

    // Compact mode: no card wrapper, simpler layout
    if (widget.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    (widget.feedback.userName ?? 'U')[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.feedback.userName ?? 'Ẩn danh',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(widget.feedback.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(widget.feedback.status),
            ],
          ),

          const SizedBox(height: 10),

          // Rating stars
          Row(
            children: [
              ...List.generate(5, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(
                    i < (widget.feedback.rating ?? 0)
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 18,
                    color: i < (widget.feedback.rating ?? 0)
                        ? Colors.amber.shade600
                        : Colors.grey.shade300,
                  ),
                );
              }),
              if (widget.feedback.rating != null) ...[
                const SizedBox(width: 6),
                Text(
                  '${widget.feedback.rating}/5',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // Feedback content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.feedback.content,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),

          // Reply button or inline form
          if (widget.isTeacher && widget.feedback.status == 'PENDING') ...[
            const SizedBox(height: 10),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _isReplying
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() => _isReplying = true),
                  icon: const Icon(Icons.reply_rounded, size: 16),
                  label: const Text('Phản hồi'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                ),
              ),
              secondChild: _buildReplyForm(colorScheme, theme),
            ),
          ],

          // Teacher reply (if exists)
          if (widget.feedback.teacherReply != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          size: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Phản hồi từ giáo viên',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const Spacer(),
                      if (widget.feedback.reviewedAt != null)
                        Text(
                          _formatDate(widget.feedback.reviewedAt!),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.feedback.teacherReply!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade900,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    // Full card mode (original)
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header (if applicable)
          if (isQuestionFeedback)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.quiz_rounded,
                      size: 16,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.effectiveQuestionContent!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurple.shade700,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info row
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          (widget.feedback.userName ?? 'U')[0].toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.feedback.userName ?? 'Ẩn danh',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(widget.feedback.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    _buildStatusBadge(widget.feedback.status),
                  ],
                ),

                const SizedBox(height: 12),

                // Rating stars
                Row(
                  children: [
                    ...List.generate(5, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Icon(
                          i < (widget.feedback.rating ?? 0)
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 20,
                          color: i < (widget.feedback.rating ?? 0)
                              ? Colors.amber.shade600
                              : Colors.grey.shade300,
                        ),
                      );
                    }),
                    if (widget.feedback.rating != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${widget.feedback.rating}/5',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // Feedback content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.feedback.content,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),

                // Reply button or inline form
                if (widget.isTeacher &&
                    widget.feedback.status == 'PENDING') ...[
                  const SizedBox(height: 12),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: _isReplying
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _isReplying = true),
                        icon: const Icon(Icons.reply_rounded, size: 18),
                        label: const Text('Phản hồi'),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                        ),
                      ),
                    ),
                    secondChild: _buildReplyForm(colorScheme, theme),
                  ),
                ],

                // Teacher reply (if exists)
                if (widget.feedback.teacherReply != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.school_rounded,
                                size: 14,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Phản hồi từ giáo viên',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const Spacer(),
                            if (widget.feedback.reviewedAt != null)
                              Text(
                                _formatDate(widget.feedback.reviewedAt!),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade400,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.feedback.teacherReply!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String statusText;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'PENDING':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        statusText = 'Chờ xử lý';
        icon = Icons.schedule_rounded;
        break;
      case 'REVIEWED':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        statusText = 'Đã xem';
        icon = Icons.visibility_rounded;
        break;
      case 'RESOLVED':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        statusText = 'Đã giải quyết';
        icon = Icons.check_circle_rounded;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        statusText = status;
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyForm(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phản hồi đánh giá',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _replyController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập nội dung phản hồi...',
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Trạng thái sau phản hồi',
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'REVIEWED',
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility_rounded,
                      size: 18,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Text('Đã xem xét'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'RESOLVED',
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text('Đã giải quyết'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedStatus = value);
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _isSending
                    ? null
                    : () {
                        setState(() {
                          _isReplying = false;
                          _replyController.clear();
                        });
                      },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Hủy'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _isSending ? null : _sendReply,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(_isSending ? 'Đang gửi...' : 'Gửi phản hồi'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  Future<void> _sendReply() async {
    if (_replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Vui lòng nhập nội dung phản hồi'),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final feedbackService = ref.read(feedbackServiceProvider);
      final replyModel = TeacherReplyModel(
        reply: _replyController.text.trim(),
        status: _selectedStatus,
      );

      await feedbackService.addTeacherReply(widget.feedback.id!, replyModel);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Đã gửi phản hồi thành công'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        setState(() {
          _isReplying = false;
          _replyController.clear();
        });
        widget.onReplyAdded?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Lỗi: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }
}
