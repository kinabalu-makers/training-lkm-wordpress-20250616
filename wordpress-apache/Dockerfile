# Use the official Windows Server Core 2022 image as base
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set environment variables
ENV APACHE_VERSION 2.4.63-250207
ENV PHP_VERSION 8.4.8
ENV WORDPRESS_VERSION 6.8
ENV UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'

# Set the working directory
WORKDIR C:\\Setup

# Install Chocolatey (Windows package manager)
RUN powershell -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install required dependencies
RUN choco install -y vcredist140
# RUN choco install -y --ignore-dependencies winsvc

# Download and install Apache
RUN powershell -Command \
    $ProgressPreference = 'SilentlyContinue'; \
    Invoke-WebRequest -Uri "https://www.apachelounge.com/download/VS17/binaries/httpd-%APACHE_VERSION%-win64-VS17.zip" -UserAgent '%UserAgent%' -OutFile "apache.zip"; \
    Expand-Archive -Path "apache.zip" -DestinationPath "C:\Setup\httpd"; \
    Copy-Item -Path "C:\Setup\httpd\*" -Destination "C:\Apache" -Recurse; \
    Remove-Item -Path "C:\Setup\httpd" -Recurse; \
    Remove-Item -Path "apache.zip"; \
    Remove-Item -Path "C:\Apache\htdocs\index.html"; 

# Download and install PHP
RUN powershell -Command \
    $ProgressPreference = 'SilentlyContinue'; \
    Invoke-WebRequest -Uri "https://windows.php.net/downloads/releases/php-%PHP_VERSION%-Win32-vs17-x64.zip" -OutFile "php.zip"; \
    Expand-Archive -Path "php.zip" -DestinationPath "C:\php"; \
    Remove-Item -Path "php.zip";

# Download and install WordPress into htdocs
RUN powershell -Command \
    $ProgressPreference = 'SilentlyContinue'; \
    Invoke-WebRequest -Uri "https://wordpress.org/wordpress-%WORDPRESS_VERSION%.zip" -OutFile "wordpress.zip"; \
    Expand-Archive -Path "wordpress.zip" -DestinationPath "C:\Setup"; \
    Copy-Item -Path "C:\Setup\wordpress\*" -Destination "C:\Apache\htdocs" -Recurse; \
    Remove-Item -Path "C:\Setup\wordpress" -Recurse; \
    Remove-Item -Path "wordpress.zip";

# Create WordPress directories and set permissions
RUN powershell -Command \
    New-Item -ItemType Directory -Path "C:\Apache\htdocs\wp-content\uploads" -Force;
    # New-Item -ItemType Directory -Path "C:\Apache\htdocs\wordpress\wp-content\plugins" -Force; \
    # New-Item -ItemType Directory -Path "C:\Apache\htdocs\wordpress\wp-content\themes" -Force;
    # icacls "C:\Apache\htdocs\wordpress" /grant "Everyone:(OI)(CI)F" /T

# Copy configuration files
COPY httpd.conf C:/Apache/conf/httpd.conf
COPY php.ini C:/php/php.ini
COPY wp-config.php C:/Apache/htdocs/wp-config.php

# Expose port 8080
EXPOSE 80

# Start Apache
CMD ["C:\\Apache\\bin\\httpd.exe", "-D", "FOREGROUND"]