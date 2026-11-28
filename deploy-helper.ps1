# ==============================================
# Minimarket Putra API - Deployment Helper (PowerShell)
# ==============================================
# Script untuk membantu setup dan debugging MySQL di Windows
# ==============================================

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "   Minimarket Putra API - Deploy Helper" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# Function: Check if .env exists
function Check-EnvFile {
    Write-Host "🔍 Checking .env file..." -ForegroundColor Yellow
    if (Test-Path .env) {
        Write-Host "✓ .env file found" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "✗ .env file not found!" -ForegroundColor Red
        Write-Host ""
        Write-Host "📝 Creating .env from .env.production.example..." -ForegroundColor Yellow
        if (Test-Path .env.production.example) {
            Copy-Item .env.production.example .env
            Write-Host "✓ .env created. Please edit with your credentials!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Edit dengan: notepad .env" -ForegroundColor Cyan
            return $false
        }
        else {
            Write-Host "✗ .env.production.example not found!" -ForegroundColor Red
            return $false
        }
    }
}

# Function: Show current DB config
function Show-DBConfig {
    Write-Host ""
    Write-Host "📊 Current Database Configuration:" -ForegroundColor Cyan
    Write-Host "------------------------------------"
    if (Test-Path .env) {
        $envContent = Get-Content .env
        $dbHost = ($envContent | Select-String "DB_HOST=").ToString().Split("=")[1]
        $dbPort = ($envContent | Select-String "DB_PORT=").ToString().Split("=")[1]
        $dbDatabase = ($envContent | Select-String "DB_DATABASE=").ToString().Split("=")[1]
        $dbUsername = ($envContent | Select-String "DB_USERNAME=").ToString().Split("=")[1]
        
        Write-Host "DB_HOST:     $dbHost"
        Write-Host "DB_PORT:     $dbPort"
        Write-Host "DB_DATABASE: $dbDatabase"
        Write-Host "DB_USERNAME: $dbUsername"
        Write-Host "DB_PASSWORD: ********"
    }
    else {
        Write-Host "No .env file found" -ForegroundColor Red
    }
    Write-Host "------------------------------------"
}

# Function: Clear Laravel cache
function Clear-LaravelCache {
    Write-Host ""
    Write-Host "🧹 Clearing Laravel Cache..." -ForegroundColor Yellow
    
    php artisan config:clear
    php artisan cache:clear
    php artisan view:clear
    php artisan route:clear
    
    Write-Host "✓ Cache cleared!" -ForegroundColor Green
}

# Function: Cache config
function Set-LaravelCache {
    Write-Host ""
    Write-Host "⚡ Caching Configuration..." -ForegroundColor Yellow
    
    php artisan config:cache
    php artisan route:cache
    
    Write-Host "✓ Configuration cached!" -ForegroundColor Green
}

# Function: Test Laravel DB connection
function Test-LaravelDB {
    Write-Host ""
    Write-Host "🔍 Testing Laravel Database Connection..." -ForegroundColor Yellow
    
    $result = php artisan migrate:status 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Laravel can connect to database!" -ForegroundColor Green
        php artisan migrate:status
        return $true
    }
    else {
        Write-Host "✗ Laravel cannot connect to database!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Error details:" -ForegroundColor Yellow
        Write-Host $result -ForegroundColor Red
        Write-Host ""
        Write-Host "Common fixes:" -ForegroundColor Cyan
        Write-Host "1. Check DB_HOST in .env (should not be 127.0.0.1 for remote server)" -ForegroundColor White
        Write-Host "2. Verify DB_USERNAME and DB_PASSWORD" -ForegroundColor White
        Write-Host "3. Make sure database exists on server" -ForegroundColor White
        Write-Host "4. Check if user has permission to access database" -ForegroundColor White
        return $false
    }
}

# Function: Run migrations
function Run-Migrations {
    Write-Host ""
    Write-Host "🚀 Running Migrations..." -ForegroundColor Yellow
    
    $confirm = Read-Host "Are you sure? This will modify database. (y/n)"
    
    if ($confirm -eq "y") {
        php artisan migrate --force
        Write-Host "✓ Migrations completed!" -ForegroundColor Green
    }
    else {
        Write-Host "Migrations cancelled." -ForegroundColor Yellow
    }
}

