import 'dart:core';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  // Auth endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String forgotPasswordEndpoint = '/forgetPassword';
  static const String resetPasswordEndpoint = '/resetPassword';
  static const String verifyOtpEndpoint = '/verifyOtp';
  static const String resetPasswordVerifyEndpoint = '/passwordReset/verifyOtp';
  static const String meEndpoint = '/auth/me';

  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';

  // User endpoints
  static const String getAllUserEndpoint = '/user';
  static const String getUserByIdEndpoint = '/user/{id}';
  static const String updateUserEndpoint = '/user/{id}';
  static const String deleteUserEndpoint = '/user/{id}';
  static const String createUserEndpoint = '/user';

  // Minio endpoints
  static const String minioUploadEndpoint = '/upload';
  static const String minioGetElementEndpoint = '/file/{filename}';

  // OutfitItems endpoints
  static const String createOutfitItemEndpoint = '/outfitItem';
  static const String deleteOutfitItemEndpoint = '/outfitItem/{id}';

  // Address endpoints
  static const String getAllAddressEndpoint = '/address';
  static const String getAddressByIdEndpoint = '/address/{id}';
  static const String getAddressByUserIdEndpoint = '/address/user/{userId}';
  static const String createAddressEndpoint = '/address';
  static const String updateAddressEndpoint = '/address/{id}';
  static const String deleteAddressEndpoint = '/address/{id}';

  // Outfit endpoints
  static const String getAllOutfitEndpoint = '/outfit';
  static const String getOutfitByIdEndpoint = '/outfit/{id}';
  static const String getOutfitByUserIdEndpoint = '/outfit/user/{userId}';
  static const String createOutfitEndpoint = '/outfit';
  static const String updateOutfitEndpoint = '/outfit/{id}';
  static const String deleteOutfitEndpoint = '/outfit/{id}';
  static const String getClothingByOutfitIdEndpoint = '/outfit/{id}/clothing';

  // Favorite endpoints
  static const String getAllFavoriteEndpoint = '/favorite';
  static const String getFavoriteByIdEndpoint = '/favorite/{id}';
  static const String getFavoriteByUserIdEndpoint = '/favorite/user/{userId}';
  static const String createFavoriteEndpoint = '/favorite';
  static const String updateFavoriteEndpoint = '/favorite/{id}';
  static const String deleteFavoriteEndpoint = '/favorite/{id}';

  // ClothingModel endpoints
  static const String getAllClothingModelEndpoint = '/clothingModel';
  static const String getClothingModelByIdEndpoint = '/clothingModel/{id}';
  static const String createClothingModelEndpoint = '/clothingModel';
  static const String updateClothingModelEndpoint = '/clothingModel/{id}';
  static const String deleteClothingModelEndpoint = '/clothingModel/{id}';

  // Clothing endpoints
  static const String getAllClothingEndpoint = '/clothing';
  static const String getClothingByIdEndpoint = '/clothing/{id}';
  static const String getClothingByUserIdEndpoint = '/clothing/user/{userId}';
  static const String updateClothingEndpoint = '/clothing/{id}';
  static const String deleteClothingEndpoint = '/clothing/{id}';
  static const String analyzeClothingEndpoint = '/ai/inspect/clothing'; 
  //static const String analyzeClothingEndpoint = '/clothing';     this line is for our IA if it works well 
  static const String createClothingEndpoint = '/clothing/store';

  // Suitcase endpoints
  static const String getAllUserSuitcasesEndpoint = '/suitcases';
  static const String createSuitcaseEndpoint = '/suitcase';
  static const String getSuitcaseByIdEndpoint = '/suitcase/{suitcaseId}';
  static const String updateSuitcaseEndpoint = '/suitcase{suitcaseId}';
  static const String deleteSuitcaseEndpoint = '/suitcase/{suitcaseId}';
  static const String addClothingIntoSuitcaseEndpoint = '/suitcase/{suitcaseId}/add-clothing';
  static const String removeClothingFromSuitcaseEndpoint = '/suitcase/{suitcaseId}/remove-clothing';

  // 3D endpoint
  static const String convertImageEndpoint = '/convert-image-to-glb';
}
