# Inspiria Frontend - User Data Management Guide

## Overview
The Inspiria Flutter app uses a **ChangeNotifier-based state management** (NOT Riverpod) for authentication and user data. Different screens use service classes for fetching specific data from the backend.

---

## 1. Current Logged-in User Data Management

### Main State Management: `AuthProvider`
**Location:** [lib/features/auth/logic/provider/auth_provider.dart](lib/features/auth/logic/provider/auth_provider.dart)

**What it manages:**
- Current user authentication state (`_currentUser: UserEntity?`)
- Authentication status (`_status: AuthStatus`)
- Access token (`_accessToken: String?`)

**Key Properties:**
```dart
AuthStatus get status => _status;              // Authentication status (unknown, authenticated, unauthenticated)
UserEntity? get currentUser => _currentUser;   // Current logged-in user
String? get accessToken => _accessToken;       // JWT access token
```

**How it works:**
```dart
// The AuthProvider listens to AuthRepository for auth status changes
_authRepository.authStatus.listen((status) {
  _status = status;
  if (status != AuthStatus.authenticated) {
    _currentUser = null;
    _accessToken = null;
  }
  notifyListeners();
});
```

### AuthRepository
**Location:** [lib/core/api/repository/auth_repository.dart](lib/core/api/repository/auth_repository.dart)

**Interface:**
```dart
abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<void> logout();
  Future<String?> getAccessToken();
  Future<void> saveAccessToken(String token);
  Future<String?> getRefreshToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> refreshAccessToken();
  Stream<AuthStatus> get authStatus;
  AuthStatus get currentStatus;
}

enum AuthStatus { unknown, authenticated, unauthenticated }
```

### Token Storage (Secure Storage)
**Location:** [lib/core/api/token_storage.dart](lib/core/api/token_storage.dart)

Uses **FlutterSecureStorage** to securely store:
- `access_token` - JWT token
- `refresh_token` - Refresh token
- `user_id` - Current user's ID

**Methods:**
```dart
Future<String?> getAccessToken()      // Get current access token
Future<int?> getUserId()               // Get current user's ID (stored as string, returns int)
Future<void> saveAccessToken(String token)
Future<void> saveRefreshToken(String token)
Future<void> saveUserId(int id)
Future<void> deleteAllTokens()        // Clear all stored tokens (logout)
```

---

## 2. User Models

### UserEntity (Core Auth Model)
**Location:** [lib/core/api/entity/user_entity.dart](lib/core/api/entity/user_entity.dart)

Minimal auth entity:
```dart
class UserEntity {
  final String id;
  final String email;
}
```

### UserModel (Full User Data)
**Location:** [lib/core/model/user_model.dart](lib/core/model/user_model.dart)

Complete user data model:
```dart
class UserModel {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String? sso;
  final String? profilePictureUrl;
  final bool? isActif;
  final bool? newsletter;
  final String? rememberToken;
  
  // Sensitive fields (not serialized)
  final String? password;
  final String? otp;
  final DateTime? otpGeneratedAt;
}
```

---

## 3. Fetching User Data

### Main User Service
**Location:** [lib/features/profil/data/user_service.dart](lib/features/profil/data/user_service.dart)

**Available Methods:**
```dart
class UserService {
  // Fetch single user by ID
  static Future<UserResponce?> getUserById(String id)
  
  // Fetch all users (admin)
  static Future<UserResponces?> getAllUser()
  
  // Update user data
  static Future<UserResponce?> updateUser(String id, Map<String, dynamic> updatedData)
  
  // Create new user
  static Future<UserResponce?> createUser(Map<String, dynamic> userData)
  
  // Delete user
  static Future<bool> deleteUser(String id)
}
```

**Usage Example (from profil_screen.dart):**
```dart
Future<UserModel?> _fetchProfileData() async {
  // 1. Get current user ID from secure storage
  final int? userId = await TokenStorage().getUserId();
  
  if (userId == null) return null;
  
  // 2. Fetch full user data
  final userResponse = await UserService.getUserById(userId.toString());
  
  // 3. Check response and extract user
  if (userResponse != null && 
      userResponse.statusCode == 200 && 
      userResponse.user != null) {
    return userResponse.user;
  }
  return null;
}
```

---

## 4. User Statistics - Clothing, Looks, Suitcases

### ClothingModel
**Location:** [lib/core/model/clothing_model.dart](lib/core/model/clothing_model.dart)

```dart
class ClothingModel {
  final int? id;
  final String? itemType;        // Type of clothing item
  final String? itemSubtype;     // Subtype
  final String? color;
  final String? size;
  final String? style;
  final String? season;
  final String? gender;
  final String? fabric;
  final String? texture;
  final int? userId;             // Owner's user ID
  final int? clothingModelId;
  final String? imageName;
}
```

### Clothing Service (Clothes Count)
**Location:** [lib/features/outfit/data/clothing_material/clothing_service.dart](lib/features/outfit/data/clothing_material/clothing_service.dart)

