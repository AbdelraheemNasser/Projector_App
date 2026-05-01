import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../models/doctor.dart';
import 'pdf_viewer_screen.dart';

class PDFScreen extends StatefulWidget {
  final Doctor doctor;

  const PDFScreen({super.key, required this.doctor});

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  List<String> _pdfPaths = [];
  bool _isConnected = false;
  static const platform = MethodChannel('com.videocaster/display');

  @override
  void initState() {
    super.initState();
    _loadPDFs();
    _setupDisplayListener();
  }

  void _setupDisplayListener() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onDisplayConnected') {
        setState(() => _isConnected = true);
      } else if (call.method == 'onDisplayDisconnected') {
        setState(() => _isConnected = false);
      }
    });
  }

  Future<void> _loadPDFs() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'pdfs_${widget.doctor.username}';
    final savedPDFs = prefs.getStringList(key) ?? [];
    
    // Filter out PDFs that no longer exist
    final existingPDFs = <String>[];
    for (final path in savedPDFs) {
      if (await File(path).exists()) {
        existingPDFs.add(path);
      }
    }
    
    setState(() {
      _pdfPaths = existingPDFs;
    });
    
    // Save the filtered list
    if (existingPDFs.length != savedPDFs.length) {
      await prefs.setStringList(key, existingPDFs);
    }
  }

  Future<void> _savePDFs() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'pdfs_${widget.doctor.username}';
    await prefs.setStringList(key, _pdfPaths);
  }

  Future<void> _pickPDF() async {
    if (_pdfPaths.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يمكنك إضافة 3 ملفات PDF كحد أقصى'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      
      if (!_pdfPaths.contains(path)) {
        setState(() {
          _pdfPaths.add(path);
        });
        await _savePDFs();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إضافة ملف PDF بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('هذا الملف موجود بالفعل'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _removePDF(int index) async {
    setState(() {
      _pdfPaths.removeAt(index);
    });
    await _savePDFs();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف ملف PDF'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _openPDF(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(
          pdfPath: path,
          doctorName: widget.doctor.fullName,
        ),
      ),
    );
  }

  Future<void> _startCasting() async {
    try {
      await platform.invokeMethod('startCasting');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'محاضرات PDF',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
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
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'ملفات PDF الخاصة بك (${_pdfPaths.length}/3)',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: _pdfPaths.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF7B2FF7).withOpacity(0.3),
                                    Color(0xFFE94560).withOpacity(0.3)
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.picture_as_pdf,
                                size: 70,
                                color: Colors.white54,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'لم يتم إضافة ملفات PDF',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'اضغط على الزر أدناه لإضافة ملفات',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _pdfPaths.length,
                        itemBuilder: (context, index) {
                          final path = _pdfPaths[index];
                          final fileName = _getFileName(path);
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF7B2FF7).withOpacity(0.3),
                                  Color(0xFFE94560).withOpacity(0.3)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Color(0xFF7B2FF7).withOpacity(0.5),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _openPDF(path),
                                borderRadius: BorderRadius.circular(15),
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF7B2FF7),
                                              Color(0xFFE94560)
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              fileName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'اضغط للعرض',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _removePDF(index),
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Color(0xFFE94560),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF7B2FF7), Color(0xFFE94560)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF7B2FF7).withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _pdfPaths.length < 3 ? _pickPDF : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'إضافة ملف PDF',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (_pdfPaths.isNotEmpty) ...[
                      SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00D4FF), Color(0xFF7B2FF7)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF00D4FF).withOpacity(0.3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _startCasting,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: Icon(Icons.cast, color: Colors.white),
                          label: Text(
                            'بدء العرض',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (_isConnected)
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      'متصل بالشاشة',
                      style: TextStyle(color: Colors.green, fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
