import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/listings_provider.dart';
import 'providers/requests_provider.dart';
import 'providers/theme_provider.dart';

import 'utils/app_colors.dart';
import 'utils/app_routes.dart';

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
import 'screens/main_screen.dart';

import 'models/listing_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ShelfSwapApp());
}

class ShelfSwapApp extends StatelessWidget {
  const ShelfSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ListingsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RequestsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ShelfSwap',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: AppColors.background,
              textTheme: GoogleFonts.poppinsTextTheme(),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: Colors.black,
              textTheme: GoogleFonts.poppinsTextTheme(
                ThemeData.dark().textTheme,
              ),
              useMaterial3: true,
            ),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,

            // AuthGate checks whether the user is logged in or logged out.
            home: const AuthGate(),

            routes: {
              AppRoutes.home: (context) => const MainScreen(),
              AppRoutes.createAccount: (context) =>
                  const CreateAccountScreen(),
              AppRoutes.signIn: (context) => const SignInScreen(),
              AppRoutes.profile: (context) => const ProfileScreen(),
              AppRoutes.editProfile: (context) =>
                  const EditProfileScreen(),
              AppRoutes.itemDetails: (context) {
                final args = ModalRoute.of(context)!.settings.arguments;

                return ItemDetailsScreen(
                  item: args is ListingItem ? args : null,
                );
              },
              AppRoutes.favorites: (context) => const FavoritesScreen(),
              AppRoutes.myListings: (context) => const MyListingsScreen(),
              AppRoutes.addItem: (context) {
                final args = ModalRoute.of(context)!.settings.arguments;

                return AddItemScreen.fromRouteArguments(args);
              },
              AppRoutes.preview: (context) => const PreviewScreen(),
              AppRoutes.requests: (context) => const RequestsScreen(),
              AppRoutes.requestChat: (context) =>
                  const RequestChatScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authProvider.user == null) {
          return const SignInScreen();
        }

        return const MainScreen();
      },
    );
  }
}