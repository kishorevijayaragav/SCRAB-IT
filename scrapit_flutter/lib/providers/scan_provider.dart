import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/scan_result.dart';
import '../services/api_service.dart';

enum ScanStep {
  scanningImage('Scanning image'),
  identifyingMaterial('Identifying material'),
  estimatingQuantity('Estimating quantity'),
  checkingMarketPrice('Checking market price');

  final String label;
  const ScanStep(this.label);
}

class ScanProvider extends ChangeNotifier {
  final ApiService _apiService;
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedFile;
  bool _isAnalyzing = false;
  ScanStep _currentStep = ScanStep.scanningImage;
  double _analysisProgress = 0.0;
  ScanResult? _latestResult;
  String? _errorMessage;

  ScanProvider({required ApiService apiService}) : _apiService = apiService;

  XFile? get selectedFile => _selectedFile;
  bool get isAnalyzing => _isAnalyzing;
  ScanStep get currentStep => _currentStep;
  double get analysisProgress => _analysisProgress;
  ScanResult? get latestResult => _latestResult;
  String? get errorMessage => _errorMessage;

  void clearSelection() {
    _selectedFile = null;
    _errorMessage = null;
    notifyListeners();
  }

  void resetResult() {
    _latestResult = null;
    _selectedFile = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    _errorMessage = null;
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );
      if (picked != null) {
        _selectedFile = picked;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to capture or pick image: $e';
      notifyListeners();
    }
  }

  void setSelectedFile(XFile file) {
    _selectedFile = file;
    _errorMessage = null;
    notifyListeners();
  }

  Future<ScanResult?> analyze() async {
    if (_selectedFile == null) {
      _errorMessage = 'Please select or capture an image first';
      notifyListeners();
      return null;
    }

    _isAnalyzing = true;
    _analysisProgress = 0.1;
    _currentStep = ScanStep.scanningImage;
    _errorMessage = null;
    notifyListeners();

    try {
      // Step 1: Scanning Image
      await Future.delayed(const Duration(milliseconds: 400));
      _analysisProgress = 0.35;
      _currentStep = ScanStep.identifyingMaterial;
      notifyListeners();

      // Upload in background
      String? uploadedUrl;
      try {
        uploadedUrl = await _apiService.uploadImage(
          _selectedFile!.path,
          _selectedFile!.name,
        );
      } catch (_) {}

      // Step 2: Identifying Material
      await Future.delayed(const Duration(milliseconds: 500));
      _analysisProgress = 0.65;
      _currentStep = ScanStep.estimatingQuantity;
      notifyListeners();

      // Step 3: Estimating Quantity
      await Future.delayed(const Duration(milliseconds: 450));
      _analysisProgress = 0.85;
      _currentStep = ScanStep.checkingMarketPrice;
      notifyListeners();

      // Call analyze endpoint
      final result = await _apiService.analyzeScan(
        imageUrl: uploadedUrl,
        filename: _selectedFile!.name,
      );

      _analysisProgress = 1.0;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));

      _latestResult = result;
      _isAnalyzing = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isAnalyzing = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
