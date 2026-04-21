// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(price) => "Proposed price: ${price} UZS";

  static String m1(count) =>
      "${Intl.plural(count, zero: '0 students', one: '${count} student', other: '${count} students')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "absent": MessageLookupByLibrary.simpleMessage("Absent"),
        "acceptOrder": MessageLookupByLibrary.simpleMessage("Accept Order"),
        "acceptPrice": MessageLookupByLibrary.simpleMessage("Accept Price"),
        "add_file": MessageLookupByLibrary.simpleMessage("+ Add file"),
        "additional": MessageLookupByLibrary.simpleMessage("Additional"),
        "additionalOptions":
            MessageLookupByLibrary.simpleMessage("Additional Options"),
        "additional_files":
            MessageLookupByLibrary.simpleMessage("Additional files"),
        "additional_note":
            MessageLookupByLibrary.simpleMessage("Additional note"),
        "advance": MessageLookupByLibrary.simpleMessage("Advance"),
        "agreedPrice": MessageLookupByLibrary.simpleMessage("Agreed Price"),
        "amount": MessageLookupByLibrary.simpleMessage("Enter Amount"),
        "an_issue_occurred":
            MessageLookupByLibrary.simpleMessage("An issue occurred!"),
        "announcement_date":
            MessageLookupByLibrary.simpleMessage("Announcement date"),
        "april": MessageLookupByLibrary.simpleMessage("April"),
        "assignment": MessageLookupByLibrary.simpleMessage("Assignment"),
        "assignment_date":
            MessageLookupByLibrary.simpleMessage("Assignment date"),
        "attendance": MessageLookupByLibrary.simpleMessage("Attendance"),
        "august": MessageLookupByLibrary.simpleMessage("August"),
        "auto": MessageLookupByLibrary.simpleMessage("Auto"),
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "balanceAndRating":
            MessageLookupByLibrary.simpleMessage("Balance and Rating"),
        "came": MessageLookupByLibrary.simpleMessage("Came"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cannotExceedHunnid":
            MessageLookupByLibrary.simpleMessage("Cannot exceed 100"),
        "carNumber": MessageLookupByLibrary.simpleMessage("License Plate"),
        "carRegistrationCert": MessageLookupByLibrary.simpleMessage(
            "Car Registration Certificate"),
        "carSpecs": MessageLookupByLibrary.simpleMessage("Car Specifications"),
        "carVin": MessageLookupByLibrary.simpleMessage(
            "Vehicle Identification Number"),
        "change_image": MessageLookupByLibrary.simpleMessage("Change image"),
        "childSeats": MessageLookupByLibrary.simpleMessage("Child Seats"),
        "choose_from_gallery":
            MessageLookupByLibrary.simpleMessage("Choose from Gallery"),
        "color": MessageLookupByLibrary.simpleMessage("Color"),
        "comment": MessageLookupByLibrary.simpleMessage("Comment"),
        "completed": MessageLookupByLibrary.simpleMessage("Completed"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirmLogout": MessageLookupByLibrary.simpleMessage("Confirm Logout"),
        "confirmed": MessageLookupByLibrary.simpleMessage("Confirmed"),
        "contactFleet": MessageLookupByLibrary.simpleMessage(
            "To change these options, please contact your fleet"),
        "control_table_title":
            MessageLookupByLibrary.simpleMessage("Control Table"),
        "create_button": MessageLookupByLibrary.simpleMessage("Create"),
        "create_title": MessageLookupByLibrary.simpleMessage("Create"),
        "currency": MessageLookupByLibrary.simpleMessage("so\'m"),
        "dark": MessageLookupByLibrary.simpleMessage("Dark"),
        "date": MessageLookupByLibrary.simpleMessage("Date"),
        "december": MessageLookupByLibrary.simpleMessage("December"),
        "deleteAllProfiles":
            MessageLookupByLibrary.simpleMessage("Delete All Profiles"),
        "deleteAndLogout":
            MessageLookupByLibrary.simpleMessage("Delete and Logout"),
        "delete_confirmation":
            MessageLookupByLibrary.simpleMessage("Do you want to delete?"),
        "description": MessageLookupByLibrary.simpleMessage("Description"),
        "direction": MessageLookupByLibrary.simpleMessage("Direction"),
        "driverLicense":
            MessageLookupByLibrary.simpleMessage("Driver\'s License"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "end": MessageLookupByLibrary.simpleMessage("End"),
        "end_date": MessageLookupByLibrary.simpleMessage("End date"),
        "enter": MessageLookupByLibrary.simpleMessage("Enter"),
        "enterLogin": MessageLookupByLibrary.simpleMessage("Enter login"),
        "enter_login": MessageLookupByLibrary.simpleMessage("Enter login"),
        "enter_password":
            MessageLookupByLibrary.simpleMessage("Enter password"),
        "enter_task_comment": MessageLookupByLibrary.simpleMessage(
            "Enter a comment for the task"),
        "error": MessageLookupByLibrary.simpleMessage("Error"),
        "error_end_before_start": MessageLookupByLibrary.simpleMessage(
            "End date cannot be before start date"),
        "error_message": MessageLookupByLibrary.simpleMessage("Error"),
        "error_not_graded":
            MessageLookupByLibrary.simpleMessage("You have not graded yet"),
        "error_occurred":
            MessageLookupByLibrary.simpleMessage("An error occurred:"),
        "exam": MessageLookupByLibrary.simpleMessage("Exam"),
        "exam_date": MessageLookupByLibrary.simpleMessage("Exam date"),
        "example_title":
            MessageLookupByLibrary.simpleMessage("Example: \'To be\' verb"),
        "exitCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "exitConfirm": MessageLookupByLibrary.simpleMessage("Exit"),
        "exitDoubleCheckMessage": MessageLookupByLibrary.simpleMessage(
            "Are you really sure you want to exit?"),
        "exitDoubleCheckTitle":
            MessageLookupByLibrary.simpleMessage("Confirm Exit"),
        "exitMessage": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to exit?"),
        "exitTitle": MessageLookupByLibrary.simpleMessage("Exit App"),
        "expired_date_attendance_not_taken":
            MessageLookupByLibrary.simpleMessage(
                "Attendance will not be taken for past dates."),
        "f_i_sh": MessageLookupByLibrary.simpleMessage("Full name"),
        "february": MessageLookupByLibrary.simpleMessage("February"),
        "fine": MessageLookupByLibrary.simpleMessage("Fine"),
        "fio": MessageLookupByLibrary.simpleMessage("F.I.O"),
        "friday": MessageLookupByLibrary.simpleMessage("Friday"),
        "fridayShort": MessageLookupByLibrary.simpleMessage("Fr"),
        "frontSide": MessageLookupByLibrary.simpleMessage("Front Side"),
        "go": MessageLookupByLibrary.simpleMessage("Go"),
        "graded": MessageLookupByLibrary.simpleMessage("Graded"),
        "group_title": MessageLookupByLibrary.simpleMessage("Groups"),
        "groups": MessageLookupByLibrary.simpleMessage("Groups"),
        "hi": MessageLookupByLibrary.simpleMessage("Hi"),
        "hint_comment_task": MessageLookupByLibrary.simpleMessage(
            "Enter a comment about the task"),
        "hint_score_range": MessageLookupByLibrary.simpleMessage("0-100"),
        "login": MessageLookupByLibrary.simpleMessage("Home"),
        "hour": MessageLookupByLibrary.simpleMessage("hour"),
        "image_selection_error":
            MessageLookupByLibrary.simpleMessage("Image selection error:"),
        "inActiveCar": MessageLookupByLibrary.simpleMessage("In active car"),
        "inProgress": MessageLookupByLibrary.simpleMessage("In Progress"),
        "internetConnected":
            MessageLookupByLibrary.simpleMessage("Internet Connected"),
        "january": MessageLookupByLibrary.simpleMessage("January"),
        "july": MessageLookupByLibrary.simpleMessage("July"),
        "june": MessageLookupByLibrary.simpleMessage("June"),
        "label_comment": MessageLookupByLibrary.simpleMessage("Comment"),
        "label_score": MessageLookupByLibrary.simpleMessage("Score"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "late": MessageLookupByLibrary.simpleMessage("Late"),
        "lesson_schedule":
            MessageLookupByLibrary.simpleMessage("Lesson Schedule"),
        "licenseAgreement":
            MessageLookupByLibrary.simpleMessage("License Agreement"),
        "light": MessageLookupByLibrary.simpleMessage("Light"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "main": MessageLookupByLibrary.simpleMessage("Main"),
        "mainCar": MessageLookupByLibrary.simpleMessage("Main car"),
        "makeActiveCar":
            MessageLookupByLibrary.simpleMessage("Make active car"),
        "makeInactiveCar":
            MessageLookupByLibrary.simpleMessage("Make inactive car"),
        "manufactureYear":
            MessageLookupByLibrary.simpleMessage("Year of Manufacture"),
        "march": MessageLookupByLibrary.simpleMessage("March"),
        "max_score": MessageLookupByLibrary.simpleMessage("Maximum score"),
        "may": MessageLookupByLibrary.simpleMessage("May"),
        "minute": MessageLookupByLibrary.simpleMessage("minute"),
        "monday": MessageLookupByLibrary.simpleMessage("Monday"),
        "mondayShort": MessageLookupByLibrary.simpleMessage("Mo"),
        "month_april": MessageLookupByLibrary.simpleMessage("April"),
        "month_august": MessageLookupByLibrary.simpleMessage("August"),
        "month_december": MessageLookupByLibrary.simpleMessage("December"),
        "month_february": MessageLookupByLibrary.simpleMessage("February"),
        "month_january": MessageLookupByLibrary.simpleMessage("January"),
        "month_july": MessageLookupByLibrary.simpleMessage("July"),
        "month_june": MessageLookupByLibrary.simpleMessage("June"),
        "month_march": MessageLookupByLibrary.simpleMessage("March"),
        "month_may": MessageLookupByLibrary.simpleMessage("May"),
        "month_november": MessageLookupByLibrary.simpleMessage("November"),
        "month_october": MessageLookupByLibrary.simpleMessage("October"),
        "month_september": MessageLookupByLibrary.simpleMessage("September"),
        "monthlyIncome": MessageLookupByLibrary.simpleMessage("Monthly Income"),
        "myOffers": MessageLookupByLibrary.simpleMessage("Offers"),
        "new_password": MessageLookupByLibrary.simpleMessage("New password"),
        "night_mode": MessageLookupByLibrary.simpleMessage("Night mode"),
        "noInternet": MessageLookupByLibrary.simpleMessage("No Internet"),
        "no_data": MessageLookupByLibrary.simpleMessage(
            "No data found for the query!"),
        "no_groups": MessageLookupByLibrary.simpleMessage("No groups"),
        "no_lessons": MessageLookupByLibrary.simpleMessage("No lessons :)"),
        "no_payments_found":
            MessageLookupByLibrary.simpleMessage("No payments found!"),
        "no_students": MessageLookupByLibrary.simpleMessage("No students"),
        "no_students_found":
            MessageLookupByLibrary.simpleMessage("No students found"),
        "no_tariffs_available":
            MessageLookupByLibrary.simpleMessage("No tariffs available"),
        "no_tasks_yet": MessageLookupByLibrary.simpleMessage("No tasks yet :)"),
        "not_graded": MessageLookupByLibrary.simpleMessage("Not graded"),
        "notification": MessageLookupByLibrary.simpleMessage("Notification"),
        "november": MessageLookupByLibrary.simpleMessage("November"),
        "october": MessageLookupByLibrary.simpleMessage("October"),
        "offerPrice": MessageLookupByLibrary.simpleMessage("Offer Price"),
        "old_password": MessageLookupByLibrary.simpleMessage("Old password"),
        "optional": MessageLookupByLibrary.simpleMessage("Optional"),
        "orders": MessageLookupByLibrary.simpleMessage("Orders"),
        "passing_score": MessageLookupByLibrary.simpleMessage("Passing score"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "payments": MessageLookupByLibrary.simpleMessage("Salaries"),
        "phone_number": MessageLookupByLibrary.simpleMessage("Phone number"),
        "poweredBy":
            MessageLookupByLibrary.simpleMessage("©️ Powered by IMB Tech"),
        "present": MessageLookupByLibrary.simpleMessage("Present"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
        "profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "proposedPrice": m0,
        "rate": MessageLookupByLibrary.simpleMessage("Rate"),
        "rearSide": MessageLookupByLibrary.simpleMessage("Rear Side"),
        "reason_for_absence":
            MessageLookupByLibrary.simpleMessage("Reason for absence"),
        "reason_for_lateness":
            MessageLookupByLibrary.simpleMessage("Reason for lateness"),
        "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
        "refrigeratedTruck":
            MessageLookupByLibrary.simpleMessage("Refrigerated Truck"),
        "register": MessageLookupByLibrary.simpleMessage("Sign up"),
        "reload": MessageLookupByLibrary.simpleMessage("Reload"),
        "repeat_new_password":
            MessageLookupByLibrary.simpleMessage("Repeat new password"),
        "resendCode": MessageLookupByLibrary.simpleMessage("Resend code"),
        "role": MessageLookupByLibrary.simpleMessage("Role"),
        "salary": MessageLookupByLibrary.simpleMessage("Salary"),
        "saturday": MessageLookupByLibrary.simpleMessage("Saturday"),
        "saturdayShort": MessageLookupByLibrary.simpleMessage("Sa"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "score": MessageLookupByLibrary.simpleMessage("Score"),
        "selectDateRange":
            MessageLookupByLibrary.simpleMessage("Select date range"),
        "selectLang": MessageLookupByLibrary.simpleMessage("Select language"),
        "select_date": MessageLookupByLibrary.simpleMessage("Select date"),
        "select_image": MessageLookupByLibrary.simpleMessage("Select Image"),
        "september": MessageLookupByLibrary.simpleMessage("September"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "sign_in": MessageLookupByLibrary.simpleMessage("Sign in"),
        "start": MessageLookupByLibrary.simpleMessage("Start"),
        "start_date": MessageLookupByLibrary.simpleMessage("Start date"),
        "status": MessageLookupByLibrary.simpleMessage("Status"),
        "status_active": MessageLookupByLibrary.simpleMessage("Active"),
        "status_deleted": MessageLookupByLibrary.simpleMessage("Deleted"),
        "status_frozen": MessageLookupByLibrary.simpleMessage("Frozen"),
        "status_not_submitted":
            MessageLookupByLibrary.simpleMessage("Not Submitted"),
        "status_suspended": MessageLookupByLibrary.simpleMessage("Suspended"),
        "status_trial": MessageLookupByLibrary.simpleMessage("On trial"),
        "students": MessageLookupByLibrary.simpleMessage("Students"),
        "students_count": m1,
        "students_upload_label": MessageLookupByLibrary.simpleMessage(
            "Allow students to upload tasks"),
        "submitOffer": MessageLookupByLibrary.simpleMessage("Submit Offer"),
        "sum": MessageLookupByLibrary.simpleMessage("Sum"),
        "sunday": MessageLookupByLibrary.simpleMessage("Sunday"),
        "sundayShort": MessageLookupByLibrary.simpleMessage("Su"),
        "take_from_camera":
            MessageLookupByLibrary.simpleMessage("Take from Camera"),
        "task": MessageLookupByLibrary.simpleMessage("Homework"),
        "tasks": MessageLookupByLibrary.simpleMessage("Tasks"),
        "techPassport":
            MessageLookupByLibrary.simpleMessage("Technical Passport"),
        "textbook": MessageLookupByLibrary.simpleMessage("Textbook"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "thursday": MessageLookupByLibrary.simpleMessage("Thursday"),
        "thursdayShort": MessageLookupByLibrary.simpleMessage("Th"),
        "tilesInfo": MessageLookupByLibrary.simpleMessage(
            "Tiles available, will be loaded tomorrow"),
        "time_error": MessageLookupByLibrary.simpleMessage(
            "Return time cannot be before leave time"),
        "title_required":
            MessageLookupByLibrary.simpleMessage("Title is required"),
        "topic": MessageLookupByLibrary.simpleMessage("Topic"),
        "total_groups": MessageLookupByLibrary.simpleMessage("Total Groups"),
        "total_students":
            MessageLookupByLibrary.simpleMessage("Total Students"),
        "trailer": MessageLookupByLibrary.simpleMessage("Trailer"),
        "tuesday": MessageLookupByLibrary.simpleMessage("Tuesday"),
        "tuesdayShort": MessageLookupByLibrary.simpleMessage("Tu"),
        "unauthorized_access": MessageLookupByLibrary.simpleMessage(
            "Access denied, please contact administration!"),
        "underReview": MessageLookupByLibrary.simpleMessage("Under Review"),
        "version": MessageLookupByLibrary.simpleMessage("Version"),
        "wednesday": MessageLookupByLibrary.simpleMessage("Wednesday"),
        "wednesdayShort": MessageLookupByLibrary.simpleMessage("We"),
        "workplaces": MessageLookupByLibrary.simpleMessage("Workplaces"),
        "your_old_password":
            MessageLookupByLibrary.simpleMessage("Your old password")
      };
}
