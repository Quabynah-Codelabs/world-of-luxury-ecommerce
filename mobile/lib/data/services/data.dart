import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/service_locator.dart';
import 'package:handyman/core/utils.dart';
import 'package:handyman/data/entities/artisan_model.dart';
import 'package:handyman/data/entities/category.dart';
import 'package:handyman/data/entities/customer_model.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/data/services/storage.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:handyman/domain/services/data.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

/// API service for application.
/// [LocalDatabase] is the source of data.
/// Data is fetched using streams so that upon update it will
/// automatically notify all listeners.
@immutable
class DataServiceImpl implements DataService {
  final _userDao = sl.get<LocalDatabase>().userDao;
  final _categoryDao = sl.get<LocalDatabase>().categoryDao;
  final _messageDao = sl.get<LocalDatabase>().messageDao;
  final _reviewDao = sl.get<LocalDatabase>().reviewDao;
  final _bookingDao = sl.get<LocalDatabase>().bookingDao;
  final _galleryDao = sl.get<LocalDatabase>().galleryDao;
  final _firestore = sl.get<FirebaseFirestore>();

  // Private constructor
  DataServiceImpl._();

  // Singleton
  static DataServiceImpl get instance => DataServiceImpl._();

  /// Get all [Artisan]s from data source
  @override
  Stream<List<BaseUser>> getArtisans({@required String category}) async* {
    // Sample data
    final data = await rootBundle.loadString("assets/sample_artisan.json");
    var decodedData = json.decode(data);

    List<dynamic> artisans = decodedData ??= [];

    List<BaseUser> models = artisans
        .map((e) => ArtisanModel(artisan: Artisan.fromJson(e)))
        .toList();
    models.forEach((element) {
      _userDao.saveProvider(element);
    });

    final localSource = _userDao
        .artisans(category)
        .watch()
        .map((event) => event.map((e) => ArtisanModel(artisan: e)).toList());
    yield* localSource;

    // Get snapshot
    final snapshots = _firestore
        .collection(FirestoreUtils.kArtisanRef)
        .snapshots(includeMetadataChanges: true);

    // Listen for changes in the snapshot
    snapshots.listen((event) {
      event.docs.forEach((element) async {
        if (element.exists) {
          final artisan = Artisan.fromJson(element.data());
          await _userDao.saveProvider(ArtisanModel(artisan: artisan));
        }
      });
    });
  }

  @override
  Stream<BaseUser> getArtisanById({@required String id}) async* {
    final localSource = _userDao
        .artisanById(id)
        .watchSingle()
        .map((artisan) => ArtisanModel(artisan: artisan));
    yield* localSource;

    var snapshots = _firestore
        .collection(FirestoreUtils.kArtisanRef)
        .doc(id)
        .snapshots(includeMetadataChanges: true);
    snapshots.listen((event) async {
      if (event.exists) {
        final artisanModel =
            ArtisanModel(artisan: Artisan.fromJson(event.data()));
        await _userDao.saveProvider(artisanModel);
      }
    });
  }

  @override
  Future<void> sendMessage({@required Conversation conversation}) async {
    await _messageDao.sendMessage(conversation);
    await _firestore
        .collection(FirestoreUtils.kMessagesRef)
        .doc(conversation.id)
        .set(conversation.toJson(), SetOptions(merge: true));
  }

  // FIXME: Messages only return sender's chat'
  @override
  Stream<List<Conversation>> getConversation(
      {@required String sender, @required String recipient}) async* {
    // Sample data
    final msgData =
        await rootBundle.loadString("assets/sample_conversation.json");
    var msgDecodedData = json.decode(msgData);

    List<dynamic> msgs = msgDecodedData ??= [];

    List<Conversation> conversationModels =
        msgs.map((e) => Conversation.fromJson(e)).toList();
    conversationModels.forEach((element) {
      _messageDao.sendMessage(element);
    });

    final localSource = _messageDao.conversationWithRecipient(
        sender: sender, recipient: recipient);
    yield* localSource;

    var snapshotsForRecipient = _firestore
        .collection(FirestoreUtils.kMessagesRef)
        .where("recipient", isEqualTo: sender)
        .where("author", isEqualTo: recipient)
        .orderBy("created_at", descending: true)
        .snapshots(includeMetadataChanges: true);

    var snapshotsForSender = _firestore
        .collection(FirestoreUtils.kMessagesRef)
        .where("author", isEqualTo: sender)
        .where("recipient", isEqualTo: recipient)
        .orderBy("created_at", descending: true)
        .snapshots(includeMetadataChanges: true);

    snapshotsForRecipient.listen((event) {
      event.docs.forEach((element) async {
        if (element.exists)
          await _messageDao.sendMessage(Conversation.fromJson(element.data()));
      });
    });

    snapshotsForSender.listen((event) {
      event.docs.forEach((element) async {
        if (element.exists)
          await _messageDao.sendMessage(Conversation.fromJson(element.data()));
      });
    });
  }

