import 'package:flutter/foundation.dart';
import '../models/mango_model.dart';
import '../services/mango_service.dart';

class MangoProvider with ChangeNotifier {
  final MangoService _mangoService = MangoService();

  List<MangoModel> _mangoes = [];
  List<MangoModel> get mangoes => _mangoes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Load all mangoes
  Future<void> loadMangoes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mangoes = await _mangoService.getAllMangoes();
    } catch (e) {
      _errorMessage = 'Failed to load mangoes: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get mango by ID
  MangoModel? getMangoById(String id) {
    try {
      return _mangoes.firstWhere((mango) => mango.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add mango (Admin)
  Future<bool> addMango(MangoModel mango) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _mangoService.addMango(mango);
      if (success) {
        _mangoes.add(mango);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to add mango: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update mango (Admin)
  Future<bool> updateMango(MangoModel mango) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _mangoService.updateMango(mango);
      if (success) {
        final index = _mangoes.indexWhere((m) => m.id == mango.id);
        if (index != -1) {
          _mangoes[index] = mango;
        }
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update mango: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete mango (Admin)
  Future<bool> deleteMango(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _mangoService.deleteMango(id);
      if (success) {
        _mangoes.removeWhere((mango) => mango.id == id);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete mango: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search mangoes
  Future<void> searchMangoes(String query) async {
    if (query.isEmpty) {
      await loadMangoes();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _mangoes = await _mangoService.searchMangoes(query);
    } catch (e) {
      _errorMessage = 'Search failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
