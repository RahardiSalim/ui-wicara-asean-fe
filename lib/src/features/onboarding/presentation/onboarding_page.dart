import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/wicara_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/security_note.dart';
import '../../auth/data/auth_session_store.dart';
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
  final _profileFormKey = GlobalKey<FormState>();
  final _preferencesFormKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _studyGoalController = TextEditingController(
    text: 'Improve understanding',
  );

  static const _countryOptions = [
    'Indonesia',
    'Malaysia',
    'Philippines',
    'Vietnam',
  ];
  static const _educationLevels = [
    'Elementary School',
    'Junior High School',
    'Senior High School',
    'University',
  ];
  static const Map<String, List<String>> _gradeOptionsByLevel = {
    'Elementary School': [
      'Grade 1',
      'Grade 2',
      'Grade 3',
      'Grade 4',
      'Grade 5',
      'Grade 6',
    ],
    'Junior High School': ['Grade 7', 'Grade 8', 'Grade 9'],
    'Senior High School': ['Grade 10', 'Grade 11', 'Grade 12'],
    'University': ['Year 1', 'Year 2', 'Year 3', 'Year 4', 'Graduate'],
  };
  static const _languageOptions = [
    'Bahasa Indonesia',
    'English',
    'Bahasa Melayu',
    'Filipino',
    'Vietnamese',
  ];
  static const _dailyStudyTimeOptions = [
    '15-30 minutes',
    '30-60 minutes',
    '60-90 minutes',
  ];

  int _currentStep = 1;
  bool _isSaving = false;
  String _country = _countryOptions.first;
  String _educationLevel = 'Senior High School';
  String _gradeLevel = 'Grade 11';
  String _preferredLanguage = _languageOptions.first;
  String _dailyStudyTime = '30-60 minutes';

  final List<_SubjectChoice> _subjects = [
    const _SubjectChoice(
      title: 'Math',
      description: 'Algebra, Geometry, Calculus',
      icon: Icons.calculate_outlined,
      tint: WicaraColors.math,
      isSelected: true,
    ),
    const _SubjectChoice(
      title: 'Physics',
      description: 'Mechanics, Waves, Thermo',
      icon: Icons.bolt_outlined,
      tint: WicaraColors.physics,
      isSelected: true,
    ),
    const _SubjectChoice(
      title: 'Chemistry',
      description: 'Stoichiometry, Reactions',
      icon: Icons.science_outlined,
      tint: WicaraColors.chemistry,
      isSelected: true,
    ),
    const _SubjectChoice(
      title: 'Biology',
      description: 'Cell, Genetics, Ecology',
      icon: Icons.eco_outlined,
      tint: WicaraColors.biology,
      isSelected: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final displayName = authSessionStore.currentSession?.displayName ?? '';
    if (displayName.trim().isNotEmpty) {
      _fullNameController.text = displayName.trim();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studyGoalController.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_currentStep == 1 &&
        !(_profileFormKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_currentStep == 3 &&
        !(_preferencesFormKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_currentStep == 2 && !_subjects.any((subject) => subject.isSelected)) {
      _showMessage('Select at least one subject.');
      return;
    }

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
      Navigator.of(context).pushReplacementNamed(AppRoutes.learningGoal);
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

  void _previousStep() {
    if (_currentStep == 1) {
      return;
    }
    setState(() => _currentStep -= 1);
  }

  OnboardingProfile get _profile {
    return OnboardingProfile(
      fullName: _fullNameController.text.trim(),
      country: _country,
      educationLevel: _educationLevel,
      gradeLevel: _gradeLevel,
      preferredLanguage: _preferredLanguage,
      selectedSubjects: _subjects
          .where((subject) => subject.isSelected)
          .map((subject) => subject.title)
          .toList(),
      studyGoal: _studyGoalController.text.trim(),
      dailyStudyTime: _dailyStudyTime,
    );
  }

  void _toggleSubject(int index, bool isSelected) {
    setState(() {
      _subjects[index] = _subjects[index].copyWith(isSelected: isSelected);
    });
  }

  List<String> get _gradeOptions =>
      _gradeOptionsByLevel[_educationLevel] ?? const ['Grade 11'];

  void _setEducationLevel(String value) {
    setState(() {
      _educationLevel = value;
      final options = _gradeOptionsByLevel[_educationLevel] ?? const <String>[];
      if (!options.contains(_gradeLevel) && options.isNotEmpty) {
        _gradeLevel = options.first;
      }
    });
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
                          if (_currentStep > 1) ...[
                            _OnboardingBackButton(onPressed: _previousStep),
                            const SizedBox(height: 16),
                          ],
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
      Form(
        key: _profileFormKey,
        child: Column(
          children: [
            _OnboardingTextField(
              label: 'Full name',
              controller: _fullNameController,
              icon: Icons.person_outline_rounded,
              hintText: 'Enter your full name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 26),
            _OnboardingDropdown(
              label: 'Country',
              value: _country,
              options: _countryOptions,
              leading: const IndonesiaFlag(),
              onChanged: (value) => setState(() => _country = value),
            ),
            const SizedBox(height: 26),
            _OnboardingDropdown(
              label: 'Education level',
              value: _educationLevel,
              options: _educationLevels,
              leading: const _SoftIcon(Icons.account_balance_outlined),
              onChanged: _setEducationLevel,
            ),
            const SizedBox(height: 26),
            _OnboardingDropdown(
              label: 'Grade level',
              value: _gradeLevel,
              options: _gradeOptions,
              leading: const _SoftIcon(Icons.school_outlined),
              onChanged: (value) => setState(() => _gradeLevel = value),
            ),
            const SizedBox(height: 26),
            _OnboardingDropdown(
              label: 'Preferred language',
              value: _preferredLanguage,
              options: _languageOptions,
              leading: const _SoftIcon(Icons.language_rounded),
              onChanged: (value) => setState(() => _preferredLanguage = value),
            ),
          ],
        ),
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
          fontWeight: FontWeight.w600,
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
          fontWeight: FontWeight.w600,
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
      Form(
        key: _preferencesFormKey,
        child: Column(
          children: [
            _OnboardingTextField(
              label: 'Study goal (optional)',
              controller: _studyGoalController,
              icon: Icons.track_changes_rounded,
              hintText: 'What do you want to improve?',
            ),
            const SizedBox(height: 25),
            _OnboardingDropdown(
              label: 'Daily study time (optional)',
              value: _dailyStudyTime,
              options: _dailyStudyTimeOptions,
              leading: const _SoftIcon(Icons.schedule_rounded),
              onChanged: (value) => setState(() => _dailyStudyTime = value),
            ),
          ],
        ),
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
          fontWeight: FontWeight.w600,
        ),
      ),
    ];
  }
}

class _OnboardingBackButton extends StatelessWidget {
  const _OnboardingBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        tooltip: 'Back',
        onPressed: onPressed,
        icon: const Icon(Icons.chevron_left_rounded),
        iconSize: 32,
        color: WicaraColors.ink,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 38, height: 38),
      ),
    );
  }
}

class _OnboardingTitle extends StatelessWidget {
  const _OnboardingTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'lib/src/assets/onboardingIcon.png',
          width: 84,
          height: 84,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 24, height: 1.12),
        ),
        const SizedBox(height: 13),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: WicaraColors.muted,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _OnboardingTextField extends StatelessWidget {
  const _OnboardingTextField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hintText,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: WicaraColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          validator: validator,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: WicaraColors.softMuted, size: 21),
            filled: true,
            fillColor: WicaraColors.fieldFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: WicaraColors.line,
                width: 1.4,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: WicaraColors.line,
                width: 1.4,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: WicaraColors.primaryDeep,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingDropdown extends StatelessWidget {
  const _OnboardingDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.leading,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final Widget leading;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: [
        for (final option in options)
          DropdownMenuItem<String>(value: option, child: Text(option)),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: SizedBox(width: 48, child: Center(child: leading)),
        filled: true,
        fillColor: WicaraColors.fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: WicaraColors.line, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: WicaraColors.line, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: WicaraColors.primaryDeep,
            width: 1.4,
          ),
        ),
      ),
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
