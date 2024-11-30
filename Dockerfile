# mssql.Dockerfile

FROM php:8.2-fpm-alpine

# Install prerequisites for tools and extensions
RUN apk add --no-cache supervisor bash gnupg less libpng-dev libzip-dev su-exec unzip npm nodejs curl gcc g++ make unixodbc-dev zip \
    freetype freetype-dev libjpeg-turbo libjpeg-turbo-dev libpng libpng-dev oniguruma-dev gettext-dev nginx autoconf \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip pdo pdo_mysql \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable gd \
    && docker-php-ext-install bcmath exif gettext opcache \
    && docker-php-ext-enable bcmath exif gettext opcache

# Install and enable required PHP extensions with installer script
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/install-php-extensions
RUN chmod uga+x /usr/bin/install-php-extensions \
    && sync \
    && install-php-extensions ds intl redis pcntl

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set up Microsoft SQL Server drivers
ENV ACCEPT_EULA=Y
RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.10.5.1-1_amd64.apk && \
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.10.1.1-1_amd64.apk && \
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.10.5.1-1_amd64.sig && \
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.10.1.1-1_amd64.sig && \
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --import - && \
    gpg --verify msodbcsql17_17.10.5.1-1_amd64.sig msodbcsql17_17.10.5.1-1_amd64.apk && \
    gpg --verify mssql-tools_17.10.1.1-1_amd64.sig mssql-tools_17.10.1.1-1_amd64.apk && \
    apk add --allow-untrusted msodbcsql17_17.10.5.1-1_amd64.apk && \
    apk add --allow-untrusted mssql-tools_17.10.1.1-1_amd64.apk

# Install PECL extensions
RUN pecl install sqlsrv pdo_sqlsrv \
    && docker-php-ext-enable pdo_sqlsrv sqlsrv

# Configure PHP for sqlsrv extensions
RUN echo "extension=pdo_sqlsrv.so" > /usr/local/etc/php/conf.d/10_pdo_sqlsrv.ini && \
    echo "extension=sqlsrv.so" > /usr/local/etc/php/conf.d/20_sqlsrv.ini

# Set working directory and copy application files
WORKDIR /var/www/html
COPY . .

RUN mkdir -p /var/www/html/storage/logs

# Set ownership and permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

RUN chown -R www-data:www-data storage \
    && chmod -R u+rwX,g+rwX,o-rwx storage

# Install dependencies
RUN composer install --no-dev --prefer-dist \
    && npm install \
    && npm run build \
    && chown -R www-data:www-data /var/www/html/vendor \
    && chmod -R 775 /var/www/html/vendor

# Generate storage link
RUN php artisan storage:link

# Copy nginx configuration
COPY ./nginx.conf /etc/nginx/http.d/default.conf

# Copy the crontab file
COPY crontab /etc/crontabs/root

# Create log directory for Supervisor
RUN mkdir -p /var/log/supervisor

# Copy Supervisor configuration files
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
