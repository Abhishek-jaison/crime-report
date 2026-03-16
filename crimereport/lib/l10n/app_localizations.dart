import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ml.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ml'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Crime Report'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get changeProfilePhoto;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @myCrimeReports.
  ///
  /// In en, this message translates to:
  /// **'My Crime Reports'**
  String get myCrimeReports;

  /// No description provided for @noReportsFound.
  ///
  /// In en, this message translates to:
  /// **'No reports found'**
  String get noReportsFound;

  /// No description provided for @reported.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get reported;

  /// No description provided for @reviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @crimeType.
  ///
  /// In en, this message translates to:
  /// **'Crime Type'**
  String get crimeType;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get recording;

  /// No description provided for @voiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice Note (Optional)'**
  String get voiceNote;

  /// No description provided for @holdToRecord.
  ///
  /// In en, this message translates to:
  /// **'Hold to record audio description'**
  String get holdToRecord;

  /// No description provided for @emergencyAlert.
  ///
  /// In en, this message translates to:
  /// **'Emergency Alert'**
  String get emergencyAlert;

  /// No description provided for @sosAlert.
  ///
  /// In en, this message translates to:
  /// **'SOS Alert'**
  String get sosAlert;

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @systemStatusActive.
  ///
  /// In en, this message translates to:
  /// **'System Status: Active'**
  String get systemStatusActive;

  /// No description provided for @activePatrols.
  ///
  /// In en, this message translates to:
  /// **'3 active patrols in your vicinity.'**
  String get activePatrols;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @complaint.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get complaint;

  /// No description provided for @heatMap.
  ///
  /// In en, this message translates to:
  /// **'Heat Map'**
  String get heatMap;

  /// No description provided for @crimeZones.
  ///
  /// In en, this message translates to:
  /// **'Crime Zones'**
  String get crimeZones;

  /// No description provided for @police.
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get police;

  /// No description provided for @stationFinder.
  ///
  /// In en, this message translates to:
  /// **'Station Finder'**
  String get stationFinder;

  /// No description provided for @guidelines.
  ///
  /// In en, this message translates to:
  /// **'Guidelines'**
  String get guidelines;

  /// No description provided for @legalInfo.
  ///
  /// In en, this message translates to:
  /// **'Legal Info'**
  String get legalInfo;

  /// No description provided for @recentReports.
  ///
  /// In en, this message translates to:
  /// **'Recent Reports'**
  String get recentReports;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @sosSent.
  ///
  /// In en, this message translates to:
  /// **'SOS Alert Sent to Server!'**
  String get sosSent;

  /// No description provided for @locationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location disabled'**
  String get locationDisabled;

  /// No description provided for @findingStation.
  ///
  /// In en, this message translates to:
  /// **'Finding nearest station...'**
  String get findingStation;

  /// No description provided for @swipeForSOS.
  ///
  /// In en, this message translates to:
  /// **'Swipe for Emergency SOS'**
  String get swipeForSOS;

  /// No description provided for @slideToSaveLives.
  ///
  /// In en, this message translates to:
  /// **'Slide to Save Lives'**
  String get slideToSaveLives;

  /// No description provided for @registerComplaint.
  ///
  /// In en, this message translates to:
  /// **'Register Complaint'**
  String get registerComplaint;

  /// No description provided for @incidentDetails.
  ///
  /// In en, this message translates to:
  /// **'INCIDENT DETAILS'**
  String get incidentDetails;

  /// No description provided for @detailedSummary.
  ///
  /// In en, this message translates to:
  /// **'Brief summary of incident'**
  String get detailedSummary;

  /// No description provided for @complaintTitle.
  ///
  /// In en, this message translates to:
  /// **'Complaint Title'**
  String get complaintTitle;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @detailedDescription.
  ///
  /// In en, this message translates to:
  /// **'DETAILED DESCRIPTION'**
  String get detailedDescription;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Please provide as much detail as possible, including date, time, and location...'**
  String get descriptionHint;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get addVideo;

  /// No description provided for @submitComplaint.
  ///
  /// In en, this message translates to:
  /// **'Submit Complaint'**
  String get submitComplaint;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get errorTitle;

  /// No description provided for @errorCrimeType.
  ///
  /// In en, this message translates to:
  /// **'Please select a crime type'**
  String get errorCrimeType;

  /// No description provided for @errorDescription.
  ///
  /// In en, this message translates to:
  /// **'Please provide a description'**
  String get errorDescription;

  /// No description provided for @errorNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in. Please login again.'**
  String get errorNotLoggedIn;

  /// No description provided for @successSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Complaint Submitted Successfully!'**
  String get successSubmitted;

  /// No description provided for @errorFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission Failed'**
  String get errorFailed;

  /// No description provided for @confirmAccuracy.
  ///
  /// In en, this message translates to:
  /// **'By submitting this report, you confirm that the information provided is accurate to the best of your knowledge. False reporting is a punishable offense.'**
  String get confirmAccuracy;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @loginDesc.
  ///
  /// In en, this message translates to:
  /// **'Log in to access your secure crime reporting dashboard.'**
  String get loginDesc;

  /// No description provided for @theft.
  ///
  /// In en, this message translates to:
  /// **'Theft'**
  String get theft;

  /// No description provided for @harassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get harassment;

  /// No description provided for @assault.
  ///
  /// In en, this message translates to:
  /// **'Assault'**
  String get assault;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @evidenceAndAttachments.
  ///
  /// In en, this message translates to:
  /// **'EVIDENCE & ATTACHMENTS'**
  String get evidenceAndAttachments;

  /// No description provided for @guidelinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety & Legal Guidelines'**
  String get guidelinesTitle;

  /// No description provided for @howToFileTitle.
  ///
  /// In en, this message translates to:
  /// **'How to File a Complaint'**
  String get howToFileTitle;

  /// No description provided for @howToFileStep1.
  ///
  /// In en, this message translates to:
  /// **'Open the app and tap \'Register Complaint\' from the home screen.'**
  String get howToFileStep1;

  /// No description provided for @howToFileStep2.
  ///
  /// In en, this message translates to:
  /// **'Provide a clear, factual title and a detailed description of the incident.'**
  String get howToFileStep2;

  /// No description provided for @howToFileStep3.
  ///
  /// In en, this message translates to:
  /// **'Select the appropriate crime type from the list (e.g., Theft, Assault).'**
  String get howToFileStep3;

  /// No description provided for @howToFileStep4.
  ///
  /// In en, this message translates to:
  /// **'Attach relevant photos or video evidence if available.'**
  String get howToFileStep4;

  /// No description provided for @howToFileStep5.
  ///
  /// In en, this message translates to:
  /// **'Submit the complaint — you will receive a case ID for tracking.'**
  String get howToFileStep5;

  /// No description provided for @howToFileStep6.
  ///
  /// In en, this message translates to:
  /// **'You can track your complaint status in the Profile section.'**
  String get howToFileStep6;

  /// No description provided for @sosFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Using the SOS Feature'**
  String get sosFeatureTitle;

  /// No description provided for @sosStep1.
  ///
  /// In en, this message translates to:
  /// **'In life-threatening situations, use the SOS slider on the home screen.'**
  String get sosStep1;

  /// No description provided for @sosStep2.
  ///
  /// In en, this message translates to:
  /// **'Slide fully to the right to trigger an emergency alert.'**
  String get sosStep2;

  /// No description provided for @sosStep3.
  ///
  /// In en, this message translates to:
  /// **'Your GPS location is automatically shared with authorities.'**
  String get sosStep3;

  /// No description provided for @sosStep4.
  ///
  /// In en, this message translates to:
  /// **'The SOS alert is dispatched to the nearest response team.'**
  String get sosStep4;

  /// No description provided for @sosStep5.
  ///
  /// In en, this message translates to:
  /// **'Do NOT misuse the SOS feature — false alarms are a punishable offence.'**
  String get sosStep5;

  /// No description provided for @sosStep6.
  ///
  /// In en, this message translates to:
  /// **'Ensure location permissions are enabled for SOS to work correctly.'**
  String get sosStep6;

  /// No description provided for @legalRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Legal Rights'**
  String get legalRightsTitle;

  /// No description provided for @legalRightsStep1.
  ///
  /// In en, this message translates to:
  /// **'You have the right to file a First Information Report (FIR) at any police station.'**
  String get legalRightsStep1;

  /// No description provided for @legalRightsStep2.
  ///
  /// In en, this message translates to:
  /// **'FIR registration cannot be refused by police officers — it is your right.'**
  String get legalRightsStep2;

  /// No description provided for @legalRightsStep3.
  ///
  /// In en, this message translates to:
  /// **'You may file a complaint online or in person at the nearest station.'**
  String get legalRightsStep3;

  /// No description provided for @legalRightsStep4.
  ///
  /// In en, this message translates to:
  /// **'You have the right to receive a copy of the FIR free of charge.'**
  String get legalRightsStep4;

  /// No description provided for @legalRightsStep5.
  ///
  /// In en, this message translates to:
  /// **'Witnesses and complainants are protected under Indian law from retaliation.'**
  String get legalRightsStep5;

  /// No description provided for @legalRightsStep6.
  ///
  /// In en, this message translates to:
  /// **'If police refuse to file an FIR, approach the Superintendent of Police.'**
  String get legalRightsStep6;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data Protection'**
  String get privacyTitle;

  /// No description provided for @privacyStep1.
  ///
  /// In en, this message translates to:
  /// **'Your personal data is securely stored and encrypted.'**
  String get privacyStep1;

  /// No description provided for @privacyStep2.
  ///
  /// In en, this message translates to:
  /// **'Your identity is not disclosed publicly. Only authorised officers see your details.'**
  String get privacyStep2;

  /// No description provided for @privacyStep3.
  ///
  /// In en, this message translates to:
  /// **'Evidence (photos/videos) you upload is stored on secure cloud servers.'**
  String get privacyStep3;

  /// No description provided for @privacyStep4.
  ///
  /// In en, this message translates to:
  /// **'You may request deletion of your account and associated data.'**
  String get privacyStep4;

  /// No description provided for @privacyStep5.
  ///
  /// In en, this message translates to:
  /// **'We do not share your information with third parties.'**
  String get privacyStep5;

  /// No description provided for @responsibleReportingTitle.
  ///
  /// In en, this message translates to:
  /// **'Responsible Reporting'**
  String get responsibleReportingTitle;

  /// No description provided for @responsibleReportingStep1.
  ///
  /// In en, this message translates to:
  /// **'Only report genuine incidents — false complaints are a criminal offence.'**
  String get responsibleReportingStep1;

  /// No description provided for @responsibleReportingStep2.
  ///
  /// In en, this message translates to:
  /// **'Provide accurate information to help authorities respond effectively.'**
  String get responsibleReportingStep2;

  /// No description provided for @responsibleReportingStep3.
  ///
  /// In en, this message translates to:
  /// **'Do not include personal opinions; stick to facts and observable events.'**
  String get responsibleReportingStep3;

  /// No description provided for @responsibleReportingStep4.
  ///
  /// In en, this message translates to:
  /// **'Filing false reports may result in legal action against the complainant.'**
  String get responsibleReportingStep4;

  /// No description provided for @responsibleReportingStep5.
  ///
  /// In en, this message translates to:
  /// **'Complaints can be withdrawn, but this does not erase the record.'**
  String get responsibleReportingStep5;

  /// No description provided for @emergencyContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Numbers'**
  String get emergencyContactsTitle;

  /// No description provided for @policeLabel.
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get policeLabel;

  /// No description provided for @ambulanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get ambulanceLabel;

  /// No description provided for @womenHelpline.
  ///
  /// In en, this message translates to:
  /// **'Women Helpline'**
  String get womenHelpline;

  /// No description provided for @emergencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergencyLabel;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login Successful'**
  String get loginSuccess;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No Email'**
  String get noEmail;

  /// No description provided for @profilePicUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated!'**
  String get profilePicUpdated;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ml'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ml':
      return AppLocalizationsMl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
