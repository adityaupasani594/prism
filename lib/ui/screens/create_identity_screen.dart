import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import '../app_routes.dart';
import '../../services/api_service.dart';

class CreateIdentityScreen extends StatefulWidget {
  const CreateIdentityScreen({Key? key}) : super(key: key);

  @override
  State<CreateIdentityScreen> createState() => _CreateIdentityScreenState();
}

class _CreateIdentityScreenState extends State<CreateIdentityScreen> {
  static const String _demoDid = 'did:prism:user123';

  final ImagePicker _imagePicker = ImagePicker();
  bool _isScanning = false;
  bool _isOnboarding = false;
  Map<String, dynamic>? _lastScanResult;

  Future<void> _scanIdentityDocument(String docType) async {
    if (_isScanning) return;

    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _isScanning = true;
    });

    try {
      final bytes = await pickedFile.readAsBytes();
      final response = await ApiService().scanIdentityDocument(
        fileBytes: bytes,
        fileName: pickedFile.name,
      );

      if (!mounted) return;

      setState(() {
        _lastScanResult = {
          'document_type': docType,
          ...response,
        };
      });

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('$docType Scan Complete'),
            content: Text(response.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _onboardAndGenerateIdentity() async {
    if (_isOnboarding) return;

    setState(() {
      _isOnboarding = true;
    });

    try {
      await ApiService().onboardUser(_demoDid).timeout(const Duration(seconds: 3));
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.onboardingSecured);
    } on TimeoutException {
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.onboardingSecured);
    } catch (e) {
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.onboardingSecured);
    } finally {
      if (!mounted) return;
      setState(() {
        _isOnboarding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text('PRISM', style: TextStyle(
              fontWeight: FontWeight.w900, 
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: -1,
            )),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero Security Indicator
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Icon(Icons.lock_outline, size: 48, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Create Your Demo Identity',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Generate a PRISM digital ID for the MVP demo. Document upload is optional and only used to show future verification.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              
              // Trust Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTrustBadge(context, Icons.enhanced_encryption, 'AES-256 Encrypted'),
                  const SizedBox(width: 12),
                  _buildTrustBadge(context, Icons.verified_user, 'Privacy Guaranteed'),
                ],
              ),
              const SizedBox(height: 48),

              // Interactive Cards
              _buildUploadCard(
                context,
                icon: Icons.badge,
                title: 'Upload Aadhaar',
                subtitle: 'Optional demo step for future verified credentials. Do not upload real documents for the MVP video.',
                onTap: () {
                  _scanIdentityDocument('Aadhaar');
                },
              ),
              const SizedBox(height: 16),
              _buildUploadCard(
                context,
                icon: Icons.credit_card,
                title: 'Upload PAN',
                subtitle: 'Optional demo step for future KYC proof. The MVP can generate a demo ID without this.',
                onTap: () {
                  _scanIdentityDocument('PAN');
                },
              ),
              if (_isScanning) ...[
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text('Scanning document...'),
                  ],
                ),
              ],
              if (_lastScanResult != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Last scan (${_lastScanResult!['document_type']}): ${_lastScanResult.toString()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Info Block
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Theme.of(context).colorScheme.tertiary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'For the hackathon MVP, you can generate a demo digital ID without uploading Aadhaar, PAN, or any real document.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Primary Action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isOnboarding ? null : _onboardAndGenerateIdentity,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(_isOnboarding ? 'Generating demo ID...' : 'Generate Demo Digital ID'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 8,
                    shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadge(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildUploadCard(BuildContext context, {
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
              blurRadius: 32,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Start Upload', style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                )),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16, color: Theme.of(context).colorScheme.primary),
              ],
            )
          ],
        ),
      ),
    );
  }
}
