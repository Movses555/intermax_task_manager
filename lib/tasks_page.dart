import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chopper/chopper.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intermax_task_manager/Brigades%20Settings/brigades_settings.dart';
import 'package:intermax_task_manager/FCM%20Controller/fcm_controller.dart';
import 'package:intermax_task_manager/Flutter%20Toast/flutter_toast.dart';
import 'package:intermax_task_manager/ServerSideApi/server_side_api.dart';
import 'package:intermax_task_manager/Tasks%20Settings/task_model.dart';
import 'package:intermax_task_manager/Tasks%20Settings/task_server_model.dart';
import 'package:intermax_task_manager/Tasks%20Settings/tasks_settings.dart';
import 'package:intermax_task_manager/User%20State/user_state.dart';
import 'package:intermax_task_manager/main.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:translit/translit.dart';


class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {

  int? _bottomNavBarItemIndex = 0;

  FocusNode? _ipAddressFocusNode;
  FocusNode? _nameFocusNode;
  FocusNode? _passwordFocusNode;
  FocusNode? _tasksFocusNode;
  FocusNode? _addressFocusNode;
  FocusNode? _telephoneFocusNode;

  ShowMessage? _showMessage;
  TabController? _tabController;
  NotifyBrigades? _notifyBrigades;

  bool? _isGreen = false;
  bool? _isRed = false;
  bool? _isBlue = false;

  List<TaskServerModel>? _tasksList;
  List<TaskServerModel>? _brigadeTaskList;

