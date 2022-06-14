import 'dart:async';
import 'dart:convert';
import 'package:chopper/chopper.dart';
import 'package:data_table_2/paginated_data_table_2.dart';
import 'package:intermax_task_manager/Brigade%20Model/brigade_model.dart';
import 'package:intermax_task_manager/Brigades%20Settings/brigade_details.dart';
import 'package:intermax_task_manager/Maps%20API/maps.dart';
import 'package:intermax_task_manager/Privileges/privileges.dart';
import 'package:intermax_task_manager/Privileges/privileges_constants.dart';
import 'package:intermax_task_manager/Privileges/privileges_for_current_user.dart';
import 'package:intermax_task_manager/Provider/stop_watch_provider.dart';
import 'package:intermax_task_manager/Status%20Data/status_model.dart';
import 'package:flutter/material.dart';
import 'package:intermax_task_manager/FCM%20Controller/fcm_controller.dart';
import 'package:intermax_task_manager/Flutter%20Toast/flutter_toast.dart';
import 'package:intermax_task_manager/ServerSideApi/server_side_api.dart';
import 'package:intermax_task_manager/Tasks%20Settings/task_model.dart';
import 'package:intermax_task_manager/Tasks%20Settings/task_server_model.dart';
import 'package:intermax_task_manager/User%20Details/user_details.dart';
import 'package:intermax_task_manager/User%20State/user_state.dart';
import 'package:intermax_task_manager/main.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:sizer/sizer.dart';
import 'package:web_socket_channel/html.dart';

import 'Backup File Model/back_up_file_model.dart';

class TaskPage extends StatefulWidget {

  String? ip;

