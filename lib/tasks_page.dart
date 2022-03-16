import 'dart:async';
import 'dart:convert';
import 'package:chopper/chopper.dart';
import 'package:intermax_task_manager/Maps%20API/maps.dart';
import 'package:intermax_task_manager/Status%20Data/status_model.dart';
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
import 'package:web_socket_channel/html.dart';
import 'package:google_maps/google_maps.dart' as m;

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {

  Stream? _socketBroadcastStream;
  HtmlWebSocketChannel? _htmlWebSocketChannel;

  StateSetter? taskInfoState;
  StateSetter? mapTaskInfoState;
  StateSetter? mapState;

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

  List<TaskServerModel>? _taskList;
  List<Status>? _statusList = [];

  Stream<int>? onWayTimerStream;
  Stream<int>? workStartedTimerStream;

  StreamSubscription<int>? onWayTimerSubscription;
  StreamSubscription<int>? workStartedTimerSubscription;

  MapsAPI? maps;

  var dateFormatter = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    Tasks.initPreferences();
    Brigades.initPreferences();

    maps = MapsAPI.init();

    _tasksFocusNode = FocusNode();
    _ipAddressFocusNode = FocusNode();
    _nameFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _telephoneFocusNode = FocusNode();

    _showMessage = ShowMessage.init();
    _notifyBrigades = NotifyBrigades.createInstance();
    _tabController = TabController(length: 2, vsync: this);

    _statusList!.add(Status(status: 'Не выполнено', color: Colors.red));
    _statusList!.add(Status(status: 'В пути', color: Colors.orangeAccent[700]));
    _statusList!.add(Status(status: 'На месте', color: Colors.yellow[700]));
    _statusList!.add(Status(status: 'Завершено', color: Colors.green));

    _htmlWebSocketChannel =
        HtmlWebSocketChannel.connect('ws://192.168.0.38:8080');
    _socketBroadcastStream = _htmlWebSocketChannel!.stream.asBroadcastStream();
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
          appBar: AppBar(
            title: const Text(
                'Планировщик задач Intermax', style: TextStyle(fontSize: 25)),
            centerTitle: false,
            backgroundColor: Colors.deepOrangeAccent,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: () {

                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddTaskDialog(),
              ),
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () => _showAddUserDialog(),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _showSignOutDialog(),
              ),
              PopupMenuButton(
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
                                      borderRadius: BorderRadius.circular(3)),
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
              )
            ],
          ),
          body: getTasks()
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
          _taskList = snapshot.data!.body;
          return buildTasksTable(_taskList);
        } else {
          return const Center(
            child: Text('Список задач пуст', style: TextStyle(fontSize: 20)),
          );
        }
      },
    );
  }

  // Building tasks table
  Widget buildTasksTable(List<TaskServerModel>? _tasksList) {
    return SizedBox.expand(
      child: DataTable(
        columnSpacing: 3,
        columns: const [
          DataColumn(label: Text('Задание')),
          DataColumn(label: Text('Бригада')),
          DataColumn(label: Text('Адрес')),
          DataColumn(label: Text('Тел.')),
          DataColumn(label: Text('Дата')),
          DataColumn(label: Text('Время')),
          DataColumn(label: Text('Срочно')),
          DataColumn(label: Text('Примечание 1')),
          DataColumn(label: Text('Примечание 2')),
          DataColumn(label: Text('Пользователь')),
          DataColumn(label: Text('Статус')),
          DataColumn(label: Text('')),
          DataColumn(label: Text('')),
          DataColumn(label: Text('')),
        ],
        rows: List<DataRow>.generate(_tasksList!.length, (index) {
          TaskServerModel task = _tasksList[index];
          String? brigadesValue;
          String? status = task.status;

          if (task.brigade != '') {
            brigadesValue = _taskList![index].brigade;
          }

          List<TextEditingController> note1TextEditingControllers = List
              .generate(_tasksList.length, (index) {
            return TextEditingController();
          });
          List<TextEditingController> note2TextEditingControllers = List
              .generate(_tasksList.length, (index) {
            return TextEditingController();
          });

          note1TextEditingControllers[index].value =
              note1TextEditingControllers[index].value.copyWith(
                  text: task.note1);
          note2TextEditingControllers[index].value =
              note2TextEditingControllers[index].value.copyWith(
                  text: task.note2);

          _listenSocket(task);
          return DataRow(
            cells: [
              DataCell(Text(task.task, style: TextStyle(
                  color: Color(int.parse('0x' + task.color))))),
              DataCell(StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButton<String>(
                    hint: const Text('Выберите бригаду'),
                    value: brigadesValue,
                    onChanged: (String? value) {
                      setState(() {
                        brigadesValue = value;
                        var data = {
                          'ip': UserState.temporaryIp,
                          'id': task.id,
                          'brigade': brigadesValue
                        };
                        ServerSideApi.create(UserState.temporaryIp, 1)
                            .changeBrigade(data)
                            .then((value) {
                          _notifyBrigades!.notify(
                              task.address, brigadesValue!, 'Новая задача',
                              task.date, task.time,
                              task.isUrgent == true ? "Срочно" : "Не срочно");
                        });
                      });
                    },
                    items: Brigades.getBrigadesList()!.map<
                        DropdownMenuItem<String>>((task) {
                      return DropdownMenuItem(
                        value: task,
                        child: Text(task),
                      );
                    }).toList(),
                  );
                },
              )),
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
                      var note1SocketData = {
                        'id': task.id,
                        'brigade': brigadesValue,
                        'note1': text
                      };

                      _htmlWebSocketChannel!.sink.add(json.encode(
                          note1SocketData));
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
                      var note2SocketData = {
                        'id': task.id,
                        'brigade': brigadesValue,
                        'note2': text
                      };

                      _htmlWebSocketChannel!.sink.add(json.encode(
                          note2SocketData));
                    },
                  )
              )),
              DataCell(Text(task.addedBy)),
              DataCell(StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButton<String>(
                    value: status,
                    onChanged: (String? value) {
                      task.status = value!;
                      setState(() {
                        status = value;
                        var data = {
                          'ip': UserState.temporaryIp,
                          'id': task.id,
                          'status': value
                        };
                        ServerSideApi.create(UserState.temporaryIp, 1)
                            .updateStatus(data);
                        var socketData = {
                          'id': task.id,
                          'brigade': brigadesValue,
                          'status': value
                        };

                        _htmlWebSocketChannel!.sink.add(
                            json.encode(socketData));
                      });
                    },
                    items: _statusList!.map<DropdownMenuItem<String>>((status) {
                      return DropdownMenuItem(
                        value: status.status,
                        child: Text(status.status,
                            style: TextStyle(color: status.color)),
                      );
                    }).toList(),
                  );
                },
              )),
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
                      Response response = await ServerSideApi.create(
                          UserState.temporaryIp, 1).deleteTask(data);
                      if (response.body == 'task_deleted') {
                        _showMessage!.show(context, 7);
                        Navigator.pop(context);

                        var socketData = {
                          'delete_task': true,
                          'brigade': task.brigade,
                        };
                        _htmlWebSocketChannel!.sink.add(
                            json.encode(socketData));

                        setState(() {});
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
              )),
              DataCell(IconButton(
                icon: const Icon(Icons.info),
                onPressed: () {
                  requireLocationData(task);
                  double height = MediaQuery
                      .of(context)
                      .size
                      .height;
                  double width = MediaQuery
                      .of(context)
                      .size
                      .width;
                  showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StatefulBuilder(
                                  builder: (context, setState){
                                    mapTaskInfoState = setState;
                                    return SizedBox(
                                        width: width/4,
                                        child: Column(
                                          children: [
                                            const Text('Информация о задании', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                            const SizedBox(height: 20),
                                            Row(
                                              children: [
                                                const Text('Задание: ', style: TextStyle(fontSize: 15)),
                                                Text('${task.task}', style: TextStyle(color: Color(int.parse('0x' + task.color)), fontSize: 15))
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Text('Бригада: ', style: TextStyle(fontSize: 15)),
                                                Text('${task.brigade}', style: const TextStyle(fontSize: 15))
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Text('Адрес: ', style: TextStyle(fontSize: 15)),
                                                Text('${task.address}', style: const TextStyle(fontSize: 15))
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Text('Время в пути: ', style: TextStyle(fontSize: 15)),
                                                Text('${task.onWayTime}', style: const TextStyle(fontSize: 15))
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Text('Время работы: ', style: TextStyle(fontSize: 15)),
                                                Text('${task.workTime}', style: const TextStyle(fontSize: 15))
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Text('Общее время задания: ', style: TextStyle(fontSize: 15)),
                                                Text('${task.allTaskTime}', style: const TextStyle(fontSize: 15))
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Text('Статус: ', style: TextStyle(fontSize: 15)),
                                                Text('${task.status}', style: const TextStyle(fontSize: 15))
                                              ],
                                            )
                                          ],
                                        )
                                    );
                                  },
                                ),
                                SizedBox(
                                  child: mapsBuilder(),
                                  height: height * 0.5,
                                  width: width / 2,
                                )
                              ],
                            )
                          ],
                        );
                      }
                  );
                },
              ))
            ],
          );
        }),
      ),
    );
  }

  void requireLocationData(TaskServerModel task){
    if (task.status == 'Не выполнено') {
      var socketRequestData = {
        'brigade': task.brigade,
        'data': 'requesting_current_location'
      };

      _htmlWebSocketChannel!.sink.add(json.encode(socketRequestData));
    } else if (task.status == 'В пути') {

    } else if (task.status == 'На месте') {

    } else {

    }
  }

  StreamBuilder mapsBuilder(){
    return StreamBuilder(
      stream: _socketBroadcastStream,
      builder: (context, snapshot) {
        while(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
        }

        if(snapshot.connectionState == ConnectionState.active && snapshot.hasData){
          Map<String, dynamic>? cord = json.decode(snapshot.data);

          return maps!.getMaps(cord!['lat'], cord['long']);
        }else{
          return const Center(child: Text("Error"));
        }
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
                          borderRadius: BorderRadius.circular(3.0)),
                      label: const Text('Адрес'),
                      labelStyle: TextStyle(
                          color: _addressFocusNode!.hasFocus ? Colors
                              .deepOrangeAccent : Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3.0),
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
                          borderRadius: BorderRadius.circular(3.0)),
                      label: const Text('Телефон'),
                      labelStyle: TextStyle(
                          color: _telephoneFocusNode!.hasFocus ? Colors
                              .deepOrangeAccent : Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3.0),
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
                        if (taskValue != null) {
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
                          options.add(color!);
                          if (brigadesValue != null) {
                            options.add(brigadesValue!);
                          }
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
                      Tab(text: 'Админ'),
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
                                    borderRadius: BorderRadius.circular(3.0)),
                                label: const Text('IP Адрес'),
                                labelStyle: TextStyle(
                                    color: _ipAddressFocusNode!.hasFocus
                                        ? Colors.deepOrangeAccent
                                        : Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3.0),
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
                                    borderRadius: BorderRadius.circular(3.0)),
                                label: const Text('Имя пользователя'),
                                labelStyle: TextStyle(
                                    color: _nameFocusNode!.hasFocus ? Colors
                                        .deepOrangeAccent : Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3.0),
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
                                      borderRadius: BorderRadius.circular(3.0)),
                                  label: const Text('Пароль'),
                                  labelStyle: TextStyle(
                                      color: _passwordFocusNode!.hasFocus
                                          ? Colors.deepOrangeAccent
                                          : Colors.grey),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(3.0),
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
                                shape: const BeveledRectangleBorder(
                                    borderRadius: BorderRadius.zero
                                ),
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
                                    borderRadius: BorderRadius.circular(3.0)),
                                label: const Text('IP Адрес'),
                                labelStyle: TextStyle(
                                    color: _ipAddressFocusNode!.hasFocus
                                        ? Colors.deepOrangeAccent
                                        : Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3.0),
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
                                    borderRadius: BorderRadius.circular(3.0)),
                                label: const Text('Имя пользователя'),
                                labelStyle: TextStyle(
                                    color: _nameFocusNode!.hasFocus ? Colors
                                        .deepOrangeAccent : Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3.0),
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
                                      borderRadius: BorderRadius.circular(3.0)),
                                  label: const Text('Пароль'),
                                  labelStyle: TextStyle(
                                      color: _passwordFocusNode!.hasFocus
                                          ? Colors.deepOrangeAccent
                                          : Colors.grey),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(3.0),
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
                                shape: const BeveledRectangleBorder(
                                    borderRadius: BorderRadius.zero
                                ),
                                onPressed: () =>
                                    _registerBrigade(
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
    String? status = task.status;

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
                          borderRadius: BorderRadius.circular(3.0)),
                      label: const Text('Адрес'),
                      labelStyle: TextStyle(
                          color: _addressFocusNode!.hasFocus ? Colors
                              .deepOrangeAccent : Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3.0),
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
                          borderRadius: BorderRadius.circular(3.0)),
                      label: const Text('Телефон'),
                      labelStyle: TextStyle(
                          color: _telephoneFocusNode!.hasFocus ? Colors
                              .deepOrangeAccent : Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3.0),
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
                          _editTask(
                              task, options, dateAndTime, _isUrgent, status);
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
    String? task;
    String? color;
    String? brigade;
    if (options.length == 3) {
      task = options[0].toString();
      color = options[1].toString();
      brigade = options[2].toString();
    } else {
      task = options[0].toString();
      color = options[1].toString();
    }

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

      if (brigade != null) {
        _notifyBrigades!.notify(address, brigade, 'Новая задача', date, time,
            isUrgent == true ? "Срочно" : "Не срочно");
      }

      setState(() {});
    }
  }

  // Edit task to server
  void _editTask(TaskServerModel taskModel, List<String> options,
      List<TextEditingController> dateAndTime, bool isUrgent,
      String? status) async {
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
      'status': status
    };

    Response response = await ServerSideApi.create(UserState.temporaryIp, 1)
        .editTask(data);
    if (response.body == 'task_edited') {
      _showMessage!.show(context, 7);
      Navigator.pop(context);
      setState(() {});
    }

    var socketData = {
      'id': taskModel.id,
      'task': task,
      'brigade': brigade,
      'address': address,
      'date': date,
      'time': time,
      'telephone': telephone,
      'color': color,
      'urgent': isUrgent == true ? 1 : 0,
    };

    _htmlWebSocketChannel!.sink.add(json.encode(socketData));
  }

  // Showing sign out dialog
  void _showSignOutDialog() {
    Widget _signOutButton = TextButton(
      child: const Text(
        'Выйти',
        style: TextStyle(color: Colors.redAccent),
      ),
      onPressed: () {
        UserState.rememberUserState(false);
        UserState.clearBrigade();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => const TaskManagerMainPage()));
      },
    );

    Widget _cancelButton = TextButton(
        child: const Text(
            'Отмена', style: TextStyle(color: Colors.deepOrangeAccent)),
        onPressed: () {
          Navigator.pop(context);
          _htmlWebSocketChannel!.sink.close();
        });

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

  // Listener for socket
  void _listenSocket(TaskServerModel? task) {
    _socketBroadcastStream!.listen((event) {
      Map<String, dynamic> eventMap = json.decode(event);
      String? taskId = eventMap['id'];
      if (taskId == task!.id) {
        eventMap.forEach((key, value) {
          switch (key) {
            case 'onWayTime':
              mapTaskInfoState!(() {
                task.onWayTime = eventMap['onWayTime'];
              });
              break;
            case 'workTime':
              mapTaskInfoState!(() {
                task.workTime = eventMap['workTime'];
              });
              break;
            case 'allTaskTime':
              mapTaskInfoState!(() {
                task.allTaskTime = eventMap['allTaskTime'];
              });
              break;
            case 'status':
              setState(() {});

              task.status = eventMap['status'];
              mapTaskInfoState!(() {});
              break;
          }
        });
      }
    });
  }

}