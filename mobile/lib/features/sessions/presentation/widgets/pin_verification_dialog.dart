import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';

/// Shows a PIN verification dialog and returns true if verified
Future<bool> showPinVerificationDialog(BuildContext context, WidgetRef ref) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _PinVerificationDialog(),
  );
  return result ?? false;
}

/// PIN verification dialog for parent to confirm drill completion
class _PinVerificationDialog extends ConsumerStatefulWidget {
  const _PinVerificationDialog();

  @override
  ConsumerState<_PinVerificationDialog> createState() =>
      _PinVerificationDialogState();
}

class _PinVerificationDialogState
    extends ConsumerState<_PinVerificationDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isVerifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    Future.microtask(() {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    if (_controller.text.length == 4) {
      _verifyPin();
    }
  }

  Future<void> _verifyPin() async {
    final pin = _controller.text;
    if (pin.length != 4) return;

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      final isValid = await repository.verifyPin(pin);

      if (!mounted) return;

      if (isValid) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isVerifying = false;
          _error = 'Wrong PIN. Try again!';
        });
        _clearPin();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _error = 'Could not verify PIN. Try again.';
      });
      _clearPin();
    }
  }

  void _clearPin() {
    _controller.clear();
    // Use post-frame callback to ensure focus is reliably restored after state rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.unfocus();
        _focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lock icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 32,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Title
            Text(
              'Parent Check',
              style: AppTypography.title.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Subtitle
            Text(
              'Enter your PIN to confirm',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Hidden text field for keyboard input
            SizedBox(
              width: 1,
              height: 1,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                maxLength: 4,
                enabled: !_isVerifying,
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
              onTap: () => _focusNode.requestFocus(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final hasValue = index < text.length;
                  final isActive = index == text.length && _focusNode.hasFocus;

                  return Container(
                    width: 56,
                    height: 64,
                    margin: EdgeInsets.only(
                      left: index > 0 ? AppSpacing.sm : 0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isActive
                            ? AppColors.secondary
                            : hasValue
                                ? AppColors.secondary
                                : AppColors.border,
                        width: isActive || hasValue ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: hasValue
                          ? Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    ),
                  );
                }),
              ),
            ),

            // Error message
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _error!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],

            // Loading indicator
            if (_isVerifying) ...[
              const SizedBox(height: AppSpacing.md),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            // Cancel button
            TextButton(
              onPressed: _isVerifying
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
