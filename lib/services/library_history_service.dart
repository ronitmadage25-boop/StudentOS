import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Service layer managing Favorites and Recent Files history for the Library.
///
/// Features:
///   • Add/remove favorites
///   • Track recently opened PDFs (max 10, most recent first)
///   • Persist data to SharedPreferences
///   • Calculate library statistics
class LibraryHistoryService {
  LibraryHistoryService._();

  static const String _favoritesKey = 'studentos_library_favorites';
  static const String _recentKey = 'studentos_library_recent';
  static const int _maxRecent = 10;

  // ─── Favorites Persistence ───────────────────────────────────────────────

  /// Saves favorite file IDs to SharedPreferences.
  static Future<void> saveFavorites(List<String> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favoriteIds);
  }

  /// Loads favorite file IDs from SharedPreferences.
  static Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  /// Adds a file ID to favorites.
  static Future<void> addFavorite(String fileId) async {
    final favorites = await loadFavorites();
    if (!favorites.contains(fileId)) {
      favorites.add(fileId);
      await saveFavorites(favorites);
    }
  }

  /// Removes a file ID from favorites.
  static Future<void> removeFavorite(String fileId) async {
    final favorites = await loadFavorites();
    favorites.remove(fileId);
    await saveFavorites(favorites);
  }

  /// Checks if a file is favorited.
  static Future<bool> isFavorite(String fileId) async {
    final favorites = await loadFavorites();
    return favorites.contains(fileId);
  }

  // ─── Recent Files Persistence ────────────────────────────────────────────

  /// Saves recent file IDs to SharedPreferences (max 10, most recent first).
  static Future<void> saveRecent(List<String> recentIds) async {
    final prefs = await SharedPreferences.getInstance();
    // Enforce max 10
    final limited = recentIds.take(_maxRecent).toList();
    await prefs.setStringList(_recentKey, limited);
  }

  /// Loads recent file IDs from SharedPreferences (most recent first).
  static Future<List<String>> loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentKey) ?? [];
  }

  /// Records that a file was opened.
  ///
  /// Adds the file to the front of recent list (removing duplicates).
  /// Keeps max 10 items.
  static Future<void> recordOpenedFile(String fileId) async {
    var recent = await loadRecent();
    // Remove if already exists (we'll add it to front)
    recent.remove(fileId);
    // Add to front
    recent.insert(0, fileId);
    // Keep only max items
    await saveRecent(recent.take(_maxRecent).toList());
  }

  // ─── Filtered File Lists ──────────────────────────────────────────────────

  /// Returns only favorite files from the given list, sorted by creation date.
  static Future<List<LibraryFileModel>> getFavoriteFiles(
    List<LibraryFileModel> allFiles,
  ) async {
    final favoriteIds = await loadFavorites();
    final favorites =
        allFiles.where((f) => favoriteIds.contains(f.id)).toList();
    favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return favorites;
  }

  /// Returns only recent files from the given list, in order.
  static Future<List<LibraryFileModel>> getRecentFiles(
    List<LibraryFileModel> allFiles,
  ) async {
    final recentIds = await loadRecent();
    final recentMap = {for (var f in allFiles) f.id: f};
    return recentIds
        .where((id) => recentMap.containsKey(id))
        .map((id) => recentMap[id]!)
        .toList();
  }

  // ─── Statistics ───────────────────────────────────────────────────────────

  /// Returns library statistics.
  static Future<LibraryStats> getStats({
    required List<LibraryFileModel> allFiles,
    required List<LibrarySemester> allSemesters,
  }) async {
    final favoriteIds = await loadFavorites();
    final recentIds = await loadRecent();

    return LibraryStats(
      totalPdfs: allFiles.length,
      totalFavorites: favoriteIds.length,
      totalRecent: recentIds.length,
      totalSubjects: allSemesters.fold<int>(
        0,
        (sum, sem) => sum + sem.subjects.length,
      ),
    );
  }
}

/// Statistics about the library.
class LibraryStats {
  const LibraryStats({
    required this.totalPdfs,
    required this.totalFavorites,
    required this.totalRecent,
    required this.totalSubjects,
  });

  final int totalPdfs;
  final int totalFavorites;
  final int totalRecent;
  final int totalSubjects;
}
