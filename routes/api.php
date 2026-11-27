<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProfileController;
use Illuminate\Support\Facades\Route;

// Endpoint Publik (Belum punya token)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Endpoint Terproteksi (Wajib membawa Header Authorization: Bearer <token>)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::put('/profile', [ProfileController::class, 'updateProfile']);
    Route::put('/profile/password', [ProfileController::class, 'updatePassword']);
    Route::post('/profile/photo', [ProfileController::class, 'updatePhoto']);
    Route::post('/logout', [AuthController::class, 'logout']);
});
