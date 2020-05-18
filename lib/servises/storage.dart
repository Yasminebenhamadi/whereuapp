import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:whereuapp/classes/SharableUserInfo.dart';
import 'package:path_provider/path_provider.dart';

class StorageService{
  Directory _tempDirectory;
  Future<void> setTempDir () async {
    _tempDirectory = await getTemporaryDirectory();
  }

  Directory get tempDirectory => _tempDirectory;

  Future<File> pickPhoto () async {
    File file  = await FilePicker.getFile(type: FileType.image);
    return file ;
  }
  Future<void> uploadPhoto(File file , String path) async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(path);
    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    print('photo url'+url);
  }
  Future<void> downloadPhoto(String path) async {
    StorageReference pictureRef = FirebaseStorage.instance.ref().child(path);
    setTempDir().then((_){
      final File tempImageFile = File('${_tempDirectory.path}/$path');
      tempImageFile.createSync(recursive: true);
      final StorageFileDownloadTask downloadTask = pictureRef.writeToFile(tempImageFile);
      downloadTask.future.then((snapshot) =>  print('Image downloaded')) ;
    });
  }
  Future<FileImage> photoMessage (String photoPath) async {
    await downloadPhoto(photoPath) ;
    return FileImage(File(('${tempDirectory.path}/'+photoPath)));
  }
  Future<ImageProvider> usersPhoto (bool photo,String photoPath,Gender gender) async {
    if(photo){
      try{
         await downloadPhoto(photoPath) ;
         return FileImage(File(('${tempDirectory.path}/'+photoPath)));
      }
      catch(e){
        return null;
      }
    }
    else{
      if(gender == Gender.Female)
        return AssetImage('assets/images/profileFemale.png');
      else
        return AssetImage('assets/images/profileMale.gif');
    }
  }
  Future<ImageProvider> groupsImage (bool photoExists,String groupPhoto) async {
    if(photoExists){
      try{
        return await downloadPhoto(groupPhoto).then((_){
          return FileImage(File(('${tempDirectory.path}/$groupPhoto')));
        });
      }
      catch(e){
        return null;
      }
    }
    else{
      return AssetImage('assets/images/groupe.png');
    }
  }
}