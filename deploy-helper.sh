#!/bin/bash

# ==============================================
# Minimarket Putra API - Deployment Helper
# ==============================================
# Script untuk membantu setup dan debugging MySQL
# ==============================================

echo "=============================================="
echo "   Minimarket Putra API - Deploy Helper"
echo "=============================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function: Check if .env exists
check_env() {
    echo "🔍 Checking .env file..."
    if [ -f .env ]; then
        echo -e "${GREEN}✓${NC} .env file found"
        return 0
    else
        echo -e "${RED}✗${NC} .env file not found!"
        echo ""
        echo "📝 Creating .env from .env.production.example..."
        if [ -f .env.production.example ]; then
            cp .env.production.example .env
            echo -e "${GREEN}✓${NC} .env created. Please edit with your credentials!"
            echo ""
            echo "Edit dengan: nano .env"
            return 1
        else
            echo -e "${RED}✗${NC} .env.production.example not found!"
            return 1
        fi
    fi
}

# Function: Show current DB config
show_db_config() {
    echo ""
    echo "📊 Current Database Configuration:"
    echo "------------------------------------"
    if [ -f .env ]; then
        echo "DB_HOST:     $(grep DB_HOST .env | cut -d '=' -f2)"
        echo "DB_PORT:     $(grep DB_PORT .env | cut -d '=' -f2)"
        echo "DB_DATABASE: $(grep DB_DATABASE .env | cut -d '=' -f2)"
        echo "DB_USERNAME: $(grep DB_USERNAME .env | cut -d '=' -f2)"
        echo "DB_PASSWORD: ********"
    else
        echo -e "${RED}No .env file found${NC}"
    fi
    echo "------------------------------------"
}

# Function: Test MySQL connection
test_mysql() {
    echo ""
    echo "🔌 Testing MySQL Connection..."
    
    if ! command -v mysql &> /dev/null; then
        echo -e "${YELLOW}⚠${NC} MySQL client not found. Skipping connection test."
        return 1
    fi
    
    DB_HOST=$(grep DB_HOST .env | cut -d '=' -f2)
    DB_PORT=$(grep DB_PORT .env | cut -d '=' -f2)
    DB_USER=$(grep DB_USERNAME .env | cut -d '=' -f2)
    DB_PASS=$(grep DB_PASSWORD .env | cut -d '=' -f2)
    DB_NAME=$(grep DB_DATABASE .env | cut -d '=' -f2)
    
    if mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME;" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} MySQL connection successful!"
        return 0
    else
        echo -e "${RED}✗${NC} MySQL connection failed!"
        echo ""
        echo "Possible issues:"
        echo "1. Wrong credentials in .env"
        echo "2. MySQL server not running"
        echo "3. Host/Port incorrect"
        echo "4. User doesn't have permission"
        return 1
    fi
}

# Function: Clear Laravel cache
clear_cache() {
    echo ""
    echo "🧹 Clearing Laravel Cache..."
    php artisan config:clear
    php artisan cache:clear
    php artisan view:clear
    php artisan route:clear
    echo -e "${GREEN}✓${NC} Cache cleared!"
}

# Function: Cache config
cache_config() {
    echo ""
    echo "⚡ Caching Configuration..."
    php artisan config:cache
    php artisan route:cache
    echo -e "${GREEN}✓${NC} Configuration cached!"
}

# Function: Test Laravel DB connection
test_laravel_db() {
    echo ""
    echo "🔍 Testing Laravel Database Connection..."
    if php artisan migrate:status > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Laravel can connect to database!"
        php artisan migrate:status
        return 0
    else
        echo -e "${RED}✗${NC} Laravel cannot connect to database!"
        echo ""
        echo "Run this for more details:"
        echo "php artisan migrate:status"
        return 1
    fi
}

# Function: Run migrations
run_migrations() {
    echo ""
    echo "🚀 Running Migrations..."
    read -p "Are you sure? This will modify database. (y/n): " confirm
    if [ "$confirm" = "y" ]; then
        php artisan migrate --force
        echo -e "${GREEN}✓${NC} Migrations completed!"
    else
        echo "Migrations cancelled."
    fi
}

# Function: Create MySQL user (if have root access)
create_mysql_user() {
    echo ""
    echo "👤 Create MySQL User"
    echo "------------------------------------"
    read -p "Enter new username: " new_user
    read -p "Enter new password: " new_pass
    read -p "Enter database name: " new_db
    
    echo ""
    echo "SQL Commands to run as MySQL root:"
    echo "------------------------------------"
    echo "CREATE USER '$new_user'@'localhost' IDENTIFIED BY '$new_pass';"
    echo "CREATE USER '$new_user'@'127.0.0.1' IDENTIFIED BY '$new_pass';"
    echo "CREATE DATABASE IF NOT EXISTS $new_db;"
    echo "GRANT ALL PRIVILEGES ON $new_db.* TO '$new_user'@'localhost';"
    echo "GRANT ALL PRIVILEGES ON $new_db.* TO '$new_user'@'127.0.0.1';"
    echo "FLUSH PRIVILEGES;"
    echo "------------------------------------"
    echo ""
    read -p "Copy commands and run in MySQL? (y/n): " run_now
    
    if [ "$run_now" = "y" ]; then
        mysql -u root -p <<EOF
CREATE USER '$new_user'@'localhost' IDENTIFIED BY '$new_pass';
CREATE USER '$new_user'@'127.0.0.1' IDENTIFIED BY '$new_pass';
CREATE DATABASE IF NOT EXISTS $new_db;
GRANT ALL PRIVILEGES ON $new_db.* TO '$new_user'@'localhost';
GRANT ALL PRIVILEGES ON $new_db.* TO '$new_user'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF
        echo -e "${GREEN}✓${NC} MySQL user created!"
    fi
}

# Function: Show help
show_help() {
    echo ""
    echo "Available commands:"
    echo "  1) Check .env file"
    echo "  2) Show DB config"
    echo "  3) Test MySQL connection"
    echo "  4) Clear cache"
    echo "  5) Cache config"
    echo "  6) Test Laravel DB"
    echo "  7) Run migrations"
    echo "  8) Create MySQL user"
    echo "  9) Run all checks"
    echo "  0) Exit"
    echo ""
}

# Function: Run all checks
run_all_checks() {
    check_env
    show_db_config
    test_mysql
    clear_cache
    cache_config
    test_laravel_db
}

# Main Menu
main_menu() {
    while true; do
        show_help
        read -p "Select option (0-9): " choice
        
        case $choice in
            1) check_env ;;
            2) show_db_config ;;
            3) test_mysql ;;
            4) clear_cache ;;
            5) cache_config ;;
            6) test_laravel_db ;;
            7) run_migrations ;;
            8) create_mysql_user ;;
            9) run_all_checks ;;
            0) echo "Goodbye!"; exit 0 ;;
            *) echo -e "${RED}Invalid option${NC}" ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main menu
main_menu