# Function: Show MySQL commands to create user
function Show-MySQLCommands {
    Write-Host ""
    Write-Host "👤 MySQL User Creation Commands" -ForegroundColor Cyan
    Write-Host "------------------------------------"
    
    $newUser = Read-Host "Enter new username"
    $newPass = Read-Host "Enter new password"
    $newDB = Read-Host "Enter database name"
    
    Write-Host ""
    Write-Host "Copy and run these commands in MySQL as root:" -ForegroundColor Yellow
    Write-Host "------------------------------------" -ForegroundColor Cyan
    Write-Host "CREATE USER '$newUser'@'localhost' IDENTIFIED BY '$newPass';"
    Write-Host "CREATE USER '$newUser'@'127.0.0.1' IDENTIFIED BY '$newPass';"
    Write-Host "CREATE USER '$newUser'@'%' IDENTIFIED BY '$newPass';"
    Write-Host "CREATE DATABASE IF NOT EXISTS $newDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    Write-Host "GRANT ALL PRIVILEGES ON $newDB.* TO '$newUser'@'localhost';"
    Write-Host "GRANT ALL PRIVILEGES ON $newDB.* TO '$newUser'@'127.0.0.1';"
    Write-Host "GRANT ALL PRIVILEGES ON $newDB.* TO '$newUser'@'%';"
    Write-Host "FLUSH PRIVILEGES;"
    Write-Host "------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Then update your .env file:" -ForegroundColor Yellow
    Write-Host "DB_HOST=localhost"
    Write-Host "DB_DATABASE=$newDB"
    Write-Host "DB_USERNAME=$newUser"
    Write-Host "DB_PASSWORD=$newPass"
}

# Function: Run all checks
function Run-AllChecks {
    Write-Host ""
    Write-Host "🔍 Running All Checks..." -ForegroundColor Cyan
    Write-Host ""
    
    Check-EnvFile
    Show-DBConfig
    Clear-LaravelCache
    Set-LaravelCache
    Test-LaravelDB
    
    Write-Host ""
    Write-Host "✓ All checks completed!" -ForegroundColor Green
}

# Function: Edit .env file
function Edit-EnvFile {
    Write-Host ""
    Write-Host "📝 Opening .env file..." -ForegroundColor Yellow
    
    if (Test-Path .env) {
        notepad .env
    }
    else {
        Write-Host "✗ .env file not found!" -ForegroundColor Red
    }
}

# Function: Show help
function Show-Help {
    Write-Host ""
    Write-Host "Available commands:" -ForegroundColor Cyan
    Write-Host "  1) Check .env file"
    Write-Host "  2) Show DB config"
    Write-Host "  3) Edit .env file"
    Write-Host "  4) Clear cache"
    Write-Host "  5) Cache config"
    Write-Host "  6) Test Laravel DB"
    Write-Host "  7) Run migrations"
    Write-Host "  8) Show MySQL commands"
    Write-Host "  9) Run all checks"
    Write-Host "  0) Exit"
    Write-Host ""
}

# Main Menu
function Show-Menu {
    while ($true) {
        Show-Help
        $choice = Read-Host "Select option (0-9)"
        
        switch ($choice) {
            "1" { Check-EnvFile }
            "2" { Show-DBConfig }
            "3" { Edit-EnvFile }
            "4" { Clear-LaravelCache }
            "5" { Set-LaravelCache }
            "6" { Test-LaravelDB }
            "7" { Run-Migrations }
            "8" { Show-MySQLCommands }
            "9" { Run-AllChecks }
            "0" { 
                Write-Host "Goodbye!" -ForegroundColor Green
                exit 
            }
            default { 
                Write-Host "Invalid option" -ForegroundColor Red 
            }
        }
        
        Write-Host ""
        Read-Host "Press Enter to continue"
        Clear-Host
        Write-Host "==============================================" -ForegroundColor Cyan
        Write-Host "   Minimarket Putra API - Deploy Helper" -ForegroundColor Cyan
        Write-Host "==============================================" -ForegroundColor Cyan
    }
}

# Run main menu
Show-Menu