**Key Methods:**
```dart
class ClothingService {
  // Get all clothing items for a specific user
  static Future<ClothingResponces?> getClothingByUserId(String userId)
  
  // Get all clothing items (global)
  static Future<ClothingResponces?> getAllClothing()
  
  // Get a specific clothing item
  static Future<ClothingResponce?> getClothingById(String id)
}
```

**To get user's clothing count:**
```dart
final response = await ClothingService.getClothingByUserId(userId);
int clothingCount = response?.clothingList?.length ?? 0;
```

**Response Model:**
```dart
class ClothingResponces {
  final int statusCode;
  final List<ClothingModel>? clothingList;
  final String? errorMessage;
}
```

---

### Outfit Model & Service (Looks Count)
**Location:** [lib/features/outfit/data/outfit_service.dart](lib/features/outfit/data/outfit_service.dart)

**Key Methods:**
```dart
class OutfitService {
  // Get all outfits for a specific user
  static Future<OutfitResponces?> getOutfitByUserId(String userId)
  
  // Get all outfits (global)
  static Future<OutfitResponces?> getAllOutfit()
  
  // Get a specific outfit
  static Future<OutfitResponce?> getOutfitById(String id)
}
```

**To get user's looks/outfits count:**
```dart
final response = await OutfitService.getOutfitByUserId(userId);
int looksCount = response?.outfitList?.length ?? 0;
```

**Response Model:**
```dart
class OutfitResponces {
  final int statusCode;
  final List<OutfitModel>? outfitList;
  final String? errorMessage;
}
```

---

### SuitcaseModel & Service (Suitcases Count)
**Location:** [lib/features/suitcase/data/suitcase_service.dart](lib/features/suitcase/data/suitcase_service.dart)

**Model:**
```dart
class SuitcaseModel {
  final int? id;
  final String name;
  final DateTime departure_date;
  final DateTime end_date;
  final String destination;
  final int user_id;              // Owner's user ID
  final List<Map<String, dynamic>>? clothings;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

**Key Methods:**
```dart
class SuitcaseService {
  // Get all suitcases for a specific user
  static Future<SuitcaseResponces?> getAllSuitcaseByUserId(String userId)
  
  // Get specific suitcase
  static Future<SuitcaseResponce?> getSuitcaseById(String suitcaseId)
}
```

**To get user's suitcases count:**
```dart
final response = await SuitcaseService.getAllSuitcaseByUserId(userId);
int suitcasesCount = response?.suitcaseList?.length ?? 0;
```

**Response Model:**
```dart
class SuitcaseResponces {
  final int statusCode;
  final List<SuitcaseModel>? suitcaseList;
  final String? errorMessage;
}
```

---

## 5. API Endpoints Reference

**Location:** [lib/core/utils/constant/api.dart](lib/core/utils/constant/api.dart)

### User Endpoints
```dart
GET    /user                    // Get all users
GET    /user/{id}              // Get user by ID
PUT    /user/{id}              // Update user
DELETE /user/{id}              // Delete user
POST   /user                   // Create user
```

### Clothing Endpoints
```dart
GET    /clothing               // Get all clothing
GET    /clothing/{id}          // Get clothing by ID
GET    /clothing/user/{userId} // Get user's clothing
POST   /clothing               // Create clothing
PUT    /clothing/{id}          // Update clothing
DELETE /clothing/{id}          // Delete clothing
```

### Outfit Endpoints
```dart
GET    /outfit                      // Get all outfits
GET    /outfit/{id}                 // Get outfit by ID
GET    /outfit/user/{userId}        // Get user's outfits
POST   /outfit                      // Create outfit
PUT    /outfit/{id}                 // Update outfit
DELETE /outfit/{id}                 // Delete outfit
```

### Suitcase Endpoints
```dart
GET    /suitcases                                      // Get all suitcases (includes userId)
POST   /suitcase                                       // Create suitcase
GET    /suitcase/{suitcaseId}                         // Get by ID
PUT    /suitcase/{suitcaseId}                         // Update suitcase
DELETE /suitcase/{suitcaseId}                         // Delete suitcase
POST   /suitcase/{suitcaseId}/add-clothing            // Add clothing to suitcase
POST   /suitcase/{suitcaseId}/remove-clothing         // Remove clothing from suitcase
```

---

## 6. How to Access Data in UI

### Pattern 1: Direct Service Calls (Current Pattern)
```dart
// In a StatefulWidget
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = await TokenStorage().getUserId();
    
    // Get user data
    final userResponse = await UserService.getUserById(userId.toString());
    
    // Get statistics
    final clothingResponse = await ClothingService.getClothingByUserId(userId.toString());
    final outfitsResponse = await OutfitService.getOutfitByUserId(userId.toString());
    final suitcasesResponse = await SuitcaseService.getAllSuitcaseByUserId(userId.toString());
  }
}
```

### Pattern 2: Using FutureBuilder (Current in profil_screen.dart)
```dart
FutureBuilder<UserModel?>(
  future: UserService.getUserById(userId.toString()),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError || !snapshot.hasData) {
      return const Text('Error loading user');
    }
    
    final user = snapshot.data!;
    return Text('${user.firstname} ${user.lastname}');
  },
)
```

### Pattern 3: Using AuthProvider (from auth_provider.dart)
```dart
// Access current user in ChangeNotifier context
final authProvider = Provider.of<AuthProvider>(context);