  var dateFormatter = DateFormat('dd.MM.yyyy');

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: 'high_importance_channel',
            wakeUpScreen: true,
            displayOnBackground: true,
            displayOnForeground: true,
            title: '${message.notification!.title}',
            body: '${message.notification!.body}'
        )
    );
  }

  @override
  void initState() {
    super.initState();
    Tasks.initPreferences();
    Brigades.initPreferences();

    _tasksFocusNode = FocusNode();
    _ipAddressFocusNode = FocusNode();
    _nameFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _telephoneFocusNode = FocusNode();

    _showMessage = ShowMessage.init();
    _notifyBrigades = NotifyBrigades.createInstance();
    _tabController = TabController(length: 2, vsync: this);

    if (Platform.isAndroid) {
        FirebaseMessaging.instance.getInitialMessage();
        FirebaseMessaging.instance.subscribeToTopic(Translit().toTranslit(source: UserState.getBrigade()!));

      FirebaseMessaging.onMessage.listen((message) {
        if (message.notification != null) {
          AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: 10,
                wakeUpScreen: true,
                displayOnBackground: true,
                backgroundColor: Colors.purpleAccent,
                displayOnForeground: true,
                channelKey: 'high_importance_channel',
                title: '${message.notification!.title}',
                body: '${message.notification!.body}',
              )
          );
        }
      });

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessageOpenedApp.listen((message) {

      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _ipAddressFocusNode!.dispose();
    _nameFocusNode!.dispose();
    _passwordFocusNode!.dispose();
    _tasksFocusNode!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper.builder(
      Scaffold(
          appBar: UserState.isSignedIn == true ? AppBar(
            title: const Text(
                'Планировщик задач Intermax', style: TextStyle(fontSize: 25)),
            centerTitle: false,
            backgroundColor: Colors.deepOrangeAccent,
            actions: [
              !Platform.isAndroid ? IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: () => null,
              ) : Container(),
              !Platform.isAndroid ? IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddTaskDialog(),
              ) : Container(),
              !Platform.isAndroid ? IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () => _showAddUserDialog(),
              ) : Container(),
              !Platform.isAndroid ? IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _showSignOutDialog(),
              ) : Container(),
              !Platform.isAndroid ? PopupMenuButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Настройки',
                itemBuilder: (context) =>
                const [
                  PopupMenuItem(
                    value: 1,
                    child: Text('Изменить задания'),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text('Изменить бригад'),
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: Text('Сделать резервную копию'),
                  ),
                  PopupMenuItem(
                    value: 4,
                    child: Text('Восстановить из резервной копии'),
                  ),
                  PopupMenuItem(
                    value: 5,
                    child: Text('Изменить пароль'),
                  ),
                  PopupMenuItem(
                      value: 6,
                      child: Text('Изменить привилегии')
                  )
                ],
                onSelected: (value) {
                  switch (value) {
                    case 1:
                      TextEditingController tasksController = TextEditingController();
                      showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(builder: (context,
                                setState) {
                              return SimpleDialog(
                                  title: const Text('Задания',
                                      style: TextStyle(color: Colors.black,
                                          fontSize: 30)),
                                  contentPadding: const EdgeInsets.all(20),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          3)),
                                  backgroundColor: Colors.white,
                                  children: [
                                    Row(
                                      children: [
                                        RoundCheckBox(
                                          isChecked: _isRed,
                                          uncheckedColor: Colors.red,
                                          checkedColor: Colors.red,
                                          checkedWidget: const Icon(
                                              Icons.check,
                                              color: Colors.white),
                                          onTap: (value) {
                                            setState(() {
                                              _isRed = true;
                                              _isGreen = false;
                                              _isBlue = false;
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 5),
                                        RoundCheckBox(
                                          isChecked: _isGreen,
                                          uncheckedColor: Colors.green,
                                          checkedColor: Colors.green,
                                          checkedWidget: const Icon(
                                              Icons.check,
                                              color: Colors.white),
                                          onTap: (value) {
                                            setState(() {
                                              _isGreen = true;
                                              _isRed = false;
                                              _isBlue = false;
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 5),
                                        RoundCheckBox(
                                          isChecked: _isBlue,
                                          uncheckedColor: Colors.blue,
                                          checkedColor: Colors.blue,
                                          checkedWidget: const Icon(
                                              Icons.check,
                                              color: Colors.white),
                                          onTap: (value) {
                                            setState(() {
                                              _isBlue = true;
                                              _isRed = false;
                                              _isGreen = false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Column(children: [
                                      Row(children: [
                                        Flexible(
                                          child: TextFormField(
                                            cursorColor: Colors
                                                .deepOrangeAccent,
                                            focusNode: _tasksFocusNode,
                                            keyboardType: TextInputType
                                                .text,
                                            controller: tasksController,
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius
                                                    .circular(3),
                                                borderSide: const BorderSide(
                                                  color: Colors
                                                      .deepOrangeAccent,
                                                  width: 2,
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius
                                                      .circular(3)),
                                              label: const Text('Задание'),
                                              labelStyle: TextStyle(
                                                  color: _tasksFocusNode!
                                                      .hasFocus
                                                      ? Colors
                                                      .deepOrangeAccent
                                                      : Colors.grey),
                                            ),

                                            onTap: () {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                  _tasksFocusNode);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        FloatingActionButton.small(
                                            backgroundColor: Colors
                                                .deepOrangeAccent,
                                            child: const Icon(Icons.add),
                                            onPressed: () {
                                              if (tasksController.text !=
                                                  '') {
                                                String? color;
                                                if (_isRed == true) {
                                                  color = 'red';
                                                } else if (_isGreen == true) {
                                                  color = 'green';
                                                } else if (_isBlue == true) {
                                                  color = 'blue';
                                                }
                                                TaskModel taskModel = TaskModel(
                                                    name: tasksController
                                                        .text,
                                                    color: color);
                                                Tasks.addTask(taskModel);
                                                tasksController.clear();
                                                setState(() {});
                                              } else if (_isRed == false &&
                                                  _isGreen == false &&
                                                  _isBlue == false) {
                                                _showMessage!.show(
                                                    context, 8);
                                              } else {
                                                _showMessage!.show(
                                                    context, 3);
                                              }
                                            })
                                      ]),
                                      SizedBox(
                                          width: 400,
                                          height: 400,
                                          child: Tasks
                                              .getTasksList()
                                              .isNotEmpty ? ListView(
                                            children: List<
                                                ListTile>.generate(Tasks
                                                .getTasksList()
                                                .length, (index) {
                                              String? color = Tasks
                                                  .getTasksList()[index]
                                                  .color;
                                              Color? textColor;
                                              switch (color) {
                                                case 'red':
                                                  textColor = Colors.red;
                                                  break;
                                                case 'green':
                                                  textColor = Colors.green;
                                                  break;
                                                case 'blue':
                                                  textColor = Colors.blue;
                                                  break;
                                              }
                                              return ListTile(
                                                title: Text(
                                                  '${Tasks
                                                      .getTasksList()[index]
                                                      .name}',
                                                  style: TextStyle(
                                                      color: textColor
                                                  ),
                                                ),
                                                trailing: IconButton(
                                                  icon: const Icon(
                                                      Icons.delete),
                                                  onPressed: () {
                                                    Tasks.removeTask(Tasks
                                                        .getTasksList()[index]);
                                                    setState(() {});
                                                  },
                                                ),
                                              );
                                            }),
                                          ) : const Center(child: Text(
                                              'Список задач пуст'))
                                      )
                                    ])
                                  ]);
                            });
                          });
                      break;
                    case 2:
                      TextEditingController brigadesController = TextEditingController();
                      showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(builder: (context,
                                setState) {
                              return SimpleDialog(
                                  title: const Text('Бригады',
                                      style: TextStyle(color: Colors.black,
                                          fontSize: 30)),
                                  contentPadding: const EdgeInsets.all(20),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          3)),
                                  backgroundColor: Colors.white,
                                  children: [
                                    Column(children: [
                                      Row(children: [
                                        Flexible(
                                          child: TextFormField(
                                            cursorColor: Colors
                                                .deepOrangeAccent,
                                            focusNode: _tasksFocusNode,
                                            keyboardType: TextInputType
                                                .text,
                                            controller: brigadesController,
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius
                                                    .circular(3),
                                                borderSide: const BorderSide(
                                                  color: Colors
                                                      .deepOrangeAccent,
                                                  width: 2,
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius
                                                      .circular(3)),
                                              label: const Text('Бригады'),
                                              labelStyle: TextStyle(
                                                  color: _tasksFocusNode!
                                                      .hasFocus
                                                      ? Colors
                                                      .deepOrangeAccent
                                                      : Colors.grey),
                                            ),

                                            onTap: () {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                  _tasksFocusNode);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        FloatingActionButton.small(
                                            backgroundColor: Colors
                                                .deepOrangeAccent,
                                            child: const Icon(Icons.add),
                                            onPressed: () =>
                                            {
                                              setState(() {
                                                if (brigadesController
                                                    .text != '') {
                                                  Brigades.addBrigade(
                                                      brigadesController
                                                          .text);
                                                  brigadesController
                                                      .clear();
                                                } else {
                                                  _showMessage!.show(
                                                      context, 3);
                                                }
                                              })
                                            })
                                      ]),
                                      SizedBox(
                                          width: 400,
                                          height: 400,
                                          child: Brigades.getBrigadesList()!
                                              .isNotEmpty
                                              ? ListView(
                                            children: List<
                                                ListTile>.generate(
                                                Brigades.getBrigadesList()!
                                                    .length, (index) {
                                              return ListTile(
                                                title: Text(
                                                    Brigades
                                                        .getBrigadesList()![index]
                                                ),
                                                trailing: IconButton(
                                                  icon: const Icon(
                                                      Icons.delete),
                                                  onPressed: () {
                                                    Brigades.removeBrigade(
                                                        Brigades
                                                            .getBrigadesList()![index]);
                                                    setState(() {});
                                                  },
                                                ),
                                              );
                                            }),
                                          ) : const Center(
                                              child: Text('Список бригад пуст'))
                                      )
                                    ])
                                  ]);
                            });
                          });
                      break;
                  }
                },
              ) : Container()
            ],
          ) : null,
          bottomNavigationBar: Platform.isAndroid ? ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: UserState.isSignedIn == true ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              iconSize: 30,
              elevation: 20.0,
              currentIndex: _bottomNavBarItemIndex!,
              selectedItemColor: Colors.deepOrangeAccent,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                    label: 'Новые задачи',
                    icon: Icon(Icons.upcoming_rounded)
                ),
                BottomNavigationBarItem(
                    label: 'Текущие задачи',
                    icon: Icon(Icons.task_rounded)
                ),
                BottomNavigationBarItem(
                    label: 'Завершённые задачи',
                    icon: Icon(Icons.done)
                ),
                BottomNavigationBarItem(
                    label: 'Выйти',
                    icon: Icon(Icons.logout)
                )
              ],
              onTap: (index) {
                if (index == 0) {
                  setState(() {
                    _bottomNavBarItemIndex = index;
                  });
                } else if (index == 1) {
                  setState(() {
                    _bottomNavBarItemIndex = index;
                  });
                } else if (index == 2) {
                  setState(() {
                    _bottomNavBarItemIndex = index;
                  });
                } else if (index == 3) {
                  _showSignOutDialog();
                }
              },
            ) : null,
          ) : null,
          body: UserState.isSignedIn == true
              ? !Platform.isAndroid ? getTasks() : Center(
              child: getBrigadeTasks(_bottomNavBarItemIndex!)
          )
              : const TaskManagerMainPage()
      ),
      breakpoints: const [
        ResponsiveBreakpoint.resize(500, name: MOBILE),
        ResponsiveBreakpoint.resize(800, name: TABLET),
        ResponsiveBreakpoint.resize(1000, name: DESKTOP),
      ],
      defaultScale: true,
    );
  }

  // Getting tasks from server
  FutureBuilder<Response<List<TaskServerModel>>> getTasks() {
    var data = {'ip': UserState.temporaryIp};
    return FutureBuilder<Response<List<TaskServerModel>>>(
      future: ServerSideApi.create(UserState.temporaryIp, 3).getTasks(data),
      builder: (context, snapshot) {
        while (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.deepOrangeAccent,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          _tasksList = snapshot.data!.body;
          return buildTasksTable();
        } else {
          return const Center(
            child: Text('Список задач пуст', style: TextStyle(fontSize: 20)),
          );
        }
      },
    );
  }

  // Getting tasks from server (Android version)
  FutureBuilder<Response<List<TaskServerModel>>> getBrigadeTasks(int index) {
    String? status;
    switch (index) {
      case 0:
        status = 'Не выполнено';
        break;
      case 1:
        status = 'В пути';
        break;
      case 2:
        status = 'Завершён';
        break;
    }
    var data = {
      'ip': '192.168.0.38',
      'brigade': UserState.getBrigade(),
      'status': status
    };

    return FutureBuilder<Response<List<TaskServerModel>>>(
      future: ServerSideApi.create('192.168.0.38', 3).getBrigadeTask(data),
      builder: (context, snapshot) {
        while (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.deepOrangeAccent,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          _brigadeTaskList = snapshot.data!.body;
          return buildTaskForBrigade();
        } else {
          return const Center(
            child: Text('Список задач пуст', style: TextStyle(fontSize: 20)),
          );
        }
      },
    );
  }

  // Building tasks table
  Widget buildTasksTable() {
    return SizedBox.expand(
      child: DataTable(
        columnSpacing: 3,
        columns: const [
          DataColumn2(label: Text('Задание'), size: ColumnSize.S),
          DataColumn2(label: Text('Бригада'), size: ColumnSize.S),
          DataColumn2(label: Text('Адрес'), size: ColumnSize.S),
          DataColumn2(label: Text('Тел.'), size: ColumnSize.S),
          DataColumn2(label: Text('Дата'), size: ColumnSize.S),
          DataColumn2(label: Text('Время'), size: ColumnSize.S),
          DataColumn2(label: Text('Срочно'), size: ColumnSize.S),
          DataColumn2(label: Text('Примечание 1'), size: ColumnSize.S),
          DataColumn2(label: Text('Примечание 2'), size: ColumnSize.S),
          DataColumn2(label: Text('Пользователь'), size: ColumnSize.S),
          DataColumn2(label: Text('Статус'), size: ColumnSize.S),
          DataColumn2(label: Text(''), size: ColumnSize.L),
          DataColumn2(label: Text(''), size: ColumnSize.L),
        ],
        rows: List<DataRow2>.generate(_tasksList!.length, (index) {
          TaskServerModel task = _tasksList![index];
          List<TextEditingController> note1TextEditingControllers = List
              .generate(_tasksList!.length, (index) {
            return TextEditingController();
          });
          List<TextEditingController> note2TextEditingControllers = List
              .generate(_tasksList!.length, (index) {
            return TextEditingController();
          });
          note1TextEditingControllers[index].value =
              note1TextEditingControllers[index].value.copyWith(
                  text: task.note1);
          note2TextEditingControllers[index].value =
              note2TextEditingControllers[index].value.copyWith(
                  text: task.note2);
          Color? statusColor;
          if (task.status == 'Не выполнено') {
            statusColor = Colors.red;
          } else if (task.status == 'В пути') {
            statusColor = Colors.orangeAccent;
          } else if (task.status == 'Завершён') {
            statusColor = Colors.green;
          }
          return DataRow2(
              cells: [
                DataCell(Text(task.task, style: TextStyle(
                    color: Color(int.parse('0x' + task.color))))),
                DataCell(Text(task.brigade)),
                DataCell(Text(task.address)),
                DataCell(Text(task.telephone)),
                DataCell(Text(task.date)),
                DataCell(Text(task.time)),
                DataCell(Text(task.isUrgent == '1' ? 'Да' : 'Нет')),
                DataCell(SizedBox(
                    width: 150,
                    child: TextFormField(
                      controller: note1TextEditingControllers[index],
                      cursorColor: Colors.deepOrangeAccent,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.deepOrangeAccent),
                        ),
                      ),
                      onFieldSubmitted: (text) {
                        var data = {
                          'ip': UserState.temporaryIp,
                          'id': task.id,
                          'note_1': text,
                        };
                        ServerSideApi.create(UserState.temporaryIp, 1)
                            .editNotes1(data);
                      },
                    )
                )),
                DataCell(SizedBox(
                    width: 150,
                    child: TextFormField(
                      controller: note2TextEditingControllers[index],
                      cursorColor: Colors.deepOrangeAccent,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.deepOrangeAccent),
                        ),
                      ),
                      onFieldSubmitted: (text) {
                        var data = {
                          'ip': UserState.temporaryIp,
                          'id': task.id,
                          'note_2': text,
                        };
                        ServerSideApi.create(UserState.temporaryIp, 1)
                            .editNotes2(data);
                      },
                    )
                )),
                DataCell(Text(task.addedBy)),
                DataCell(
                    Text(task.status, style: TextStyle(color: statusColor))),
                DataCell(IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditTaskDialog(task),
                )),
                DataCell(IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    Widget _deleteButton = TextButton(
                      child: const Text(
                        'Удалить',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onPressed: () async {
                        var data = {'ip': UserState.temporaryIp, 'id': task.id};
                        _tasksList!.remove(task);
                        setState(() {});

                        Response response = await ServerSideApi.create(
                            UserState.temporaryIp, 1).deleteTask(data);
                        if (response.body == 'task_deleted') {
                          _showMessage!.show(context, 7);
                          Navigator.pop(context);
                        }
                      },
                    );

                    Widget _cancelButton = TextButton(
                        child: const Text('Отмена', style: TextStyle(
                            color: Colors.deepOrangeAccent)),
                        onPressed: () => Navigator.pop(context));

                    AlertDialog dialog = AlertDialog(
                        title: const Text('Удалить задачу'),
                        content: const Text(
                            'Вы действительно хотите удалить задачу ?'),
                        actions: [_cancelButton, _deleteButton]);

                    showDialog(
                        context: context,
                        builder: (context) {
                          return dialog;
                        });
                  },
                ))
              ]
          );
        }),
      ),
    );
  }

  // Building tasks table for specific brigade(Android version)
  Widget buildTaskForBrigade() {
    List<bool>? onMyWayPressed;
    return ListView.builder(
      itemCount: _brigadeTaskList!.length,
      itemBuilder: (context, index) {
        onMyWayPressed = List.generate(_brigadeTaskList!.length, (index) => false);
        TaskServerModel brigadeTask = _brigadeTaskList![index];
        String? formattedDate = dateFormatter.format(DateTime.now());
        String? date;
        if (formattedDate == brigadeTask.date) {
          date = "Сегодня";
        } else {
          date = brigadeTask.date;
        }
        return GestureDetector(
          child: Card(
            elevation: 5,
            child: ListTile(
              title: Text(brigadeTask.task, style: TextStyle(
                  color: Color(int.parse('0x' + brigadeTask.color)),
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
              subtitle: Text(
                date! + " в " + brigadeTask.time + " на " +
                    brigadeTask.address,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, dialogState){
                      return SimpleDialog(
                        title: const Text(
                          'Детали о задаче',
                          style: TextStyle(color: Colors.black, fontSize: 30),
                        ),
                        contentPadding: const EdgeInsets.only(
                            left: 5, right: 5, bottom: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        backgroundColor: Colors.white,
                        children: [
                          const SizedBox(height: 5),
                          Center(
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    brigadeTask.task,
                                    style: TextStyle(color: Color(
                                        int.parse('0x' + brigadeTask.color))),
                                  ),
                                  leading: const Icon(Icons.task),
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  title: Text(brigadeTask.address),
                                  leading: const Icon(Icons.add_location_rounded),
                                ),
                                const Divider(height: 1),
                                ListTile(
                                    title: Text(brigadeTask.telephone),
                                    leading: const Icon(Icons.phone),
                                  onTap: (){
                                      launch('tel://${brigadeTask.telephone}');
                                  },
                                ),
                                const Divider(height: 1),
                                ListTile(
                                    title: Text(brigadeTask.isUrgent == '1'
                                        ? "Срочно"
                                        : "Не срочно"),
                                    leading: const Icon(Icons.access_time_outlined)
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: FloatingActionButton.extended(
                                        label: const Text('В пути'),
                                        backgroundColor: brigadeTask.status == 'В пути' || brigadeTask.status == 'Завершён' ? Colors.grey : Colors.orangeAccent[700],
                                        onPressed: brigadeTask.status == 'В пути' || brigadeTask.status == 'Завершён' ? null : () async {
                                          setState(() {
                                            onMyWayPressed![index] = true;
                                          });
                                          var data = {
                                            'ip' : '192.168.0.38',
                                            'id' : brigadeTask.id,
                                            'status' : 'В пути'
                                          };
                                          Response response = await ServerSideApi.create('192.168.0.38', 1).updateStatus(data);
                                          if(response.body == 'status_updated'){
                                            Navigator.pop(context);
                                            _brigadeTaskList!.remove(brigadeTask);
                                            setState((){});
                                          }
                                        }
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    SizedBox(
                                      width: 139,
                                      child: FloatingActionButton.extended(
                                        label: const Text('Завершено'),
                                        backgroundColor: brigadeTask.status == 'В пути' ? Colors.green[700] : Colors.grey,
                                        onPressed: brigadeTask.status == 'В пути' ? () async {
                                          var data = {
                                            'ip' : '192.168.0.38',
                                            'id' : brigadeTask.id,
                                            'status' : 'Завершён'
                                          };
                                          Response response = await ServerSideApi.create('192.168.0.38', 1).updateStatus(data);
                                          if(response.body == 'status_updated'){
                                            Navigator.pop(context);
                                            _brigadeTaskList!.remove(brigadeTask);
                                            setState((){});
                                          }
                                        }: null,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: 300,
                                  child: FloatingActionButton.extended(
                                    label: const Text('Закрыть'),
                                    backgroundColor: Colors.blue,
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  );
                }
            );
          },
        );
      },
    );
  }

  // Showing dialog to add a task
  void _showAddTaskDialog() {
    TextEditingController addressController = TextEditingController();
    TextEditingController telephoneController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController timeController = TextEditingController();

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    String formattedDate = dateFormatter.format(selectedDate);

    String? hour = selectedTime.hour.toString();
    String? minutes = selectedTime.minute.toString();

    if (int.parse(hour) < 10) {
      hour = '0' + hour;
    }

    if (int.parse(minutes) < 10) {
      minutes = '0' + minutes;
    }

    dateController.value = dateController.value.copyWith(text: formattedDate);
    timeController.value =
        timeController.value.copyWith(text: hour + ":" + minutes);

    var _isUrgent = false;
    String? taskValue;
    String? brigadesValue;
    String? color;

    List<String> options = [];
    List<TextEditingController> dateAndTime = [
      addressController,
      telephoneController,
      dateController,
      timeController,
    ];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                title: const Text(
                  'Добавить задачу',
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
                contentPadding: const EdgeInsets.all(20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0)),
                backgroundColor: Colors.white,
                children: [
                  Row(
                    children: [
                      const Text('Задание:', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 15),
                      DropdownButton<String>(
                        hint: const Text('Выберите задание'),
                        value: taskValue,
                        onChanged: (String? value) {
                          setState(() {
                            taskValue = value!;
                          });
                        },
                        items: Tasks.getTasksList().map<
                            DropdownMenuItem<String>>((task) {
                          String? taskColor = task.color;
                          Color? textColor;
                          switch (taskColor) {
                            case 'red':
                              textColor = Colors.red;
                              break;
                            case 'green':
                              textColor = Colors.green;
                              break;
                            case 'blue':
                              textColor = Colors.blue;
                              break;
                          }

                          return DropdownMenuItem(
                            value: task.name,
                            child: Text(
                                task.name, style: TextStyle(color: textColor)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Бригада:', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 15),
                      DropdownButton<String>(
                        hint: const Text('Выберите бригаду'),
                        value: brigadesValue,
                        onChanged: (String? value) {
                          setState(() {
                            brigadesValue = value!;
                          });
                        },
                        items: Brigades.getBrigadesList()!.map<
                            DropdownMenuItem<String>>((brigade) {
                          return DropdownMenuItem(
                            value: brigade,
                            child: Text(brigade),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    cursorColor: Colors.deepOrangeAccent,
                    focusNode: _addressFocusNode,
                    keyboardType: TextInputType.text,
                    controller: addressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              Platform.isAndroid ? 20.0 : 3.0)),
                      label: const Text('Адрес'),
                      labelStyle: TextStyle(
                          color: _addressFocusNode!.hasFocus ? Colors
                              .deepOrangeAccent : Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            Platform.isAndroid ? 20.0 : 3.0),
                        borderSide: const BorderSide(
                          color: Colors.deepOrangeAccent,
                          width: 2.0,
                        ),
                      ),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(_addressFocusNode);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    cursorColor: Colors.deepOrangeAccent,
                    focusNode: _telephoneFocusNode,
                    keyboardType: TextInputType.text,
                    controller: telephoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              Platform.isAndroid ? 20.0 : 3.0)),
                      label: const Text('Телефон'),
                      labelStyle: TextStyle(
                          color: _telephoneFocusNode!.hasFocus ? Colors
                              .deepOrangeAccent : Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            Platform.isAndroid ? 20.0 : 3.0),
                        borderSide: const BorderSide(
                          color: Colors.deepOrangeAccent,
                          width: 2.0,
                        ),
                      ),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(_telephoneFocusNode);
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          cursorColor: Colors.deepOrangeAccent,
                          keyboardType: TextInputType.text,
                          enabled: false,
                          controller: dateController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.0)),
                            label: const Text('Дата выполнения'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        icon: const Icon(Icons.calendar_today_outlined),
                        color: Colors.deepOrangeAccent,
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2010),
                              lastDate: DateTime(2030)
                          );
                          if (picked != null && picked != selectedDate) {
                            setState(() {
                              formattedDate = dateFormatter.format(picked);
                              dateController.value =
                                  dateController.value.copyWith(
                                      text: formattedDate);
                            });
                          }
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          cursorColor: Colors.deepOrangeAccent,
                          keyboardType: TextInputType.text,
                          enabled: false,
                          controller: timeController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.0)),
                            label: const Text('Время выполнения'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                          icon: const Icon(Icons.watch_later_outlined),
                          color: Colors.deepOrangeAccent,
                          onPressed: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                                helpText: 'Выберите время выполнения',
                                builder: (BuildContext? context,
                                    Widget? child) {
                                  return MediaQuery(
                                    data: MediaQuery.of(context!).copyWith(
                                        alwaysUse24HourFormat: true),
                                    child: child!,
                                  )
                                }
                            );
                            if (pickedTime != null &&
                                pickedTime != selectedTime) {
                              setState(() {
                                selectedTime = pickedTime;
                                String? hour = selectedTime.hour.toString();
                                String? minutes = selectedTime.minute
                                    .toString();

                                if (int.parse(hour) < 10) {
                                  hour = '0' + hour;
                                }

                                if (int.parse(minutes) < 10) {
                                  minutes = '0' + minutes;
                                }
                                timeController.value =
                                    dateController.value.copyWith(
                                        text: hour + ":" + minutes);
                              });
                            }
                          }
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _isUrgent,
                        checkColor: Colors.white,
                        activeColor: Colors.deepOrangeAccent,
                        onChanged: (value) {
                          setState(() {
                            _isUrgent = value!;
                          });
                        },
                      ),
                      const SizedBox(width: 2),
                      const Text('Срочно', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  FloatingActionButton.extended(
                      backgroundColor: Colors.deepOrangeAccent,
                      label: const Text('Добавить задачу'),
                      shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.zero
                      ),
                      onPressed: () {
                        if (taskValue != null && brigadesValue != null) {
                          for (var task in Tasks.getTasksList()) {
                            if (task.name == taskValue) {
                              switch (task.color) {
                                case 'red':
                                  color = Colors.red.value.toRadixString(16)
                                      .toUpperCase();
                                  break;
                                case 'green':
                                  color = Colors.green.value.toRadixString(16)
                                      .toUpperCase();
                                  break;
                                case 'blue':
                                  color = Colors.blue.value.toRadixString(16)
                                      .toUpperCase();
                                  break;
                              }
                            }
                          }
                          options.add(taskValue!);
                          options.add(brigadesValue!);
                          options.add(color!);
                          _addTask(options, dateAndTime, _isUrgent);
                        } else {
                          _showMessage!.show(context, 3);
                        }
                      }
                  )
                ],
              );
            },
          );
        });
  }

  // Showing dialog to add a user
  void _showAddUserDialog() {
    TextEditingController ipController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    TextEditingController brigadeNameController = TextEditingController();
    TextEditingController brigadePasswordController = TextEditingController();

    String? brigadesValue;

    if (UserState.temporaryIp != '') {
      ipController.value =
          ipController.value.copyWith(text: UserState.temporaryIp);
    }

    List<TextEditingController> controllers = [
      ipController,
      nameController,
      passwordController,
    ];

    List<TextEditingController> brigadeControllers = [
      ipController,
      brigadeNameController,
      brigadePasswordController,
    ];

    var _isHidden = true;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                title: const Text(
                  'Добавить пользователя',
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
                contentPadding: const EdgeInsets.all(20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0)),
                backgroundColor: Colors.white,
                children: [
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.deepOrangeAccent,
                    unselectedLabelColor: Colors.grey,
                    labelColor: Colors.deepOrangeAccent,
                    tabs: const [
                      Tab(text: 'Пользователя'),
                      Tab(text: 'Бригаду')
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 350,
                    width: 200,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 5),
                            TextFormField(
                              cursorColor: Colors.deepOrangeAccent,
                              focusNode: _ipAddressFocusNode,
                              keyboardType: TextInputType.text,
                              controller: ipController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Platform.isAndroid ? 20.0 : 3.0)),
                                label: const Text('IP Адрес'),
                                labelStyle: TextStyle(
                                    color: _ipAddressFocusNode!.hasFocus
                                        ? Colors.deepOrangeAccent
                                        : Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      Platform.isAndroid ? 20.0 : 3.0),
                                  borderSide: const BorderSide(
                                    color: Colors.deepOrangeAccent,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              onTap: () {
                                FocusScope.of(context).requestFocus(
                                    _ipAddressFocusNode);
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              cursorColor: Colors.deepOrangeAccent,
                              focusNode: _nameFocusNode,
                              keyboardType: TextInputType.text,
                              controller: nameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Platform.isAndroid ? 20.0 : 3.0)),
                                label: const Text('Имя пользователя'),
                                labelStyle: TextStyle(
                                    color: _nameFocusNode!.hasFocus ? Colors
                                        .deepOrangeAccent : Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      Platform.isAndroid ? 20.0 : 3.0),
                                  borderSide: const BorderSide(
                                    color: Colors.deepOrangeAccent,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              onTap: () {
                                FocusScope.of(context).requestFocus(
                                    _nameFocusNode);
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              cursorColor: Colors.deepOrangeAccent,
                              focusNode: _passwordFocusNode,
                              keyboardType: TextInputType.text,
                              obscureText: _isHidden,
                              controller: passwordController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          Platform.isAndroid ? 20.0 : 3.0)),
                                  label: const Text('Пароль'),
                                  labelStyle: TextStyle(
                                      color: _passwordFocusNode!.hasFocus
                                          ? Colors.deepOrangeAccent
                                          : Colors.grey),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Platform.isAndroid ? 20.0 : 3.0),
                                    borderSide: const BorderSide(
                                      color: Colors.deepOrangeAccent,
                                      width: 2.0,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    color: _passwordFocusNode!.hasFocus ? Colors
                                        .deepOrangeAccent : Colors.black,
                                    icon: Icon(!_isHidden
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        _isHidden = !_isHidden;
                                      });
                                    },
                                  )),
                              onTap: () {
                                FocusScope.of(context).requestFocus(
                                    _passwordFocusNode);
                              },
                            ),
                            const SizedBox(height: 20),
                            FloatingActionButton.extended(
                                backgroundColor: Colors.deepOrangeAccent,
                                label: const Text('Зарегистрировать'),
                                shape: !Platform.isAndroid
                                    ? const BeveledRectangleBorder(
                                    borderRadius: BorderRadius.zero
                                )
                                    : null,
                                onPressed: () => _registerUser(controllers)
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 5),
                            TextFormField(
                              cursorColor: Colors.deepOrangeAccent,
                              focusNode: _ipAddressFocusNode,
                              keyboardType: TextInputType.text,
                              controller: ipController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Platform.isAndroid ? 20.0 : 3.0)),
                                label: const Text('IP Адрес'),
                                labelStyle: TextStyle(
                                    color: _ipAddressFocusNode!.hasFocus
                                        ? Colors.deepOrangeAccent
                                        : Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      Platform.isAndroid ? 20.0 : 3.0),
                                  borderSide: const BorderSide(
                                    color: Colors.deepOrangeAccent,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              onTap: () {
                                FocusScope.of(context).requestFocus(
                                    _ipAddressFocusNode);
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              cursorColor: Colors.deepOrangeAccent,
                              focusNode: _nameFocusNode,
                              keyboardType: TextInputType.text,
                              controller: brigadeNameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Platform.isAndroid ? 20.0 : 3.0)),
                                label: const Text('Имя пользователя'),
                                labelStyle: TextStyle(
                                    color: _nameFocusNode!.hasFocus ? Colors
                                        .deepOrangeAccent : Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      Platform.isAndroid ? 20.0 : 3.0),
                                  borderSide: const BorderSide(
                                    color: Colors.deepOrangeAccent,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              onTap: () {
                                FocusScope.of(context).requestFocus(
                                    _nameFocusNode);
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              cursorColor: Colors.deepOrangeAccent,
                              focusNode: _passwordFocusNode,
                              keyboardType: TextInputType.text,
                              obscureText: _isHidden,
                              controller: brigadePasswordController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          Platform.isAndroid ? 20.0 : 3.0)),
                                  label: const Text('Пароль'),
                                  labelStyle: TextStyle(
                                      color: _passwordFocusNode!.hasFocus
                                          ? Colors.deepOrangeAccent
                                          : Colors.grey),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Platform.isAndroid ? 20.0 : 3.0),
                                    borderSide: const BorderSide(
                                      color: Colors.deepOrangeAccent,
                                      width: 2.0,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    color: _passwordFocusNode!.hasFocus ? Colors
                                        .deepOrangeAccent : Colors.black,
                                    icon: Icon(!_isHidden
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        _isHidden = !_isHidden;
                                      });
                                    },
                                  )),
                              onTap: () {
                                FocusScope.of(context).requestFocus(
                                    _passwordFocusNode);
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Text(
                                    'Бригада:', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 15),
                                DropdownButton<String>(
                                  hint: const Text('Выберите бригаду'),
                                  value: brigadesValue,
                                  onChanged: (String? value) {
                                    setState(() {
                                      brigadesValue = value!;
                                    });
                                  },
                                  items: Brigades.getBrigadesList()!.map<
                                      DropdownMenuItem<String>>((task) {
                                    return DropdownMenuItem(
                                      value: task,
                                      child: Text(task),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            FloatingActionButton.extended(
                                backgroundColor: Colors.deepOrangeAccent,
                                label: const Text('Зарегистрировать'),
                                shape: !Platform.isAndroid
                                    ? const BeveledRectangleBorder(
                                    borderRadius: BorderRadius.zero
                                )
                                    : null,
                                onPressed: () => _registerBrigade(
                                    brigadeControllers, brigadesValue)
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        });
  }

  // Register simple user
  void _registerUser(List<TextEditingController> controllers) async {
    var ip = controllers[0].text;
    var name = controllers[1].text;
    var password = controllers[2].text;

    if (ip == '' || name == '' || password == '') {
      _showMessage!.show(context, 3);
    } else {
      try {
        var data = {
          'ip': ip,
          'name': name,
          'password': password
        };
        Response response = await ServerSideApi.create(ip, 1).registerUser(
            data);
        if (response.body == 'user_registered') {
          Navigator.pop(context);
          _showMessage!.show(context, 7);
        } else if (response.body == 'user_already_exists') {
          _showMessage!.show(context, 2);
        }
      } on Exception catch (_) {}
    }
  }

  // Register brigade
  void _registerBrigade(List<TextEditingController> brigadeControllers,
      String? brigadeValue) async {
    var ip = brigadeControllers[0].text;
    var name = brigadeControllers[1].text;
    var password = brigadeControllers[2].text;

    if (ip == '' || name == '' || password == '' || brigadeValue == null) {
      _showMessage!.show(context, 3);
    } else {
      try {
        var data = {
          'ip': ip,
          'name': name,
          'brigade': brigadeValue,
          'password': password
        };
        Response response = await ServerSideApi.create(ip, 1).registerBrigade(
            data);
        if (response.body == 'user_registered') {
          Navigator.pop(context);
          _showMessage!.show(context, 7);
        } else if (response.body == 'user_already_exists') {
          _showMessage!.show(context, 2);
        }
      } on Exception catch (_) {}
    }
  }

  // Showing dialog to edit task
  void _showEditTaskDialog(TaskServerModel task) {
    TextEditingController addressController = TextEditingController();
    TextEditingController telephoneController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController timeController = TextEditingController();

    String year = task.date.toString().split('.')[2];
    String month = task.date.toString().split('.')[1];
    String day = task.date.toString().split('.')[0];

    String hour = task.time.toString().split(':')[0];
    String minutes = task.time.toString().split(':')[1];

    DateTime selectedDate = DateTime(
        int.parse(year), int.parse(month), int.parse(day));
    TimeOfDay selectedTime = TimeOfDay(
        hour: int.parse(hour), minute: int.parse(minutes));

    String formattedDate = dateFormatter.format(selectedDate);

    addressController.value =
        addressController.value.copyWith(text: task.address);
    telephoneController.value =
        telephoneController.value.copyWith(text: task.telephone);
    dateController.value = dateController.value.copyWith(text: formattedDate);
    timeController.value = timeController.value.copyWith(text: task.time);

    var _isUrgent = task.isUrgent == '1' ? true : false;

    String? taskValue = task.task;
    String? brigadesValue = task.brigade;
    String? color;

    List<String> options = [];
    List<TextEditingController> dateAndTime = [
      addressController,
      telephoneController,
      dateController,
      timeController,
    ];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                title: const Text(
                  'Добавить задачу',
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
                contentPadding: const EdgeInsets.all(20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0)),
                backgroundColor: Colors.white,
                children: [
                  Row(
                    children: [
                      const Text('Задание:', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 15),
                      DropdownButton<String>(
                        hint: const Text('Выберите задание'),
                        value: taskValue,
                        onChanged: (String? value) {
                          setState(() {
                            taskValue = value!;
                          });
                        },
                        items: Tasks.getTasksList().map<
                            DropdownMenuItem<String>>((task) {
                          String? taskColor = task.color;
                          Color? textColor;
                          switch (taskColor) {
                            case 'red':
                              textColor = Colors.red;
                              break;
                            case 'green':
                              textColor = Colors.green;
                              break;
                            case 'blue':
                              textColor = Colors.blue;
                              break;
                          }

                          return DropdownMenuItem(
                            value: task.name,
                            child: Text(
                                task.name, style: TextStyle(color: textColor)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Бригада:', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 15),
                      DropdownButton<String>(
                        hint: const Text('Выберите бригаду'),
                        value: brigadesValue,
                        onChanged: (String? value) {
                          setState(() {
                            brigadesValue = value!;
                          });
                        },
                        items: Brigades.getBrigadesList()!.map<
                            DropdownMenuItem<String>>((task) {
                          return DropdownMenuItem(
                            value: task,
                            child: Text(task),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    cursorColor: Colors.deepOrangeAccent,
                    focusNode: _addressFocusNode,
                    keyboardType: TextInputType.text,
                    controller: addressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              Platform.isAndroid ? 20.0 : 3.0)),
                      label: const Text('Адрес'),
                      labelStyle: TextStyle(
                          color: _addressFocusNode!.hasFocus ? Colors
                              .deepOrangeAccent : Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            Platform.isAndroid ? 20.0 : 3.0),
                        borderSide: const BorderSide(
                          color: Colors.deepOrangeAccent,
                          width: 2.0,
                        ),
                      ),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(_addressFocusNode);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    cursorColor: Colors.deepOrangeAccent,
                    focusNode: _addressFocusNode,
                    keyboardType: TextInputType.text,
                    controller: addressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              Platform.isAndroid ? 20.0 : 3.0)),
                      label: const Text('Телефон'),
                      labelStyle: TextStyle(
                          color: _addressFocusNode!.hasFocus ? Colors
                              .deepOrangeAccent : Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            Platform.isAndroid ? 20.0 : 3.0),
                        borderSide: const BorderSide(
                          color: Colors.deepOrangeAccent,
                          width: 2.0,
                        ),
                      ),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(_addressFocusNode);
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          cursorColor: Colors.deepOrangeAccent,
                          keyboardType: TextInputType.text,
                          enabled: false,
                          controller: dateController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.0)),
                            label: const Text('Дата выполнения'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        icon: const Icon(Icons.calendar_today_outlined),
                        color: Colors.deepOrangeAccent,
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2010),
                              lastDate: DateTime(2030)
                          );
                          if (picked != null && picked != selectedDate) {
                            setState(() {
                              formattedDate = dateFormatter.format(picked);
                              dateController.value =
                                  dateController.value.copyWith(
                                      text: formattedDate);
                            });
                          }
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          cursorColor: Colors.deepOrangeAccent,
                          keyboardType: TextInputType.text,
                          enabled: false,
                          controller: timeController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.0)),
                            label: const Text('Время выполнения'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                          icon: const Icon(Icons.watch_later_outlined),
                          color: Colors.deepOrangeAccent,
                          onPressed: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                                helpText: 'Выберите время выполнения',
                                builder: (BuildContext? context,
                                    Widget? child) {
                                  return MediaQuery(
                                    data: MediaQuery.of(context!).copyWith(
                                        alwaysUse24HourFormat: true),
                                    child: child!,
                                  )
                                }
                            );
                            if (pickedTime != null &&
                                pickedTime != selectedTime) {
                              setState(() {
                                selectedTime = pickedTime;
                                String? hour = selectedTime.hour.toString();
                                String? minutes = selectedTime.minute
                                    .toString();

                                if (int.parse(hour) < 10) {
                                  hour = '0' + hour;
                                }

                                if (int.parse(minutes) < 10) {
                                  minutes = '0' + minutes;
                                }
                                timeController.value =
                                    dateController.value.copyWith(
                                        text: hour + ":" + minutes);
                              });
                            }
                          }
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _isUrgent,
                        checkColor: Colors.white,
                        activeColor: Colors.deepOrangeAccent,
                        onChanged: (value) {
                          setState(() {
                            _isUrgent = value!;
                          });
                        },
                      ),
                      const SizedBox(width: 2),
                      const Text('Срочно', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  FloatingActionButton.extended(
                      backgroundColor: Colors.deepOrangeAccent,
                      label: const Text('Изменить задачу'),
                      shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.zero
                      ),
                      onPressed: () {
                        if (taskValue != null && brigadesValue != null) {
                          for (var task in Tasks.getTasksList()) {
                            if (task.name == taskValue) {
                              switch (task.color) {
                                case 'red':
                                  color = Colors.red.value.toRadixString(16)
                                      .toUpperCase();
                                  break;
                                case 'green':
                                  color = Colors.green.value.toRadixString(16)
                                      .toUpperCase();
                                  break;
                                case 'blue':
                                  color = Colors.blue.value.toRadixString(16)
                                      .toUpperCase();
                                  break;
                              }
                            }
                          }
                          options.add(taskValue!);
                          options.add(brigadesValue!);
                          options.add(color!);
                          _editTask(task, options, dateAndTime, _isUrgent);
                        } else {
                          _showMessage!.show(context, 3);
                        }
                      }
                  )
                ],
              );
            },
          );
        });
  }

  // Add task to server
  void _addTask(List<String> options, List<TextEditingController> dateAndTime,
      bool isUrgent) async {
    String task = options[0].toString();
    String brigade = options[1].toString();
    String color = options[2].toString();

    String address = dateAndTime[0].text.toString();
    String telephone = dateAndTime[1].text.toString();
    String date = dateAndTime[2].text.toString();
    String time = dateAndTime[3].text.toString();

    var data = {
      'ip': UserState.temporaryIp,
      'task': task,
      'brigade': brigade,
      'address': address,
      'telephone': telephone,
      'date': date,
      'time': time,
      'urgent': isUrgent == true ? 1 : 0,
      'color': color,
      'added_by': UserState.userName,
      'status': 'Не выполнено',
    };

    Response response = await ServerSideApi.create(UserState.temporaryIp, 1)
        .addTask(data);
    if (response.body == 'task_added') {
      _showMessage!.show(context, 7);
      Navigator.pop(context);

      var data = {'ip': UserState.temporaryIp};
      Response response = await ServerSideApi.create(UserState.temporaryIp, 3)
          .getTasks(data);
      _tasksList = response.body;
      _notifyBrigades!.notify(address, brigade, 'Новая задача', date, time,
          isUrgent == true ? "Срочно" : "Не срочно");
      setState(() {});
    }
  }

  // Edit task to server
  void _editTask(TaskServerModel taskModel, List<String> options,
      List<TextEditingController> dateAndTime, bool isUrgent) async {
    String task = options[0].toString();
    String brigade = options[1].toString();
    String color = options[2].toString();

    String address = dateAndTime[0].text.toString();
    String telephone = dateAndTime[1].text.toString();
    String date = dateAndTime[2].text.toString();
    String time = dateAndTime[3].text.toString();

    var data = {
      'ip': UserState.temporaryIp,
      'id': taskModel.id,
      'task': task,
      'brigade': brigade,
      'address': address,
      'telephone': telephone,
      'date': date,
      'time': time,
      'urgent': isUrgent == true ? 1 : 0,
      'color': color,
    };

    Response response = await ServerSideApi.create(UserState.temporaryIp, 1)
        .editTask(data);
    if (response.body == 'task_edited') {
      _showMessage!.show(context, 7);
      Navigator.pop(context);

      Response response = await ServerSideApi.create(UserState.temporaryIp, 3)
          .getTasks(data);
      _tasksList = response.body;
      setState(() {});
    }
  }

  // Showing sign out dialog
  void _showSignOutDialog() {
    Widget _signOutButton = TextButton(
      child: const Text(
        'Выйти',
        style: TextStyle(color: Colors.redAccent),
      ),
      onPressed: () {
        Navigator.pop(context);
        UserState.rememberUserState(false);
        setState(() {
          UserState.isSignedIn = false;
        });
        FirebaseMessaging.instance.unsubscribeFromTopic(
            Translit().toTranslit(source: UserState.getBrigade()!));
        UserState.clearBrigade();
      },
    );

    Widget _cancelButton = TextButton(
        child: const Text(
            'Отмена', style: TextStyle(color: Colors.deepOrangeAccent)),
        onPressed: () => Navigator.pop(context));

    AlertDialog dialog = AlertDialog(
        title: const Text('Выйти из аккаунта'),
        content: const Text('Вы действительно хотите выйти ?'),
        actions: [_cancelButton, _signOutButton]);

    showDialog(
        context: context,
        builder: (context) {
          return dialog;
        });
  }
}