  /// Get [Customer] by [id]
  @override
  Stream<BaseUser> getCustomerById({@required String id}) async* {
    var localSource = _userDao
        .customerById(id)
        .watchSingle()
        .map((customer) => CustomerModel(customer: customer));

    yield* localSource;

    var snapshots = _firestore
        .collection(FirestoreUtils.kCustomerRef)
        .doc(id)
        .snapshots(includeMetadataChanges: true);
    snapshots.listen((event) async {
      if (event.exists)
        await _userDao.addCustomer(
          CustomerModel(
            customer: Customer.fromJson(event.data()),
          ),
        );
    });
  }

  /// Get all [ServiceCategory] from data source
  @override
  Stream<List<ServiceCategory>> getCategories({
    CategoryGroup categoryGroup = CategoryGroup.FEATURED,
  }) async* {
    // Decode categories from json array
    final categoryData =
        await rootBundle.loadString("assets/sample_categories.json");
    var decodedCategoryData = json.decode(categoryData);

    List<dynamic> categories = decodedCategoryData ??= [];

    // Convert each object to `ServiceCategory` object
    _categoryDao
        .addItems(categories.map((e) => ServiceCategory.fromJson(e)).toList());

    final localSource = _categoryDao
        .categoryByGroup(categoryGroup.index)
        .watch()
        .asBroadcastStream();
    yield* localSource;

    var snapshots = _firestore
        .collection(FirestoreUtils.kCategoriesRef)
        .where("group_name", isEqualTo: categoryGroup.index)
        .snapshots(includeMetadataChanges: true);

    snapshots.listen((event) {
      event.docs.forEach((element) async {
        if (element.exists)
          await _categoryDao
              .addSingleItem(ServiceCategory.fromJson(element.data()));
      });
    });
  }

  @override
  Stream<List<CustomerReview>> getReviewsForArtisan(String id) async* {
    final localSource = _reviewDao.reviewsForProvider(id).watch();
    yield* localSource;

    var snapshots = _firestore
        .collection(FirestoreUtils.kReviewsRef)
        .where("provider_id", isEqualTo: id)
        .snapshots(includeMetadataChanges: true);

    snapshots.listen((event) {
      event.docs.forEach((element) async {
        if (element.exists)
          await _reviewDao.addItem(CustomerReview.fromJson(element.data()));
      });
    });
  }

  @override
  Stream<List<Booking>> getBookingsForArtisan(String id) async* {
    // Decode bookings from json array
    final bookingsData =
        await rootBundle.loadString("assets/sample_bookings.json");
    var decodedBookingsData = json.decode(bookingsData);

    List<dynamic> _bookings = decodedBookingsData ??= [];

    // Save to database
    await _bookingDao
        .addItems(_bookings.map((e) => Booking.fromJson(e)).toList());

    final localSource = _bookingDao.bookingsForProvider(id).watch();
    yield* localSource;

    var snapshots = _firestore
        .collection(FirestoreUtils.kBookingsRef)
        .where("provider_id", isEqualTo: id)
        .snapshots(includeMetadataChanges: true);

    snapshots.listen((event) {
      event.docs.forEach((element) async {
        if (element.exists)
          await _bookingDao.addItem(Booking.fromJson(element.data()));
      });
    });
  }

  @override
  Stream<List<Booking>> getBookingsForCustomer(String id) async* {
    // Decode bookings from json array
    final bookingsData =
        await rootBundle.loadString("assets/sample_bookings.json");
    var decodedBookingsData = json.decode(bookingsData);

    List<dynamic> _bookings = decodedBookingsData ??= [];

    // Save to database
    await _bookingDao
        .addItems(_bookings.map((e) => Booking.fromJson(e)).toList());

    final localSource = _bookingDao.bookingsForCustomer(id).watch();
    yield* localSource;

    var snapshots = _firestore
        .collection(FirestoreUtils.kBookingsRef)
        .where("customer_id", isEqualTo: id)
        .snapshots(includeMetadataChanges: true);

    snapshots.listen((event) {
      event.docs.forEach((element) async {
        if (element.exists)
          await _bookingDao.addItem(Booking.fromJson(element.data()));
      });
    });
  }

