///Note file new_room_bloc_dart

import 'dart:io';
import 'package:rxdart/rxdart.dart';
import 'package:path/path.dart' as Path;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_booking_mobile_app/base/base_bloc.dart';
import 'package:flutter_booking_mobile_app/remote/remote_manager.dart';
import 'package:flutter_booking_mobile_app/base/flutter_show_toast.dart';
import 'package:flutter_booking_mobile_app/app/fire_base/fire_base_auth.dart';
import 'package:flutter_booking_mobile_app/remote/province_response/province_response.dart';

///NewRoomBloc extends BaseBloc
class NewRoomBloc extends BaseBloc {
  ///Initialization stream
  ///newRoomStateStream
  BehaviorSubject<UIState> newRoomStateStream = new BehaviorSubject();

  ///fileImageStream
  BehaviorSubject<File> fileImageStream = new BehaviorSubject();

  ///listProvinceStream
  BehaviorSubject<List<Province>> listProvinceStream = new BehaviorSubject();

  ///Clear stream
  @override
  void dispose() {
    newRoomStateStream.close();
    fileImageStream.close();
    listProvinceStream.close();
  }

  @override
  void init() {
    _getProvince();
  }

  ///Get image from library
  void getImageByGallery(ImagePicker picker) async {
    try {
      // ignore: deprecated_member_use
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      File _file = File(pickedFile.path);
      fileImageStream.add(_file);
    } catch (e) {
      FlutterToast().showToast(e.message);
    }
  }

  ///Get image from camera
  void getImageByCamera(ImagePicker picker) async {
    try {
      // ignore: deprecated_member_use
      final pickedFile = await picker.getImage(source: ImageSource.camera);
      File _file = File(pickedFile.path);
      fileImageStream.add(_file);
    } catch (e) {
      FlutterToast().showToast(e.message);
    }
  }

  ///Get list city
  void _getProvince() async {
    try {
      listProvinceStream.add([]);
      var tmp = await ManageRemote.provinceService.getAllProvince();
      listProvinceStream.add(tmp);
    } catch (e) {
      FlutterToast().showToast(e.message);
    }
  }

  ///Add room
  void addRoom(
    File file,
    String name,
    String startDay,
    String endDay,
    int adults,
    int child,
    int numberRoom,
    String address,
    String city,
    String desc,
    double price,
    double discount,
  ) async {
    newRoomStateStream.add(UIState.LOADING);
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference storageReference =
          storage.ref().child('${Path.basename(file.path)}}');
      await storageReference.putFile(file).then(
        (val) {
          val.ref.getDownloadURL().then((val) {
            FirAuth().createNewRoom(val, name, startDay, endDay, adults, child,
                address, city, desc, price, discount, numberRoom, () {
              newRoomStateStream.add(UIState.SUCCESS);
              FlutterToast().showToast("Success");
            }, (va) {
              newRoomStateStream.add(UIState.ERROR);
              FlutterToast().showToast(va);
            });
          });
        },
      );
    } catch (e) {
      newRoomStateStream.add(UIState.ERROR);
      FlutterToast().showToast(e.message);
    }
  }
}
