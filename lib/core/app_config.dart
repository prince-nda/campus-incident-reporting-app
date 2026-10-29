/// App-wide configuration. Change [allowedEmailDomains] if your ALU
/// addresses use a different domain.
class AppConfig {
  static const appName = 'CampusFix';
  static const allowedEmailDomains = ['alustudent.com', 'alueducation.com'];

  static const useFirebaseStorage = false;
  static const maxInlinePhotoBytes = 600 * 1024;

  static const campusLocations = [
    'Leadership Center',
    'Social Commons',
    'Enterprise Commons',
    'Library',
    'Cafeteria',
    'Student residence',
    'Sports ground',
    'Admin block',
    'Parking / gate',
    'Other',
  ];
}