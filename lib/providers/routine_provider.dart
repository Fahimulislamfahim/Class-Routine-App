import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/routine_model.dart';
import '../models/class_session.dart';
import '../services/gemini_vision_service.dart';
import '../services/storage_service.dart';
import '../services/calendar_export_service.dart';
import '../data/sample_routine_data.dart';

class RoutineProvider extends ChangeNotifier {
  final GeminiVisionService _visionService = GeminiVisionService();

  RoutineModel? _routine;
  bool _isLoading = false;
  String _statusMessage = '';
  String? _errorMessage;
  String _subgroupFilter = 'ALL';
  String _searchQuery = '';
  String _viewMode = 'grid'; // 'grid' or 'agenda'
  String? _selectedDay;
  bool _isDarkMode = false;
  String _apiKey = '';
  String _selectedModel = GeminiVisionService.defaultModel;
  Uint8List? _routineImageBytes;
  String? _routineImageName;

  // Getters
  RoutineModel? get routine => _routine;
  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;
  String get subgroupFilter => _subgroupFilter;
  String get searchQuery => _searchQuery;
  String get viewMode => _viewMode;
  String? get selectedDay => _selectedDay;
  bool get isDarkMode => _isDarkMode;
  String get apiKey => _apiKey;
  String get selectedModel => _selectedModel;
  Uint8List? get routineImageBytes => _routineImageBytes;
  String? get routineImageName => _routineImageName;
  bool get hasApiKey => _apiKey.trim().isNotEmpty;

  /// Check if a given filter key is active
  bool isFilterActive(String key) {
    if (_subgroupFilter == key) return true;
    if (_subgroupFilter == 'ALL' || _subgroupFilter == 'THEORY' || _subgroupFilter == 'LAB') {
      return false;
    }
    // Suffix match: e.g. active is 'D1', matches 'A1' on new routine
    if (key.endsWith('1') && _subgroupFilter.endsWith('1')) return true;
    if (key.endsWith('2') && _subgroupFilter.endsWith('2')) return true;
    return false;
  }

  /// Initialize provider from storage
  Future<void> init() async {
    _apiKey = await StorageService.getApiKey() ?? '';
    _selectedModel = await StorageService.getModel();
    _subgroupFilter = await StorageService.getSubgroupFilter();
    _isDarkMode = await StorageService.getDarkMode();

    final savedRoutine = await StorageService.loadSavedRoutine();
    if (savedRoutine != null) {
      _routine = savedRoutine;
      _alignSubgroupFilterWithRoutine();
    } else {
      // Default to sample routine
      await loadSampleRoutine();
    }
    notifyListeners();
  }

  void setApiKey(String key) {
    _apiKey = key.trim();
    StorageService.saveApiKey(_apiKey);
    notifyListeners();
  }

  void setSelectedModel(String model) {
    _selectedModel = model;
    StorageService.saveModel(model);
    notifyListeners();
  }