// Get current user
final currentUser = authProvider.currentUser;    // Returns UserEntity (id + email)
final accessToken = authProvider.accessToken;   // JWT token
final status = authProvider.status;              // AuthStatus enum
```

---

## 7. Authentication Flow

```dart
// 1. Login
await authProvider.login(email, password);

// 2. AuthProvider:
//    - Calls LoginUseCase.call(email, password)
//    - AuthRepository.login() → AuthRemoteDataSource.login()
//    - Receives AuthResponseModel with accessToken, refreshToken, userId
//    - Saves tokens in TokenStorage
//    - Updates _currentUser and _status
//    - Notifies listeners

// 3. In UI:
if (authProvider.status == AuthStatus.authenticated) {
  // User is logged in
  final userId = await TokenStorage().getUserId();
  final accessToken = authProvider.accessToken;
}

// 4. Logout
await authProvider.logout();
// - Clears tokens from storage
// - Sets _currentUser to null
// - Sets _status to unauthenticated
// - NotifyListeners
```

---

## 8. Key Files Summary

| File | Purpose |
|------|---------|
| [auth_provider.dart](lib/features/auth/logic/provider/auth_provider.dart) | Main auth state manager using ChangeNotifier |
| [auth_repository.dart](lib/core/api/repository/auth_repository.dart) | Auth business logic interface |
| [token_storage.dart](lib/core/api/token_storage.dart) | Secure token/user ID storage |
| [user_service.dart](lib/features/profil/data/user_service.dart) | User CRUD operations |
| [clothing_service.dart](lib/features/outfit/data/clothing_material/clothing_service.dart) | Clothing CRUD, get by user |
| [outfit_service.dart](lib/features/outfit/data/outfit_service.dart) | Outfit/Looks CRUD, get by user |
| [suitcase_service.dart](lib/features/suitcase/data/suitcase_service.dart) | Suitcase CRUD, get by user |
| [user_model.dart](lib/core/model/user_model.dart) | Full user data structure |
| [clothing_model.dart](lib/core/model/clothing_model.dart) | Clothing item structure |
| [suitcase_model.dart](lib/core/model/suitcase_model.dart) | Suitcase structure |
| [api.dart](lib/core/utils/constant/api.dart) | API endpoint constants |

---

## 9. Example: Complete Statistics Widget

```dart
// Get all user statistics in one place
Future<Map<String, int>> getUserStatistics(int userId) async {
  try {
    final String userIdStr = userId.toString();
    
    final clothingResponse = await ClothingService.getClothingByUserId(userIdStr);
    final outfitsResponse = await OutfitService.getOutfitByUserId(userIdStr);
    final suitcasesResponse = await SuitcaseService.getAllSuitcaseByUserId(userIdStr);
    
    return {
      'clothing': clothingResponse?.clothingList?.length ?? 0,
      'looks': outfitsResponse?.outfitList?.length ?? 0,
      'suitcases': suitcasesResponse?.suitcaseList?.length ?? 0,
    };
  } catch (e) {
    print('Error fetching statistics: $e');
    return {'clothing': 0, 'looks': 0, 'suitcases': 0};
  }
}
```

---

## 10. Current Issues/Notes

1. **Statistics are hardcoded in home_screen.dart** - The stats section shows hardcoded values ('12', '8', '3') instead of fetching from services
2. **No state management providers** - Uses direct service calls instead of Riverpod or similar
3. **Manual token management** - Tokens accessed directly from TokenStorage in each service
4. **No caching** - Each screen refetches data - no local caching mechanism
5. **Mixed service patterns** - Some services use http.Client, others use Dio

---

## Quick Reference

### Get current user ID:
```dart
final userId = await TokenStorage().getUserId();
```

### Get current user full data:
```dart
final response = await UserService.getUserById(userId.toString());
final user = response?.user;
```

### Get clothing count:
```dart
final response = await ClothingService.getClothingByUserId(userId.toString());
int count = response?.clothingList?.length ?? 0;
```

### Get looks count:
```dart
final response = await OutfitService.getOutfitByUserId(userId.toString());
int count = response?.outfitList?.length ?? 0;
```

### Get suitcases count:
```dart
final response = await SuitcaseService.getAllSuitcaseByUserId(userId.toString());
int count = response?.suitcaseList?.length ?? 0;
```

