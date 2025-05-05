FROM debian:bullseye-slim

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    libapache2-mod-auth-radius \
    apache2 \
    curl \
    nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod auth_radius

# Copy Apache configuration
COPY ./000-default.conf /etc/apache2/sites-enabled/

RUN echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf

# Create web directory and set permissions
RUN mkdir -p /var/www/html/auth
RUN chown -R www-data:www-data /var/www/html/auth

# Create a simple index page
RUN echo "<html><body><h1>Apache with RADIUS Authentication</h1></body></html>" > /var/www/html/index.html
