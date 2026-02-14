import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/l10n/app_localizations.dart';
import 'package:pickture/presentation/providers/onboarding_provider.dart';
import 'package:pickture/presentation/widgets/onboarding/onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: AppConstants.durationNormal,
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  void _complete() {
    ref.read(onboardingNotifierProvider.notifier).complete();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _complete,
                child: Text(l10n.onboardingSkip),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  OnboardingPage(
                    icon: Icons.swipe,
                    iconColor: theme.colorScheme.primary,
                    title: l10n.onboardingTitle1,
                    description: l10n.onboardingDesc1,
                  ),
                  OnboardingPage(
                    icon: Icons.shield_outlined,
                    iconColor: theme.colorScheme.tertiary,
                    title: l10n.onboardingTitle2,
                    description: l10n.onboardingDesc2,
                  ),
                  OnboardingPage(
                    icon: Icons.bar_chart,
                    iconColor: theme.colorScheme.secondary,
                    title: l10n.onboardingTitle3,
                    description: l10n.onboardingDesc3,
                  ),
                ],
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots
                  Row(
                    children: List.generate(
                      3,
                      (i) => AnimatedContainer(
                        duration: AppConstants.durationFast,
                        margin: const EdgeInsets.only(
                          right: AppConstants.spacing8,
                        ),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.2,
                                ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next / Get Started button
                  FilledButton(
                    onPressed: _onNext,
                    child: Text(
                      _currentPage == 2
                          ? l10n.onboardingGetStarted
                          : l10n.onboardingNext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
