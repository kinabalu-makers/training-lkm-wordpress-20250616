# Use the official Windows Server Core 2022 image as base
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set environment variables
ENV APACHE_VERSION 2.4.63-250207
ENV PHP_VERSION 8.2.8
ENV WORDPRESS_VERSION 6.6.2

# Set the working directory
WORKDIR C:\Setup

# Install Chocolatey (Windows package manager)
RUN powershell -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install required dependencies
RUN choco install -y vcredist2015 vcredist2017 vcredist2019 vcredist2022
RUN choco install -y --ignore-dependencies winsvc

# Download and install Apache
RUN powershell -Command \
    $ProgressPreference = 'SilentlyContinue'; \
    Invoke-WebRequest -Uri "https://www.apachelounge.com/download/VS17/binaries/httpd-%APACHE_VERSION%-win64-VS17.zip" -OutFile "apache.zip"; \
    Expand-Archive -Path "apache.zip" -DestinationPath "C:\"; \
    Rename-Item -Path "C:\Apache24" -NewName "C:\Apache"; \
    Remove-Item -Path "apache.zip"

# Download and install PHP
RUN powershell -Command \
    $ProgressPreference = 'SilentlyContinue'; \
    Invoke-WebRequest -Uri "https://windows.php.net/downloads/releases/php-%PHP_VERSION%-Win32-vs16-x64.zip" -OutFile "php.zip"; \
    Expand-Archive -Path "php.zip" -DestinationPath "C:\php"; \
    Remove-Item -Path "php.zip"

# Download and install WordPress into htdocs
RUN powershell -Command \
    $ProgressPreference = 'SilentlyContinue'; \
    Invoke-WebRequest -Uri "https://wordpress.org/wordpress-%WORDPRESS_VERSION%.zip" -OutFile "wordpress.zip"; \
    Expand-Archive -Path "wordpress.zip" -DestinationPath "C:\Apache\htdocs"; \
    Remove-Item -Path "wordpress.zip"

# Create WordPress directories and set permissions
RUN powershell -Command \
    New-Item -ItemType Directory -Path "C:\Apache\htdocs\wordpress\wp-content\uploads" -Force; \
    New-Item -ItemType Directory -Path "C:\Apache\htdocs\wordpress\wp-content\plugins" -Force; \
    New-Item -ItemType Directory -Path "C:\Apache\htdocs\wordpress\wp-content\themes" -Force; \
    icacls "C:\Apache\htdocs\wordpress" /grant "Everyone:(OI)(CI)F" /T

# Copy configuration files
COPY httpd.conf C:/Apache/conf/httpd.conf
COPY php.ini C:/php/php.ini
COPY wp-config.php C:/Apache/htdocs/wordpress/wp-config.php

# Expose port 8080
EXPOSE 8080

# Start Apache
CMD ["C:\\Apache\\bin\\httpd.exe", "-D", "FOREGROUND"]