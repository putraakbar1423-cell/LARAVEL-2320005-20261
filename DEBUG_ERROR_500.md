# 🔍 DEBUG ERROR 500 - EthioDeploy

## ❌ Error Yang Terjadi
- POST `/api/register` → 500 Internal Server Error
- POST `/api/login` → 500 Internal Server Error

---

## 🎯 LANGKAH DEBUGGING

### **Step 1: Cek Debug Endpoint**

Saya sudah menambahkan endpoint debug. Test dengan Postman atau browser:

```
GET https://laravel-2320805-20261.ethiodeploy.app/api/debug
```

**Expected Output:**
```json
{
  "php_version": "8.3.x",
  "laravel_version": "11.x",
  "env": "production",
  "db_connection": "mysql",
  "db_host": "cmwz58n5y8Qqm8unlx75dfbyy-addon-mysql",
  "db_database": "ethiodeploy",
  "storage_writable": true,
  "cache_writable": true
}
```

Jika endpoint ini return error 500 juga → masalah fundamental (permissions, APP_KEY, dll)

---

### **Step 2: Cek Health Check Endpoint**

```
GET https://laravel-2320805-20261.ethiodeploy.app/api/health
```

**Expected:**
```json
{
  "status": "ok",
  "database": "connected",
  "timestamp": "2026-11-28T04:08:03.000000Z"
}
```

Jika "database": "disconnected" → masalah koneksi database

---

### **Step 3: Cek Laravel Log**

**Via Dashboard EthioDeploy:**
1. Login ke dashboard
2. Buka "Logs" atau "Shell/Terminal"
3. Jalankan:
```bash
tail -100 /var/www/html/storage/logs/laravel.log
```

**Via SSH:**
```bash
ssh ke-server
cd /var/www/html
tail -100 storage/logs/laravel.log
```

**Cari error message** seperti:
- `Class not found`
- `Permission denied`
- `Connection refused`
- `SQLSTATE error`

---

### **Step 4: Test dengan Postman**

Import file `postman_collection.json` yang sudah saya buat.

**Test berurutan:**

#### **1. Health Check**
```
GET https://laravel-2320805-20261.ethiodeploy.app/api/health
```

#### **2. Debug Info**
```
GET https://laravel-2320805-20261.ethiodeploy.app/api/debug
```

#### **3. Register**
```
POST https://laravel-2320805-20261.ethiodeploy.app/api/register
Headers:
  Content-Type: application/json
  Accept: application/json

Body (raw JSON):
{
  "name": "Test User",
  "email": "test@minimarketputra.com",
  "no_hp": "08123456789",
  "password": "password123",
  "password_confirmation": "password123"
}
```

---

## 🔧 KEMUNGKINAN PENYEBAB & SOLUSI

### **Problem 1: APP_KEY Missing**

**Gejala:** Error 500 di semua endpoint, termasuk `/api/debug`

**Solusi:** 
1. Cek di dashboard EthioDeploy → Environment Variables
2. Pastikan ada `APP_KEY` dengan value: `base64:IdIVQK5wrafyXoUGxPuNDX42/DFS93/L+BH9tOnALMw=`
3. Jika tidak ada, tambahkan
4. Restart application

---

### **Problem 2: Storage Permission**

**Gejala:** Error "Permission denied" di log

**Solusi:**
```bash
# Via SSH atau terminal dashboard
cd /var/www/html
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
# Atau
chown -R nginx:nginx storage bootstrap/cache
```

---

### **Problem 3: Config Cache Corrupt**

**Gejala:** Error 500 setelah deploy, config tidak update

**Solusi:**
```bash
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear
php artisan config:cache
php artisan route:cache
```

---

### **Problem 4: Missing ENV Variables**

**Gejala:** Database connection error, APP_KEY error

**Solusi:** Cek di dashboard EthioDeploy, pastikan ada:
- `APP_KEY`
- `APP_ENV=production`
- `APP_DEBUG=false`
- `DB_HOST=cmwz58n5y8Qqm8unlx75dfbyy-addon-mysql`
- `DB_DATABASE=ethiodeploy`
- `DB_USERNAME=ethiodeploy`
- `DB_PASSWORD=5a87ed1463aa86cfc319b387ca4df93544f183be92551a4`

---

### **Problem 5: Class Not Found**

**Gejala:** Error "Class 'App\Http\Controllers\Api\AuthController' not found"

**Solusi:**
```bash
composer dump-autoload
php artisan optimize:clear
php artisan optimize
```

---

### **Problem 6: CORS Issue**

**Gejala:** Error 500 saat akses dari mobile app

**Solusi:** Update `config/cors.php`:
```php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
```

---

## 📋 CHECKLIST DEBUG

- [ ] Test `/api/debug` endpoint
- [ ] Test `/api/health` endpoint  
- [ ] Check Laravel log for error details
- [ ] Verify ENV variables di dashboard
- [ ] Check storage permissions
- [ ] Clear all cache
- [ ] Test dengan Postman
- [ ] Check CORS configuration

---

## 🚀 AFTER FIX

Setelah error resolved:

1. **Hapus endpoint debug:**
   ```php
   // Hapus route /api/debug dari routes/api.php
   ```

2. **Test semua endpoint:**
   - ✅ Register
   - ✅ Login
   - ✅ Get Profile
   - ✅ Update Profile
   - ✅ Upload Photo

3. **Test dari mobile app**

---

## 📞 NEXT STEPS

**Jika masih error 500:**

1. **Share Laravel log** (copy paste dari `storage/logs/laravel.log`)
2. **Share output dari `/api/debug`**
3. **Share screenshot error dari Postman**

Dengan informasi ini saya bisa bantu troubleshoot lebih spesifik.

---

## 💡 QUICK FIX COMMANDS

```bash
# 1. SSH ke server
ssh username@ethiodeploy-server

# 2. Masuk ke folder Laravel
cd /var/www/html

# 3. Clear semua cache
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

# 4. Optimize
php artisan config:cache
php artisan route:cache
php artisan optimize

# 5. Fix permissions
chmod -R 775 storage bootstrap/cache

# 6. Check log
tail -50 storage/logs/laravel.log
```

---

Good luck debugging! 🔍
