import 'package:flutter/widgets.dart';
import 'package:skymanager/screens/customer_passes/components/totp_create_screen.dart';
import 'package:skymanager/screens/customer_passes/components/totp_import_screen.dart';
// import 'package:skymanager/screens/contact_us_screen.dart';
//Import the Screens
import 'package:skymanager/screens/customer_passes/customer_passes_screen.dart';
import 'package:skymanager/screens/customer_passes/new_pass_screen.dart';
import 'package:skymanager/screens/loginScreen/login_screen.dart';
import 'package:skymanager/screens/settings/enable_2fa_screen.dart';
import 'package:skymanager/screens/settings/settings_screen.dart';
import 'package:skymanager/screens/tasks/create_edit_task.dart';
// import 'package:skymanager/screens/tickets_customers/components/tasks/tasks_view.dart';
import 'package:skymanager/screens/ticketDetailScreen/new_eintrag_screen.dart';
import 'package:skymanager/screens/tickets_customers/components/wiki/show_wiki_screen.dart';
import 'package:skymanager/screens/tickets_customers/import_customers_screen.dart';
import 'package:skymanager/screens/tickets_customers/new_kunden_screen.dart';
import 'package:skymanager/screens/tickets_customers/tickets_customers_screen.dart';
import 'package:skymanager/screens/ticketDetailScreen/ticketdetail_screen.dart';
import 'package:skymanager/screens/tickets_customers/new_ticket_screen.dart';
import 'package:skymanager/screens/user_profile/profile_screen.dart';
import 'package:skymanager/screens/usersScreen/new_user_screen.dart';
import 'package:skymanager/screens/usersScreen/show_users_screen.dart';

//Map the Screens to the Routes
final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  // "/InstancesScreen": (BuildContext context) => InstancesScreen(),
  "/Home": (BuildContext context) => const TicketCustomersScreen(),
  "/": (BuildContext context) => const TicketCustomersScreen(),
  "/Login": (BuildContext context) => const LoginScreen(),
  "/tickets/details": (BuildContext context) => const TicketDetailScreen(),
  "/tickets/create": (BuildContext context) => const NewTicketScreen(),
  "/customers/details": (BuildContext context) => const CustomerPassesScreen(),
  "/customers/create": (BuildContext context) => const NewKundeScreen(),
  "/customers/import": (BuildContext context) => const ImportCustomers(),
  "/customers/passes/create": (BuildContext context) => const NewPassScreen(),
  "/entries/create": (BuildContext context) => const NewEintragScreen(
        isNewEntry: true,
      ),
  "/entries/edit": (BuildContext context) => const NewEintragScreen(
        isNewEntry: false,
      ),
  "/Settings": (BuildContext context) => const SettingsScreen(),
  "/users": (BuildContext context) => const ShowUsersScreen(),
  "/users/create": (BuildContext context) => const NewUserScreen(),
  "/tasks/create": (BuildContext context) => const CreateTaskScreen(
        isNewTask: true,
      ),
  "/wikis": (BuildContext context) => const ShowWikiScreen(),
  "/users/profile": (BuildContext context) => const ProfileScreen(),
  "/users/Enable2FA": (BuildContext context) => const Enable2FA(),
  "/customers/totp/create": (BuildContext context) => const TOTPCreateScreeen(),
  "/customers/totp/import": (BuildContext context) => const TOTPImportScreen(),
};