  void setSubgroupFilter(String filter) {
    _subgroupFilter = filter;
    StorageService.saveSubgroupFilter(filter);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setViewMode(String mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setSelectedDay(String? day) {
    _selectedDay = day;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    StorageService.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  /// Align subgroup filter if section changed (e.g. from D1 to A1)
  void _alignSubgroupFilterWithRoutine() {
    if (_routine == null) return;
    if (_subgroupFilter == 'ALL' || _subgroupFilter == 'THEORY' || _subgroupFilter == 'LAB') {
      return;
    }
    final available = _routine!.availableSubgroups;
    if (available.contains(_subgroupFilter)) return;

    // Try finding matching group 1 or 2
    if (_subgroupFilter.endsWith('1')) {
      final match1 = available.firstWhere((g) => g.endsWith('1'), orElse: () => available.first);
      _subgroupFilter = match1;
    } else if (_subgroupFilter.endsWith('2')) {
      final match2 = available.firstWhere((g) => g.endsWith('2'), orElse: () => available.last);
      _subgroupFilter = match2;
    } else {
      _subgroupFilter = 'ALL';
    }
    StorageService.saveSubgroupFilter(_subgroupFilter);
  }

  /// Load sample demo routine
  Future<void> loadSampleRoutine() async {
    _isLoading = true;
    _statusMessage = 'Loading sample DIU routine...';
    _errorMessage = null;
    notifyListeners();

    try {
      final byteData = await rootBundle.load(SampleRoutineData.sampleAssetPath);
      _routineImageBytes = byteData.buffer.asUint8List();
      _routineImageName = 'sample_routine_section_D.jpg';
    } catch (_) {}

    _routine = SampleRoutineData.getSampleRoutine();
    _alignSubgroupFilterWithRoutine();
    await StorageService.saveRoutine(_routine!);
    _isLoading = false;
    _statusMessage = '';
    notifyListeners();
  }

  /// Process uploaded routine image with Gemini Multimodal Vision
  Future<void> extractFromImageBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    _routineImageBytes = bytes;
    _routineImageName = filename;
    _errorMessage = null;
    _isLoading = true;
    _statusMessage = 'Preprocessing routine image...';
    notifyListeners();

    try {
      if (_apiKey.trim().isEmpty) {
        throw Exception(
          'Gemini API Key is not set. Please click the API Key button at the top right to configure your Google Gemini API Key, or use the Demo Routine.',
        );
      }

      _statusMessage = 'Connecting to Gemini Vision ($_selectedModel)...';
      notifyListeners();

      _statusMessage = 'Analyzing schedule grid and extracting sessions...';
      notifyListeners();

      final extractedRoutine = await _visionService.extractRoutineFromImage(
        imageBytes: bytes,
        apiKey: _apiKey,
        mimeType: mimeType,
        model: _selectedModel,
      );

      _routine = extractedRoutine;
      _alignSubgroupFilterWithRoutine();
      await StorageService.saveRoutine(extractedRoutine);

      _statusMessage = 'Extraction complete! Loaded ${extractedRoutine.schedule.length} sessions for Section ${extractedRoutine.metadata.section}.';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Update existing class session
  void updateSession(ClassSession updated) {
    if (_routine == null) return;
    final index = _routine!.schedule.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      final updatedList = List<ClassSession>.from(_routine!.schedule);
      updatedList[index] = updated;
      _routine = _routine!.copyWith(schedule: updatedList);
      StorageService.saveRoutine(_routine!);
      notifyListeners();
    }
  }

  /// Add new class session
  void addSession(ClassSession newSession) {
    if (_routine == null) return;
    final updatedList = List<ClassSession>.from(_routine!.schedule)..add(newSession);
    _routine = _routine!.copyWith(schedule: updatedList);
    StorageService.saveRoutine(_routine!);
    notifyListeners();
  }

  /// Delete class session
  void deleteSession(String id) {
    if (_routine == null) return;
    final updatedList = _routine!.schedule.where((s) => s.id != id).toList();
    _routine = _routine!.copyWith(schedule: updatedList);
    StorageService.saveRoutine(_routine!);
    notifyListeners();
  }

  /// Export routine as JSON
  void exportJson() {
    if (_routine == null) return;
    final jsonStr = const JsonEncoder.withIndent('  ').convert(_routine!.toJson());
    final filename = 'routine_${_routine!.metadata.section}_batch${_routine!.metadata.batch}.json';
    CalendarExportService.downloadFile(jsonStr, filename, 'application/json');
  }

  /// Export routine as .ics calendar
  void exportICalendar() {
    if (_routine == null) return;
    final icsStr = CalendarExportService.generateICalendar(_routine!, subgroupFilter: _subgroupFilter);
    final filename = 'routine_${_routine!.metadata.section}_group$_subgroupFilter.ics';
    CalendarExportService.downloadFile(icsStr, filename, 'text/calendar');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
