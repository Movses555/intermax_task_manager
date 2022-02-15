import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShowMessage{

  static ShowMessage? instance;

  static ShowMessage init(){
    if(instance == null){
      instance = ShowMessage();
      return instance!;
    }else{
      return instance!;
    }
  }

  void show(BuildContext context, int requestCode){
    FToast fToast = FToast();
    fToast.init(context);
    late Container toast;

    switch (requestCode) {
      case 1:
        toast = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.greenAccent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check),
              SizedBox(
                width: 5,
              ),
              Text("Вы успешно зарегистрировались"),
            ],
          ),
        );
        break;
      case 2:
        toast = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.redAccent),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.error),
              SizedBox(
                width: 5
              ),
              Text("Аккаунт с таким именем уже существует"),
            ],
          ),
        );
        break;
      case 3:
        toast = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.redAccent),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.warning),
              SizedBox(
                width: 5,
              ),
              Text("Пожалуйста заполните все поля"),
            ],
          ),
        );
        break;
      case 4:
        toast = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.greenAccent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check),
              SizedBox(
                width: 5,
              ),
               Text("Добро пожаловать"),
            ],
          ),
        );
        break;
      case 5:
        toast = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.redAccent),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.warning),
              SizedBox(
                width: 5,
              ),
              Text("Неверное имя пользователя или пароль"),
            ],
          ),
        );
        break;
      case 6:
        toast = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.redAccent),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.warning),
              SizedBox(
                width: 5,
              ),
              Text("Неверный хост"),
            ],
          ),
        );
        break;
      case 7:
        toast = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.greenAccent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check),
              SizedBox(
                width: 5.0,
              ),
              Text("Успешно"),
            ],
          ),
        );
        break;
      case 8:
        toast = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.redAccent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.warning),
              SizedBox(
                width: 5.0,
              ),
              Text("Выберите цвет задания"),
            ],
          ),
        );
        break;
    }

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );
  }
}