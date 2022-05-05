import 'package:flutter/material.dart';
import 'package:skymanager/models/role.dart';
import 'package:flash/flash.dart';
import 'package:skymanager/services/load_models.dart';
import 'package:skymanager/services/api_requests.dart' as api;

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({Key? key}) : super(key: key);

  @override
  _NewUserScreenState createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final TextEditingController _nameController = TextEditingController(),
      _emailController = TextEditingController(),
      _roleController = TextEditingController(),
      _passwordController = TextEditingController();

  var rollen = <Role>[];

  @override
  void initState() {
    loadRoleList(context).then((value) => setState(() {
          rollen = value;
          _roleController.text = rollen[1].rolename;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New User'),
        ),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      onSubmitted: (String value) {
                        _createUser(context);
                        // Process data.
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        child: const Text('Create User'),
                        onPressed: () {
                          _createUser(context);
                        }),
                  ],
                ))));
  }

// username, password, email
  _createUser(BuildContext context) {
    _nameController.text = _nameController.text.trim();
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showInputError(
        message: "Please fill in all fields",
      );
      return;
    }
    if (_nameController.text.length < 3 ||
        _emailController.text.length < 3 ||
        _passwordController.text.length < 3) {
      _showInputError(
        message: "All fields requires at least 3 characters",
      );
      return;
    }
    if (_nameController.text.contains(" ") ||
        _emailController.text.contains(" ") ||
        _passwordController.text.contains(" ")) {
      _showInputError(
        message: "You cannot have spaces in your fields",
      );
      return;
    }
    api
        .createUser(_nameController.text, _passwordController.text,
            _emailController.text, context)
        .then((value) => Navigator.pop(context));
  }

  void _showInputError(
      {flashStyle = FlashBehavior.fixed, required String message}) {
    showFlash(
      context: context,
      duration: const Duration(seconds: 3),
      builder: (context, controller) {
        return Flash(
          controller: controller,
          behavior: flashStyle,
          position: FlashPosition.top,
          boxShadows: kElevationToShadow[4],
          horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            title: const Text('Error'),
            content: Text(message),
            showProgressIndicator: false,
            primaryAction: TextButton(
              onPressed: () => controller.dismiss(),
              child:
                  const Text('DISMISS', style: TextStyle(color: Colors.amber)),
            ),
          ),
        );
      },
    );
  }
}
