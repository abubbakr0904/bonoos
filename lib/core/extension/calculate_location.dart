// import 'dart:math';
//
// extension DistanceCalculator on Point {
//   double calculateDistanceTo(Point otherPoint) {
//     const double earthRadiusKm = 6371.0;
//
//     double lat1 = degreesToRadians(latitude);
//     double lon1 = degreesToRadians(longitude);
//     double lat2 = degreesToRadians(otherPoint.latitude);
//     double lon2 = degreesToRadians(otherPoint.longitude);
//
//     double dLat = lat2 - lat1;
//     double dLon = lon2 - lon1;
//
//     double a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(lat1) * cos(lat2) *
//             sin(dLon / 2) * sin(dLon / 2);
//     double c = 2 * atan2(sqrt(a), sqrt(1 - a));
//
//     return earthRadiusKm * c;
//   }
//
//   double degreesToRadians(double degrees) {
//     return degrees * pi / 180.0;
//   }
// }
