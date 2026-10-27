/// App-wide configuration. Change [allowedEmailDomains] if your ALU
/// addresses use a different domain.
class AppConfig {
  static const appName = 'CampusFix';
  static const allowedEmailDomains = ['alustudent.com', 'alueducation.com'];

  static const campusLocations = [
    'Classroom block',
    'Library',
    'Cafeteria',
    'Student residence',
    'Sports ground',
    'Admin block',
    'Parking / gate',
    'Other',
  ];
}