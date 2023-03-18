import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:my_map_app/failures/failure.dart';
import 'package:my_map_app/failures/firestore_failure.dart';

class PlacesService {
  final firestore = FirebaseFirestore.instance;

  Either<Failure, Stream<QuerySnapshot<Map<String, dynamic>>>> getPlaces() {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> placesStream =
          firestore.collection('locations').snapshots();

      return Right(placesStream);
    } catch (e) {
      return Left(FirestoreFailure(message: 'Error en firestore'));
    }
  }
}
