import 'package:antep_depo_app/constants/images_path.dart';
import 'package:antep_depo_app/constants/project_dio.dart';
import 'package:antep_depo_app/service/order_services.dart';
import 'package:antep_depo_app/views/home_screen.dart';
import 'package:antep_depo_app/views/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with ProjectDioMixin {
  final formKey = GlobalKey<FormState>();
  late TextEditingController _kullaniciAdiController;
  late TextEditingController _passwordController;
  late final IOrderServices _orderServices;

  @override
  void initState() {
    super.initState();
    _kullaniciAdiController = TextEditingController();
    _passwordController = TextEditingController();
    _orderServices = OrderServices(dio: servicePath);
  }

  @override
  void dispose() {
    _kullaniciAdiController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        final prefs = await SharedPreferences.getInstance();

        // Kullanıcı adı ve şifreyi formdan alın
        final kullaniciAdi = _kullaniciAdiController.text.trim();
        final sifre = _passwordController.text.trim();

        // API'ye istek atın
        final isLogin = await _orderServices.login(kullaniciAdi, sifre);

        if (isLogin) {
          // Başarılı giriş yapıldı, isLoggedIn durumunu kaydedin
          await prefs.setBool('isLoggedIn', true);

          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // Başarısız mesajı gösterin
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Giriş başarısız',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bir hata oluştu.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        //appBar: AppBar(),
        body: SingleChildScrollView(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  Stack(children: [
                    ClipPath(
                      clipper: WaveClipper(),
                      child: Container(
                        height: 300,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 242, 185, 29),
                              Color.fromARGB(255, 242, 185, 29)
                            ], // mor-mavi geçiş
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    Hero(
                      tag: 'hero-demo',
                      flightShuttleBuilder: (flightContext, animation,
                          direction, fromHero, toHero) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            // Yukarıdan aşağıya kayma animasyonu (geri dönüşte tersine)
                            final offset = Tween<Offset>(
                              begin:
                                  const Offset(0, -1.0), // Yukarıdan başlayacak
                              end: Offset.zero, // Ortada bitecek
                            ).animate(animation).value;

                            return Transform.translate(
                              offset: Offset(
                                  0,
                                  offset.dy *
                                      MediaQuery.of(context).size.height),
                              child: child,
                            );
                          },
                          child: toHero.widget,
                        );
                      },
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/360_Stocker.jpg'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(55),
                            bottomRight: Radius.circular(55),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),

              //todo: Burada Giriş FormField Kısmı olacak
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                child: Card(
                  color: Colors.white,
                  //color: const Color.fromARGB(255, 248, 255, 234).withOpacity(0.6),
                  elevation: 20,
                  child: Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //Todo: Kullanıcı Adı
                            CustomTextFormField(
                              controller: _kullaniciAdiController,
                              message: "Kullanıcı Adı",
                              errorMessage: "Kullanıcı Adı Boş Olamaz",
                              icon: Icons.account_circle_outlined,
                              isObscure: false,
                            ),

                            CustomTextFormField(
                                isObscure: true,
                                icon: Icons.lock_outline_rounded,
                                controller: _passwordController,
                                message: "Şifre",
                                errorMessage: "Şifre Boş Olamaz"),

                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: login,
                                style: ElevatedButton.styleFrom(
                                  //padding: const EdgeInsets.symmetric(vertical: 10),
                                  backgroundColor:
                                      const Color.fromARGB(255, 242, 185, 29),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  'Giriş Yap',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dalgayı çizen özel clipper
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