  @override
  Stream<List<Booking>> bookingsForCustomerAndArtisan(
      String customerId, String providerId) async* {
    final localSource = _bookingDao
        .bookingsForCustomerAndProvider(customerId, providerId)
        .watch();
    yield* localSource;

    var snapshots = _firestore
        .collection(FirestoreUtils.kBookingsRef)
        .where("customer_id", isEqualTo: customerId)
        .where("provider_id", isEqualTo: providerId)
        .snapshots(includeMetadataChanges: true);

    snapshots.listen((event) {
      event.docs.forEach((element) async {
        if (element.exists)
          await _bookingDao.addItem(Booking.fromJson(element.data()));
      });
    });
  }

  @override
  Stream<List<Gallery>> getPhotosForArtisan(String userId) async* {
    // Sample data
    final data = await rootBundle.loadString("assets/sample_photos.json");
    var decodedData = json.decode(data);

    List<dynamic> photos = decodedData ??= [];

    List<Gallery> models = photos.map((e) => Gallery.fromJson(e)).toList();
    models.forEach((element) {
      _galleryDao.addPhoto(element);
    });

    final localSource = _galleryDao.photosForUser(userId).watch();
    yield* localSource;

    var snapshots = _firestore
        .collection(FirestoreUtils.kGalleryRef)
        .where("user_id", isEqualTo: userId)
        .snapshots(includeMetadataChanges: true);

    snapshots.listen((event) {
      event.docs.forEach((element) async {
        if (element.exists)
          await _galleryDao.addPhoto(Gallery.fromJson(element.data()));
      });
    });
  }

  /// Save [CustomerReview] in database
  @override
  Future<void> sendReview(
      {String message, String reviewer, String artisan}) async {
    final review = CustomerReview(
      id: Uuid().v4(),
      review: message,
      customerId: reviewer,
      providerId: artisan,
      createdAt: DateTime.now(),
    );
    await _reviewDao.addItem(review);
    await _firestore
        .collection(FirestoreUtils.kReviewsRef)
        .doc(review.id)
        .set(review.toJson(), SetOptions(merge: true));
  }

  /// Fetch [ServiceCategory] by [id]
  @override
  Stream<ServiceCategory> getCategoryById({String id}) async* {
    final localSource = _categoryDao.categoryById(id).watchSingle();
    yield* localSource;

    var snapshots = _firestore
        .collection(FirestoreUtils.kCategoriesRef)
        .doc(id)
        .snapshots(includeMetadataChanges: true);

    snapshots.listen((event) async {
      if (event.exists)
        await _galleryDao.addPhoto(Gallery.fromJson(event.data()));
    });
  }

  /// Performs a search for [Artisan]s in [Algolia]
  @override
  Future<List<BaseUser>> searchFor(
      {@required String value, String categoryId = kGeneralCategory}) async {
    try {
      // Perform search with index
      var query =
          algolia.instance.index(AlgoliaUtils.kArtisanIndex).search(value);

      // Get snapshot
      var snapshot = await query.getObjects();

      // Checking if has [AlgoliaQuerySnapshot]
      debugPrint('Hits count: ${snapshot.nbHits}');

      // Return transformed data from API
      return snapshot.empty
          ? _userDao.searchFor(value, categoryId).get()
          : snapshot.hits
              .map((e) => ArtisanModel(
                    artisan: Artisan.fromJson(e.data),
                  ))
              .toList();
    } on Exception {
      return Future.value(<BaseUser>[]);
    }
  }

  @override
  Future<void> updateUser(BaseUser user, {bool sync = true}) async {
    final token = await sl.get<FirebaseMessaging>().getToken();
    // compute(_createUpdateUserCompute, user);
    return _firestore
        .collection(user.isCustomer
            ? FirestoreUtils.kCustomerRef
            : FirestoreUtils.kArtisanRef)
        .doc(user.user.id)
        .set(user.user.copyWith(token: token).toJson(), SetOptions(merge: true));
  }

