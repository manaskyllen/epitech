<?php

use App\Http\Controllers\AddressController;
use App\Http\Controllers\AiController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ClothingController;
use App\Http\Controllers\ClothingModelController;
use App\Http\Controllers\EmailVerificationController;
use App\Http\Controllers\FavoriteController;
use App\Http\Controllers\GlbParserController;
use App\Http\Controllers\MinioController;
use App\Http\Controllers\OutfitController;
use App\Http\Controllers\OutfitItemController;
use App\Http\Controllers\SuitcaseController;
use App\Http\Controllers\TencentController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Middleware\MinioMiddleware;

// Auth routes

Route::post('/register', [AuthController::class, 'register']);

Route::post('/login', [AuthController::class, 'login'])->name('login');

Route::post('/forgetPassword', [AuthController::class, 'forgetPassword']);

Route::post('/verifyOtp', [AuthController::class, 'verifyOtp'])->name('verification.verify');

Route::post('/resetPassword', [AuthController::class, 'resetPassword']);

Route::post('/passwordReset/verifyOtp', [AuthController::class, 'passwordResetVerifyOtp'])->name('reset.verification.verify');

Route::get('/me', [AuthController::class, 'me'])->middleware('auth:sanctum');

// Address routes

Route::get('/address', [AddressController::class, 'index'])->middleware('auth:sanctum');

Route::get('/address/{id}', [AddressController::class, 'show'])->middleware('auth:sanctum');

Route::get('/address/user/{userId}', [AddressController::class, 'getAddressByUserId'])->middleware('auth:sanctum');

Route::post('/address', [AddressController::class, 'store'])->middleware('auth:sanctum');

Route::put('/address/{id}', [AddressController::class, 'update'])->middleware('auth:sanctum');

Route::delete('/address/{id}', [AddressController::class, 'destroy'])->middleware('auth:sanctum');

// Outfit routes

Route::get('/outfit', [OutfitController::class, 'index'])->middleware('auth:sanctum');

Route::get('/outfit/{id}', [OutfitController::class, 'show'])->middleware('auth:sanctum');

Route::get('/outfit/user/{userId}', [OutfitController::class, 'getOutfitsByUserId']);

Route::post('/outfit', [OutfitController::class, 'store'])->middleware('auth:sanctum');

Route::put('/outfit/{id}', [OutfitController::class, 'update'])->middleware('auth:sanctum');

Route::delete('/outfit/{id}', [OutfitController::class, 'destroy'])->middleware('auth:sanctum');

Route::get('/outfit/{id}/clothing', [OutfitController::class, 'getClothingByOutfitId'])->middleware('auth:sanctum');

// Favorite routes

Route::get('/favorite', [FavoriteController::class, 'index'])->middleware('auth:sanctum');

Route::get('/favorite/{id}', [FavoriteController::class, 'show'])->middleware('auth:sanctum');

Route::get('/favorite/user/{userId}', [FavoriteController::class, 'getFavoritesByUserId'])->middleware('auth:sanctum');

Route::post('/favorite', [FavoriteController::class, 'store'])->middleware('auth:sanctum');

Route::put('/favorite/{id}', [FavoriteController::class, 'update'])->middleware('auth:sanctum');

Route::delete('/favorite/{id}', [FavoriteController::class, 'destroy'])->middleware('auth:sanctum');

// ClothingModel routes

Route::get('/clothingModel', [ClothingModelController::class, 'index']);

Route::get('/clothingModel/{id}', [ClothingModelController::class, 'show'])->middleware('auth:sanctum');

Route::post('/clothingModel', [ClothingModelController::class, 'store'])->middleware('auth:sanctum');

Route::get('/clothingModel/{id}/file', [ClothingModelController::class, 'getModelFile']);

Route::get('/clothingModel/{id}/assets', [ClothingModelController::class, 'getAssets']);

Route::put('/clothingModel/{id}', [ClothingModelController::class, 'update'])->middleware('auth:sanctum');

Route::delete('/clothingModel/{id}', [ClothingModelController::class, 'destroy'])->middleware('auth:sanctum');

// Clothing routes

Route::get('/clothing', [ClothingController::class, 'index']);

Route::get('/clothing/{id}', [ClothingController::class, 'show'])->middleware('auth:sanctum');

Route::get('/clothing/user/{userId}', [ClothingController::class, 'getClothingByUserId'])->middleware('auth:sanctum');

Route::post('/clothing', [ClothingController::class, 'AIResult'])->middleware('auth:sanctum');

Route::post('/clothing/store', [ClothingController::class, 'store'])->middleware('auth:sanctum');

Route::put('/clothing/{id}', [ClothingController::class, 'update'])->middleware('auth:sanctum');

Route::delete('/clothing/{id}', [ClothingController::class, 'destroy'])->middleware('auth:sanctum');

// OutfitItem routes

Route::post('/outfitItem', [OutfitItemController::class, 'store'])->middleware('auth:sanctum');

Route::delete('/outfitItem/{id}', [OutfitItemController::class, 'destroy'])->middleware('auth:sanctum');

// User routes

Route::get('/user', [UserController::class, 'index'])->middleware('auth:sanctum');

Route::get('/user/{id}', [UserController::class, 'show'])->middleware('auth:sanctum');

Route::post('/user', [UserController::class, 'store'])->middleware('auth:sanctum');

Route::put('/user/{id}', [UserController::class, 'update'])->middleware('auth:sanctum');

Route::delete('/user/{id}', [UserController::class, 'destroy'])->middleware('auth:sanctum');

// Minio routes

Route::post('/upload', [MinioController::class, 'upload'])->middleware('auth:sanctum');

Route::get('/file/{filename}', [MinioController::class, 'get'])->middleware(MinioMiddleware::class);

Route::get('/minio-assets/{path}', [MinioController::class, 'stream'])->where('path', '.*');

// Suitcase routes

Route::get('/suitcases', [SuitcaseController::class, 'index'])->middleware('auth:sanctum');

Route::post('/suitcase', [SuitcaseController::class, 'store'])->middleware('auth:sanctum');

Route::get('/suitcase/{id}', [SuitcaseController::class, 'show'])->middleware('auth:sanctum');

Route::put('/suitcase/{id}', [SuitcaseController::class, 'update'])->middleware('auth:sanctum');

Route::delete('/suitcase/{id}', [SuitcaseController::class, 'destroy'])->middleware('auth:sanctum');

Route::post('/suitcase/{suitcase_id}/add-clothing', [SuitcaseController::class, 'addClothing'])->middleware('auth:sanctum');

Route::post('/suitcase/{suitcase_id}/remove-clothing', [SuitcaseController::class, 'removeClothing'])->middleware('auth:sanctum');

Route::post('/ai/inspect/clothing', [AiController::class, 'analyzeClothingImage'])->middleware('auth:sanctum');
// Tencent routes

Route::post('/convert-image-to-glb', [TencentController::class, 'convertImageOnGlb']);
