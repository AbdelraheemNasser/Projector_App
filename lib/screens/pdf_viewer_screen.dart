import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

class PDFViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String doctorName;

  const PDFViewerScreen({
    super.key,
    required this.pdfPath,
    required this.doctorName,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isReady = false;
  PDFViewController? _pdfViewController;

  String _getFileName() {
    return widget.pdfPath.split('/').last;
  }

  void _goToFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenPDFViewer(
          pdfPath: widget.pdfPath,
          currentPage: _currentPage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getFileName(),
              style: TextStyle(color: Colors.white, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_isReady)
              Text(
                'صفحة ${_currentPage + 1} من $_totalPages',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.fullscreen, color: Color(0xFF00D4FF)),
            onPressed: _goToFullScreen,
            tooltip: 'ملء الشاشة',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF7B2FF7).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: PDFView(
                    filePath: widget.pdfPath,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: true,
                    pageFling: true,
                    pageSnap: true,
                    defaultPage: _currentPage,
                    fitPolicy: FitPolicy.BOTH,
                    preventLinkNavigation: false,
                    onRender: (pages) {
                      setState(() {
                        _totalPages = pages ?? 0;
                        _isReady = true;
                      });
                    },
                    onError: (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('خطأ في تحميل PDF: $error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    onPageError: (page, error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('خطأ في الصفحة $page: $error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    onViewCreated: (PDFViewController pdfViewController) {
                      _pdfViewController = pdfViewController;
                    },
                    onPageChanged: (int? page, int? total) {
                      setState(() {
                        _currentPage = page ?? 0;
                        _totalPages = total ?? 0;
                      });
                    },
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A2E).withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: Icons.first_page,
                    label: 'الأولى',
                    onPressed: () {
                      _pdfViewController?.setPage(0);
                    },
                  ),
                  _buildControlButton(
                    icon: Icons.arrow_back_ios,
                    label: 'السابقة',
                    onPressed: _currentPage > 0
                        ? () {
                            _pdfViewController?.setPage(_currentPage - 1);
                          }
                        : null,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7B2FF7), Color(0xFFE94560)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_currentPage + 1}/$_totalPages',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _buildControlButton(
                    icon: Icons.arrow_forward_ios,
                    label: 'التالية',
                    onPressed: _currentPage < _totalPages - 1
                        ? () {
                            _pdfViewController?.setPage(_currentPage + 1);
                          }
                        : null,
                  ),
                  _buildControlButton(
                    icon: Icons.last_page,
                    label: 'الأخيرة',
                    onPressed: () {
                      _pdfViewController?.setPage(_totalPages - 1);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToFullScreen,
        backgroundColor: Color(0xFF00D4FF),
        icon: Icon(Icons.fullscreen, color: Colors.white),
        label: Text(
          'ملء الشاشة',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: isEnabled ? Color(0xFF00D4FF) : Colors.grey,
            size: 24,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isEnabled ? Colors.white : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class FullScreenPDFViewer extends StatefulWidget {
  final String pdfPath;
  final int currentPage;

  const FullScreenPDFViewer({
    super.key,
    required this.pdfPath,
    required this.currentPage,
  });

  @override
  State<FullScreenPDFViewer> createState() => _FullScreenPDFViewerState();
}

class _FullScreenPDFViewerState extends State<FullScreenPDFViewer> {
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isReady = false;
  bool _showControls = true;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentPage;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            PDFView(
              filePath: widget.pdfPath,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: true,
              pageFling: true,
              pageSnap: true,
              defaultPage: _currentPage,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
              onRender: (pages) {
                setState(() {
                  _totalPages = pages ?? 0;
                  _isReady = true;
                });
              },
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في تحميل PDF: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _pdfViewController = pdfViewController;
              },
              onPageChanged: (int? page, int? total) {
                setState(() {
                  _currentPage = page ?? 0;
                  _totalPages = total ?? 0;
                });
              },
            ),
            if (_showControls) ...[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: Colors.white, size: 30),
                        ),
                        if (_isReady)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'صفحة ${_currentPage + 1} من $_totalPages',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        SizedBox(width: 48), // Balance the close button
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFullScreenButton(
                          icon: Icons.first_page,
                          onPressed: () {
                            _pdfViewController?.setPage(0);
                          },
                        ),
                        _buildFullScreenButton(
                          icon: Icons.arrow_back_ios,
                          onPressed: _currentPage > 0
                              ? () {
                                  _pdfViewController?.setPage(_currentPage - 1);
                                }
                              : null,
                        ),
                        _buildFullScreenButton(
                          icon: Icons.arrow_forward_ios,
                          onPressed: _currentPage < _totalPages - 1
                              ? () {
                                  _pdfViewController?.setPage(_currentPage + 1);
                                }
                              : null,
                        ),
                        _buildFullScreenButton(
                          icon: Icons.last_page,
                          onPressed: () {
                            _pdfViewController?.setPage(_totalPages - 1);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;
    return Container(
      decoration: BoxDecoration(
        color: isEnabled
            ? Color(0xFF00D4FF).withOpacity(0.8)
            : Colors.grey.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
