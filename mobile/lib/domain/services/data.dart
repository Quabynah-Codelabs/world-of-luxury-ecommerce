import 'dart:io';

import 'package:handyman/data/entities/category.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:meta/meta.dart';

/// Base data service
abstract class DataService {
  /// Get all [Artisan]
  Stream<List<BaseUser>> getArtisans({@required String category});

  /// Get an [Artisan] by [id]
  Stream<BaseUser> getArtisanById({@required String id});

  /// Get [Customer] by [id]
  Stream<BaseUser> getCustomerById({@required String id});

  /// Get all [ServiceCategory]
  Stream<List<ServiceCategory>> getCategories(
      {CategoryGroup categoryGroup = CategoryGroup.FEATURED});

  /// Get [ServiceCategory] by [id]
  Stream<ServiceCategory> getCategoryById({String id});

  /// Get [CustomerReview] for [Artisan]
  Stream<List<CustomerReview>> getReviewsForArtisan(String id);

  /// Get [CustomerReview] for [Customer] by [id]
  Stream<List<CustomerReview>> getReviewsByCustomer(String id);

  /// Delete a [CustomerReview] by [id]
  Future<void> deleteReviewById({String id, String customerId});

  /// Send a [CustomerReview]
  Future<void> sendReview({String message, String reviewer, String artisan});

  /// Get [Booking] for [Artisan] by [id]
  Stream<List<Booking>> getBookingsForArtisan(String id);

  /// Get [Booking] for [Customer] by [id]
  Stream<List<Booking>> getBookingsForCustomer(String id);

  /// Get [Booking] for [Artisan] & [Customer]
  Stream<List<Booking>> bookingsForCustomerAndArtisan(
      String customerId, String artisanId);

  /// Get [Gallery] images for [Artisan] by [userId]
  Stream<List<Gallery>> getPhotosForArtisan(String userId);

  /// Upload business [images]
  Future<void> uploadBusinessPhotos(String userId, List<File> images);

  /// Search for any [Artisan]
  Future<List<BaseUser>> searchFor({@required String value, String categoryId});

  /// Get [Conversation] between [sender] & [recipient]
  Stream<List<Conversation>> getConversation(
      {@required String sender, @required String recipient});

  /// Send [Conversation]
  Future<void> sendMessage({@required Conversation conversation});

  /// Update [BaseUser] profile information
  Future<void> updateUser(BaseUser user, {bool sync = true});

  /// Get [Booking] by [id]
  Stream<Booking> getBookingById({String id});

  /// Get [Booking] by [dueDate]
  Stream<List<Booking>> getBookingsByDueDate(
      {String dueDate, String providerId});

  /// Request [Booking] for an [Artisan]
  Future<void> requestBooking({
    Artisan artisan,
    String customer,
    String category,
    int hourOfDay,
    String description,
    File image,
  });
}
