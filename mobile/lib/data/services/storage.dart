import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/service_locator.dart';
import 'package:handyman/core/utils.dart';
import 'package:handyman/domain/services/storage.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

@immutable
class StorageServiceImpl implements StorageService {
  final _bucket = sl.get<StorageReference>();
  final _firestore = sl.get<FirebaseFirestore>();

  StorageServiceImpl._();

  static StorageServiceImpl get instance => StorageServiceImpl._();

  final StreamController<StorageUploadResponse> _onStorageUploadResponse =
      StreamController.broadcast();

  @override
  Future<void> uploadFile(File file,
      {String path, String extension = ".pdf", bool isImageFile = true}) async {
    if (file == null) {
      _onStorageUploadResponse.sink.add(
        StorageUploadResponse(url: null, state: UploadProgressState.FAILED),
      );
      return;
    }
    path = path ??= Uuid().v4();
    final dir = await path_provider.getTemporaryDirectory();

    final targetPath =
        dir.absolute.path + "/$path${isImageFile ? ".jpg" : ".$extension"}";
    final filePath = file.absolute.path;
    print("File path => $filePath");
    print("Target path => $targetPath");
    final result = isImageFile
        ? await FlutterImageCompress.compressAndGetFile(
            filePath,
            targetPath,
            quality: 80, // Compress to 80% image quality
            minHeight: 512,
            minWidth: 512,
            format: filePath.endsWith("jpg") || filePath.endsWith("jpeg")
                ? CompressFormat.jpeg
                : CompressFormat.png,
          )
        : file;

    // Upload to storage bucket
    var events = _bucket.child(path).putFile(result).events;
    events.listen((event) async {
      print("Uploading => ${_bytesTransferred(event.snapshot)}");
      _onStorageUploadResponse.sink.add(
        StorageUploadResponse(
            url: null, state: UploadProgressState.IN_PROGRESS),
      );

      switch (event.type) {
        case StorageTaskEventType.success:
          try {
            final url = await event.snapshot.ref.getDownloadURL();
            _onStorageUploadResponse.sink.add(StorageUploadResponse(
              url: url,
              state: UploadProgressState.DONE,
              isInComplete: false,
            ));
            final prefs = await sl.getAsync<SharedPreferences>();
            var userId = prefs.getString(PrefsUtils.USER_ID);
            var userType = prefs.getString(PrefsUtils.USER_TYPE);

            await _firestore
                .collection(userType == kCustomerString
                    ? FirestoreUtils.kCustomerRef
                    : FirestoreUtils.kArtisanRef)
                .doc(userId)
                .set(
              {"avatar": url},
              SetOptions(merge: true),
            );
          } on PlatformException catch (e) {
            debugPrint("Upload error -> ${e.message}");
            _onStorageUploadResponse.sink.add(StorageUploadResponse(
                url: null, state: UploadProgressState.FAILED));
          }
          break;
        case StorageTaskEventType.resume:
        case StorageTaskEventType.progress:
          _onStorageUploadResponse.sink.add(StorageUploadResponse(
              url: null, state: UploadProgressState.IN_PROGRESS));
          break;
        case StorageTaskEventType.pause:
          _onStorageUploadResponse.sink.add(StorageUploadResponse(
              url: null, state: UploadProgressState.PAUSED));
          break;
        case StorageTaskEventType.failure:
          _onStorageUploadResponse.sink.add(StorageUploadResponse(
              url: null, state: UploadProgressState.FAILED));
          break;
      }
    });
  }

  // Get progress as a percentage
  double _bytesTransferred(StorageTaskSnapshot snapshot) =>
      (snapshot.bytesTransferred / snapshot.totalByteCount) * 100;

  @override
  Stream<StorageUploadResponse> get onStorageUploadResponse =>
      _onStorageUploadResponse.stream;

  @override
  void dispose() {
    _onStorageUploadResponse.close();
  }
}
