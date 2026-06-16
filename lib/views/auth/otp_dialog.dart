import 'package:flutter/material.dart';
import '../../core/widgets/custom_widgets.dart';

class OtpDialog extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final Function(String smsCode) onVerify;

  const OtpDialog({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
    required this.onVerify,
  }) : super(key: key);

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await widget.onVerify(_otpController.text.trim());
      Navigator.of(context).pop(); // Close dialog on success
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enter Verification Code',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'We have sent a 6-digit SMS code to:\n${widget.phoneNumber}',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _otpController,
                label: 'SMS Code',
                hint: '6-digit OTP',
                prefixIcon: Icons.lock_clock_outlined,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.length != 6) {
                    return 'Please enter a valid 6-digit code';
                  }
                  return null;
                },
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage,
                  style: TextStyle(color: theme.colorScheme.error, fontSize: 13, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              // Tip for users
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary.withOpacity(0.8)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Demo Tip: Enter "123456" to proceed.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Verify & Continue',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
