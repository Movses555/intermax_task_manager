import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intermax_task_manager/Brigades%20Settings/brigade_details.dart';
import 'package:intermax_task_manager/Flutter%20Toast/flutter_toast.dart';
import 'package:intermax_task_manager/ServerSideApi/server_side_api.dart';
import 'package:intermax_task_manager/User%20Details/user_details.dart';
import 'package:intermax_task_manager/User%20State/user_state.dart';
import 'package:intermax_task_manager/tasks_page.dart';
import 'package:responsive_framework/responsive_framework.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelKey: 'high_importance_channel',
            channelName: 'Basic Notifications',
            channelDescription: 'Description',
            importance: NotificationImportance.High)
      ],
  );
  runApp(const MaterialApp(
    home: TaskManagerMainPage(),
  )
  );
}

class TaskManagerMainPage extends StatefulWidget{
  const TaskManagerMainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<TaskManagerMainPage> {

  var _ipAddressFieldFocusNode;
  var _nameFieldFocus;
  var _passwordFieldFocus;


  TextEditingController? ipController;
  TextEditingController? nameController;
  TextEditingController? passwordController;


  ShowMessage? _showMessage;

  @override
  void initState() {
    super.initState();
    UserState.init();

    _showMessage = ShowMessage.init();
    _ipAddressFieldFocusNode = FocusNode();
    _nameFieldFocus = FocusNode();
    _passwordFieldFocus = FocusNode();

    ipController = TextEditingController();
    nameController = TextEditingController();
    passwordController = TextEditingController();


    UserState.getSignInStatus()!.then((status) {
      if(status == true){
        setState(() {
          UserState.isSignedIn = true;
        });
      }else{
        setState(() {
          UserState.isSignedIn = false;
        });
      }
    });
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
        appBar: UserState.isSignedIn == false ?
        AppBar(
          title:  const Text('Планировщик задач Intermax', style: TextStyle(fontSize: 25)),
          centerTitle: false,
          backgroundColor: Platform.isAndroid ? Colors.deepOrangeAccent : Colors.grey,
          actions: [
            !Platform.isAndroid ? IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => null,
            ) : Container()
          ],
        ) : null,
        body: mainWidget(),
      ),
      breakpoints: const [
        ResponsiveBreakpoint.resize(500, name: MOBILE),
        ResponsiveBreakpoint.resize(800, name: TABLET),
        ResponsiveBreakpoint.resize(1000, name: DESKTOP),
      ],
      defaultScale: true,
    );
  }

  Widget mainWidget(){
    return UserState.isSignedIn == true
        ? const TaskPage()
        : loginInterface();
  }

  // Login interface
  StatefulBuilder loginInterface(){
    ipController = TextEditingController();
    nameController = TextEditingController();
    passwordController = TextEditingController();

    if (UserState.getIP() != '' && UserState.getUserName() != null && UserState.getPassword() != null) {
      ipController!.value = ipController!.value.copyWith(text: UserState.getIP());
      nameController!.value = nameController!.value.copyWith(text: UserState.getUserName());
      passwordController!.value = passwordController!.value.copyWith(text: UserState.getPassword());
    }

    List<TextEditingController> controllers = [
      ipController!,
      nameController!,
      passwordController!
    ];

    var _isHidden = true;
    var _isChecked = false;

    double? height = MediaQuery.of(context).size.height;

    return StatefulBuilder(
      builder: (context, setState){
        return Align(
          alignment: Alignment.center,
          child: Padding(
            padding: Platform.isAndroid
                ? const EdgeInsets.only(left: 30, right: 30)
                : EdgeInsets.only(top: height/4, bottom: height/4, left: 800, right: 800),
            child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    !Platform.isAndroid ? TextFormField(
                      cursorColor: Colors.deepOrangeAccent,
                      focusNode: _ipAddressFieldFocusNode,
                      keyboardType: TextInputType.text,
                      controller: ipController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Platform.isAndroid ? 20.0 : 2.0)),
                        label: const Text('IP Адрес'),
                        labelStyle: TextStyle(color: _ipAddressFieldFocusNode.hasFocus ? Colors.deepOrangeAccent : Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Platform.isAndroid ? 20.0 : 2.0),
                          borderSide: const BorderSide(
                            color: Colors.deepOrangeAccent,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onTap: () {
                        FocusScope.of(context).requestFocus(_ipAddressFieldFocusNode);
                      },
                    ) : Container(),
                    const SizedBox(height: 20),
                    TextFormField(
                      cursorColor: Colors.deepOrangeAccent,
                      focusNode: _nameFieldFocus,
                      keyboardType: TextInputType.text,
                      controller: nameController,
                      decoration: InputDecoration(
                        contentPadding: Platform.isAndroid ?
                        const EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0) : null,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Platform.isAndroid ? 20.0 : 2.0)),
                        label: const Text('Имя пользователя'),
                        labelStyle: TextStyle(color: _nameFieldFocus.hasFocus ? Colors.deepOrangeAccent : Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Platform.isAndroid ? 20.0 : 2.0),
                          borderSide: const BorderSide(
                            color: Colors.deepOrangeAccent,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onTap: () {
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
                          contentPadding: Platform.isAndroid ?
                          const EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0) : null,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Platform.isAndroid ? 20.0 : 2.0)),
                          label: const Text('Пароль'),
                          labelStyle: TextStyle(color: _passwordFieldFocus.hasFocus ? Colors.deepOrangeAccent : Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Platform.isAndroid ? 20.0 : 2.0),
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
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _isChecked,
                            checkColor: Colors.white,
                            activeColor: Colors.deepOrangeAccent,
                            onChanged: (value){
                              setState(() {
                                _isChecked = value!;
                              });
                            },
                          ),
                          const SizedBox(width: 2),
                          Text(
                              'Запомнить меня',
                            style: TextStyle(fontSize: Platform.isAndroid ? 20 : 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: Platform.isAndroid ? 70 : null,
                      width: Platform.isAndroid ? 300 : null,
                      child: FloatingActionButton.extended(
                          backgroundColor: Colors.deepOrangeAccent,
                          label: Text(
                            'Войти',
                          style: TextStyle(fontSize: Platform.isAndroid ? 17 : 14)),
                          shape: !Platform.isAndroid ? const BeveledRectangleBorder(
                              borderRadius: BorderRadius.zero
                          ) : null,
                          onPressed: () => Platform.isAndroid ? _loginBrigade(controllers, _isChecked) : _loginUser(controllers, _isChecked)
                      ),
                    )
                  ],
                )
            ),
          ),
        );
      },
    );
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

  // Brigade login
  Future _loginBrigade(List<TextEditingController> controllersList, bool isChecked) async {
    var name = controllersList[1].text;
    var password = controllersList[2].text;

    Brigade? brigadeData;
    var data = {'ip': '192.168.0.38', 'name': name, 'password': password};

    return Future.wait([
      ServerSideApi.create('192.168.0.38', 4).loginBrigade(data).then((value) => brigadeData = value.body),
    ]).whenComplete(() {
      if(name == '' || password == '') {
        _showMessage!.show(context, 3);
      } else {
        if(brigadeData!.status == 'account_exists'){
          Navigator.pop(context);
          _showMessage!.show(context, 4);
          UserState.rememberBrigade(brigadeData!.brigade);
          if(isChecked == true){
            setState(() {
              UserState.userName = brigadeData!.username;
              UserState.rememberUser('192.168.0.38', brigadeData!.username, password);
            });
          }else{
            setState(() {
              UserState.isSignedIn = true;
              UserState.userName = brigadeData!.username;
            });
          }
          UserState.rememberUserState(true);
        }else if (brigadeData!.status == 'account_not_exists'){
          _showMessage!.show(context, 5);
        }
      }
    });
  }
}
