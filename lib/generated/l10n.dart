// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Total Groups`
  String get total_groups {
    return Intl.message(
      'Total Groups',
      name: 'total_groups',
      desc: '',
      args: [],
    );
  }

  /// `Total Students`
  String get total_students {
    return Intl.message(
      'Total Students',
      name: 'total_students',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get auto {
    return Intl.message(
      'Auto',
      name: 'auto',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Enter login`
  String get enter_login {
    return Intl.message(
      'Enter login',
      name: 'enter_login',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: 'Label for password field',
      args: [],
    );
  }

  /// `Enter`
  String get enter {
    return Intl.message(
      'Enter',
      name: 'enter',
      desc: '',
      args: [],
    );
  }

  /// `Lesson Schedule`
  String get lesson_schedule {
    return Intl.message(
      'Lesson Schedule',
      name: 'lesson_schedule',
      desc: '',
      args: [],
    );
  }

  /// `No lessons :)`
  String get no_lessons {
    return Intl.message(
      'No lessons :)',
      name: 'no_lessons',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred:`
  String get error_occurred {
    return Intl.message(
      'An error occurred:',
      name: 'error_occurred',
      desc: '',
      args: [],
    );
  }

  /// `January`
  String get january {
    return Intl.message(
      'January',
      name: 'january',
      desc: '',
      args: [],
    );
  }

  /// `February`
  String get february {
    return Intl.message(
      'February',
      name: 'february',
      desc: '',
      args: [],
    );
  }

  /// `March`
  String get march {
    return Intl.message(
      'March',
      name: 'march',
      desc: '',
      args: [],
    );
  }

  /// `April`
  String get april {
    return Intl.message(
      'April',
      name: 'april',
      desc: '',
      args: [],
    );
  }

  /// `May`
  String get may {
    return Intl.message(
      'May',
      name: 'may',
      desc: '',
      args: [],
    );
  }

  /// `June`
  String get june {
    return Intl.message(
      'June',
      name: 'june',
      desc: '',
      args: [],
    );
  }

  /// `July`
  String get july {
    return Intl.message(
      'July',
      name: 'july',
      desc: '',
      args: [],
    );
  }

  /// `August`
  String get august {
    return Intl.message(
      'August',
      name: 'august',
      desc: '',
      args: [],
    );
  }

  /// `September`
  String get september {
    return Intl.message(
      'September',
      name: 'september',
      desc: '',
      args: [],
    );
  }

  /// `Enter password`
  String get enter_password {
    return Intl.message(
      'Enter password',
      name: 'enter_password',
      desc: '',
      args: [],
    );
  }

  /// `October`
  String get october {
    return Intl.message(
      'October',
      name: 'october',
      desc: '',
      args: [],
    );
  }

  /// `November`
  String get november {
    return Intl.message(
      'November',
      name: 'november',
      desc: '',
      args: [],
    );
  }

  /// `December`
  String get december {
    return Intl.message(
      'December',
      name: 'december',
      desc: '',
      args: [],
    );
  }

  /// `Control Table`
  String get control_table_title {
    return Intl.message(
      'Control Table',
      name: 'control_table_title',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error_message {
    return Intl.message(
      'Error',
      name: 'error_message',
      desc: '',
      args: [],
    );
  }

  /// `Groups`
  String get group_title {
    return Intl.message(
      'Groups',
      name: 'group_title',
      desc: '',
      args: [],
    );
  }

  /// `No groups`
  String get no_groups {
    return Intl.message(
      'No groups',
      name: 'no_groups',
      desc: '',
      args: [],
    );
  }

  /// `Monday`
  String get monday {
    return Intl.message(
      'Monday',
      name: 'monday',
      desc: '',
      args: [],
    );
  }

  /// `Tuesday`
  String get tuesday {
    return Intl.message(
      'Tuesday',
      name: 'tuesday',
      desc: '',
      args: [],
    );
  }

  /// `Wednesday`
  String get wednesday {
    return Intl.message(
      'Wednesday',
      name: 'wednesday',
      desc: '',
      args: [],
    );
  }

  /// `Not Submitted`
  String get status_not_submitted {
    return Intl.message(
      'Not Submitted',
      name: 'status_not_submitted',
      desc: '',
      args: [],
    );
  }

  /// `Thursday`
  String get thursday {
    return Intl.message(
      'Thursday',
      name: 'thursday',
      desc: '',
      args: [],
    );
  }

  /// `Friday`
  String get friday {
    return Intl.message(
      'Friday',
      name: 'friday',
      desc: '',
      args: [],
    );
  }

  /// `Saturday`
  String get saturday {
    return Intl.message(
      'Saturday',
      name: 'saturday',
      desc: '',
      args: [],
    );
  }

  /// `Sunday`
  String get sunday {
    return Intl.message(
      'Sunday',
      name: 'sunday',
      desc: '',
      args: [],
    );
  }

  /// `Attendance`
  String get attendance {
    return Intl.message(
      'Attendance',
      name: 'attendance',
      desc: '',
      args: [],
    );
  }

  /// `Students`
  String get students {
    return Intl.message(
      'Students',
      name: 'students',
      desc: '',
      args: [],
    );
  }

  /// `Tasks`
  String get tasks {
    return Intl.message(
      'Tasks',
      name: 'tasks',
      desc: '',
      args: [],
    );
  }

  /// `Present`
  String get present {
    return Intl.message(
      'Present',
      name: 'present',
      desc: '',
      args: [],
    );
  }

  /// `Late`
  String get late {
    return Intl.message(
      'Late',
      name: 'late',
      desc: '',
      args: [],
    );
  }

  /// `Absent`
  String get absent {
    return Intl.message(
      'Absent',
      name: 'absent',
      desc: '',
      args: [],
    );
  }

  /// `Comment`
  String get comment {
    return Intl.message(
      'Comment',
      name: 'comment',
      desc: '',
      args: [],
    );
  }

  /// `No students`
  String get no_students {
    return Intl.message(
      'No students',
      name: 'no_students',
      desc: '',
      args: [],
    );
  }

  /// `Came`
  String get came {
    return Intl.message(
      'Came',
      name: 'came',
      desc: '',
      args: [],
    );
  }

  /// `January`
  String get month_january {
    return Intl.message(
      'January',
      name: 'month_january',
      desc: '',
      args: [],
    );
  }

  /// `February`
  String get month_february {
    return Intl.message(
      'February',
      name: 'month_february',
      desc: '',
      args: [],
    );
  }

  /// `March`
  String get month_march {
    return Intl.message(
      'March',
      name: 'month_march',
      desc: '',
      args: [],
    );
  }

  /// `April`
  String get month_april {
    return Intl.message(
      'April',
      name: 'month_april',
      desc: '',
      args: [],
    );
  }

  /// `May`
  String get month_may {
    return Intl.message(
      'May',
      name: 'month_may',
      desc: '',
      args: [],
    );
  }

  /// `June`
  String get month_june {
    return Intl.message(
      'June',
      name: 'month_june',
      desc: '',
      args: [],
    );
  }

  /// `July`
  String get month_july {
    return Intl.message(
      'July',
      name: 'month_july',
      desc: '',
      args: [],
    );
  }

  /// `August`
  String get month_august {
    return Intl.message(
      'August',
      name: 'month_august',
      desc: '',
      args: [],
    );
  }

  /// `September`
  String get month_september {
    return Intl.message(
      'September',
      name: 'month_september',
      desc: '',
      args: [],
    );
  }

  /// `October`
  String get month_october {
    return Intl.message(
      'October',
      name: 'month_october',
      desc: '',
      args: [],
    );
  }

  /// `November`
  String get month_november {
    return Intl.message(
      'November',
      name: 'month_november',
      desc: '',
      args: [],
    );
  }

  /// `December`
  String get month_december {
    return Intl.message(
      'December',
      name: 'month_december',
      desc: '',
      args: [],
    );
  }

  /// `Reload`
  String get reload {
    return Intl.message(
      'Reload',
      name: 'reload',
      desc: '',
      args: [],
    );
  }

  /// `No students found`
  String get no_students_found {
    return Intl.message(
      'No students found',
      name: 'no_students_found',
      desc: '',
      args: [],
    );
  }

  /// `No tasks yet :)`
  String get no_tasks_yet {
    return Intl.message(
      'No tasks yet :)',
      name: 'no_tasks_yet',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get register {
    return Intl.message(
      'Sign up',
      name: 'register',
      desc: 'Button label for creating a new account',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `Go`
  String get go {
    return Intl.message(
      'Go',
      name: 'go',
      desc: '',
      args: [],
    );
  }

  /// `No Internet`
  String get noInternet {
    return Intl.message(
      'No Internet',
      name: 'noInternet',
      desc: '',
      args: [],
    );
  }

  /// `Internet Connected`
  String get internetConnected {
    return Intl.message(
      'Internet Connected',
      name: 'internetConnected',
      desc: '',
      args: [],
    );
  }

  /// `Exit App`
  String get exitTitle {
    return Intl.message(
      'Exit App',
      name: 'exitTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to exit?`
  String get exitMessage {
    return Intl.message(
      'Are you sure you want to exit?',
      name: 'exitMessage',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exitConfirm {
    return Intl.message(
      'Exit',
      name: 'exitConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get exitCancel {
    return Intl.message(
      'Cancel',
      name: 'exitCancel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Exit`
  String get exitDoubleCheckTitle {
    return Intl.message(
      'Confirm Exit',
      name: 'exitDoubleCheckTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you really sure you want to exit?`
  String get exitDoubleCheckMessage {
    return Intl.message(
      'Are you really sure you want to exit?',
      name: 'exitDoubleCheckMessage',
      desc: '',
      args: [],
    );
  }

  /// `Enter login`
  String get enterLogin {
    return Intl.message(
      'Enter login',
      name: 'enterLogin',
      desc: 'Hint text for login/username input field',
      args: [],
    );
  }

  /// `Front Side`
  String get frontSide {
    return Intl.message(
      'Front Side',
      name: 'frontSide',
      desc: '',
      args: [],
    );
  }

  /// `Rear Side`
  String get rearSide {
    return Intl.message(
      'Rear Side',
      name: 'rearSide',
      desc: '',
      args: [],
    );
  }

  /// `Driver's License`
  String get driverLicense {
    return Intl.message(
      'Driver\'s License',
      name: 'driverLicense',
      desc: '',
      args: [],
    );
  }

  /// `Technical Passport`
  String get techPassport {
    return Intl.message(
      'Technical Passport',
      name: 'techPassport',
      desc: '',
      args: [],
    );
  }

  /// `Trailer`
  String get trailer {
    return Intl.message(
      'Trailer',
      name: 'trailer',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Balance and Rating`
  String get balanceAndRating {
    return Intl.message(
      'Balance and Rating',
      name: 'balanceAndRating',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Additional`
  String get additional {
    return Intl.message(
      'Additional',
      name: 'additional',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `License Agreement`
  String get licenseAgreement {
    return Intl.message(
      'License Agreement',
      name: 'licenseAgreement',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Delete and Logout`
  String get deleteAndLogout {
    return Intl.message(
      'Delete and Logout',
      name: 'deleteAndLogout',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Delete All Profiles`
  String get deleteAllProfiles {
    return Intl.message(
      'Delete All Profiles',
      name: 'deleteAllProfiles',
      desc: '',
      args: [],
    );
  }

  /// `©️ Powered by IMB Tech`
  String get poweredBy {
    return Intl.message(
      '©️ Powered by IMB Tech',
      name: 'poweredBy',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Logout`
  String get confirmLogout {
    return Intl.message(
      'Confirm Logout',
      name: 'confirmLogout',
      desc: '',
      args: [],
    );
  }

  /// `Night mode`
  String get night_mode {
    return Intl.message(
      'Night mode',
      name: 'night_mode',
      desc: '',
      args: [],
    );
  }

  /// `Select language`
  String get selectLang {
    return Intl.message(
      'Select language',
      name: 'selectLang',
      desc: '',
      args: [],
    );
  }

  /// `Rate`
  String get rate {
    return Intl.message(
      'Rate',
      name: 'rate',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message(
      'Status',
      name: 'status',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Resend code`
  String get resendCode {
    return Intl.message(
      'Resend code',
      name: 'resendCode',
      desc: '',
      args: [],
    );
  }

  /// `Orders`
  String get orders {
    return Intl.message(
      'Orders',
      name: 'orders',
      desc: '',
      args: [],
    );
  }

  /// `Offers`
  String get myOffers {
    return Intl.message(
      'Offers',
      name: 'myOffers',
      desc: '',
      args: [],
    );
  }

  /// `In Progress`
  String get inProgress {
    return Intl.message(
      'In Progress',
      name: 'inProgress',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message(
      'Completed',
      name: 'completed',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get confirmed {
    return Intl.message(
      'Confirmed',
      name: 'confirmed',
      desc: '',
      args: [],
    );
  }

  /// `Under Review`
  String get underReview {
    return Intl.message(
      'Under Review',
      name: 'underReview',
      desc: '',
      args: [],
    );
  }

  /// `Refrigerated Truck`
  String get refrigeratedTruck {
    return Intl.message(
      'Refrigerated Truck',
      name: 'refrigeratedTruck',
      desc: '',
      args: [],
    );
  }

  /// `Tiles available, will be loaded tomorrow`
  String get tilesInfo {
    return Intl.message(
      'Tiles available, will be loaded tomorrow',
      name: 'tilesInfo',
      desc: '',
      args: [],
    );
  }

  /// `Proposed price: {price} UZS`
  String proposedPrice(Object price) {
    return Intl.message(
      'Proposed price: $price UZS',
      name: 'proposedPrice',
      desc: '',
      args: [price],
    );
  }

  /// `Accept Order`
  String get acceptOrder {
    return Intl.message(
      'Accept Order',
      name: 'acceptOrder',
      desc: '',
      args: [],
    );
  }

  /// `Accept Price`
  String get acceptPrice {
    return Intl.message(
      'Accept Price',
      name: 'acceptPrice',
      desc: '',
      args: [],
    );
  }

  /// `Offer Price`
  String get offerPrice {
    return Intl.message(
      'Offer Price',
      name: 'offerPrice',
      desc: '',
      args: [],
    );
  }

  /// `Select date range`
  String get selectDateRange {
    return Intl.message(
      'Select date range',
      name: 'selectDateRange',
      desc: '',
      args: [],
    );
  }

  /// `Monthly Income`
  String get monthlyIncome {
    return Intl.message(
      'Monthly Income',
      name: 'monthlyIncome',
      desc: '',
      args: [],
    );
  }

  /// `Enter Amount`
  String get amount {
    return Intl.message(
      'Enter Amount',
      name: 'amount',
      desc: '',
      args: [],
    );
  }

  /// `Submit Offer`
  String get submitOffer {
    return Intl.message(
      'Submit Offer',
      name: 'submitOffer',
      desc: '',
      args: [],
    );
  }

  /// `Direction`
  String get direction {
    return Intl.message(
      'Direction',
      name: 'direction',
      desc: '',
      args: [],
    );
  }

  /// `Agreed Price`
  String get agreedPrice {
    return Intl.message(
      'Agreed Price',
      name: 'agreedPrice',
      desc: '',
      args: [],
    );
  }

  /// `Sum`
  String get sum {
    return Intl.message(
      'Sum',
      name: 'sum',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `License Plate`
  String get carNumber {
    return Intl.message(
      'License Plate',
      name: 'carNumber',
      desc: '',
      args: [],
    );
  }

  /// `Color`
  String get color {
    return Intl.message(
      'Color',
      name: 'color',
      desc: '',
      args: [],
    );
  }

  /// `Year of Manufacture`
  String get manufactureYear {
    return Intl.message(
      'Year of Manufacture',
      name: 'manufactureYear',
      desc: '',
      args: [],
    );
  }

  /// `Car Registration Certificate`
  String get carRegistrationCert {
    return Intl.message(
      'Car Registration Certificate',
      name: 'carRegistrationCert',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle Identification Number`
  String get carVin {
    return Intl.message(
      'Vehicle Identification Number',
      name: 'carVin',
      desc: '',
      args: [],
    );
  }

  /// `Child Seats`
  String get childSeats {
    return Intl.message(
      'Child Seats',
      name: 'childSeats',
      desc: '',
      args: [],
    );
  }

  /// `Car Specifications`
  String get carSpecs {
    return Intl.message(
      'Car Specifications',
      name: 'carSpecs',
      desc: '',
      args: [],
    );
  }

  /// `Additional Options`
  String get additionalOptions {
    return Intl.message(
      'Additional Options',
      name: 'additionalOptions',
      desc: '',
      args: [],
    );
  }

  /// `To change these options, please contact your fleet`
  String get contactFleet {
    return Intl.message(
      'To change these options, please contact your fleet',
      name: 'contactFleet',
      desc: '',
      args: [],
    );
  }

  /// `In active car`
  String get inActiveCar {
    return Intl.message(
      'In active car',
      name: 'inActiveCar',
      desc: '',
      args: [],
    );
  }

  /// `Make active car`
  String get makeActiveCar {
    return Intl.message(
      'Make active car',
      name: 'makeActiveCar',
      desc: '',
      args: [],
    );
  }

  /// `Make inactive car`
  String get makeInactiveCar {
    return Intl.message(
      'Make inactive car',
      name: 'makeInactiveCar',
      desc: '',
      args: [],
    );
  }

  /// `No tariffs available`
  String get no_tariffs_available {
    return Intl.message(
      'No tariffs available',
      name: 'no_tariffs_available',
      desc: '',
      args: [],
    );
  }

  /// `Main car`
  String get mainCar {
    return Intl.message(
      'Main car',
      name: 'mainCar',
      desc: '',
      args: [],
    );
  }

  /// `Homework`
  String get task {
    return Intl.message(
      'Homework',
      name: 'task',
      desc: '',
      args: [],
    );
  }

  /// `Exam`
  String get exam {
    return Intl.message(
      'Exam',
      name: 'exam',
      desc: '',
      args: [],
    );
  }

  /// `Graded`
  String get graded {
    return Intl.message(
      'Graded',
      name: 'graded',
      desc: '',
      args: [],
    );
  }

  /// `Not graded`
  String get not_graded {
    return Intl.message(
      'Not graded',
      name: 'not_graded',
      desc: '',
      args: [],
    );
  }

  /// `Salaries`
  String get payments {
    return Intl.message(
      'Salaries',
      name: 'payments',
      desc: '',
      args: [],
    );
  }

  /// `No payments found!`
  String get no_payments_found {
    return Intl.message(
      'No payments found!',
      name: 'no_payments_found',
      desc: '',
      args: [],
    );
  }

  /// `Salary`
  String get salary {
    return Intl.message(
      'Salary',
      name: 'salary',
      desc: '',
      args: [],
    );
  }

  /// `Advance`
  String get advance {
    return Intl.message(
      'Advance',
      name: 'advance',
      desc: '',
      args: [],
    );
  }

  /// `Fine`
  String get fine {
    return Intl.message(
      'Fine',
      name: 'fine',
      desc: '',
      args: [],
    );
  }

  /// `so'm`
  String get currency {
    return Intl.message(
      'so\'m',
      name: 'currency',
      desc: '',
      args: [],
    );
  }

  /// `An issue occurred!`
  String get an_issue_occurred {
    return Intl.message(
      'An issue occurred!',
      name: 'an_issue_occurred',
      desc: '',
      args: [],
    );
  }

  /// `Hi`
  String get hi {
    return Intl.message(
      'Hi',
      name: 'hi',
      desc: '',
      args: [],
    );
  }

  /// `Select Image`
  String get select_image {
    return Intl.message(
      'Select Image',
      name: 'select_image',
      desc: '',
      args: [],
    );
  }

  /// `Choose from Gallery`
  String get choose_from_gallery {
    return Intl.message(
      'Choose from Gallery',
      name: 'choose_from_gallery',
      desc: '',
      args: [],
    );
  }

  /// `Take from Camera`
  String get take_from_camera {
    return Intl.message(
      'Take from Camera',
      name: 'take_from_camera',
      desc: '',
      args: [],
    );
  }

  /// `Image selection error:`
  String get image_selection_error {
    return Intl.message(
      'Image selection error:',
      name: 'image_selection_error',
      desc: '',
      args: [],
    );
  }

  /// `Old password`
  String get old_password {
    return Intl.message(
      'Old password',
      name: 'old_password',
      desc: '',
      args: [],
    );
  }

  /// `Your old password`
  String get your_old_password {
    return Intl.message(
      'Your old password',
      name: 'your_old_password',
      desc: '',
      args: [],
    );
  }

  /// `New password`
  String get new_password {
    return Intl.message(
      'New password',
      name: 'new_password',
      desc: '',
      args: [],
    );
  }

  /// `Repeat new password`
  String get repeat_new_password {
    return Intl.message(
      'Repeat new password',
      name: 'repeat_new_password',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Role`
  String get role {
    return Intl.message(
      'Role',
      name: 'role',
      desc: '',
      args: [],
    );
  }

  /// `Phone number`
  String get phone_number {
    return Intl.message(
      'Phone number',
      name: 'phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Workplaces`
  String get workplaces {
    return Intl.message(
      'Workplaces',
      name: 'workplaces',
      desc: '',
      args: [],
    );
  }

  /// `Change image`
  String get change_image {
    return Intl.message(
      'Change image',
      name: 'change_image',
      desc: '',
      args: [],
    );
  }

  /// `Main`
  String get main {
    return Intl.message(
      'Main',
      name: 'main',
      desc: '',
      args: [],
    );
  }

  /// `Groups`
  String get groups {
    return Intl.message(
      'Groups',
      name: 'groups',
      desc: '',
      args: [],
    );
  }

  /// `Mo`
  String get mondayShort {
    return Intl.message(
      'Mo',
      name: 'mondayShort',
      desc: '',
      args: [],
    );
  }

  /// `Tu`
  String get tuesdayShort {
    return Intl.message(
      'Tu',
      name: 'tuesdayShort',
      desc: '',
      args: [],
    );
  }

  /// `We`
  String get wednesdayShort {
    return Intl.message(
      'We',
      name: 'wednesdayShort',
      desc: '',
      args: [],
    );
  }

  /// `Th`
  String get thursdayShort {
    return Intl.message(
      'Th',
      name: 'thursdayShort',
      desc: '',
      args: [],
    );
  }

  /// `Fr`
  String get fridayShort {
    return Intl.message(
      'Fr',
      name: 'fridayShort',
      desc: '',
      args: [],
    );
  }

  /// `Sa`
  String get saturdayShort {
    return Intl.message(
      'Sa',
      name: 'saturdayShort',
      desc: '',
      args: [],
    );
  }

  /// `Su`
  String get sundayShort {
    return Intl.message(
      'Su',
      name: 'sundayShort',
      desc: '',
      args: [],
    );
  }

  /// `Topic`
  String get topic {
    return Intl.message(
      'Topic',
      name: 'topic',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create_title {
    return Intl.message(
      'Create',
      name: 'create_title',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create_button {
    return Intl.message(
      'Create',
      name: 'create_button',
      desc: '',
      args: [],
    );
  }

  /// `Textbook`
  String get textbook {
    return Intl.message(
      'Textbook',
      name: 'textbook',
      desc: '',
      args: [],
    );
  }

  /// `Assignment`
  String get assignment {
    return Intl.message(
      'Assignment',
      name: 'assignment',
      desc: '',
      args: [],
    );
  }

  /// `Title is required`
  String get title_required {
    return Intl.message(
      'Title is required',
      name: 'title_required',
      desc: '',
      args: [],
    );
  }

  /// `Example: 'To be' verb`
  String get example_title {
    return Intl.message(
      'Example: \'To be\' verb',
      name: 'example_title',
      desc: '',
      args: [],
    );
  }

  /// `Announcement date`
  String get announcement_date {
    return Intl.message(
      'Announcement date',
      name: 'announcement_date',
      desc: '',
      args: [],
    );
  }

  /// `Select date`
  String get select_date {
    return Intl.message(
      'Select date',
      name: 'select_date',
      desc: '',
      args: [],
    );
  }

  /// `Additional note`
  String get additional_note {
    return Intl.message(
      'Additional note',
      name: 'additional_note',
      desc: '',
      args: [],
    );
  }

  /// `Optional`
  String get optional {
    return Intl.message(
      'Optional',
      name: 'optional',
      desc: '',
      args: [],
    );
  }

  /// `Assignment date`
  String get assignment_date {
    return Intl.message(
      'Assignment date',
      name: 'assignment_date',
      desc: '',
      args: [],
    );
  }

  /// `Exam date`
  String get exam_date {
    return Intl.message(
      'Exam date',
      name: 'exam_date',
      desc: '',
      args: [],
    );
  }

  /// `Start date`
  String get start_date {
    return Intl.message(
      'Start date',
      name: 'start_date',
      desc: '',
      args: [],
    );
  }

  /// `End date`
  String get end_date {
    return Intl.message(
      'End date',
      name: 'end_date',
      desc: '',
      args: [],
    );
  }

  /// `Score`
  String get score {
    return Intl.message(
      'Score',
      name: 'score',
      desc: '',
      args: [],
    );
  }

  /// `Passing score`
  String get passing_score {
    return Intl.message(
      'Passing score',
      name: 'passing_score',
      desc: '',
      args: [],
    );
  }

  /// `Maximum score`
  String get max_score {
    return Intl.message(
      'Maximum score',
      name: 'max_score',
      desc: '',
      args: [],
    );
  }

  /// `Allow students to upload tasks`
  String get students_upload_label {
    return Intl.message(
      'Allow students to upload tasks',
      name: 'students_upload_label',
      desc: '',
      args: [],
    );
  }

  /// `Additional files`
  String get additional_files {
    return Intl.message(
      'Additional files',
      name: 'additional_files',
      desc: '',
      args: [],
    );
  }

  /// `+ Add file`
  String get add_file {
    return Intl.message(
      '+ Add file',
      name: 'add_file',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `No data found for the query!`
  String get no_data {
    return Intl.message(
      'No data found for the query!',
      name: 'no_data',
      desc: 'Shown when a search or query returns no results.',
      args: [],
    );
  }

  /// `{count, plural, =0{0 students} one{{count} student} other{{count} students}}`
  String students_count(int count) {
    return Intl.plural(
      count,
      zero: '0 students',
      one: '$count student',
      other: '$count students',
      name: 'students_count',
      desc:
          'Shows total number of students (active + frozen + new). Argument: integer count',
      args: [count],
    );
  }

  /// `F.I.O`
  String get fio {
    return Intl.message(
      'F.I.O',
      name: 'fio',
      desc: 'Label for full name (Family, First, Patronymic)',
      args: [],
    );
  }

  /// `Active`
  String get status_active {
    return Intl.message(
      'Active',
      name: 'status_active',
      desc: 'Student status = active',
      args: [],
    );
  }

  /// `On trial`
  String get status_trial {
    return Intl.message(
      'On trial',
      name: 'status_trial',
      desc: 'Student status = trial',
      args: [],
    );
  }

  /// `Frozen`
  String get status_frozen {
    return Intl.message(
      'Frozen',
      name: 'status_frozen',
      desc: 'Student status = frozen',
      args: [],
    );
  }

  /// `Deleted`
  String get status_deleted {
    return Intl.message(
      'Deleted',
      name: 'status_deleted',
      desc: 'Student status = deleted/removed',
      args: [],
    );
  }

  /// `Suspended`
  String get status_suspended {
    return Intl.message(
      'Suspended',
      name: 'status_suspended',
      desc: 'Student status = suspended/paused',
      args: [],
    );
  }

  /// `hour`
  String get hour {
    return Intl.message(
      'hour',
      name: 'hour',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message(
      'Start',
      name: 'start',
      desc: '',
      args: [],
    );
  }

  /// `End`
  String get end {
    return Intl.message(
      'End',
      name: 'end',
      desc: '',
      args: [],
    );
  }

  /// `minute`
  String get minute {
    return Intl.message(
      'minute',
      name: 'minute',
      desc: '',
      args: [],
    );
  }

  /// `End date cannot be before start date`
  String get error_end_before_start {
    return Intl.message(
      'End date cannot be before start date',
      name: 'error_end_before_start',
      desc:
          'Validation error shown when the end date is earlier than the start date',
      args: [],
    );
  }

  /// `Score`
  String get label_score {
    return Intl.message(
      'Score',
      name: 'label_score',
      desc: 'Label for score/grade input field',
      args: [],
    );
  }

  /// `Comment`
  String get label_comment {
    return Intl.message(
      'Comment',
      name: 'label_comment',
      desc: 'Label for description/comment field',
      args: [],
    );
  }

  /// `Enter a comment about the task`
  String get hint_comment_task {
    return Intl.message(
      'Enter a comment about the task',
      name: 'hint_comment_task',
      desc: 'Hint text for description/comment input',
      args: [],
    );
  }

  /// `0-100`
  String get hint_score_range {
    return Intl.message(
      '0-100',
      name: 'hint_score_range',
      desc: 'Hint text showing valid score range',
      args: [],
    );
  }

  /// `You have not graded yet`
  String get error_not_graded {
    return Intl.message(
      'You have not graded yet',
      name: 'error_not_graded',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get sign_in {
    return Intl.message(
      'Sign in',
      name: 'sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Access denied, please contact administration!`
  String get unauthorized_access {
    return Intl.message(
      'Access denied, please contact administration!',
      name: 'unauthorized_access',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to delete?`
  String get delete_confirmation {
    return Intl.message(
      'Do you want to delete?',
      name: 'delete_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Full name`
  String get f_i_sh {
    return Intl.message(
      'Full name',
      name: 'f_i_sh',
      desc: '',
      args: [],
    );
  }

  /// `Enter a comment for the task`
  String get enter_task_comment {
    return Intl.message(
      'Enter a comment for the task',
      name: 'enter_task_comment',
      desc: '',
      args: [],
    );
  }

  /// `Return time cannot be before leave time`
  String get time_error {
    return Intl.message(
      'Return time cannot be before leave time',
      name: 'time_error',
      desc: '',
      args: [],
    );
  }

  /// `Attendance will not be taken for past dates.`
  String get expired_date_attendance_not_taken {
    return Intl.message(
      'Attendance will not be taken for past dates.',
      name: 'expired_date_attendance_not_taken',
      desc: '',
      args: [],
    );
  }

  /// `Reason for absence`
  String get reason_for_absence {
    return Intl.message(
      'Reason for absence',
      name: 'reason_for_absence',
      desc: '',
      args: [],
    );
  }

  /// `Reason for lateness`
  String get reason_for_lateness {
    return Intl.message(
      'Reason for lateness',
      name: 'reason_for_lateness',
      desc: '',
      args: [],
    );
  }

  /// `Cannot exceed 100`
  String get cannotExceedHunnid {
    return Intl.message(
      'Cannot exceed 100',
      name: 'cannotExceedHunnid',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'uz'),
      Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
