import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
// import 'package:test_app/components/my_drawer.dart';
import 'package:test_app/exceptions/validation.exception.dart';
import 'package:test_app/services/auth.service.dart' as auth_service;

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  var _autoValidateMode = AutovalidateMode.disabled;
  var _isLoading = false;
  final _registerFormKey = GlobalKey<FormState>();
  Map _validationErrors = {};
  bool _termsAccepted = false;
  var _showPassword = false;
  FocusNode? _passwordFocus, _emailFocus;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _passwordFocus!.dispose();
    _emailFocus!.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future _register() async {
    try {
      if (!_termsAccepted) {
        return showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('Terms are not accepted'),
            content: Text('Please accept terms and conditions to continue'),
          ),
        );
      }

      setState(() {
        _isLoading = true;
        _validationErrors = {};
      });

      if (!_registerFormKey.currentState!.validate()) {
        return setState(() {
          _isLoading = false;
          _autoValidateMode = AutovalidateMode.always;
        });
      }

      await auth_service.register(
        context: context,
        email: _emailController.text,
        name: _nameController.text,
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      Navigator.pushNamed(context, 'dashboard');
    } on ValidationException catch (e) {
      setState(() {
        _validationErrors = e.errors;
        _isLoading = false;
        _autoValidateMode = AutovalidateMode.always;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      // drawer: MyDrawer(),
      body: SafeArea(
        child: Form(
          autovalidateMode: _autoValidateMode,
          key: _registerFormKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              const SizedBox(height: 20.0),
              Hero(
                child: TextFormField(
                  autofillHints: const [AutofillHints.name],
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(_emailFocus);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter name';
                    }
                    if (_validationErrors.containsKey('name')) {
                      return _validationErrors['name'][0];
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    labelText: 'Name *',
                  ),
                  maxLength: 128,
                ),
                tag: 'nameInput',
              ),
              const SizedBox(height: 20.0),
              Hero(
                child: TextFormField(
                  autofillHints: const [AutofillHints.email],
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(_passwordFocus);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!isEmail(value)) {
                      return 'Please enter valid email';
                    }
                    if (_validationErrors.containsKey('email')) {
                      return _validationErrors['email'][0];
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: 'Email *',
                  ),
                  maxLength: 128,
                ),
                tag: 'emailInput',
              ),
              const SizedBox(height: 20.0),
              Hero(
                child: TextFormField(
                  autofillHints: const [AutofillHints.newPassword],
                  obscureText: !_showPassword,
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter password';
                    }
                    if (_validationErrors.containsKey('password')) {
                      return _validationErrors['password'][0];
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                        icon: Icon(!_showPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        }),
                    labelText: 'Password *',
                  ),
                  maxLength: 64,
                ),
                tag: 'passwordInput',
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                dense: true,
                contentPadding: const EdgeInsets.all(0),
                value: _termsAccepted,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  setState(() {
                    _termsAccepted = value == null;
                  });
                },
                title: const Text("I Agree to accept all terms and conditions"),
              ),
              Hero(
                  child: ElevatedButton(
                      child: Text(_isLoading ? 'Loading...' : 'Register'),
                      onPressed: _isLoading ? null : _register),
                  tag: 'cta'),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  const Flexible(
                      flex: 1, child: SizedBox(width: double.infinity)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'login');
                    },
                    child: const Text('Login instead?'),
                  ),
                ],
              ),
              const SizedBox(height: 20.0)
            ],
          ),
        ),
      ),
    );
  }
}