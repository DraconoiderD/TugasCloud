# Menggunakan PHP 8.2-FPM sebagai image dasar
FROM php:8.2-fpm

# Memperbarui sistem dan menginstal dependensi yang diperlukan
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip pdo pdo_mysql exif \
    && docker-php-ext-enable exif

# Menetapkan direktori kerja
WORKDIR /var/www

# Menyalin semua file proyek ke dalam container
COPY . .

# Menginstal Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Menjalankan perintah Composer tanpa skrip dan autoloader
RUN composer install --no-scripts --no-autoloader

# Mengatur izin untuk direktori yang dibutuhkan Laravel
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Menginstal Node.js
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs

# Menginstal dependensi npm
RUN npm install

# Membuild aset front-end (ubah ke `npm run dev` jika build tidak diperlukan)
RUN npm run build

# Mengekspos port yang digunakan PHP-FPM
EXPOSE 9000

# Perintah default untuk menjalankan PHP-FPM
CMD ["php-fpm"]
