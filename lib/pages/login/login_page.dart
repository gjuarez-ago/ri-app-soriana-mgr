import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/pages/home/home_page.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:ago_app/utils/dialogs.dart';
import 'package:ago_app/widgets/header_widget.dart';
import 'package:ago_app/widgets/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  static String routeName = "login_page";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final double _headerHeight = 250;
  final _formKey = GlobalKey<FormState>();

  TextEditingController userText = TextEditingController();
  TextEditingController passwordText = TextEditingController();

  LoginBloc? _loginBloc;
  bool _isObscure = true;

  late String lastEmail;

  String _version = '';
  String _buildNumber = '';

  @override
  void dispose() {
    userText.dispose();
    passwordText.dispose();
    super.dispose();
  }

  void initialData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getString('usuario') != null) {
      lastEmail = preferences.getString('usuario')!;
      userText.text = lastEmail;
    }

    _loginBloc = BlocProvider.of<LoginBloc>(context);
  }

  @override
  void initState() {
    initialData();
    _getAppVersion();

    super.initState();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      _version = packageInfo.version; // ← Esto es el 2.0.1
      _buildNumber = packageInfo.buildNumber; // ← Esto es el +2
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<LoginBloc, LoginState>(listener: (context, state) async {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          if (state is IsLoadingAuth) {
            ProgressDialog.show(context);
          } else if (state is SuccessAuth) {
            ProgressDialog.dissmiss(context);

            if (state.response?.name == null || state.response!.name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    "Usuario o contraseña incorrecta",
                    style: const TextStyle(
                        color:
                            Color.fromARGB(255, 255, 255, 255)), // Texto blanco
                  ),
                  backgroundColor:
                      const Color.fromARGB(255, 208, 13, 13), // Fondo verde
                ),
              );

              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  "Bienvenido ${userText.text} 🙂!",
                  style: const TextStyle(
                      color:
                          Color.fromARGB(255, 255, 255, 255)), // Texto blanco
                ),
                backgroundColor:
                    Color.fromARGB(255, 16, 137, 10), // Fondo verde
              ),
            );

            savePref(
                1,
                state.response!.jwt,
                state.response!.apMaterno,
                state.response!.apPaterno,
                state.response!.idUsuario,
                state.response!.mensaje,
                state.response!.name,
                state.response!.admin,
                state.response!.esSupercito,
                state.response!.rol);

            await saveEnviroments(
                state.response!.constants.apiPathService,
                state.response!.constants.apiUrlService,
                state.response!.constants.apiEnvironment,
                state.response!.constants.apiPathSuaje,
                state.response!.constants.apiUrlSuaje,
                state.response!.constants.apiPathRICh,
                state.response!.constants.apiUrlRICh,
                state.response!.constants.apiUrlBI,
                state.response!.constants.malUbicadosSecuencia,
                state.response!.constants.malUbicadosProdSinHuecos);

            await Constants.loadEnviroments();
            await Constants.loadToken();
            Navigator.pushNamedAndRemoveUntil(
              context,
              HomePage.routeName,
              (route) => false,
            );
          }

          if (state is ErrorAuth) {
            ProgressDialog.dissmiss(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  "Usuario o contraseña incorrecta",
                  style: const TextStyle(
                      color:
                          Color.fromARGB(255, 255, 255, 255)), // Texto blanco
                ),
                backgroundColor:
                    const Color.fromARGB(255, 208, 13, 13), // Fondo verde
              ),
            );

            // ProgressDialog.dissmiss(context);
            // snackbarRoundInfo(context, "${state.messageError}", Colors.red);
          }
        }, builder: (context, state) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: _headerHeight,
                    child: HeaderWidget(
                        _headerHeight,
                        true,
                        Icons
                            .login_rounded), //let's create a common header widget
                  ),
                  SafeArea(
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        margin: const EdgeInsets.fromLTRB(
                            20, 10, 20, 10), // This will be the login form
                        child: Column(
                          children: [
                            const Text(
                              'Bienvenido',
                              style: TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Ingresa tus credenciales',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 30.0),
                            Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    Container(
                                      child: TextFormField(
                                        controller: userText,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Campo requerido';
                                          }
                                          return null;
                                        },
                                        decoration:
                                            ThemeHelper().textInputDecoration(
                                          Icons.email,
                                          'Usuario, correo o número',
                                          'Ingresa tu usuario',
                                        ),
                                      ),
                                      decoration: ThemeHelper()
                                          .inputBoxDecorationShaddow(),
                                    ),
                                    const SizedBox(height: 20.0),
                                    Container(
                                      child: TextFormField(
                                        controller: passwordText,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Ingresa la contraseña';
                                          }
                                          return null;
                                        },
                                        obscureText: _isObscure,
                                        decoration: ThemeHelper()
                                            .textInputDecoration(
                                              Icons.password,
                                              'Contraseña',
                                              'Ingresa la contraseña',
                                            )
                                            .copyWith(
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _isObscure
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _isObscure = !_isObscure;
                                                  });
                                                },
                                              ),
                                            ),
                                      ),
                                      decoration: ThemeHelper()
                                          .inputBoxDecorationShaddow(),
                                    ),
                                    const SizedBox(height: 20.0),
                                    // Container(
                                    //   margin: const EdgeInsets.fromLTRB(
                                    //       10, 0, 10, 20),
                                    //   alignment: Alignment.topRight,
                                    //   child: GestureDetector(
                                    //     onTap: () {
                                    //       // Navigator.push(
                                    //       //     context,
                                    //       //     MaterialPageRoute(
                                    //       //         builder: (context) =>
                                    //       //             const RecoveryPasswordPage()));
                                    //     },
                                    //     child: const Text(
                                    //       "¿Olvidaste tu contraseña?",
                                    //       style: TextStyle(
                                    //         color: Colors.grey,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    Container(
                                      decoration: ThemeHelper()
                                          .buttonBoxDecoration(context),
                                      child: ElevatedButton(
                                        style: ThemeHelper().buttonStyle(),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              40, 10, 40, 10),
                                          child: Text(
                                            'Ingresar'.toUpperCase(),
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ),
                                        onPressed: () async {
                                          onSubmit(context);
                                        },
                                      ),
                                    ),
                                    // GestureDetector(
                                    //   onTap: () {
                                    //     // Navigator.pushReplacementNamed(
                                    //     //     context, RegisterPage.routeName);
                                    //   },
                                    //   child: Container(
                                    //     margin: const EdgeInsets.fromLTRB(
                                    //         10, 30, 10, 20),
                                    //     //child: Text('Don\'t have an account? Create'),
                                    //     child:
                                    //         const Text.rich(TextSpan(children: [
                                    //       TextSpan(
                                    //           text: "Aun no tienes cuenta? "),
                                    //       TextSpan(
                                    //         text: 'Registrate',
                                    //         style: TextStyle(
                                    //             fontWeight: FontWeight.bold,
                                    //             color: Colors.black),
                                    //       ),
                                    //     ])),
                                    //   ),
                                    // ),
                                  ],
                                )),
                            const SizedBox(height: 20.0),
                            Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Text(
                                  'Versión $_version',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                )),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          );
        }));
  }

  void onSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
      final regExp = RegExp(pattern);
      bool validate = true;

      // if (!regExp.hasMatch(userText.text.trim())) {
      //   // snackbarRoundInfo(context, "No es un email valido!",
      //   //     Color.fromARGB(255, 235, 132, 7));
      //   validate = false;
      // }

      if (validate) {
        _loginBloc?.add(EventAuth(
            user: userText.text.trim(), password: passwordText.text.trim()));
      }
    }
  }

  savePref(
      int value,
      String token,
      String apMaterno,
      String apPaterno,
      String idUsuario,
      String mensaje,
      String name,
      bool admin,
      bool esSupercito,
      String permisos) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      preferences.setBool("admin", admin);
      preferences.setBool("esSupercito", esSupercito);
      preferences.setInt("value", value);
      preferences.setString("token", token);
      preferences.setString("apMaterno", apMaterno);
      preferences.setString("apPaterno", apPaterno);
      preferences.setString("usuario", idUsuario);
      preferences.setString("mensaje", mensaje);
      preferences.setString("name", name);
      preferences.setBool("dactilar", false);
      preferences.setString(
          "expiredToken", JwtDecoder.getExpirationDate(token).toString());
      preferences.setString("permisos", permisos);
      // ignore: deprecated_member_use
      preferences.commit();
    });
  }

  saveEnviroments(
      String apiPathService,
      String apiUrlService,
      String apiEnvironment,
      String apiPathSuaje,
      String apiUrlSuaje,
      String apiPathRICh,
      String apiUrlRICh,
      String apiUrlBI,
      String malUbicadosSecuencia,
      String malUbicadosProdSinHuecos) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      preferences.setString("apiPathService", apiPathService);
      preferences.setString("apiUrlService", apiUrlService);
      preferences.setString("apiEnvironment", apiEnvironment);
      preferences.setString("apiPathSuaje", apiPathSuaje);
      preferences.setString("apiUrlSuaje", apiUrlSuaje);
      preferences.setString("apiPathRICh", apiPathRICh);
      preferences.setString("apiUrlRICh", apiUrlRICh);
      preferences.setString("apiUrlBI", apiUrlBI);
      preferences.setString("malUbicadosSecuencia", malUbicadosSecuencia);
      preferences.setString(
          "malUbicadosProdSinHuecos", malUbicadosProdSinHuecos);
    });
  }
}
