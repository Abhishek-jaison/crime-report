// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Crime Report';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get profile => 'Profile';

  @override
  String get home => 'Home';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get changeProfilePhoto => 'Change Profile Photo';

  @override
  String get logout => 'Logout';

  @override
  String get myCrimeReports => 'My Crime Reports';

  @override
  String get noReportsFound => 'No reports found';

  @override
  String get reported => 'Reported';

  @override
  String get reviewed => 'Reviewed';

  @override
  String get pending => 'Pending';

  @override
  String get resolved => 'Resolved';

  @override
  String get description => 'Description';

  @override
  String get title => 'Title';

  @override
  String get crimeType => 'Crime Type';

  @override
  String get submit => 'Submit';

  @override
  String get recording => 'Recording...';

  @override
  String get voiceNote => 'Voice Note (Optional)';

  @override
  String get holdToRecord => 'Hold to record audio description';

  @override
  String get emergencyAlert => 'Emergency Alert';

  @override
  String get sosAlert => 'SOS Alert';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get welcomeBack => 'Welcome back,';

  @override
  String get systemStatusActive => 'System Status: Active';

  @override
  String get activePatrols => '3 active patrols in your vicinity.';

  @override
  String get register => 'Register';

  @override
  String get complaint => 'Complaint';

  @override
  String get heatMap => 'Heat Map';

  @override
  String get crimeZones => 'Crime Zones';

  @override
  String get police => 'Police';

  @override
  String get stationFinder => 'Station Finder';

  @override
  String get guidelines => 'Guidelines';

  @override
  String get legalInfo => 'Legal Info';

  @override
  String get recentReports => 'Recent Reports';

  @override
  String get seeAll => 'See All';

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String get sosSent => 'SOS Alert Sent to Server!';

  @override
  String get locationDisabled => 'Location disabled';

  @override
  String get findingStation => 'Finding nearest station...';

  @override
  String get swipeForSOS => 'Swipe for Emergency SOS';

  @override
  String get slideToSaveLives => 'Slide to Save Lives';

  @override
  String get registerComplaint => 'Register Complaint';

  @override
  String get incidentDetails => 'INCIDENT DETAILS';

  @override
  String get detailedSummary => 'Brief summary of incident';

  @override
  String get complaintTitle => 'Complaint Title';

  @override
  String get selectCategory => 'Select category';

  @override
  String get detailedDescription => 'DETAILED DESCRIPTION';

  @override
  String get descriptionHint =>
      'Please provide as much detail as possible, including date, time, and location...';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get addVideo => 'Add Video';

  @override
  String get submitComplaint => 'Submit Complaint';

  @override
  String get errorTitle => 'Please enter a title';

  @override
  String get errorCrimeType => 'Please select a crime type';

  @override
  String get errorDescription => 'Please provide a description';

  @override
  String get errorNotLoggedIn => 'User not logged in. Please login again.';

  @override
  String get successSubmitted => 'Complaint Submitted Successfully!';

  @override
  String get errorFailed => 'Submission Failed';

  @override
  String get confirmAccuracy =>
      'By submitting this report, you confirm that the information provided is accurate to the best of your knowledge. False reporting is a punishable offense.';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get loginDesc =>
      'Log in to access your secure crime reporting dashboard.';

  @override
  String get theft => 'Theft';

  @override
  String get harassment => 'Harassment';

  @override
  String get assault => 'Assault';

  @override
  String get other => 'Other';

  @override
  String get evidenceAndAttachments => 'EVIDENCE & ATTACHMENTS';

  @override
  String get guidelinesTitle => 'Safety & Legal Guidelines';

  @override
  String get howToFileTitle => 'How to File a Complaint';

  @override
  String get howToFileStep1 =>
      'Open the app and tap \'Register Complaint\' from the home screen.';

  @override
  String get howToFileStep2 =>
      'Provide a clear, factual title and a detailed description of the incident.';

  @override
  String get howToFileStep3 =>
      'Select the appropriate crime type from the list (e.g., Theft, Assault).';

  @override
  String get howToFileStep4 =>
      'Attach relevant photos or video evidence if available.';

  @override
  String get howToFileStep5 =>
      'Submit the complaint — you will receive a case ID for tracking.';

  @override
  String get howToFileStep6 =>
      'You can track your complaint status in the Profile section.';

  @override
  String get sosFeatureTitle => 'Using the SOS Feature';

  @override
  String get sosStep1 =>
      'In life-threatening situations, use the SOS slider on the home screen.';

  @override
  String get sosStep2 =>
      'Slide fully to the right to trigger an emergency alert.';

  @override
  String get sosStep3 =>
      'Your GPS location is automatically shared with authorities.';

  @override
  String get sosStep4 =>
      'The SOS alert is dispatched to the nearest response team.';

  @override
  String get sosStep5 =>
      'Do NOT misuse the SOS feature — false alarms are a punishable offence.';

  @override
  String get sosStep6 =>
      'Ensure location permissions are enabled for SOS to work correctly.';

  @override
  String get legalRightsTitle => 'Your Legal Rights';

  @override
  String get legalRightsStep1 =>
      'You have the right to file a First Information Report (FIR) at any police station.';

  @override
  String get legalRightsStep2 =>
      'FIR registration cannot be refused by police officers — it is your right.';

  @override
  String get legalRightsStep3 =>
      'You may file a complaint online or in person at the nearest station.';

  @override
  String get legalRightsStep4 =>
      'You have the right to receive a copy of the FIR free of charge.';

  @override
  String get legalRightsStep5 =>
      'Witnesses and complainants are protected under Indian law from retaliation.';

  @override
  String get legalRightsStep6 =>
      'If police refuse to file an FIR, approach the Superintendent of Police.';

  @override
  String get privacyTitle => 'Privacy & Data Protection';

  @override
  String get privacyStep1 =>
      'Your personal data is securely stored and encrypted.';

  @override
  String get privacyStep2 =>
      'Your identity is not disclosed publicly. Only authorised officers see your details.';

  @override
  String get privacyStep3 =>
      'Evidence (photos/videos) you upload is stored on secure cloud servers.';

  @override
  String get privacyStep4 =>
      'You may request deletion of your account and associated data.';

  @override
  String get privacyStep5 =>
      'We do not share your information with third parties.';

  @override
  String get responsibleReportingTitle => 'Responsible Reporting';

  @override
  String get responsibleReportingStep1 =>
      'Only report genuine incidents — false complaints are a criminal offence.';

  @override
  String get responsibleReportingStep2 =>
      'Provide accurate information to help authorities respond effectively.';

  @override
  String get responsibleReportingStep3 =>
      'Do not include personal opinions; stick to facts and observable events.';

  @override
  String get responsibleReportingStep4 =>
      'Filing false reports may result in legal action against the complainant.';

  @override
  String get responsibleReportingStep5 =>
      'Complaints can be withdrawn, but this does not erase the record.';

  @override
  String get emergencyContactsTitle => 'Emergency Contact Numbers';

  @override
  String get policeLabel => 'Police';

  @override
  String get ambulanceLabel => 'Ambulance';

  @override
  String get womenHelpline => 'Women Helpline';

  @override
  String get emergencyLabel => 'Emergency';

  @override
  String get loginSuccess => 'Login Successful';

  @override
  String get loading => 'Loading...';

  @override
  String get user => 'User';

  @override
  String get noEmail => 'No Email';

  @override
  String get profilePicUpdated => 'Profile picture updated!';

  @override
  String get uploadFailed => 'Upload failed';

  @override
  String get unknownDate => 'Unknown date';

  @override
  String get jan => 'Jan';

  @override
  String get feb => 'Feb';

  @override
  String get mar => 'Mar';

  @override
  String get apr => 'Apr';

  @override
  String get may => 'May';

  @override
  String get jun => 'Jun';

  @override
  String get jul => 'Jul';

  @override
  String get aug => 'Aug';

  @override
  String get sep => 'Sep';

  @override
  String get oct => 'Oct';

  @override
  String get nov => 'Nov';

  @override
  String get dec => 'Dec';

  @override
  String get suspectDetails => 'Suspect Details (Optional)';

  @override
  String get suspectDetailsHint => 'Any known information about the suspect...';
}
