import 'dart:io';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intermax_task_manager/Flutter%20Toast/flutter_toast.dart';
import 'package:intermax_task_manager/ServerSideApi/server_side_api.dart';
import 'package:intermax_task_manager/User%20Details/user_details.dart';
import 'package:intermax_task_manager/User%20State/user_state.dart';
import 'package:intermax_task_manager/tasks_page.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: TaskManagerMainPage(),
  ));
}

class TaskManagerMainPage extends StatefulWidget{
  const TaskManagerMainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<TaskManagerMainPage>{

  var _ipAddressFieldFocusNode;
  var _nameFieldFocus;
  var _passwordFieldFocus;

  ShowMessage? _showMessage;

  @override
  void initState() {
    super.initState();
    UserState.init();
    _showMessage = ShowMessage.init();
    _ipAddressFieldFocusNode = FocusNode();
    _nameFieldFocus = FocusNode();
    _passwordFieldFocus = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();

    _ipAddressFieldFocusNode.dispose();
    _nameFieldFocus.dispose();
    _passwordFieldFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper.builder(
      Scaffold(
        appBar: UserState.isSignedIn == false ? AppBar(
          title: const Text('Планировщик задач Intermax', style: TextStyle(fontSize: 20)),
          centerTitle: false,
          backgroundColor: Colors.grey,
          actions: [
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () => _showLoginDialog(),
            ),
            !Platform.isAndroid ? IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => null,
            ) : Container()
          ],
        ) : null,
        body: mainWidget(),
      ),
      breakpoints: const [
        ResponsiveBreakpoint.resize(200, name: MOBILE),
        ResponsiveBreakpoint.resize(800, name: TABLET),
        ResponsiveBreakpoint.resize(1000, name: DESKTOP),
      ],
      defaultScale: true,
    );
  }

  Widget mainWidget(){
    return UserState.isSignedIn == true
        ? const TaskPage()
        : const Center(child: Text('Пожалуйста войдите в свой аккаунт', style: TextStyle(fontSize: 20)));
  }

  void _showLoginDialog(){
    TextEditingController ipController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    List<TextEditingController> controllers = [
      ipController,
      nameController,
      passwordController
    ];

    if (UserState.getIP() != '' &&
        UserState.getUserName() != null &&
        UserState.getPassword() != null) {
      ipController.value = ipController.value.copyWith(text: UserState.getIP());
      nameController.value = nameController.value.copyWith(text: UserState.getUserName());
      passwordController.value = passwordController.value.copyWith(text: UserState.getPassword());
    }

    var _isHidden = true;
    var _isChecked = false;

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                title: const Text(
                  'Войти',
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
                contentPadding: const EdgeInsets.all(20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Platform.isAndroid ? 20.0 : 3.0)),
                backgroundColor: Colors.white,
                children: [
                  Column(
                    children: [
                      TextFormField(
                        cursorColor: Colors.deepOrangeAccent,
                        focusNode: _ipAddressFieldFocusNode,
                        keyboardType: TextInputType.text,
                        controller: ipController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Platform.isAndroid ? 20.0 : 3.0)),
                          label: const Text('IP Адрес'),
                          labelStyle: TextStyle(color: _ipAddressFieldFocusNode.hasFocus ? Colors.deepOrangeAccent : Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Platform.isAndroid ? 20.0 : 3.0),
                            borderSide: const BorderSide(
                              color: Colors.deepOrangeAccent,
                              width: 2.0,
                            ),
                          ),
                        ),
                        onTap: () {
                          FocusScope.of(context).requestFocus(_ipAddressFieldFocusNode);
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        cursorColor: Colors.deepOrangeAccent,
                        focusNode: _nameFieldFocus,
                        keyboardType: TextInputType.text,
                        controller: nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Platform.isAndroid ? 20.0 : 3.0)),
                          label: const Text('Имя пользователя'),
                          labelStyle: TextStyle(color: _nameFieldFocus.hasFocus ? Colors.deepOrangeAccent : Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Platform.isAndroid ? 20.0 : 3.0),
                            borderSide: const BorderSide(
                              color: Colors.deepOrangeAccent,
                              width: 2.0,
                            ),
                          ),
                        ),
                        onTap: (){
                          FocusScope.of(context).requestFocus(_nameFieldFocus);
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        cursorColor: Colors.deepOrangeAccent,
                        focusNode: _passwordFieldFocus,
                        keyboardType: TextInputType.text,
                        obscureText: _isHidden,
                        controller: passwordController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Platform.isAndroid ? 20.0 : 3.0)),
                            label: const Text('Пароль'),
                            labelStyle: TextStyle(color: _passwordFieldFocus.hasFocus ? Colors.deepOrangeAccent : Colors.grey),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Platform.isAndroid ? 20.0 : 3.0),
                              borderSide: const BorderSide(
                                color: Colors.deepOrangeAccent,
                                width: 2.0,
                              ),
                            ),
                            suffixIcon: IconButton(
                              color: _passwordFieldFocus.hasFocus ? Colors.deepOrangeAccent : Colors.black,
                              icon: Icon(!_isHidden
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isHidden = !_isHidden;
                                });
                              },
                            )),
                        onTap: (){
                          FocusScope.of(context).requestFocus(_passwordFieldFocus);
                        },
                      ),
                      const SizedBox(height: 20),
                      CheckboxListTile(
                          title: const Text('Запомнить меня'),
                          checkColor: Colors.white,
                          activeColor: Colors.deepOrangeAccent,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: _isChecked,
                          onChanged: (value) {
                            setState(() {
                              _isChecked = value!;
                            });
                          }),
                      const SizedBox(height: 20),
                      FloatingActionButton.extended(
                        backgroundColor: Colors.deepOrangeAccent,
                        label: const Text('Войти'),
                          shape: !Platform.isAndroid ? const BeveledRectangleBorder(
                              borderRadius: BorderRadius.zero
                          ) : null,
                        onPressed: () => _loginUser(controllers, _isChecked)
                      )
                    ],
                  )
                ],
              );
            },
          );
        });
  }

  // User login
  Future _loginUser(List<TextEditingController> controllersList, bool isChecked) async {
    var ip = controllersList[0].text;
    var name = controllersList[1].text;
    var password = controllersList[2].text;

    User? userData;
    var data = {'ip': ip, 'name': name, 'password': password};

    return Future.wait([
      ServerSideApi.create(ip, 2).loginUser(data).then((value) => userData = value.body),
    ]).whenComplete(() {
      if(ip == '' || name == '' || password == ''){
        _showMessage!.show(context, 3);
      }else{
        if(userData!.status == 'account_exists'){
          Navigator.pop(context);
          _showMessage!.show(context, 4);
          if(isChecked == true){
            setState(() {
              UserState.isSignedIn = true;
              UserState.temporaryIp = ip;
              UserState.userName = userData!.username;
              UserState.rememberUser(ip, userData!.username, password);
            });
          }else{
            setState(() {
              UserState.isSignedIn = true;
              UserState.temporaryIp = ip;
              UserState.userName = userData!.username;
            });
          }
        }else if (userData!.status == 'account_not_exists'){
          _showMessage!.show(context, 5);
        }
      }
    });
  }
}
