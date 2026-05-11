import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/wicara_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/security_note.dart';
import '../domain/onboarding_profile.dart';
import '../domain/onboarding_repository.dart';
import 'widgets/onboarding_progress.dart';
import 'widgets/onboarding_select_field.dart';
import 'widgets/preference_callout.dart';
import 'widgets/subject_tile.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.onboardingRepository, super.key});

  final OnboardingRepository onboardingRepository;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _fullName = 'Aisyah Putri';
  static const _country = 'Indonesia';
  static const _gradeLevel = 'Grade 11 (SMA Kelas 2)';
  static const _preferredLanguage = 'Bahasa Indonesia';
  static const _studyGoal = 'Improve understanding';
  static const _dailyStudyTime = '30-60 minutes';

  int _currentStep = 1;
  bool _isSaving = false;

  final List<_SubjectChoice> _subjects = [
    const _SubjectChoice(
      title: 'Math',
      description: 'Algebra, Geometry, Calculus',
      icon: Icons.calculate_outlined,
      tint: WicaraColors.periwinkle,
      isSelected: true,
    ),
    const _SubjectChoice(
      title: 'Physics',
      description: 'Mechanics, Waves, Thermo',
      icon: Icons.bolt_outlined,
      tint: WicaraColors.periwinkle,
      isSelected: true,
    ),
    const _SubjectChoice(
      title: 'Chemistry',
      description: 'Stoichiometry, Reactions',
      icon: Icons.science_outlined,
      tint: WicaraColors.periwinkle,
      isSelected: true,
    ),
    const _SubjectChoice(
      title: 'Biology',
      description: 'Cell, Genetics, Ecology',
      icon: Icons.eco_outlined,
      tint: Color(0xFF7CC5A5),
      isSelected: true,
    ),
  ];

  Future<void> _nextStep() async {
    if (_currentStep < 3) {
      setState(() => _currentStep += 1);
      return;
    }

    final profile = _profile;
    setState(() => _isSaving = true);
    try {
      await widget.onboardingRepository.saveProfile(profile);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(AppRoutes.pretest);
    } on OnboardingException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  OnboardingProfile get _profile {
    return OnboardingProfile(
      fullName: _fullName,
      country: _country,
      gradeLevel: _gradeLevel,
      preferredLanguage: _preferredLanguage,
      selectedSubjects: _subjects
          .where((subject) => subject.isSelected)
          .map((subject) => subject.title)
          .toList(),
      studyGoal: _studyGoal,
      dailyStudyTime: _dailyStudyTime,
    );
  }

  void _toggleSubject(int index, bool isSelected) {
    setState(() {
      _subjects[index] = _subjects[index].copyWith(isSelected: isSelected);
    });
  }

  void _showMockPicker(String label) {
    _showMessage('$label picker is mocked for now.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pageWidth = math.min(constraints.maxWidth, 430.0);

            return Center(
              child: SizedBox(
                width: pageWidth,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 50, 28, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 74,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OnboardingProgress(currentStep: _currentStep),
                          const SizedBox(height: 52),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: KeyedSubtree(
                              key: ValueKey(_currentStep),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: _stepWidgets(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _stepWidgets(BuildContext context) {
    return switch (_currentStep) {
      1 => _profileStep(context),
      2 => _subjectsStep(context),
      _ => _preferencesStep(context),
    };
  }

  List<Widget> _profileStep(BuildContext context) {
    return [
      const _OnboardingTitle(
        title: "Let's set you up",
        subtitle: 'Tell us a bit about yourself to personalize\nyour learning.',
      ),
      const SizedBox(height: 37),
      OnboardingSelectField(
        label: 'Full name',
        value: _fullName,
        showChevron: false,
        leading: const _SoftIcon(Icons.person_outline_rounded),
        onTap: () => _showMockPicker('Full name'),
      ),
      const SizedBox(height: 26),
      OnboardingSelectField(
        label: 'Country',
        value: _country,
        leading: const IndonesiaFlag(),
        onTap: () => _showMockPicker('Country'),
      ),
      const SizedBox(height: 26),
      OnboardingSelectField(
        label: 'Grade level',
        value: _gradeLevel,
        leading: const _SoftIcon(Icons.school_outlined),
        onTap: () => _showMockPicker('Grade level'),
      ),
      const SizedBox(height: 26),
      OnboardingSelectField(
        label: 'Preferred language',
        value: _preferredLanguage,
        leading: const _SoftIcon(Icons.language_rounded),
        onTap: () => _showMockPicker('Preferred language'),
      ),
      const SizedBox(height: 34),
      GradientButton(
        label: 'Continue',
        onPressed: _isSaving ? null : _nextStep,
      ),
      const SizedBox(height: 19),
      Text(
        "We'll keep improving this experience\njust for you.",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: WicaraColors.softMuted,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 42),
      const SecurityNote(maxWidth: 235),
    ];
  }

  List<Widget> _subjectsStep(BuildContext context) {
    return [
      const _OnboardingTitle(
        title: 'Choose your subjects',
        subtitle:
            'Select the subjects you want to learn.\nYou can adjust these anytime.',
      ),
      const SizedBox(height: 31),
      for (var index = 0; index < _subjects.length; index++) ...[
        SubjectTile(
          title: _subjects[index].title,
          description: _subjects[index].description,
          icon: _subjects[index].icon,
          tint: _subjects[index].tint,
          isSelected: _subjects[index].isSelected,
          onChanged: (value) => _toggleSubject(index, value),
        ),
        if (index < _subjects.length - 1) const SizedBox(height: 10),
      ],
      const SizedBox(height: 29),
      GradientButton(
        label: 'Continue',
        onPressed: _isSaving ? null : _nextStep,
      ),
      const SizedBox(height: 18),
      Text(
        'You can customize more later.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: WicaraColors.softMuted,
          fontWeight: FontWeight.w900,
        ),
      ),
    ];
  }

  List<Widget> _preferencesStep(BuildContext context) {
    return [
      const _OnboardingTitle(
        title: 'How would you like to learn?',
        subtitle: 'Pick your preferences. You can change\nthem anytime.',
      ),
      const SizedBox(height: 23),
      OnboardingSelectField(
        label: 'Study goal (optional)',
        value: _studyGoal,
        leading: const _SoftIcon(Icons.track_changes_rounded),
        onTap: () => _showMockPicker('Study goal'),
      ),
      const SizedBox(height: 25),
      OnboardingSelectField(
        label: 'Daily study time (optional)',
        value: _dailyStudyTime,
        leading: const _SoftIcon(Icons.schedule_rounded),
        onTap: () => _showMockPicker('Daily study time'),
      ),
      const SizedBox(height: 18),
      const PreferenceCallout(),
      const SizedBox(height: 34),
      GradientButton(
        label: 'Continue to adaptive pretest',
        onPressed: _isSaving ? null : _nextStep,
        isLoading: _isSaving,
      ),
      const SizedBox(height: 19),
      Text(
        'This helps us personalize your learning path.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: WicaraColors.softMuted,
          fontWeight: FontWeight.w900,
        ),
      ),
    ];
  }
}

class _OnboardingTitle extends StatelessWidget {
  const _OnboardingTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 24, height: 1.12),
        ),
        const SizedBox(height: 13),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: WicaraColors.muted,
            fontWeight: FontWeight.w800,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _SoftIcon extends StatelessWidget {
  const _SoftIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: WicaraColors.softMuted, size: 21);
  }
}

class _SubjectChoice {
  const _SubjectChoice({
    required this.title,
    required this.description,
    required this.icon,
    required this.tint,
    required this.isSelected,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color tint;
  final bool isSelected;

  _SubjectChoice copyWith({bool? isSelected}) {
    return _SubjectChoice(
      title: title,
      description: description,
      icon: icon,
      tint: tint,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
