<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProfileController;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;

// Health Check Endpoint
Route::get('/health', function () {
    try {
        DB::connection()->getPdo();
        return response()->json([
            'status' => 'ok',
            'database' => 'connected',
            'timestamp' => now()->toISOString(),
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'database' => 'disconnected',
            'message' => $e->getMessage(),
        ], 500);
    }
});

// Debug Endpoint (HAPUS SETELAH TESTING!)
Route::get('/debug', function () {
    return response()->json([
        'php_version' => PHP_VERSION,
        'laravel_version' => app()->version(),
        'env' => app()->environment(),
        'db_connection' => config('database.default'),
        'db_host' => config('database.connections.mysql.host'),
        'db_database' => config('database.connections.mysql.database'),
        'storage_writable' => is_writable(storage_path()),
        'cache_writable' => is_writable(storage_path('framework/cache')),
    ]);
});

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
