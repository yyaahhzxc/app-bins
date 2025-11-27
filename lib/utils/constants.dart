import 'package:flutter/material.dart';

// --- LIGHT THEME COLORS ---
const Color kPrimaryColor = Color(0xFF1A237E); // Navy Blue
const Color kSurfaceColor = Color(0xFFFFFFFF); // White
const Color kBackgroundColor = Color(0xFFF5F5F5); // Light Gray
const Color kUnpaidContainerColor = Color(0xFFDCE1FF); // Lavender
const Color kListItemColor = Color(0xFFE8EAF6); // Light Blue/Lavender
const Color kErrorColor = Color(0xFFD32F2F);

// --- DARK THEME COLORS ---
const Color kPrimaryColorDark = Color(0xFF5C6BC0); // Lighter Indigo for Dark Mode
const Color kSurfaceColorDark = Color(0xFF1E1E1E); // Dark Grey Cards
const Color kBackgroundColorDark = Color(0xFF121212); // Almost Black
const Color kUnpaidContainerColorDark = Color(0xFF28293D); // Dark Slate
const Color kListItemColorDark = Color(0xFF2C2C3A); // Darker List Item

// --- TEXT COLORS ---
const Color kTextPrimary = Color(0xFF000000);
const Color kTextPrimaryDark = Color(0xFFFFFFFF);
const Color kTextSecondary = Color(0xFF757575);
const Color kTextSecondaryDark = Color(0xFFB0B0B0);
const Color kTextOnPrimary = Color(0xFFFFFFFF);

// --- DIMENSIONS ---
const double kBorderRadius = 16.0;
const double kPaddingSmall = 8.0;
const double kPaddingMedium = 16.0;
const double kPaddingLarge = 24.0;

const double kHeadingSize = 24.0;
const double kTitleSize = 18.0;
const double kBodySize = 14.0;
const double kCaptionSize = 12.0;

// --- DATABASE & FILES ---
const String kDatabaseName = 'vince_app.db';
const int kDatabaseVersion = 2;
const String kTableFriends = 'friends';
const String kTableTransactions = 'transactions';
const String kExportFileName = 'vince_app_backup';
const String kExportFileExtension = '.json';