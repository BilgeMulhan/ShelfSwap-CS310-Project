import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/app_colors.dart';
import 'utils/app_routes.dart';
import 'screens/home_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/item_details_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/my_listings_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/preview_screen.dart';
import 'screens/requests_screen.dart';
import 'screens/request_chat_screen.dart';

void main() {
  runApp(const ShelfSwapApp());
}

class ShelfSwapApp extends StatelessWidget {
  const ShelfSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShelfSwap',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.signIn,
      routes: {
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.createAccount: (context) => const CreateAccountScreen(),
        AppRoutes.signIn: (context) => const SignInScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.editProfile: (context) => const EditProfileScreen(),
        AppRoutes.itemDetails: (context) => const ItemDetailsScreen(),
        AppRoutes.favorites: (context) => const FavoritesScreen(),
        AppRoutes.myListings: (context) => const MyListingsScreen(),
        AppRoutes.addItem: (context) => const AddItemScreen(),
        AppRoutes.preview: (context) => const PreviewScreen(),
        AppRoutes.requests: (context) => const RequestsScreen(),
        AppRoutes.requestChat: (context) => const RequestChatScreen(),
      },
    );
  }
}