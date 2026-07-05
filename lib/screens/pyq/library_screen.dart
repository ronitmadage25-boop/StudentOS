import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../services/library_service.dart';
import '../../services/library_history_service.dart';
import '../../widgets/folder_tile.dart';
import '../../widgets/subject_tile.dart';
import '../../widgets/favorite_pdf_tile.dart';
import '../../widgets/recent_pdf_tile.dart';
import '../../widgets/library_stats_card.dart';
import '../pdf_viewer_screen.dart';

/// Phase 5A + 5B + 5D — Library Folder Management, PDF Import, and Enhancements.
///
/// Hierarchy: LibrarySemester → LibrarySubject → LibraryCategoryModel → LibraryFileModel
///
/// Phase 5A-5B Features:
///   • Create / Rename / Delete semesters
///   • Create / Rename / Delete subjects (auto-creates 3 categories)
///   • Expand / Collapse tree (semester → subject → category)
///   • Import PDF per category via FilePicker (PDF only, no duplicates)
///   • Delete imported PDFs
///   • Live search (semester + subject)
///   • SharedPreferences persistence (folders + files)
///
/// Phase 5D Features:
///   • Favorites System (mark/unmark PDFs as favorites)
///   • Recent Files System (track up to 10 recently opened PDFs)
///   • Enhanced Search (search PDFs by name, subject, or category)
///   • Library Statistics (total PDFs, favorites, recent, subjects)
///   • Favorites section at top
///   • Recently opened section at top
///   • Statistics card with 2x2 grid
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // ─── Data State ───────────────────────────────────────────────────────────
  List<LibrarySemester> _semesters = [];
  List<LibraryFileModel> _allFiles = [];
  bool _isLoading = true;

  // ─── Phase 5D State ────────────────────────────────────────────────────────
  List<String> _favoriteIds = [];
  List<String> _recentIds = [];
  LibraryStats? _stats;

  // ─── Expand / Collapse State ──────────────────────────────────────────────
  final Set<String> _expandedSemesters = {};
  final Set<String> _expandedSubjects = {};

  /// Map of subjectId → Set of expanded categoryIds.
  final Map<String, Set<String>> _expandedCategories = {};

  // ─── Search State ─────────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  List<LibrarySearchResult> _searchResults = [];
  List<LibraryFileModel> _pdfSearchResults = [];

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      LibraryService.load(),
      LibraryService.loadFiles(),
      LibraryHistoryService.loadFavorites(),
      LibraryHistoryService.loadRecent(),
    ]);
    if (!mounted) return;
    
    _semesters = results[0] as List<LibrarySemester>;
    _allFiles = results[1] as List<LibraryFileModel>;
    _favoriteIds = results[2] as List<String>;
    _recentIds = results[3] as List<String>;
    
    // Calculate stats
    _stats = await LibraryHistoryService.getStats(
      allFiles: _allFiles,
      allSemesters: _semesters,
    );
    
    setState(() => _isLoading = false);
  }

  // ─── Search ───────────────────────────────────────────────────────────────
  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _searchQuery = query;
      if (query.trim().isEmpty) {
        _searchResults = [];
        _pdfSearchResults = [];
      } else {
        // Search both folders and PDFs
        _searchResults = LibraryService.search(query: query, semesters: _semesters);
        _pdfSearchResults = LibraryService.searchPdfs(query: query, allFiles: _allFiles);
      }
    });
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchResults = [];
      _pdfSearchResults = [];
    });
  }

  // ─── Semester CRUD ────────────────────────────────────────────────────────
  Future<void> _showAddSemesterDialog() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _NameDialog(
        title: 'New Semester',
        hint: 'e.g. Semester 3',
        controller: ctrl,
        actionLabel: 'Create',
      ),
    );
    if (result != null && mounted) {
      try {
        final updated =
            await LibraryService.createSemester(name: result, current: _semesters);
        setState(() => _semesters = updated);
        _showSnack('Semester "$result" created');
      } on ArgumentError catch (e) {
        _showSnack(e.message.toString(), isError: true);
      }
    }
  }

  Future<void> _showRenameSemesterDialog(LibrarySemester semester) async {
    final ctrl = TextEditingController(text: semester.name);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _NameDialog(
        title: 'Rename Semester',
        hint: 'Semester name',
        controller: ctrl,
        actionLabel: 'Save',
      ),
    );
    if (result != null && mounted) {
      try {
        final updated = await LibraryService.renameSemester(
          semesterId: semester.id,
          newName: result,
          current: _semesters,
        );
        setState(() => _semesters = updated);
        _showSnack('Renamed to "$result"');
      } on ArgumentError catch (e) {
        _showSnack(e.message.toString(), isError: true);
      }
    }
  }

  Future<void> _confirmDeleteSemester(LibrarySemester semester) async {
    final confirmed = await _showDeleteDialog(
      title: 'Delete Semester',
      message:
          'Delete "${semester.name}" and all ${semester.subjects.length} subjects '
          'including their PDFs?\n\nThis cannot be undone.',
    );
    if (confirmed && mounted) {
      final updated = await LibraryService.deleteSemester(
        semesterId: semester.id,
        current: _semesters,
      );
      // loadFiles again since cascade happened inside the service
      final files = await LibraryService.loadFiles();
      setState(() {
        _semesters = updated;
        _allFiles = files;
        _expandedSemesters.remove(semester.id);
      });
      _showSnack('"${semester.name}" deleted');
    }
  }

  // ─── Subject CRUD ─────────────────────────────────────────────────────────
  Future<void> _showAddSubjectDialog(LibrarySemester semester) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _NameDialog(
        title: 'New Subject',
        hint: 'e.g. AOA, DBMS, OS',
        controller: ctrl,
        actionLabel: 'Create',
        subtitle: 'Auto-creates: PYQs · Notes · Important Questions',
      ),
    );
    if (result != null && mounted) {
      try {
        final updated = await LibraryService.createSubject(
          semesterId: semester.id,
          name: result,
          current: _semesters,
        );
        setState(() {
          _semesters = updated;
          _expandedSemesters.add(semester.id);
        });
        _showSnack('"$result" added to ${semester.name}');
      } on ArgumentError catch (e) {
        _showSnack(e.message.toString(), isError: true);
      }
    }
  }

  Future<void> _showRenameSubjectDialog(
    LibrarySemester semester,
    LibrarySubject subject,
  ) async {
    final ctrl = TextEditingController(text: subject.name);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _NameDialog(
        title: 'Rename Subject',
        hint: 'Subject name',
        controller: ctrl,
        actionLabel: 'Save',
      ),
    );
    if (result != null && mounted) {
      try {
        final updated = await LibraryService.renameSubject(
          semesterId: semester.id,
          subjectId: subject.id,
          newName: result,
          current: _semesters,
        );
        setState(() => _semesters = updated);
        _showSnack('Renamed to "$result"');
      } on ArgumentError catch (e) {
        _showSnack(e.message.toString(), isError: true);
      }
    }
  }

  Future<void> _confirmDeleteSubject(
    LibrarySemester semester,
    LibrarySubject subject,
  ) async {
    final confirmed = await _showDeleteDialog(
      title: 'Delete Subject',
      message:
          'Delete "${subject.name}" and its categories including all PDFs?\n\nThis cannot be undone.',
    );
    if (confirmed && mounted) {
      final updated = await LibraryService.deleteSubject(
        semesterId: semester.id,
        subjectId: subject.id,
        current: _semesters,
      );
      final files = await LibraryService.loadFiles();
      setState(() {
        _semesters = updated;
        _allFiles = files;
        _expandedSubjects.remove(subject.id);
        _expandedCategories.remove(subject.id);
      });
      _showSnack('"${subject.name}" deleted');
    }
  }

  // ─── PDF CRUD ─────────────────────────────────────────────────────────────
  Future<void> _addPdf({
    required LibrarySemester semester,
    required LibrarySubject subject,
    required LibraryCategoryModel category,
  }) async {
    try {
      final platformFile = await LibraryService.pickPdf();
      if (platformFile == null || !mounted) return; // user cancelled

      final updated = await LibraryService.addPdf(
        platformFile: platformFile,
        semesterId: semester.id,
        subjectId: subject.id,
        subjectName: subject.name,
        category: category.category,
        current: _allFiles,
      );
      
      // Reload stats
      final stats = await LibraryHistoryService.getStats(
        allFiles: updated,
        allSemesters: _semesters,
      );
      
      setState(() {
        _allFiles = updated;
        _stats = stats;
      });
      _showSnack('"${platformFile.name}" added to ${category.name}');
    } on StateError catch (e) {
      _showSnack(e.message, isError: true);
    }
  }

  Future<void> _deletePdf(LibraryFileModel file) async {
    final confirmed = await _showDeleteDialog(
      title: 'Remove PDF',
      message: 'Remove "${file.fileName}" from ${file.subjectName}?',
    );
    if (confirmed && mounted) {
      final updated =
          await LibraryService.deletePdf(fileId: file.id, current: _allFiles);
      
      // Remove from favorites if present
      await LibraryHistoryService.removeFavorite(file.id);
      _favoriteIds.remove(file.id);
      
      // Remove from recent if present
      _recentIds.remove(file.id);
      await LibraryHistoryService.saveRecent(_recentIds);
      
      // Reload stats
      final stats = await LibraryHistoryService.getStats(
        allFiles: updated,
        allSemesters: _semesters,
      );
      
      setState(() {
        _allFiles = updated;
        _stats = stats;
      });
      _showSnack('"${file.fileName}" removed');
    }
  }

  // ─── Phase 5D: Favorites & Recent ─────────────────────────────────────────
  
  Future<void> _toggleFavorite(LibraryFileModel file) async {
    if (_favoriteIds.contains(file.id)) {
      await LibraryHistoryService.removeFavorite(file.id);
      _favoriteIds.remove(file.id);
      _showSnack('"${file.fileName}" removed from favorites');
    } else {
      await LibraryHistoryService.addFavorite(file.id);
      _favoriteIds.add(file.id);
      _showSnack('"${file.fileName}" added to favorites');
    }
    
    // Recalculate stats
    final stats = await LibraryHistoryService.getStats(
      allFiles: _allFiles,
      allSemesters: _semesters,
    );
    
    setState(() => _stats = stats);
  }

  Future<void> _openPdf(LibraryFileModel file) async {
    // Record this file as recently opened
    _recentIds.remove(file.id);
    _recentIds.insert(0, file.id);
    _recentIds = _recentIds.take(10).toList();
    
    await LibraryHistoryService.recordOpenedFile(file.id);
    
    // Recalculate stats
    final stats = await LibraryHistoryService.getStats(
      allFiles: _allFiles,
      allSemesters: _semesters,
    );
    
    setState(() => _stats = stats);
    
    // Navigate to viewer
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(
            fileName: file.fileName,
            filePath: file.filePath,
          ),
        ),
      );
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
  }

  Future<bool> _showDeleteDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Set<String> _categoriesFor(String subjectId) =>
      _expandedCategories.putIfAbsent(subjectId, () => {});

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search PDFs, subjects…',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  isDense: true,
                ),
              )
            : const Text('Library'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Cancel Search',
              onPressed: _stopSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search',
              onPressed: _startSearch,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSemesterDialog,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.create_new_folder_rounded),
        label: const Text('Add Semester'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSearching && _searchQuery.trim().isNotEmpty
              ? _buildSearchResults()
              : _buildTree(),
    );
  }

  // ─── Tree ─────────────────────────────────────────────────────────────────
  Widget _buildTree() {
    if (_semesters.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          0,
          AppDimens.screenPadding,
          0,
          120,
        ),
        children: [
          // Statistics Card
          if (_stats != null)
            LibraryStatsCard(stats: _stats!),
          
          // Favorites Section
          if (_favoriteIds.isNotEmpty)
            ..._buildFavoritesSection(),
          
          // Recently Opened Section
          if (_recentIds.isNotEmpty)
            ..._buildRecentSection(),
          
          // Divider if there are favorites/recent
          if (_favoriteIds.isNotEmpty || _recentIds.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenPadding,
                vertical: AppDimens.md,
              ),
              child: Divider(
                color: AppColors.divider,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: AppDimens.screenPadding,
                right: AppDimens.screenPadding,
                bottom: AppDimens.sm,
              ),
              child: Text(
                'Library',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
          
          // Semesters List
          ..._semesters.map((sem) => _buildSemesterTile(sem)),
        ],
      ),
    );
  }

  List<Widget> _buildFavoritesSection() {
    final favoriteFiles = _allFiles.where((f) => _favoriteIds.contains(f.id)).toList();
    if (favoriteFiles.isEmpty) return [];
    
    // Sort by creation date (newest first)
    favoriteFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return [
      Padding(
        padding: const EdgeInsets.only(
          left: AppDimens.screenPadding,
          right: AppDimens.screenPadding,
          bottom: AppDimens.sm,
        ),
        child: Row(
          children: [
            Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
            const SizedBox(width: AppDimens.xs),
            Text(
              'Favorites',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      ...favoriteFiles.map((file) => FavoritePdfTile(
        key: ValueKey('fav_${file.id}'),
        file: file,
        onRemoveFavorite: () => _toggleFavorite(file),
        onTap: () => _openPdf(file),
      )),
      const SizedBox(height: AppDimens.md),
    ];
  }

  List<Widget> _buildRecentSection() {
    final recentFiles = _recentIds
        .where((id) => _allFiles.any((f) => f.id == id))
        .map((id) => _allFiles.firstWhere((f) => f.id == id))
        .toList();
    
    if (recentFiles.isEmpty) return [];
    
    return [
      Padding(
        padding: const EdgeInsets.only(
          left: AppDimens.screenPadding,
          right: AppDimens.screenPadding,
          bottom: AppDimens.sm,
        ),
        child: Row(
          children: [
            Icon(Icons.history_rounded, color: AppColors.success, size: 18),
            const SizedBox(width: AppDimens.xs),
            Text(
              'Recently Opened',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      ...recentFiles.take(5).map((file) => RecentPdfTile(
        key: ValueKey('recent_${file.id}'),
        file: file,
        onTap: () => _openPdf(file),
      )),
      const SizedBox(height: AppDimens.md),
    ];
  }

  Widget _buildSemesterTile(LibrarySemester semester) {
    final isExpanded = _expandedSemesters.contains(semester.id);

    return SemesterTile(
      semesterName: semester.name,
      subjectCount: semester.subjects.length,
      isExpanded: isExpanded,
      onToggle: () => setState(() {
        if (isExpanded) {
          _expandedSemesters.remove(semester.id);
        } else {
          _expandedSemesters.add(semester.id);
        }
      }),
      onRename: () => _showRenameSemesterDialog(semester),
      onDelete: () => _confirmDeleteSemester(semester),
      onAddSubject: () => _showAddSubjectDialog(semester),
      children: semester.subjects.isEmpty
          ? [_buildEmptySubjectHint(semester)]
          : semester.subjects
              .map((sub) => _buildSubjectTile(semester, sub))
              .toList(),
    );
  }

  Widget _buildEmptySubjectHint(LibrarySemester semester) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.screenPadding,
        vertical: AppDimens.md,
      ),
      child: Row(
        children: [
          const SizedBox(width: AppDimens.lg),
          Icon(Icons.add_circle_outline_rounded,
              color: AppColors.textTertiary, size: AppDimens.iconSm),
          const SizedBox(width: AppDimens.sm),
          Text(
            'No subjects yet. Tap ⋮ → Add Subject.',
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTile(LibrarySemester semester, LibrarySubject subject) {
    final isExpanded = _expandedSubjects.contains(subject.id);
    final catExpanded = _categoriesFor(subject.id);

    return SubjectTile(
      key: ValueKey(subject.id),
      subject: subject,
      isExpanded: isExpanded,
      expandedCategories: catExpanded,
      allFiles: _allFiles,
      onToggle: () => setState(() {
        if (isExpanded) {
          _expandedSubjects.remove(subject.id);
        } else {
          _expandedSubjects.add(subject.id);
        }
      }),
      onCategoryToggle: (catId) => setState(() {
        if (catExpanded.contains(catId)) {
          catExpanded.remove(catId);
        } else {
          catExpanded.add(catId);
        }
      }),
      onRename: () => _showRenameSubjectDialog(semester, subject),
      onDelete: () => _confirmDeleteSubject(semester, subject),
      onAddPdf: (cat) => _addPdf(
        semester: semester,
        subject: subject,
        category: cat,
      ),
      onDeletePdf: _deletePdf,
      onTapPdf: _openPdf,
      favoriteIds: _favoriteIds,
      onFavoriteToggle: _toggleFavorite,
    );
  }

  // ─── Search Results ───────────────────────────────────────────────────────
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: AppColors.textTertiary),
            const SizedBox(height: AppDimens.lg),
            Text(
              'No results for "$_searchQuery"',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      itemCount: _searchResults.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppDimens.sm),
      itemBuilder: (_, index) =>
          _buildSearchResultTile(_searchResults[index]),
    );
  }

  Widget _buildSearchResultTile(LibrarySearchResult result) {
    final isSemester = result.type == LibrarySearchResultType.semester;
    return InkWell(
      onTap: () {
        _stopSearch();
        setState(() {
          _expandedSemesters.add(result.semesterId);
          if (!isSemester && result.subjectId != null) {
            _expandedSubjects.add(result.subjectId!);
          }
        });
      },
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.md, vertical: AppDimens.sm),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: AppColors.divider),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSemester
                    ? AppColors.primaryBlue.withValues(alpha: 0.12)
                    : AppColors.secondaryPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Icon(
                isSemester ? Icons.folder_rounded : Icons.book_rounded,
                color: isSemester
                    ? AppColors.primaryBlue
                    : AppColors.secondaryPurple,
                size: AppDimens.iconMd,
              ),
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSemester ? result.semesterName : result.subjectName!,
                    style: AppTextStyles.labelMedium,
                  ),
                  if (!isSemester)
                    Text(
                      result.semesterName,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textTertiary),
                    ),
                ],
              ),
            ),
            Chip(
              label: Text(
                isSemester ? 'Semester' : 'Subject',
                style: AppTextStyles.caption.copyWith(
                  color: isSemester
                      ? AppColors.primaryBlue
                      : AppColors.secondaryPurple,
                ),
              ),
              backgroundColor: isSemester
                  ? AppColors.primaryBlue.withValues(alpha: 0.10)
                  : AppColors.secondaryPurple.withValues(alpha: 0.10),
              side: BorderSide.none,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimens.radiusXl),
              ),
              child: const Icon(Icons.library_books_rounded,
                  size: 52, color: Colors.white),
            ),
            const SizedBox(height: AppDimens.xl),
            Text('Your Library is Empty', style: AppTextStyles.heading3,
                textAlign: TextAlign.center),
            const SizedBox(height: AppDimens.sm),
            Text(
              'Start by creating a semester folder.\nAdd subjects to import PDFs for\nPYQs, Notes & Important Questions.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.xxl),
            FilledButton.icon(
              onPressed: _showAddSemesterDialog,
              icon: const Icon(Icons.create_new_folder_rounded),
              label: const Text('Create First Semester'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.xl, vertical: AppDimens.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable Name Dialog ─────────────────────────────────────────────────────

class _NameDialog extends StatelessWidget {
  const _NameDialog({
    required this.title,
    required this.hint,
    required this.controller,
    required this.actionLabel,
    this.subtitle,
  });

  final String title;
  final String hint;
  final TextEditingController controller;
  final String actionLabel;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            Text(subtitle!,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppDimens.md),
          ],
          TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (val) {
              final trimmed = val.trim();
              if (trimmed.isNotEmpty) Navigator.pop(context, trimmed);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final trimmed = controller.text.trim();
            if (trimmed.isNotEmpty) Navigator.pop(context, trimmed);
          },
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryBlue),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}
