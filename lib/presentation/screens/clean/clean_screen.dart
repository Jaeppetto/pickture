import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/domain/entities/cleaning_decision.dart';
import 'package:pickture/l10n/app_localizations.dart';
import 'package:pickture/presentation/providers/cleaning_session_provider.dart';
import 'package:pickture/presentation/providers/haptic_provider.dart';
import 'package:pickture/presentation/widgets/swipe/cleaning_progress_bar.dart';
import 'package:pickture/presentation/widgets/swipe/session_resume_dialog.dart';
import 'package:pickture/presentation/widgets/swipe/swipe_action_buttons.dart';
import 'package:pickture/presentation/widgets/animations/confetti_overlay.dart';
import 'package:pickture/presentation/widgets/swipe/animations/combo_counter.dart';
import 'package:pickture/presentation/widgets/swipe/swipe_card_stack.dart';
import 'package:pickture/presentation/widgets/swipe/swipe_direction.dart';

class CleanScreen extends ConsumerStatefulWidget {
  const CleanScreen({super.key});

  @override
  ConsumerState<CleanScreen> createState() => _CleanScreenState();
}

class _CleanScreenState extends ConsumerState<CleanScreen> {
  final _cardStackKey = GlobalKey<SwipeCardStackState>();
  bool _hasCheckedSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    if (_hasCheckedSession) return;
    _hasCheckedSession = true;

    final notifier = ref.read(cleaningSessionNotifierProvider.notifier);
    final activeSession = await notifier.checkActiveSession();

    if (!mounted) return;

    if (activeSession != null) {
      final resume = await SessionResumeDialog.show(context);
      if (resume == true) {
        await notifier.resumeSession();
      } else if (resume == false) {
        await notifier.startSession();
      }
    }
  }

  void _onSwiped(SwipeDirection direction) {
    final notifier = ref.read(cleaningSessionNotifierProvider.notifier);
    switch (direction) {
      case SwipeDirection.left:
        notifier.makeDecision(CleaningDecisionType.delete);
      case SwipeDirection.right:
        notifier.makeDecision(CleaningDecisionType.keep);
      case SwipeDirection.up:
        notifier.makeDecision(CleaningDecisionType.favorite);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleaningState = ref.watch(cleaningSessionNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cleanSessionTitle)),
      body: cleaningState.when(
        data: (state) {
          if (state == null) {
            return _buildStartScreen(l10n, theme);
          }

          final hasPhotos = state.currentIndex < state.photoQueue.length;

          if (!hasPhotos) {
            return _buildCompletedScreen(l10n, theme, state);
          }

          return Column(
            children: [
              CleaningProgressBar(
                reviewed: state.session.reviewedCount,
                total: state.session.totalPhotos,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SwipeCardStack(
                        key: _cardStackKey,
                        photos: state.photoQueue,
                        currentIndex: state.currentIndex,
                        onSwiped: _onSwiped,
                        hapticService: ref.read(hapticServiceProvider),
                      ),
                      // Combo counter
                      Positioned(
                        top: AppConstants.spacing8,
                        child: ComboCounter(count: state.comboCount),
                      ),
                    ],
                  ),
                ),
              ),
              SwipeActionButtons(
                onDelete: () => _cardStackKey.currentState?.animateSwipe(
                  SwipeDirection.left,
                ),
                onKeep: () => _cardStackKey.currentState?.animateSwipe(
                  SwipeDirection.right,
                ),
                onFavorite: () =>
                    _cardStackKey.currentState?.animateSwipe(SwipeDirection.up),
                onUndo: () => ref
                    .read(cleaningSessionNotifierProvider.notifier)
                    .undoLastDecision(),
                canUndo: state.lastDecision != null,
              ),
              const SizedBox(height: AppConstants.spacing16),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStartScreen(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: AppConstants.spacing24),
          Text(l10n.cleanSessionTitle, style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppConstants.spacing32),
          FilledButton.icon(
            onPressed: () async {
              await ref
                  .read(cleaningSessionNotifierProvider.notifier)
                  .startSession();
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l10n.startCleaning),
            style: FilledButton.styleFrom(minimumSize: const Size(200, 56)),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedScreen(
    AppLocalizations l10n,
    ThemeData theme,
    dynamic state,
  ) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppConstants.spacing24),
              Text(
                l10n.allPhotosCleaned,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppConstants.spacing32),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(cleaningSessionNotifierProvider.notifier)
                      .completeSession();
                  if (mounted) {
                    await context.push('/session-summary/${state.session.id}');
                  }
                },
                style: FilledButton.styleFrom(minimumSize: const Size(200, 56)),
                child: Text(l10n.done),
              ),
            ],
          ),
        ),
        const Positioned.fill(child: ConfettiOverlay()),
      ],
    );
  }
}
