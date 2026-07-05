import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../core/core.dart';
import '../widgets/pdf_loading_widget.dart';

/// Screen that views local PDF files using Syncfusion PDF Viewer.
///
/// Features scroll, zoom, page navigation, custom loading state,
/// and handles missing/corrupt files gracefully with a themed error state.
class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({
    super.key,
    required this.fileName,
    required this.filePath,
  });

  final String fileName;
  final String filePath;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  void initState() {
    super.initState();
    _checkFileExistence();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _checkFileExistence() {
    try {
      final file = File(widget.filePath);
      if (!file.existsSync()) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'The file could not be found on this device. It may have been moved or deleted.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'An error occurred while opening the file: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName,
          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _hasError
          ? _buildErrorState()
          : Stack(
              children: [
                SfPdfViewer.file(
                  File(widget.filePath),
                  controller: _pdfViewerController,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                  enableDoubleTapZooming: true,
                  canShowPageLoadingIndicator: false, // hide syncfusion loader to show ours
                  onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                        _hasError = true;
                        _errorMessage = details.description;
                      });
                    }
                  },
                ),
                if (_isLoading)
                  const PdfLoadingWidget(),
              ],
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            Text(
              'Failed to Load PDF',
              style: AppTextStyles.heading4.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.sm),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'This file format is invalid or corrupted.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.xxl),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Go Back'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.xl,
                  vertical: AppDimens.md,
                ),
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
