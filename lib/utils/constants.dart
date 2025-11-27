import 'package:flutter/material.dart';

// Color Constants - Navy Blue & Lavender Theme
const Color kPrimaryColor = Color(0xFF1A237E); // Navy Blue
const Color kSurfaceColor = Color(0xFFE8EAF6); // Lavender
const Color kBackgroundColor = Color(0xFFFBFAFF); // Off-White
const Color kErrorColor = Color(0xFFD32F2F); // Red for errors/delete
const Color kTextPrimary = Color(0xFF000000);
const Color kTextSecondary = Color(0xFF757575);
const Color kTextOnPrimary = Color(0xFFFFFFFF);

// Border Radius - The "Pill" Look
const double kBorderRadius = 16.0;

// Spacing Constants
const double kPaddingSmall = 8.0;
const double kPaddingMedium = 16.0;
const double kPaddingLarge = 24.0;

// Typography Sizes
const double kHeadingSize = 24.0;
const double kTitleSize = 18.0;
const double kBodySize = 14.0;
const double kCaptionSize = 12.0;

// Database Constants
const String kDatabaseName = 'vince_app.db';
const int kDatabaseVersion = 1;

// Table Names
const String kTableFriends = 'friends';
const String kTableTransactions = 'transactions';

// Date Formats
const String kDateFormat = 'MMM dd, yyyy';
const String kTimeFormat = 'h:mm a';
const String kDateTimeFormat = 'MMMM dd, yyyy • h:mm a';

// Export/Import
const String kExportFileName = 'vince_app_backup';
const String kExportFileExtension = '.json';
