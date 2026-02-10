import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';

/// Change PIN screen with 3-step flow:
/// 1. Verify current PIN
/// 2. Enter new PIN
/// 3. Confirm new PIN
class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _currentPinFocus = FocusNode();
  final _newPinFocus = FocusNode();
  final _confirmPinFocus = FocusNode();

  bool _isLoading = false;
  String? _error;
  int _step = 1; // 1 = current PIN, 2 = new PIN, 3 = confirm new PIN

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _currentPinFocus.dispose();
    _newPinFocus.dispose();
    _confirmPinFocus.dispose();
    super.dispose();
  }

  TextEditingController get _activeController {
    switch (_step) {
      case 1:
        return _currentPinController;
      case 2:
        return _newPinController;
      case 3:
        return _confirmPinController;
      default:
        return _currentPinController;
    }
  }

  FocusNode get _activeFocus {
    switch (_step) {
      case 1:
        return _currentPinFocus;
      case 2:
        return _newPinFocus;
      case 3:
        return _confirmPinFocus;
      default:
        return _currentPinFocus;
    }
  }

  void _onPinComplete(String pin) {
    if (pin.length != 4) return;

    switch (_step) {
      case 1:
        _verifyCurrentPin(pin);
        break;
      case 2:
        setState(() {
          _step = 3;
          _error = null;
        });
        _confirmPinFocus.requestFocus();
        break;
      case 3:
        _handleConfirmAndSubmit(pin);
        break;
    }
  }

  Future<void> _verifyCurrentPin(String pin) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final verified = await ref.read(authRepositoryProvider).verifyPin(pin);
      if (!mounted) return;

      if (verified) {
        setState(() {
          _step = 2;
          _isLoading = false;
        });
        _newPinFocus.requestFocus();
      } else {
        setState(() {
          _error = 'Incorrect PIN. Please try again.';
          _isLoading = false;
          _currentPinController.clear();
        });
        _currentPinFocus.requestFocus();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to verify PIN. Please try again.';
        _isLoading = false;
        _currentPinController.clear();
      });
      _currentPinFocus.requestFocus();
    }
  }

  Future<void> _handleConfirmAndSubmit(String confirmPin) async {
    if (confirmPin != _newPinController.text) {
      setState(() {
        _error = 'PINs do not match. Please try again.';
        _step = 2;
        _newPinController.clear();
        _confirmPinController.clear();
      });
      _newPinFocus.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).changePin(
            currentPin: _currentPinController.text,
            newPin: _newPinController.text,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN changed successfully'),
          backgroundColor: AppColors.greenMain,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to change PIN. Please try again.';
        _isLoading = false;
        _step = 1;
        _currentPinController.clear();
        _newPinController.clear();
        _confirmPinController.clear();
      });
      _currentPinFocus.requestFocus();
    }
  }

  String get _title {
    switch (_step) {
      case 1:
        return 'Enter Current PIN';
      case 2:
        return 'Enter New PIN';
      case 3:
        return 'Confirm New PIN';
      default:
        return 'Change PIN';
    }
  }

  String get _subtitle {
    switch (_step) {
      case 1:
        return 'Enter your current 4-digit PIN to continue';
      case 2:
        return 'Choose a new 4-digit PIN';
      case 3:
        return 'Enter your new PIN again to confirm';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Change PIN'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray800,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),

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
                _title,
                style: AppTypography.formTitle.copyWith(
                  color: AppColors.gray800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              Text(
                _subtitle,
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
                controller: _activeController,
                focusNode: _activeFocus,
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
                  _StepDot(isActive: _step >= 2, isComplete: _step > 2),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: 24,
                    height: 2,
                    color: _step > 2 ? AppColors.primary : AppColors.border,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _StepDot(isActive: _step >= 3, isComplete: false),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Loading indicator
              if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppSpacing.md),
                    Text('Processing...'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// PIN input widget with 4 visual boxes and hidden TextField
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.focusNode.requestFocus();
      });
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
                final isActive =
                    index == text.length && widget.focusNode.hasFocus;

                return Container(
                  width: 50,
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: hasValue ? AppColors.greenPale : AppColors.white,
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
