import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/name_input_field.dart';

/// İlk giriş ekranı - Kullanıcıdan adını alır
///
/// Bu ekran uygulamaya ilk kez giriş yapan kullanıcılar için gösterilir.
/// Kullanıcı adını girdikten sonra ana ekrana yönlendirilir.
class FirstLoginScreen extends StatefulWidget {
  const FirstLoginScreen({super.key});

  static const String routeName = '/first-login';

  @override
  State<FirstLoginScreen> createState() => _FirstLoginScreenState();
}

class _FirstLoginScreenState extends State<FirstLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Burada kullanıcı bilgilerini kaydet
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();

    // TODO: Kullanıcı modelini oluştur ve Hive'a kaydet
    // final user = UserModel(
    //   id: 'user_${DateTime.now().millisecondsSinceEpoch}',
    //   name: name,
    //   surname: surname,
    //   email: '',
    //   role: UserRole.admin,
    //   createdAt: DateTime.now(),
    // );
    // await HiveService.addUser(user);

    // Simülasyon için kısa bir gecikme
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      // Ana ekrana yönlendir
      Navigator.of(context).pushReplacementNamed('/home');
      // veya
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => const HomeScreen()),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
            vertical: AppSizes.screenPaddingV,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.spaceXxxl),

                // Logo veya İkon
                Icon(
                  Icons.account_circle_outlined,
                  size: 120,
                  color: AppColors.primary,
                ),

                const SizedBox(height: AppSizes.spaceXl),

                // Hoş geldiniz metni
                Text(
                  'Hoş Geldiniz!',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSizes.spaceSm),

                Text(
                  'Başlamak için lütfen bilgilerinizi girin',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSizes.spaceXl),

                // Ad input
                NameInputField(
                  controller: _nameController,
                  label: 'Ad',
                  hint: 'Adınızı girin',
                  icon: Icons.person_outline,
                  enabled: !_isLoading,
                ),

                const SizedBox(height: AppSizes.spaceMd),

                // Soyad input
                NameInputField(
                  controller: _surnameController,
                  label: 'Soyad',
                  hint: 'Soyadınızı girin',
                  icon: Icons.person_outline,
                  enabled: !_isLoading,
                ),

                const SizedBox(height: AppSizes.spaceXl),

                // Devam et butonu
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(
                      double.infinity,
                      AppSizes.buttonHeightLg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Devam Et',
                          style: TextStyle(
                            fontSize: AppSizes.fontLg,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),

                const SizedBox(height: AppSizes.spaceLg),

                // Bilgi metni
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingMd),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: AppSizes.iconSm,
                      ),
                      const SizedBox(width: AppSizes.spaceSm),
                      Expanded(
                        child: Text(
                          'Bu bilgiler uygulama içinde kullanılacaktır. İstediğiniz zaman ayarlardan değiştirebilirsiniz.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
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
      ),
    );
  }
}