  /// FIXME:
  /// If you're running an application and need to access
  /// the binary messenger before `runApp()` has been called
  /// (for example, during plugin initialization), then you need
  /// to explicitly call the `WidgetsFlutterBinding.ensureInitialized()` first.
  // I/flutter ( 9833): If you're running a test, you can call the `TestWidgetsFlutterBinding.ensureInitialized()` as the first line in your test's `main()` method to initialize the binding.
  /*static Future<void> _createUpdateUserCompute(BaseUser user) async {
    try {
      await Firebase.initializeApp();
      final token = await sl.get<FirebaseMessaging>().getToken();
      debugPrint("Token => $token");

      if (user.isCustomer) {
        user = CustomerModel(customer: user.user.copyWith(token: token));
        // await _userDao.addCustomer(user);
      } else {
        user = ArtisanModel(artisan: user.user.copyWith(token: token));
        // await _userDao.saveProvider(user);
      }

      return sl
          .get<FirebaseFirestore>()
          .collection(user.isCustomer
              ? FirestoreUtils.kCustomerRef
              : FirestoreUtils.kArtisanRef)
          .doc(user.user.id)
          .set(user.user.toJson(), SetOptions(merge: true));
    } catch (e) {
      print(e);
      return null;
    }
  }*/

  @override
  Stream<Booking> getBookingById({String id}) async* {
    final localSource = _bookingDao.bookingById(id).watchSingle();
    yield* localSource;

    _firestore
        .collection(FirestoreUtils.kBookingsRef)
        .doc(id)
        .snapshots(includeMetadataChanges: true)
        .listen((event) async {
      if (event.exists) {
        final bookingItem = Booking.fromJson(event.data());
        await _bookingDao.addItem(bookingItem);
      }
    });
  }

  @override
  Stream<List<Booking>> getBookingsByDueDate(
      {String dueDate, String providerId}) async* {
    final localSource =
        _bookingDao.bookingByDueDate(dueDate, providerId).watch();
    yield* localSource;

    var snapshots = _firestore
        .collection(FirestoreUtils.kBookingsRef)
        .where("due_date", isLessThanOrEqualTo: int.parse(dueDate))
        .where("provider_id", isEqualTo: providerId)
        .snapshots(includeMetadataChanges: true);

    snapshots.listen((event) {
      event.docs.forEach((element) async {
        if (element.exists)
          await _bookingDao.addItem(Booking.fromJson(element.data()));
      });
    });
  }

  @override
  Future<void> deleteReviewById({String id, String customerId}) async {
    await _reviewDao.deleteReviewById(id, customerId);
    await _firestore.collection(FirestoreUtils.kReviewsRef).doc(id).delete();
  }

  @override
  Stream<List<CustomerReview>> getReviewsByCustomer(String id) async* {
    final localSource = _reviewDao.reviewsByCustomer(id).watch();
    yield* localSource;

    var snapshots = _firestore
        .collection(FirestoreUtils.kReviewsRef)
        .where("customer_id", isEqualTo: id)
        .snapshots(includeMetadataChanges: true);

    snapshots.listen((event) {
      event.docs.forEach((element) async {
        if (element.exists)
          await _reviewDao.addItem(CustomerReview.fromJson(element.data()));
      });
    });
  }

  @override
  Future<void> requestBooking({
    Artisan artisan,
    String customer,
    String category,
    int hourOfDay,
    String description,
    File image,
  }) async {
    final booking = Booking(
      id: Uuid().v4(),
      customerId: customer,
      providerId: artisan?.id,
      category: category,
      reason: description,
      value: artisan?.startPrice,
      progress: 0.0,
    );
    final storageService = StorageServiceImpl.instance;
    await storageService.uploadFile(image, path: booking.id);
    storageService.onStorageUploadResponse.listen((event) async {
      if (!event.isInComplete) {
        await _bookingDao.addItem(booking.copyWith(imageUrl: event.url));
        await _firestore
            .collection(FirestoreUtils.kBookingsRef)
            .doc(booking.id)
            .set(booking.toJson(), SetOptions(merge: true));
      }
    });
  }

  @override
  Future<void> uploadBusinessPhotos(String userId, List<File> images) async {
    final storageService = StorageServiceImpl.instance;
    images.forEach((image) async {
      final id = Uuid().v4();
      await storageService.uploadFile(image, path: id);
      storageService.onStorageUploadResponse.listen((event) async {
        if (!event.isInComplete) {
          await _firestore.collection(FirestoreUtils.kGalleryRef).doc(id).set(
              Gallery(
                id: id,
                userId: userId,
                imageUrl: event.url,
              ).toJson(),
              SetOptions(merge: true));
        }
      });
    });
  }
}
