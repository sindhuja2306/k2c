import '../models/mango_model.dart';

class MangoService {
  // Singleton pattern
  static final MangoService _instance = MangoService._internal();
  factory MangoService() => _instance;
  MangoService._internal();

  // In-memory storage (simulates backend persistence)
  static List<MangoModel>? _cachedMangoes;

  // Get all mangoes
  Future<List<MangoModel>> getAllMangoes() async {
    try {
      // Return cached mangoes if available (admin edits persist)
      if (_cachedMangoes != null) {
        await Future.delayed(const Duration(milliseconds: 300));
        return List<MangoModel>.from(_cachedMangoes!);
      }

      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Mock data (initial load)
      _cachedMangoes = [
        MangoModel(
          id: '1',
          name: 'Alphonso Mango',
          description: 'Premium quality Alphonso mangoes from Ratnagiri',
          price: 299.99,
          imageUrl: 'https://via.placeholder.com/150',
          stock: 50,
          category: 'Premium',
          rating: 4.8,
        ),
        MangoModel(
          id: '2',
          name: 'Kesar Mango',
          description: 'Sweet and aromatic Kesar mangoes from Gujarat',
          price: 249.99,
          imageUrl: 'https://via.placeholder.com/150',
          stock: 30,
          category: 'Premium',
          rating: 4.6,
        ),
        MangoModel(
          id: '3',
          name: 'Totapuri Mango',
          description: 'Fresh Totapuri mangoes perfect for making pickles',
          price: 149.99,
          imageUrl: 'https://via.placeholder.com/150',
          stock: 100,
          category: 'Regular',
          rating: 4.2,
        ),
      ];
      return List<MangoModel>.from(_cachedMangoes!);
    } catch (e) {
      throw Exception('Failed to load mangoes');
    }
  }

  // Get mango by ID
  Future<MangoModel?> getMangoById(String id) async {
    try {
      // TODO: Implement API call
      final mangoes = await getAllMangoes();
      return mangoes.firstWhere((mango) => mango.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add mango (Admin only)
  Future<bool> addMango(MangoModel mango) async {
    try {
      // Ensure cache is initialized
      if (_cachedMangoes == null) {
        await getAllMangoes();
      }
      // TODO: Implement API call
      await Future.delayed(const Duration(milliseconds: 500));
      _cachedMangoes!.insert(0, mango);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update mango (Admin only)
  Future<bool> updateMango(MangoModel mango) async {
    try {
      // Ensure cache is initialized
      if (_cachedMangoes == null) {
        await getAllMangoes();
      }
      // TODO: Implement API call
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _cachedMangoes!.indexWhere((m) => m.id == mango.id);
      if (index != -1) {
        _cachedMangoes![index] = mango;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete mango (Admin only)
  Future<bool> deleteMango(String id) async {
    try {
      // Ensure cache is initialized
      if (_cachedMangoes == null) {
        await getAllMangoes();
      }
      // TODO: Implement API call
      await Future.delayed(const Duration(milliseconds: 500));
      _cachedMangoes!.removeWhere((mango) => mango.id == id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Search mangoes
  Future<List<MangoModel>> searchMangoes(String query) async {
    try {
      final mangoes = await getAllMangoes();
      return mangoes
          .where((mango) =>
              mango.name.toLowerCase().contains(query.toLowerCase()) ||
              mango.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
