class Doctor {
  final String username;
  final String password;
  final String fullName;
  final List<String> pdfPaths; // Paths to PDFs assigned to this doctor

  Doctor({
    required this.username,
    required this.password,
    required this.fullName,
    required this.pdfPaths,
  });
}

// Hardcoded doctor accounts
class DoctorAccounts {
  static final List<Doctor> doctors = [
    Doctor(
      username: 'dr.ahmed',
      password: '123456',
      fullName: 'د. أحمد محمد',
      pdfPaths: [], // Will be populated when doctor adds PDFs
    ),
    Doctor(
      username: 'dr.sara',
      password: '123456',
      fullName: 'د. سارة علي',
      pdfPaths: [],
    ),
    Doctor(
      username: 'dr.omar',
      password: '123456',
      fullName: 'د. عمر حسن',
      pdfPaths: [],
    ),
  ];

  static Doctor? authenticate(String username, String password) {
    try {
      return doctors.firstWhere(
        (doctor) => doctor.username == username && doctor.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  static Doctor? getDoctorByUsername(String username) {
    try {
      return doctors.firstWhere((doctor) => doctor.username == username);
    } catch (e) {
      return null;
    }
  }
}