  TaskPage({Key? key, this.ip}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TaskPage> with TickerProviderStateMixin {

  Future<Response<List<TaskModel>>>? _tasksModelFuture;
  Future<Response<List<BrigadeModel>>>? _brigadesModelFuture;
  Future<Response<List<BackupFile>>>? _backupFilesFuture;
  Future<Response<List<User>>>? _getAdminsFuture;
  Future<Response<List<User>>>? _getBrigadesFuture;



  Stream? _socketBroadcastStream;
  HtmlWebSocketChannel? _htmlWebSocketChannel;
  Privileges? _privileges;

  StateSetter? taskInfoState;
  StateSetter? mapState;
  StateSetter? tasksDialogState;
  StateSetter? brigadeDialogState;
  StateSetter? dataTableState;
  StateSetter? changeUserPassDialogState;
  StateSetter? changeBrigadePassDialogState;
  StateSetter? brigadeStatusState;

  FocusNode? _ipAddressFocusNode;
  FocusNode? _nameFocusNode;
  FocusNode? _passwordFocusNode;
  FocusNode? _tasksFocusNode;
  FocusNode? _addressFocusNode;
  FocusNode? _telephoneFocusNode;

  ShowMessage? _showMessage;
  TabController? _tabController;
  TabController? _tabController1;
  NotifyBrigades? _notifyBrigades;

  bool? _isGreen = false;
  bool? _isRed = false;
  bool? _isBlue = false;
  bool isAscending = false;


  List<TaskServerModel>? _taskList;
  List<TaskServerModel>? _taskFilteredList;
  List<BackupFile>? _backupFileList;

  List<TaskModel>? _tasksModel = [];
  List<BrigadeModel>? _brigadeModel = [];

  List<Status>? _statusList = [];

  List<User>? _adminsList = [];
  List<User>? _brigadesList = [];

  List<Brigade> _brigadeStatusesList = [];

  MapsAPI? maps;

  List<String>? brigadesValue = [];

  List<LocationData>? _locations = [];

  int? _backupFilesIndex = 0;
  int? sortColumnIndex;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  var dateFormatter = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();


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
    _tabController1 = TabController(length: 2, vsync: this);

    _statusList!.add(Status(status: 'Не выполнено', color: Colors.red));
    _statusList!.add(Status(status: 'В пути', color: Colors.orangeAccent[700]));
    _statusList!.add(Status(status: 'На месте', color: Colors.yellow[700]));
    _statusList!.add(Status(status: 'Завершено', color: Colors.green));
    _statusList!.add(Status(status: 'Не завершено', color: Colors.blue));

    _htmlWebSocketChannel = HtmlWebSocketChannel.connect('ws://${widget.ip}:1073');
    _socketBroadcastStream = _htmlWebSocketChannel!.stream.asBroadcastStream();
    _privileges = Privileges.createInstance();

    _tasksModelFuture = ServerSideApi.create(UserState.temporaryIp, 5).getTasksFromServer();
    _brigadesModelFuture = ServerSideApi.create(UserState.temporaryIp, 6).getBrigadesFromServer();
    _backupFilesFuture = ServerSideApi.create(UserState.temporaryIp, 7).getBackupFiles();
    _getAdminsFuture = ServerSideApi.create(UserState.temporaryIp, 2).getAdmins();
    _getBrigadesFuture = ServerSideApi.create(UserState.temporaryIp, 2).getBrigades();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Response<List<TaskModel>> taskResponse = await ServerSideApi.create(UserState.temporaryIp, 5).getTasksFromServer();
      Response<List<BrigadeModel>> brigadeResponse = await ServerSideApi.create(UserState.temporaryIp, 6).getBrigadesFromServer();

      _tasksModel = taskResponse.body;
      _brigadeModel = brigadeResponse.body;

      dataTableState!((){});
    });

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
    return Sizer(
      builder: (context, orientation, deviceType){
        return ResponsiveWrapper.builder(
          Scaffold(
              appBar: AppBar(
                title: const Text(
                    'Планировщик задач Intermax', style: TextStyle(fontSize: 25)),
                centerTitle: false,
                backgroundColor: Colors.deepOrangeAccent,
                automaticallyImplyLeading: false,
                actions: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today_outlined),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2030),
                          );

                          if (picked != null && picked != startDate) {
                            setState(() {
                              startDate = picked;
                            });
                          }
                        },
                      ),
                      Text(dateFormatter.format(startDate).toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 5),
                      Container(
                        height: 2,
                        width: 25,
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today_outlined),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2030),
                          );

                          if (picked != null && picked != endDate) {
                            setState(() {
                              endDate = picked;
                            });
                          }
                        },
                      ),
                      Text(dateFormatter.format(endDate).toString(), style: TextStyle(fontWeight: FontWeight.bold))
                    ],
                  ),
                  const SizedBox(width: 10),
                  Padding(
                      padding:
                      EdgeInsets.only(top: 2.sp, bottom: 2.sp, right: 2.sp),
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 300,
                          child: TextFormField(
                            cursorColor: Colors.deepOrangeAccent,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                              hintText: 'Поиск...',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepOrangeAccent)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepOrangeAccent)
                              )
                            ),
                            onChanged: (value) {
                              dataTableState!(() {
                                _taskFilteredList = _taskList!.where((item) =>
                                    item.task.toString().toLowerCase().contains(value.toLowerCase()) ||
                                    item.brigade.toString().toLowerCase().contains(value.toLowerCase()) ||
                                    item.address.toString().toLowerCase().contains(value.toLowerCase()) ||
                                    item.telephone.toString().toLowerCase().contains(value.toLowerCase()) ||
                                    item.date.toString().toLowerCase().contains(value.toLowerCase()) ||
                                    item.time.toString().toLowerCase().contains(value.toLowerCase()) ||
                                    item.note1.toString().toLowerCase().contains(value.toLowerCase()) ||
                                    item.note2.toString().toLowerCase().contains(value.toLowerCase()) ||
                                    item.addedBy.toString().toLowerCase().contains(value.toLowerCase()) ||
                                    item.status.toString().toLowerCase().contains(value.toLowerCase())).toList();
                              });
                            },
                          ),
                        ),
                      )),
                  IconButton(
                    icon: const Icon(Icons.refresh_sharp),
                    onPressed: () => setState((){}),
                  ),
                  PrivilegesConstants.ADD_NEW_TASK ? IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddTaskDialog(),
                  ) : Container(),
                  PrivilegesConstants.REGISTER_ADMIN || PrivilegesConstants.REGISTER_BRIGADE ? IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () => _showAddUserDialog(),
                  ) : Container(),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _showSignOutDialog(),
                  ),
                  PrivilegesConstants.SETTINGS ? PopupMenuButton(
                      icon: const Icon(Icons.settings),
                      tooltip: 'Настройки',
                      itemBuilder: (context) =>
                        [
                        const PopupMenuItem(
                          value: 1,
                          child: Text('Изменить задания'),
                        ),
                        const PopupMenuItem(
                          value: 2,
                          child: Text('Изменить бригад'),
                        ),
                        PopupMenuItem(
                          value: PrivilegesConstants.BACKUP_DATA ? 3 : null,
                          child: Text('Сделать резервную копию', style: TextStyle(color: PrivilegesConstants.BACKUP_DATA ? Colors.black : Colors.grey)),
                        ),
                        PopupMenuItem(
                          value: PrivilegesConstants.RESTORE_BACKUP ? 4 : null,
                          child: Text('Восстановить из резервной копии', style: TextStyle(color: PrivilegesConstants.RESTORE_BACKUP ? Colors.black : Colors.grey)),
                        ),
                        PopupMenuItem(
                          value: PrivilegesConstants.CHANGE_PASSWORDS ? 5 : null,
                          child: Text('Изменить пароль', style: TextStyle(color: PrivilegesConstants.CHANGE_PASSWORDS ? Colors.black : Colors.grey)),
                        ),
                        PopupMenuItem(
                            value: PrivilegesConstants.CHANGE_PRIVILEGES ? 6 : null,
                            child: Text('Изменить привилегии', style: TextStyle(color: PrivilegesConstants.CHANGE_PRIVILEGES ? Colors.black : Colors.grey))
                        ),
                        const PopupMenuItem(
                            value: 7,
                            child: Text('Статус бригад', style: TextStyle(color: Colors.black))
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 1:
                            TextEditingController tasksController = TextEditingController();
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                      builder: (context, setState) {
                                        tasksDialogState = setState;
                                        return SimpleDialog(
                                            title: const Text('Задания', style: TextStyle(
                                                color: Colors.black, fontSize: 30)),
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
                                                      backgroundColor: PrivilegesConstants.ADD_TASK_TEMPLATE ? Colors.deepOrangeAccent : Colors.grey,
                                                      child: const Icon(Icons.add),
                                                      onPressed: PrivilegesConstants.ADD_TASK_TEMPLATE ? () async {
                                                        String? color;
                                                        if (tasksController.text !=
                                                            '') {
                                                          if (_isRed == true) {
                                                            color = 'red';
                                                          } else
                                                          if (_isGreen == true) {
                                                            color = 'green';
                                                          } else
                                                          if (_isBlue == true) {
                                                            color = 'blue';
                                                          }


                                                          var data = {
                                                            'name': tasksController
                                                                .text,
                                                            'color': color
                                                          };

                                                          _tasksModel!.add(TaskModel(
                                                              name: tasksController
                                                                  .text,
                                                              color: color));
                                                          setState(() {});

                                                          await ServerSideApi.create(
                                                              UserState.temporaryIp,
                                                              1)
                                                              .addTaskToList(data)
                                                              .whenComplete(() {
                                                            tasksController.clear();
                                                          });
                                                        } else if (_isRed == false &&
                                                            _isGreen == false &&
                                                            _isBlue == false) {
                                                          _showMessage!.show(
                                                              context, 8);
                                                        } else {
                                                          _showMessage!.show(
                                                              context, 3);
                                                        }
                                                      } : null)
                                                ]),
                                                SizedBox(
                                                    width: 400,
                                                    height: 400,
                                                    child: getTasksModel()
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
                                  return StatefulBuilder(
                                      builder: (context, setState) {
                                        brigadeDialogState = setState;
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
                                                      backgroundColor: PrivilegesConstants.ADD_BRIGADE ? Colors.deepOrangeAccent : Colors.grey,
                                                      child: const Icon(Icons.add),
                                                      onPressed: PrivilegesConstants.ADD_BRIGADE ? () async {
                                                        if (brigadesController.text !=
                                                            '') {
                                                          var data = {
                                                            'name': brigadesController
                                                                .text
                                                          };

                                                          _brigadeModel!.add(
                                                              BrigadeModel(
                                                                  name: brigadesController
                                                                      .text));
                                                          setState(() {});
                                                          dataTableState!(() {});

                                                          await ServerSideApi.create(UserState.temporaryIp, 1).addBrigade(data).whenComplete(() {
                                                            brigadesController
                                                                .clear();
                                                          });
                                                        } else {
                                                          _showMessage!.show(
                                                              context, 3);
                                                        }
                                                        setState(() {});
                                                      } : null)
                                                ]),
                                                SizedBox(
                                                    width: 400,
                                                    height: 400,
                                                    child: getBrigadesModel()
                                                )
                                              ])
                                            ]);
                                      });
                                });
                            break;
                          case 3:
                            TextEditingController fileNameTextController = TextEditingController();
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return SimpleDialog(
                                        title: const Text('Сделать резервную копию'),
                                        contentPadding: const EdgeInsets.all(10),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero),
                                        backgroundColor: Colors.white,
                                        children: [
                                          TextFormField(
                                            keyboardType: TextInputType.text,
                                            controller: fileNameTextController,
                                            cursorColor: Colors.deepOrangeAccent,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.zero),
                                              label: Text('Имя файла'),
                                              labelStyle: TextStyle(
                                                  color: Colors.deepOrangeAccent),
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.deepOrangeAccent)
                                              ),

                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.deepOrangeAccent)
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 10),

                                          FloatingActionButton.extended(
                                            label: const Text('Сделать резервную копию'),
                                            onPressed: () => _backupData(fileNameTextController.text),
                                            backgroundColor: Colors.deepOrangeAccent,
                                            shape: const BeveledRectangleBorder(
                                                borderRadius: BorderRadius.zero
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                            );
                            break;
                          case 4:
                            showDialog(
                                context: context,
                                builder: (context){
                                  return StatefulBuilder(
                                    builder: (context, setState){
                                      return SimpleDialog(
                                        title: const Text('Восстановить из резервной копии'),
                                        contentPadding: const EdgeInsets.all(10),
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                        backgroundColor: Colors.white,
                                        children: [
                                          SizedBox(
                                            height: 400,
                                            width: 200,
                                            child: getBackupFiles(),
                                          ),
                                          const SizedBox(height: 10),
                                          FloatingActionButton.extended(
                                            label: const Text('Восстановить'),
                                            onPressed: () => _restoreData(),
                                            backgroundColor: Colors.deepOrangeAccent,
                                            shape: const BeveledRectangleBorder(
                                                borderRadius: BorderRadius.zero
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                            );
                            break;
                          case 5:
                            showDialog(
                                context: context,
                                builder: (context){
                                  return StatefulBuilder(
                                    builder: (context, setState){
                                      return SimpleDialog(
                                        title: const Text(
                                          'Изменить пароль',
                                          style: TextStyle(color: Colors.black, fontSize: 30),
                                        ),
                                        contentPadding: const EdgeInsets.all(20.0),
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                        backgroundColor: Colors.white,
                                        children: [
                                          TabBar(
                                            controller: _tabController1,
                                            indicatorColor: Colors.deepOrangeAccent,
                                            unselectedLabelColor: Colors.grey,
                                            labelColor: Colors.deepOrangeAccent,
                                            tabs: const [
                                              Tab(text: 'Админы'),
                                              Tab(text: 'Бригады')
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            height: 350,
                                            width: 200,
                                            child: TabBarView(
                                              controller: _tabController1,
                                              children: [
                                                SizedBox(
                                                  height: 400,
                                                  width: 400,
                                                  child: getAdmins('for passwords'),
                                                ),
                                                SizedBox(
                                                  height: 400,
                                                  width: 400,
                                                  child: getBrigades(),
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
                            break;
                          case 6:
                            showDialog(
                                context: context,
                                builder: (context){
                                  return StatefulBuilder(
                                    builder: (context, setState){
                                      return SimpleDialog(
                                        title: const Text(
                                          'Изменить привилегии',
                                          style: TextStyle(color: Colors.black, fontSize: 30),
                                        ),
                                        contentPadding: const EdgeInsets.all(20.0),
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                        backgroundColor: Colors.white,
                                        children: [
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            height: 350,
                                            width: 200,
                                            child: getAdmins('for privileges'),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                }
                            );
                            break;
                          case 7:
                            showDialog(
                                context: context,
                                builder: (context){
                                  return StatefulBuilder(
                                    builder: (context, setState){
                                      return SimpleDialog(
                                        title: const Text(
                                          'Статус бригад',
                                          style: TextStyle(color: Colors.black, fontSize: 30),
                                        ),
                                        contentPadding: const EdgeInsets.all(20.0),
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                        backgroundColor: Colors.white,
                                        children: [
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            height: 350,
                                            width: 200,
                                            child: getBrigadesStatus()
                                          )
                                        ],
                                      );
                                    },
                                  );
                                }
                            );
                            break;
                        }
                      }
                  ) : Container()
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
      },
    );
  }

  // Getting tasks from server
  FutureBuilder<Response<List<TaskServerModel>>> getTasks() {
    String formattedStartDate = dateFormatter.format(startDate);
    String formattedEndDate = dateFormatter.format(endDate);
    var data = {'start_date' : formattedStartDate, 'end_date' : formattedEndDate};

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

          _taskFilteredList = List.from(_taskList!.toList());

          StopWatchProvider.initTimers(_taskFilteredList);

          return buildTasksTable();
        } else {
          return const Center(
            child: Text('Список задач пуст', style: TextStyle(fontSize: 20)),
          );
        }
      },
    );
  }

  // Getting tasks models from server
  FutureBuilder<Response<List<TaskModel>>> getTasksModel(){
    return FutureBuilder<Response<List<TaskModel>>>(
      future: _tasksModelFuture,
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
          _tasksModel = snapshot.data!.body;
          return tasksModelWidget();
        } else {
          return const Center(
            child: Text('Список пуст', style: TextStyle(fontSize: 20)),
          );
        }
      },
    );
  }

  // Getting brigade models from server
  FutureBuilder<Response<List<BrigadeModel>>> getBrigadesModel(){
    return FutureBuilder<Response<List<BrigadeModel>>>(
      future: _brigadesModelFuture,
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
          _brigadeModel = snapshot.data!.body;
          return brigadeModelWidget();
        } else {
          return const Center(
            child: Text('Список пуст', style: TextStyle(fontSize: 20)),
          );
        }
      },
    );
  }

  // Getting backup files from server
  FutureBuilder<Response<List<BackupFile>>> getBackupFiles(){
    return FutureBuilder<Response<List<BackupFile>>>(
      future: _backupFilesFuture,
      builder: (context, snapshot) {
        while (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.deepOrangeAccent,
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          _backupFileList = snapshot.data!.body;
          return createBackupFilesDialogContent();
        } else {
          return const Center(
            child: Text('Список пуст', style: TextStyle(fontSize: 20)),
          );
        }
      },
    );
  }

  // Getting admins from server
  FutureBuilder<Response<List<User>>> getAdmins(String why){
    return FutureBuilder<Response<List<User>>>(
      future: _getAdminsFuture,
      builder: (context, snapshot) {
        while (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.deepOrangeAccent,
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          _adminsList = snapshot.data!.body;
          if(why == 'for passwords'){
            return createAdminsDialogContent();
          }else{
            return createAdminsDialogForPrivileges();
          }
        } else {
          return const Center(
            child: Text('Список пуст', style: TextStyle(fontSize: 20)),
          );
        }
      },
    );
  }

  // Getting brigades from server
  FutureBuilder<Response<List<User>>> getBrigades(){
    return FutureBuilder<Response<List<User>>>(
      future: _getBrigadesFuture,
      builder: (context, snapshot) {
        while (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.deepOrangeAccent,
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          _brigadesList = snapshot.data!.body;
          return createBrigadesDialogContent();
        } else {
          return const Center(
            child: Text('Список пуст', style: TextStyle(fontSize: 20)),
          );
        }
      },
    );
  }

  // Getting brigades statuses
  FutureBuilder<Response<List<Brigade>>> getBrigadesStatus(){
    return FutureBuilder<Response<List<Brigade>>>(
      future: ServerSideApi.create(UserState.temporaryIp, 4).getBrigadesStatus(),
      builder: (context, snapshot){
        while (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.deepOrangeAccent,
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          _brigadeStatusesList = snapshot.data!.body!;
          return createBrigadeStatusDialog();
        } else {
          return const Center(
            child: Text('Список пуст', style: TextStyle(fontSize: 20)),
          );
        }
      },
    );
  }

  // Creating admins dialog content
  StatefulBuilder createAdminsDialogContent(){
    return StatefulBuilder(
      builder: (context, setState){
        changeUserPassDialogState = setState;
        return SizedBox.expand(
          child: SingleChildScrollView(
            child: DataTable(
              columnSpacing: 10,
              columns: const [
                DataColumn(label: Text('Имя')),
                DataColumn(label: Text('Пароль')),
                DataColumn(label: Text('')),
                DataColumn(label: Text(''))
              ],
              rows: List<DataRow>.generate(_adminsList!.length, (index){
                User admins = _adminsList![index];
                return DataRow(
                  cells: [
                    DataCell(Text(admins.username)),
                    DataCell(Text(admins.password)),
                    DataCell(IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        TextEditingController passwordTextController = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (context){
                            return SimpleDialog(
                              title: const Text(
                                'Изменить пароль',
                                style: TextStyle(color: Colors.black, fontSize: 30),
                              ),
                              contentPadding: const EdgeInsets.all(10),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              backgroundColor: Colors.white,
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.text,
                                controller: passwordTextController,
                                cursorColor: Colors.deepOrangeAccent,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                                  label: Text('Новый пароль'),
                                  labelStyle: TextStyle(color: Colors.deepOrangeAccent),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrangeAccent)),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrangeAccent)),
                                ),
                              ),

                              const SizedBox(height: 20),

                              FloatingActionButton.extended(
                                label: const Text('Изменить пароль'),
                                onPressed: () => _changeUserPassword(admins, passwordTextController.text),
                                backgroundColor: Colors.deepOrangeAccent,
                                shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
                              ),
                            ],
                            );
                          }
                        );
                      },
                    )),
                    DataCell(IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        var data = {
                          'name' : admins.username
                        };
                        await ServerSideApi.create(UserState.temporaryIp, 1).unregisterAdmin(data).whenComplete((){
                          _adminsList!.removeAt(index);
                          setState((){});
                        });
                      },
                    ))
                  ]
                );
              })
            ),
          ),
        );
      },
    );
  }

  // Creating admins dialog content
  StatefulBuilder createAdminsDialogForPrivileges(){
    return StatefulBuilder(
      builder: (context, setState){
        changeUserPassDialogState = setState;
        return SizedBox.expand(
          child: SingleChildScrollView(
            child: DataTable(
                columnSpacing: 10,
                columns: const [
                  DataColumn(label: Text('Имя')),
                  DataColumn(label: Text('')),
                ],
                rows: List<DataRow>.generate(_adminsList!.length, (index){
                  User admins = _adminsList![index];
                  return DataRow(
                      cells: [
                        DataCell(Text(admins.username)),
                        DataCell(IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showPrivilegesDialog(admins)
                        ))
                      ]
                  );
                })
            ),
          ),
        );
      },
    );
  }

  // Creating brigades dialog content
  StatefulBuilder createBrigadesDialogContent(){
    return StatefulBuilder(
      builder: (context, setState){
        changeBrigadePassDialogState = setState;
        return SizedBox.expand(
          child: SingleChildScrollView(
            child: DataTable(
                columnSpacing: 10,
                columns: const [
                  DataColumn(label: Text('Имя')),
                  DataColumn(label: Text('Пароль')),
                  DataColumn(label: Text('')),
                  DataColumn(label: Text(''))
                ],
                rows: List<DataRow>.generate(_brigadesList!.length, (index){
                  User brigades = _brigadesList![index];
                  return DataRow(
                      cells: [
                        DataCell(Text(brigades.username)),
                        DataCell(Text(brigades.password)),
                        DataCell(IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            TextEditingController passwordTextController = TextEditingController();
                            showDialog(
                                context: context,
                                builder: (context){
                                  return SimpleDialog(
                                    title: const Text(
                                      'Изменить пароль',
                                      style: TextStyle(color: Colors.black, fontSize: 30),
                                    ),
                                    contentPadding: const EdgeInsets.all(10),
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                    backgroundColor: Colors.white,
                                    children: [
                                      TextFormField(
                                        keyboardType: TextInputType.text,
                                        controller: passwordTextController,
                                        cursorColor: Colors.deepOrangeAccent,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                                          label: Text('Новый пароль'),
                                          labelStyle: TextStyle(color: Colors.deepOrangeAccent),
                                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrangeAccent)),
                                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrangeAccent)),
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      FloatingActionButton.extended(
                                        label: const Text('Изменить пароль'),
                                        onPressed: () => _changeBrigadePassword(brigades, passwordTextController.text),
                                        backgroundColor: Colors.deepOrangeAccent,
                                        shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
                                      ),
                                    ],
                                  );
                                }
                            );
                          },
                        )),
                        DataCell(IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            var data = {
                              'name' : brigades.username
                            };
                            await ServerSideApi.create(UserState.temporaryIp, 1).unregisterBrigade(data).whenComplete((){
                              _brigadesList!.removeAt(index);
                              setState((){});
                            });
                          },
                        ))
                      ]
                  );
                })
            ),
          ),
        );
      },
    );
  }

  // Creating backup files dialog content
  StatefulBuilder createBackupFilesDialogContent() {
    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox.expand(
            child: SingleChildScrollView(
              child: DataTable(
                  columnSpacing: 10,
                  columns: const [
                    DataColumn(label: Text('Имя файла')),
                    DataColumn(label: Text(''))
                  ],
                  rows: List<DataRow>.generate(_backupFileList!.length, (index) {
                    BackupFile backupFile = _backupFileList![index];
                    return DataRow(cells: [
                      DataCell(Text(backupFile.filename)),
                      DataCell(Radio<int>(
                        value: index,
                        groupValue: _backupFilesIndex,
                        onChanged: (value) {
                          setState(() {
                            _backupFilesIndex = value;
                          });
                        },
                      ))
                    ]);
                  })),
            ));
      },
    );
  }

  // Creating brigade status dialog
  StatefulBuilder createBrigadeStatusDialog(){
    return StatefulBuilder(
      builder: (context, setState) {
        brigadeStatusState = setState;
        return SizedBox.expand(
            child: SingleChildScrollView(
              child: DataTable(
                  columnSpacing: 10,
                  columns: const [
                    DataColumn(label: Text('Бригада')),
                    DataColumn(label: Text('Статус'))
                  ],
                  rows: List<DataRow>.generate(_brigadeStatusesList.length, (index) {
                    Brigade brigade = _brigadeStatusesList[index];
                    return DataRow(cells: [
                      DataCell(Text(brigade.brigade)),
                      DataCell(Text(brigade.status, style: TextStyle(color: brigade.status == 'Offline' ? Colors.red : Colors.green)))
                    ]);
                  })),
            ));
      },
    );
  }

  // Building tasks table
  Widget buildTasksTable() {
    return SizedBox.expand(
       child: StatefulBuilder(
         builder: (context, setState){
           dataTableState = setState;
           return DataTable2(
             sortAscending: isAscending,
             sortColumnIndex: sortColumnIndex,
             columnSpacing: 3,
             headingRowHeight: 40,
             headingRowColor: MaterialStateColor.resolveWith((states) {return Colors.grey[300]!;},),
             dataRowHeight: 35,
             border: TableBorder.all(
               width: 1.0,
               color: Colors.grey,
             ),
             columns: [
               DataColumn2(label: Center(child: Text('Задание', style: TextStyle(fontSize: 12))), onSort: onSort, fixedWidth: 10.w),
               DataColumn2(label: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 10),
                 child: Text('Адрес', style: TextStyle(fontSize: 12)),
               ), onSort: onSort, fixedWidth: 16.w),
               DataColumn2(label: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 10),
                 child: Text('Бригада', style: TextStyle(fontSize: 12)),
               ), onSort: onSort, fixedWidth: 10.w),
               DataColumn2(label: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 10),
                 child: Text('Тел.', style: TextStyle(fontSize: 12)),
               ), onSort: onSort, fixedWidth: 6.w),
               DataColumn2(label: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 10),
                 child: Text('Дата', style: TextStyle(fontSize: 12)),
               ), onSort: onSort, fixedWidth: 6.w),
               DataColumn2(label: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 10),
                 child: Text('Время', style: TextStyle(fontSize: 12)),
               ), onSort: onSort, fixedWidth: 5.w),
               DataColumn2(label: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 10),
                 child: Text('Срочно', style: TextStyle(fontSize: 12)),
               ), onSort: onSort, fixedWidth: 5.w),
               DataColumn2(label: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 10),
                 child: Text('Примечание 1', style: TextStyle(fontSize: 12)),
               ), fixedWidth: 9.w),
               DataColumn2(label: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 10),
                 child: Text('Примечание 2', style: TextStyle(fontSize: 12)),
               ), fixedWidth: 9.w),
               DataColumn2(label: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 10),
                 child: Text('Админ', style: TextStyle(fontSize: 12)),
               ), onSort: onSort, fixedWidth: 5.w),
               DataColumn2(label: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 10),
                 child: Text('Статус', style: TextStyle(fontSize: 12)),
               ), onSort: onSort, fixedWidth: 8.w),
               DataColumn2(label: Text(''), fixedWidth: 3.w),
               DataColumn2(label: Text(''), fixedWidth: 3.w),
               DataColumn2(label: Text(''), fixedWidth: 3.w),
             ],
             rows: List<DataRow>.generate(_taskFilteredList!.length, (index) {
               TaskServerModel task = _taskFilteredList![index];
               String? status = task.status;

               if (task.brigade != '') {
                 brigadesValue![index] = task.brigade;
               }

               List<TextEditingController> note1TextEditingControllers = List.generate(_taskFilteredList!.length, (index) {
                 return TextEditingController();
               });
               List<TextEditingController> note2TextEditingControllers = List.generate(_taskFilteredList!.length, (index) {
                 return TextEditingController();
               });


               note1TextEditingControllers[index].value = note1TextEditingControllers[index].value.copyWith(text: task.note1);
               note2TextEditingControllers[index].value = note2TextEditingControllers[index].value.copyWith(text: task.note2);

               _listenSocket(task);

               return DataRow(
                 cells: [
                   DataCell(Text(task.task, style: TextStyle(color: Color(int.parse('0x' + task.color)), fontSize: 12))),
                   DataCell(Padding(
                     padding: const EdgeInsets.only(left: 10),
                     child: Text(task.address, style: TextStyle(fontSize: 12)),
                   )),
                   DataCell(IgnorePointer(
                     ignoring: !PrivilegesConstants.ASSIGN_TASK_TO_BRIGADE,
                     child: Padding(
                       padding: const EdgeInsets.only(left: 10),
                       child: StatefulBuilder(
                         builder: (context, setState) {
                           return DropdownButton<String>(
                             hint: const Text('Выберите бригаду', style: TextStyle(fontSize: 12)),
                             value: brigadesValue![index],
                             onChanged: (String? value) {
                               setState(() {
                                 brigadesValue![index] = value!;
                                 var data = {
                                   'ip': UserState.temporaryIp,
                                   'id': task.id,
                                   'brigade': brigadesValue![index]
                                 };
                                 ServerSideApi.create(UserState.temporaryIp, 1).changeBrigade(data).then((value) {
                                   _notifyBrigades!.notify(
                                       task.address, brigadesValue![index], 'Новая задача',
                                       task.date, task.time,
                                       task.isUrgent == true ? "Срочно" : "Не срочно");
                                 });
                               });
                             },
                             items: _brigadeModel!.map<DropdownMenuItem<String>>((brigade) {
                               return DropdownMenuItem(
                                 value: brigade.name,
                                 child: Text(brigade.name, style: TextStyle(fontSize: 12)),
                               );
                             }).toList(),
                           );
                         },
                       ),
                     ),
                   )),
                   DataCell(Padding(
                     padding: const EdgeInsets.only(left: 10),
                     child: Text(task.telephone, style: TextStyle(fontSize: 12)),
                   )),
                   DataCell(Padding(
                       padding: const EdgeInsets.only(left: 10),
                       child: Text(task.date, style: TextStyle(fontSize: 12))
                   )),
                   DataCell(Padding(
                     padding: const EdgeInsets.only(left: 10),
                     child: Text(task.time, style: TextStyle(fontSize: 12)),
                   )),
                   DataCell(Padding(
                     padding: const EdgeInsets.only(left: 10),
                     child: Text(task.isUrgent == '1' ? 'Да' : 'Нет', style: TextStyle(fontSize: 12, color: task.isUrgent == '1' ? Colors.red : Colors.black)),
                   )),
                   DataCell(SizedBox(
                       width: 150,
                       height: 30,
                       child: TextFormField(
                         textAlignVertical: TextAlignVertical.center,
                         controller: note1TextEditingControllers[index],
                         style: const TextStyle(fontSize: 12),
                         cursorColor: Colors.deepOrangeAccent,
                         decoration: const InputDecoration(
                             border: InputBorder.none
                         ),

                         onFieldSubmitted: (text) {
                           var data = {
                             'ip': UserState.temporaryIp,
                             'id': task.id,
                             'note_1': text,
                           };

                           ServerSideApi.create(UserState.temporaryIp, 1).editNotes1(data);
                           var note1SocketData = {
                             'id': task.id,
                             'brigade': task.brigade,
                             'note1': text
                           };

                           _htmlWebSocketChannel!.sink.add(json.encode(note1SocketData));
                         },
                       )
                   )),
                   DataCell(SizedBox(
                       width: 150,
                       child: TextFormField(
                         textAlignVertical: TextAlignVertical.center,
                         controller: note2TextEditingControllers[index],
                         style: const TextStyle(fontSize: 12),
                         cursorColor: Colors.deepOrangeAccent,
                         decoration: const InputDecoration(
                             border: InputBorder.none
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
                             'brigade': task.brigade,
                             'note2': text
                           };

                           _htmlWebSocketChannel!.sink.add(json.encode(
                               note2SocketData));
                         },
                       )
                   )),
                   DataCell(Padding(
                     padding: const EdgeInsets.only(left: 10),
                     child: Text(task.addedBy, style: TextStyle(fontSize: 12)),
                   )),
                   DataCell(IgnorePointer(
                     ignoring: !PrivilegesConstants.CHANGE_TASK_STATUS,
                     child: Padding(
                       padding: const EdgeInsets.only(left: 10),
                       child: StatefulBuilder(
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

                                 var socketData = {
                                   'id': task.id,
                                   'brigade': task.brigade,
                                   'status': value
                                 };

                                 ServerSideApi.create(UserState.temporaryIp, 1).updateStatus(data).whenComplete((){
                                   _htmlWebSocketChannel!.sink.add(json.encode(socketData));
                                 });
                               });
                             },
                             items: _statusList!.map<DropdownMenuItem<String>>((status) {
                               return DropdownMenuItem(
                                 value: status.status,
                                 child: Text(status.status,
                                     style: TextStyle(color: status.color, fontSize: 12)),
                               );
                             }).toList(),
                           );
                         },
                       ),
                     ),
                   )),
                   DataCell(Center(
                     child: IconButton(
                       icon: Icon(Icons.edit, color: PrivilegesConstants.EDIT_TASK ? Colors.black : Colors.grey),
                       onPressed: PrivilegesConstants.EDIT_TASK ? () => _showEditTaskDialog(task) : null,
                     ),
                   )),
                   DataCell(Center(
                     child: IconButton(
                       icon: Icon(Icons.delete, color: PrivilegesConstants.DELETE_TASK ? Colors.black : Colors.grey),
                       onPressed: PrivilegesConstants.DELETE_TASK ? () {
                         Widget _deleteButton = TextButton(
                           child: const Text(
                             'Удалить',
                             style: TextStyle(color: Colors.redAccent),
                           ),
                           onPressed: () async {
                             var data = {'ip': UserState.temporaryIp, 'id': task.id};
                             _taskList!.removeAt(index);
                             _taskFilteredList!.removeAt(index);
                             Response response = await ServerSideApi.create(UserState.temporaryIp, 1).deleteTask(data);
                             if (response.body == 'task_deleted') {
                               _showMessage!.show(context, 7);
                               Navigator.pop(context);

                               var socketData = {
                                 'delete_task': true,
                                 'brigade': task.brigade,
                               };
                               _htmlWebSocketChannel!.sink.add(json.encode(socketData));

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
                       } : null,
                     ),
                   )),
                   DataCell(Center(
                     child: IconButton(
                       icon: Icon(Icons.info, color: PrivilegesConstants.GET_TASK_INFO ? Colors.black : Colors.grey),
                       onPressed: PrivilegesConstants.GET_TASK_INFO ? () {
                         showDialog(
                             context: context,
                             builder: (context) {
                               return SimpleDialog(
                                 contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                 children: [
                                   StatefulBuilder(
                                     builder: (context, setState){
                                       taskInfoState = setState;
                                       return  SizedBox(
                                           child: Column(
                                             children: [
                                               const Text('Информация о задании', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                               const SizedBox(height: 20),
                                               Row(
                                                 children: [
                                                   const Text('Задание: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                                   Text('${task.task}', style: TextStyle(color: Color(int.parse('0x' + task.color)), fontSize: 15))
                                                 ],
                                               ),
                                               const SizedBox(height: 10),
                                               Row(
                                                 children: [
                                                   const Text('Бригада: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                                   Text('${task.brigade}', style: const TextStyle(fontSize: 15))
                                                 ],
                                               ),
                                               const SizedBox(height: 10),
                                               Row(
                                                 children: [
                                                   const Text('Адрес: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                                   Text('${task.address}', style: const TextStyle(fontSize: 15))
                                                 ],
                                               ),
                                               const SizedBox(height: 10),
                                               Consumer<StopWatchProvider>(
                                                 builder: (context, viewModel, child){
                                                   return Row(
                                                     children: [
                                                       const Text('Время в пути: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                                       Text('${viewModel.taskModelList![index].onWayTime}', style: const TextStyle(fontSize: 15))
                                                     ],
                                                   );
                                                 },
                                               ),
                                               const SizedBox(height: 10),
                                               Consumer<StopWatchProvider>(
                                                   builder: (context, viewModel, child){
                                                     return Row(
                                                       children: [
                                                         const Text('Время работы: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                                         Text('${viewModel.taskModelList![index].workTime}', style: const TextStyle(fontSize: 15))
                                                       ],
                                                     );
                                                   }
                                               ),
                                               const SizedBox(height: 10),
                                               Consumer<StopWatchProvider>(
                                                 builder: (context, viewModel, child){
                                                   return Row(
                                                     children: [
                                                       const Text('Общее время задания: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                                       Text('${viewModel.taskModelList![index].allTaskTime}', style: const TextStyle(fontSize: 15))
                                                     ],
                                                   );
                                                 },
                                               ),
                                               const SizedBox(height: 10),
                                               Row(
                                                 children: [
                                                   const Text('Статус: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                                   Text('${task.status}', style: const TextStyle(fontSize: 15))
                                                 ],
                                               )
                                             ],
                                           )
                                       );
                                     },
                                   )
                                 ],
                               );
                             }
                         );
                       } : null,
                     ),
                   ))
                 ],
               );
             }),
           );
         },
       ),
    );
  }

  // Building tasks model widget
  Widget tasksModelWidget(){
    return ListView(
      children: List<ListTile>.generate(_tasksModel!.length, (index) {
        String? color = _tasksModel![index].color;
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
          title: Text('${_tasksModel![index].name}',
            style: TextStyle(color: textColor
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: PrivilegesConstants.DELETE_TASK_TEMPLATE ? Colors.black : Colors.grey),
            onPressed: PrivilegesConstants.DELETE_TASK_TEMPLATE ? () async {
              var data = {
                'name' : _tasksModel![index].name
              };

              _tasksModel!.removeAt(index);

              tasksDialogState!((){});

              await ServerSideApi.create(UserState.temporaryIp, 1).deleteTaskFromList(data);
            } : null,
          ),
        );
      }),
    );
  }

  // Building brigade model widget
  Widget brigadeModelWidget(){
    return ListView(
      children: List<ListTile>.generate(_brigadeModel!.length, (index) {
        return ListTile(
          title: Text(
              _brigadeModel![index].name
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: PrivilegesConstants.DELETE_BRIGADE ? Colors.black : Colors.grey),
            onPressed: PrivilegesConstants.DELETE_BRIGADE ? () async {
              var data = {
                'name' : _brigadeModel![index].name
              };

              _brigadeModel!.removeAt(index);

              brigadeDialogState!((){});
              dataTableState!((){});

              await ServerSideApi.create(UserState.temporaryIp, 1).deleteBrigadeFromList(data);
            } : null,
          ),
        );
      }),
    );
  }

  // Maps polyline
  Widget mapsPolyLine() {
    return maps!.getMaps(null, null, _locations, true);
  }

  // Maps builder
  StreamBuilder mapsBuilder() {
    return StreamBuilder(
      stream: _socketBroadcastStream,
      builder: (context, snapshot) {
        while(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
        }


        if(snapshot.connectionState == ConnectionState.active && snapshot.hasData){
          Map<String, dynamic>? cord = json.decode(snapshot.data);

          return maps!.getMaps(cord!['lat'], cord['long'], null, false);
        }else{
          return const Center(child: Text("Error"));
        }

      },
    );
  }

  // Requesting location data
  void requestLocationData(TaskServerModel task){
    if (task.status == 'Не выполнено') {
      var socketRequestData = {
        'brigade': task.brigade,
        'data': 'requesting_current_location'
      };

      _htmlWebSocketChannel!.sink.add(json.encode(socketRequestData));
    } else if (task.status == 'В пути') {
      var socketRequestData = {
        'brigade': task.brigade,
        'data': 'requesting_current_location'
      };

      _htmlWebSocketChannel!.sink.add(json.encode(socketRequestData));
    } else if (task.status == 'На месте') {
      var socketRequestData = {
        'brigade': task.brigade,
        'data': 'requesting_current_location'
      };

      _htmlWebSocketChannel!.sink.add(json.encode(socketRequestData));
    } else if(task.status == 'Завершено') {
      _locations!.clear();
      _locations = jsonDecode(task.cords);
    }
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
                        items: _tasksModel!.map<DropdownMenuItem<String>>((task) {
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
                        items: _brigadeModel!.map<DropdownMenuItem<String>>((brigade) {
                          return DropdownMenuItem(
                            value: brigade.name,
                            child: Text(brigade.name),
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
                                  );
                                }
                            );
                            if (pickedTime != null && pickedTime != selectedTime) {
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
                          for (var task in _tasksModel!) {
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
                        PrivilegesConstants.REGISTER_ADMIN ? Column(
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
                        ) : Container(),
                        PrivilegesConstants.REGISTER_BRIGADE ? Column(
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
                                  items: _brigadeModel!.map<DropdownMenuItem<String>>((brigade) {
                                    return DropdownMenuItem(
                                      value: brigade.name,
                                      child: Text(brigade.name),
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
                        ) : Container(),
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

          _adminsList!.add(User(username: name, password: password));
        } else if (response.body == 'user_already_exists') {
          _showMessage!.show(context, 2);
        }
      } on Exception catch (_) {}
    }
  }

  // Register brigade
  void _registerBrigade(List<TextEditingController> brigadeControllers, String? brigadeValue) async {
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

          _brigadesList!.add(User(username: name, password: password));
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
                        items: _tasksModel!.map<DropdownMenuItem<String>>((task) {
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
                        items: _brigadeModel!.map<DropdownMenuItem<String>>((brigade) {
                          return DropdownMenuItem(
                            value: brigade.name,
                            child: Text(brigade.name),
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
                                  );
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
                          for (var task in _tasksModel!) {
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
  void _addTask(List<String> options, List<TextEditingController> dateAndTime, bool isUrgent) async {
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

    Response response = await ServerSideApi.create(UserState.temporaryIp, 1).addTask(data);
    if (response.body == 'task_added') {
      _showMessage!.show(context, 7);
      Navigator.pop(context);

      if (brigade != null) {
        _notifyBrigades!.notify(address, brigade, 'Новая задача', date, time,
            isUrgent == true ? "Срочно" : "Не срочно");
      }

      var socketData = {
        'new_task': true,
        'brigade': brigade,
      };

      _htmlWebSocketChannel!.sink.add(json.encode(socketData));

      setState(() {});
    }
  }

  // Edit task to server
  void _editTask(TaskServerModel taskModel, List<String> options, List<TextEditingController> dateAndTime, bool isUrgent, String? status) async {
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

  // Backup app data
  void _backupData(String filename) async {
    var data = {
      'filename': filename,
    };

    if (filename == '') {
      _showMessage!.show(context, 3);
    } else {
      await ServerSideApi.create(UserState.temporaryIp, 1).backupData(data);

      _showMessage!.show(context, 7);
      Navigator.pop(context);
    }
  }

  // Restoring data
  void _restoreData() async {
    BackupFile backupFile = _backupFileList![_backupFilesIndex!];
    var data = {'filename': backupFile.filename};

    await ServerSideApi.create(UserState.temporaryIp, 1).restoreBackup(data);


    _showMessage!.show(context, 7);


    Navigator.pop(context);
  }

  // Change user password
  void _changeUserPassword(User user, String password) async {

    var data = {
      'name' : user.username,
      'password' : password
    };

    await ServerSideApi.create(UserState.temporaryIp, 1).changeUserPassword(data).whenComplete((){
      Navigator.pop(context);
      _showMessage!.show(context, 7);

      changeUserPassDialogState!((){
        user.password = password;
      });
    });
  }

  // Change brigade password
  void _changeBrigadePassword(User user, String password) async {


    var data = {
      'name' : user.username,
      'password' : password
    };

    await ServerSideApi.create(UserState.temporaryIp, 1).changeBrigadePassword(data).whenComplete((){
      Navigator.pop(context);

      _showMessage!.show(context, 7);

      changeBrigadePassDialogState!((){
        user.password = password;
      });
    });
  }

  // Show privileges dialog
  void _showPrivilegesDialog(User user){
    var name = user.username;

    _privileges!.getPrivilegesForCurrentUser(name).whenComplete((){
      showDialog(
        context: context,
        builder: (context){
          return StatefulBuilder(
            builder: (context, setState){
              return SimpleDialog(
                title: Text('Изменить привилегии $name'),
                contentPadding: const EdgeInsets.all(10),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                backgroundColor: Colors.white,
                children: [
                  Divider(thickness: 0.3.sp),
                  SizedBox(
                    width: 40.w,
                    child: SingleChildScrollView(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.ADD_NEW_TASK,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.ADD_NEW_TASK = value!;
                                      });
                                    },
                                  ),
                                  Text('Добавить задачу                  '),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: Colors.deepOrangeAccent,
                                  value: PrivilegesForCurrentUser.DELETE_TASK,
                                  onChanged: (value) {
                                    setState(() {
                                      PrivilegesForCurrentUser.DELETE_TASK = value!;
                                    });
                                  },
                                ),
                                  Text('Удалить задачу                      '),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.ASSIGN_TASK_TO_BRIGADE,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.ASSIGN_TASK_TO_BRIGADE = value!;
                                      });
                                    },
                                  ),
                                  Text('Присвоить задачу бригаду'),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.CHANGE_TASK_STATUS,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.CHANGE_TASK_STATUS = value!;
                                      });
                                    },
                                  ),
                                  Text('Изменить статус задачи     '),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.REGISTER_BRIGADE,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.REGISTER_BRIGADE = value!;
                                      });
                                    },
                                  ),
                                  Text('Зарегистрировать бригаду'),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.ADD_TASK_TEMPLATE,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.ADD_TASK_TEMPLATE = value!;
                                      });
                                    },
                                  ),
                                  Text('Добавить шаблон задачи  '),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.ADD_BRIGADE,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.ADD_BRIGADE = value!;
                                      });
                                    },
                                  ),
                                  Text('Добавить бригаду                  '),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.BACKUP_DATA,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.BACKUP_DATA = value!;
                                      });
                                    },
                                  ),
                                  Text('Сделать резервную копию '),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.CHANGE_PASSWORDS,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.CHANGE_PASSWORDS = value!;
                                      });
                                    },
                                  ),
                                  Text('Изменить пароль                  '),
                                ],
                              )
                            ],
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.EDIT_TASK,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.EDIT_TASK = value!;
                                      });
                                    },
                                  ),
                                  Text('Изменить задачу                                   '),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.GET_TASK_INFO,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.GET_TASK_INFO = value!;
                                      });
                                    },
                                  ),
                                  Text('Смотреть статус задачи                        '),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.REGISTER_ADMIN,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.REGISTER_ADMIN = value!;
                                      });
                                    },
                                  ),
                                  Text('Зарегистрировать админа                      '),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.SETTINGS,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.SETTINGS = value!;
                                      });
                                    },
                                  ),
                                  Text("Раздел 'Настройки'                                "),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.DELETE_TASK_TEMPLATE,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.DELETE_TASK_TEMPLATE = value!;
                                      });
                                    },
                                  ),
                                  Text('Удалить шаблон задачи                      '),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.DELETE_BRIGADE,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.DELETE_BRIGADE = value!;
                                      });
                                    },
                                  ),
                                  Text('Удалить бригаду                                    '),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.RESTORE_BACKUP,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.RESTORE_BACKUP = value!;
                                      });
                                    },
                                  ),
                                  Text('Восстановить из резервной копии        '),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.deepOrangeAccent,
                                    value: PrivilegesForCurrentUser.CHANGE_PRIVILEGES,
                                    onChanged: (value) {
                                      setState(() {
                                        PrivilegesForCurrentUser.CHANGE_PRIVILEGES = value!;
                                      });
                                    },
                                  ),
                                  Text('Изменить привилегии                         '),
                                ],
                              ),
                            ],
                          )
                        ],
                      )
                    ),
                  ),
                  SizedBox(height: 3.h),
                  FloatingActionButton.extended(
                    label: Text('Потдвердить'),
                    backgroundColor: Colors.deepOrangeAccent,
                    shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
                    onPressed: () => _submitPrivileges(name),
                  )
                ],
              );
            },
          );
        }
      );
    });
  }

  // Submitting privileges
  void _submitPrivileges(String name) async {
    var data = {
      'user' : name,

      'add_new_task' : PrivilegesForCurrentUser.ADD_NEW_TASK,
      'edit_task' : PrivilegesForCurrentUser.EDIT_TASK,
      'delete_task' : PrivilegesForCurrentUser.DELETE_TASK,
      'get_task_info' : PrivilegesForCurrentUser.GET_TASK_INFO,
      'assign_task_to_brigade' : PrivilegesForCurrentUser.ASSIGN_TASK_TO_BRIGADE,
      'change_task_status' : PrivilegesForCurrentUser.CHANGE_TASK_STATUS,
      'register_admin' : PrivilegesForCurrentUser.REGISTER_ADMIN,
      'register_brigade' : PrivilegesForCurrentUser.REGISTER_BRIGADE,
      'settings' : PrivilegesForCurrentUser.SETTINGS,
      'add_task_template' : PrivilegesForCurrentUser.ADD_TASK_TEMPLATE,
      'delete_task_template' : PrivilegesForCurrentUser.DELETE_TASK_TEMPLATE,
      'add_brigade' : PrivilegesForCurrentUser.ADD_BRIGADE,
      'delete_brigade' : PrivilegesForCurrentUser.DELETE_BRIGADE,
      'backup_data' : PrivilegesForCurrentUser.BACKUP_DATA,
      'restore_backup' : PrivilegesForCurrentUser.RESTORE_BACKUP,
      'change_passwords' : PrivilegesForCurrentUser.CHANGE_PASSWORDS,
      'change_privileges' : PrivilegesForCurrentUser.CHANGE_PRIVILEGES,
    };

    Response response = await ServerSideApi.create(UserState.temporaryIp, 1).submitPrivileges(data);
    if(response.body == 'SUCCEED'){
      Navigator.pop(context);
      Navigator.pop(context);
      _showMessage!.show(context, 7);

      PrivilegesConstants.clear();
    }
  }

  // Listener for socket
  void _listenSocket(TaskServerModel? task) {
    int index = _taskFilteredList!.indexOf(task!);

    _socketBroadcastStream!.listen((event) {
      Map<String, dynamic> eventMap = json.decode(event);
      String? taskId = eventMap['id'];


      if (taskId == task.id) {
        eventMap.forEach((key, value) {
          switch (key) {
            case 'status':

              task.status = eventMap['status'];
              dataTableState!(() {});

              if(task.status == 'В пути'){
                Provider.of<StopWatchProvider>(context, listen: false).startOnWayTimer(index);

                taskInfoState!((){});
              }else if(task.status == 'На месте'){
                Provider.of<StopWatchProvider>(context, listen: false).stopOnWayTimer(index);
                Provider.of<StopWatchProvider>(context, listen: false).startWorkTimer(index);

                taskInfoState!((){});
              }else if(task.status == 'Завершено'){
                Provider.of<StopWatchProvider>(context, listen: false).stopWorkTimer(index);
                Provider.of<StopWatchProvider>(context, listen: false).updateTime(index);

                taskInfoState!((){});

              }else if(task.status == 'Не завершено'){
                Provider.of<StopWatchProvider>(context, listen: false).stopOnWayTimer(index);
                Provider.of<StopWatchProvider>(context, listen: false).stopWorkTimer(index);

                Provider.of<StopWatchProvider>(context, listen: false).resetOnWayTimer(index);
                Provider.of<StopWatchProvider>(context, listen: false).resetWorkTimer(index);

                taskInfoState!((){});
              }
              break;
          }
        });
      }
    });
  }

  // Sorting algorithm
  void onSort(int columnIndex, bool ascending) {
    if (_taskFilteredList == null) {
      if(columnIndex == 0){
        _taskList!.sort((a,b) => compareString(ascending, a.task, b.task));
      }else if(columnIndex == 1){
        _taskList!.sort((a,b) => compareString(ascending, a.address, b.address));
      }else if(columnIndex == 2){
        _taskList!.sort((a,b) => compareString(ascending, a.brigade, b.brigade));
      }else if(columnIndex == 3){
        _taskList!.sort((a,b) => compareString(ascending, a.telephone, b.telephone));
      }else if(columnIndex == 4){
        _taskList!.sort((a,b) => compareString(ascending, a.date, b.date));
      }else if(columnIndex == 5){
        _taskList!.sort((a,b) => compareString(ascending, a.time, b.time));
      }else if(columnIndex == 6){
        _taskList!.sort((a,b) => compareString(ascending, a.isUrgent, b.isUrgent));
      }else if(columnIndex == 9){
        _taskList!.sort((a,b) => compareString(ascending, a.addedBy, b.addedBy));
      }else if(columnIndex == 10){
        _taskList!.sort((a,b) => compareString(ascending, a.status, b.status));
      }
    } else {
      if(columnIndex == 0){
        _taskFilteredList!.sort((a,b) => compareString(ascending, a.task, b.task));
      }else if(columnIndex == 1){
        _taskFilteredList!.sort((a,b) => compareString(ascending, a.address, b.address));
      }else if(columnIndex == 2){
        _taskFilteredList!.sort((a,b) => compareString(ascending, a.brigade, b.brigade));
      }else if(columnIndex == 3){
        _taskFilteredList!.sort((a,b) => compareString(ascending, a.telephone, b.telephone));
      }else if(columnIndex == 4){
        _taskFilteredList!.sort((a,b) => compareString(ascending, a.date, b.date));
      }else if(columnIndex == 5){
        _taskFilteredList!.sort((a,b) => compareString(ascending, a.time, b.time));
      }else if(columnIndex == 6){
        _taskFilteredList!.sort((a,b) => compareString(ascending, a.isUrgent, b.isUrgent));
      }else if(columnIndex == 9){
        _taskFilteredList!.sort((a,b) => compareString(ascending, a.addedBy, b.addedBy));
      }else if(columnIndex == 10){
        _taskFilteredList!.sort((a,b) => compareString(ascending, a.status, b.status));
      }
    }

    dataTableState!(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;
    });
  }

  // Compare string
  int compareString(bool ascending, String value1, String value2) {
    return ascending ? value1.compareTo(value2) : value2.compareTo(value1);
  }
}

