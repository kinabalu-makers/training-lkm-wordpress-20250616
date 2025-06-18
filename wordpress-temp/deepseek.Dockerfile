# Use Windows Server Core 2022 as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Metadata
LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="WordPress on Windows Server Core 2022"

# Set environment variables
ENV WORDPRESS_VERSION=6.5.3
ENV PHP_VERSION=8.2.12
ENV PHP_DIR=C:\php

# Install Chocolatey
RUN powershell -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install PHP to known directory and dependencies
RUN powershell -Command \
    choco install -y php --version %PHP_VERSION% --params \"/InstallDir:%PHP_DIR%\"; \
    choco install -y wget; \
    choco install -y unzip; \
    choco install -y vcredist-all

# Configure PHP using basic replacement method
RUN powershell -Command \
    if (!(Test-Path %PHP_DIR%)) { exit 1 }; \
    Copy-Item %PHP_DIR%\php.ini-production %PHP_DIR%\php.ini; \
    $content = [System.IO.File]::ReadAllText('%PHP_DIR%\php.ini'); \
    $content = $content -replace ';extension=curl', 'extension=curl'; \
    $content = $content -replace ';extension=fileinfo', 'extension=fileinfo'; \
    $content = $content -replace ';extension=mbstring', 'extension=mbstring'; \
    $content = $content -replace ';extension=mysqli', 'extension=mysqli'; \
    $content = $content -replace ';extension=openssl', 'extension=openssl'; \
    $content = $content -replace ';extension=pdo_mysql', 'extension=pdo_mysql'; \
    $content = $content -replace ';extension=xml', 'extension=xml'; \
    $content = $content -replace ';extension=zip', 'extension=zip'; \
    $content = $content -replace ';extension=gd', 'extension=gd'; \
    $content = $content -replace ';extension=intl', 'extension=intl'; \
    $content = $content -replace ';extension=exif', 'extension=exif'; \
    $content = $content -replace ';date.timezone =', 'date.timezone = UTC'; \
    $content = $content -replace 'upload_max_filesize = 2M', 'upload_max_filesize = 64M'; \
    $content = $content -replace 'post_max_size = 8M', 'post_max_size = 64M'; \
    $content = $content -replace 'max_execution_time = 30', 'max_execution_time = 300'; \
    $content = $content -replace 'memory_limit = 128M', 'memory_limit = 256M'; \
    [System.IO.File]::WriteAllText('%PHP_DIR%\php.ini', $content)

# Download and install WordPress
RUN powershell -Command \
    Invoke-WebRequest -Uri \"https://wordpress.org/wordpress-%WORDPRESS_VERSION%.zip\" -OutFile wordpress.zip; \
    Expand-Archive -Path wordpress.zip -DestinationPath C:\; \
    Remove-Item wordpress.zip; \
    Move-Item -Path C:\wordpress -Destination C:\inetpub\wwwroot; \
    New-Item -ItemType Directory -Path C:\inetpub\wwwroot\wordpress\wp-content\uploads; \
    $acl = Get-Acl C:\inetpub\wwwroot\wordpress; \
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule('IIS_IUSRS','FullControl','ContainerInherit,ObjectInherit','None','Allow'); \
    $acl.SetAccessRule($accessRule); \
    Set-Acl C:\inetpub\wwwroot\wordpress $acl; \
    Set-Acl C:\inetpub\wwwroot\wordpress\wp-content $acl; \
    Set-Acl C:\inetpub\wwwroot\wordpress\wp-content\uploads $acl; \
    Set-Acl C:\inetpub\wwwroot\wordpress\wp-content\plugins $acl; \
    Set-Acl C:\inetpub\wwwroot\wordpress\wp-content\themes $acl

# Install and configure IIS
RUN powershell -Command \
    Install-WindowsFeature Web-Server; \
    Install-WindowsFeature Web-Mgmt-Tools; \
    Install-WindowsFeature Web-Asp-Net45; \
    Remove-Website -Name 'Default Web Site'; \
    New-Website -Name 'WordPress' -Port 80 -PhysicalPath 'C:\inetpub\wwwroot\wordpress' -ApplicationPool '.NET v4.5'; \
    New-WebHandler -Name 'PHP-FastCGI' -Path '*.php' -Verb '*' -Modules 'FastCgiModule' -ScriptProcessor \"%PHP_DIR%\php-cgi.exe\" -ResourceType 'File'; \
    Add-WebConfigurationProperty -PSPath 'IIS:\' -Filter '/system.webServer/fastCgi' -Name '.' -Value @{'fullPath'=\"%PHP_DIR%\php-cgi.exe\";'activityTimeout'=600;'requestTimeout'=600;'instanceMaxRequests'=10000}; \
    Set-WebConfigurationProperty -PSPath 'IIS:\' -Filter '/system.webServer/fastCgi/application[@fullPath=\"\"%PHP_DIR%\php-cgi.exe\"\"]/environmentVariables' -Name '.' -Value @{Name='PHP_FCGI_MAX_REQUESTS';Value='10000'}

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD powershell -command \
        try { \
            $response = iwr http://localhost/wp-admin/install.php -UseBasicParsing; \
            if ($response.StatusCode -eq 200) { exit 0 } \
            else { exit 1 } \
        } catch { exit 1 }

# Start IIS
CMD ["C:\\ServiceMonitor.exe", "w3svc"]