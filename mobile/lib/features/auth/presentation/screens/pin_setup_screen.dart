import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

/// PIN setup screen for new users
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _pinFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  bool _isLoading = false;
  String? _error;
  int _step = 1; // 1 = enter PIN, 2 = confirm PIN

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _pinFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  void _onPinComplete(String pin) {
    if (_step == 1) {
      if (pin.length == 4) {
        setState(() {
          _step = 2;
          _error = null;
        });
        _confirmFocusNode.requestFocus();
      }
    } else {
      _handleConfirm(pin);
    }
  }

  Future<void> _handleConfirm(String confirmPin) async {
    if (confirmPin != _pinController.text) {
      setState(() {
        _error = 'PINs do not match. Please try again.';
        _step = 1;
        _pinController.clear();
        _confirmPinController.clear();
      });
      _pinFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).setPin(_pinController.text);

      if (mounted) {
        // Mark PIN as set and navigate to dashboard
        ref.read(authProvider.notifier).markPinSet();
        context.go('/');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to set PIN. Please try again.';
        _isLoading = false;
        _step = 1;
        _pinController.clear();
        _confirmPinController.clear();
      });
      _pinFocusNode.requestFocus();
    }
  }

  void _resetPin() {
    setState(() {
      _step = 1;
      _error = null;
      _pinController.clear();
      _confirmPinController.clear();
    });
    _pinFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                _step == 1 ? 'Create Your PIN' : 'Confirm Your PIN',
                style: AppTypography.formTitle.copyWith(
                  color: AppColors.gray800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              Text(
                _step == 1
                    ? 'This PIN verifies completed drills.\nKeep it secret from your child!'
                    : 'Enter your PIN again to confirm',
                style: AppTypography.body.copyWith(
                  color: AppColors.gray500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Error message
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppTypography.body.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // PIN Input
              _PinInput(
                controller: _step == 1 ? _pinController : _confirmPinController,
                focusNode: _step == 1 ? _pinFocusNode : _confirmFocusNode,
                onComplete: _onPinComplete,
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepDot(isActive: _step >= 1, isComplete: _step > 1),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: 24,
                    height: 2,
                    color: _step > 1 ? AppColors.primary : AppColors.border,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _StepDot(isActive: _step >= 2, isComplete: false),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Reset button (only on step 2)
              if (_step == 2 && !_isLoading)
                TextButton(
                  onPressed: _resetPin,
                  child: Text(
                    'Start Over',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

              const Spacer(),

              // Loading indicator
              if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppSpacing.md),
                    Text('Setting up your PIN...'),
                  ],
                ),

              // Info text
              if (!_isLoading)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.info),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Your PIN confirms that you (the parent) verified your child completed a drill.',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// PIN input widget with 4 boxes
class _PinInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onComplete;
  final bool enabled;

  const _PinInput({
    required this.controller,
    required this.focusNode,
    required this.onComplete,
    this.enabled = true,
  });

  @override
  State<_PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<_PinInput> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    // Auto-focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(covariant _PinInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    if (widget.controller.text.length == 4) {
      widget.onComplete(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;

    return AutofillGroup(
      onDisposeAction: AutofillContextAction.cancel,
      child: Column(
      children: [
        // Hidden text field for keyboard input
        SizedBox(
          width: 1,
          height: 1,
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: TextInputType.number,
            maxLength: 4,
            enabled: widget.enabled,
            autofillHints: const [],
            enableSuggestions: false,
            autocorrect: false,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
          ),
        ),

        // Visual PIN boxes
        GestureDetector(
          onTap: () => widget.focusNode.requestFocus(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final hasValue = index < text.length;
              final isActive = index == text.length && widget.focusNode.hasFocus;

              return Container(
                width: 50,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: hasValue
                      ? AppColors.greenPale
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isActive
                        ? AppColors.greenMain
                        : hasValue
                            ? AppColors.greenMain
                            : AppColors.gray300,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: hasValue
                      ? Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              );
            }),
          ),
        ),
      ],
    ),
    );
  }
}

/// Step indicator dot
class _StepDot extends StatelessWidget {
  final bool isActive;
  final bool isComplete;

  const _StepDot({
    required this.isActive,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: isComplete
          ? const Icon(Icons.check, size: 8, color: Colors.white)
          : null,
    );
  }
}
