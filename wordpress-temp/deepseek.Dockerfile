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
    choco install -y php --version $env:PHP_VERSION --params '\"/InstallDir:$env:PHP_DIR\"'; \
    choco install -y wget; \
    choco install -y unzip; \
    choco install -y vcredist-all

# Configure PHP using basic commands
RUN powershell -Command \
    if (-not (Test-Path $env:PHP_DIR)) { throw \"PHP directory not found\" }; \
    Copy-Item $env:PHP_DIR\\php.ini-production $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace ';extension=curl', 'extension=curl' } | Set-Content $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace ';extension=fileinfo', 'extension=fileinfo' } | Set-Content $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace ';extension=mbstring', 'extension=mbstring' } | Set-Content $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace ';extension=mysqli', 'extension=mysqli' } | Set-Content $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace ';extension=openssl', 'extension=openssl' } | Set-Content $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace ';extension=pdo_mysql', 'extension=pdo_mysql' } | Set-Content $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace ';extension=xml', 'extension=xml' } | Set-Content $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace ';extension=zip', 'extension=zip' } | Set-Content $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace ';extension=gd', 'extension=gd' } | Set-Content $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace ';extension=intl', 'extension=intl' } | Set-Content $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace ';extension=exif', 'extension=exif' } | Set-Content $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace ';date.timezone =', 'date.timezone = UTC' } | Set-Content $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace 'upload_max_filesize = 2M', 'upload_max_filesize = 64M' } | Set-Content $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace 'post_max_size = 8M', 'post_max_size = 64M' } | Set-Content $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace 'max_execution_time = 30', 'max_execution_time = 300' } | Set-Content $env:PHP_DIR\\php.ini; \
    (Get-Content $env:PHP_DIR\\php.ini) | ForEach-Object { $_ -replace 'memory_limit = 128M', 'memory_limit = 256M' } | Set-Content $env:PHP_DIR\\php.ini

# Download and install WordPress
RUN powershell -Command \
    $ErrorActionPreference = 'Stop'; \
    Invoke-WebRequest -Uri \"https://wordpress.org/wordpress-$env:WORDPRESS_VERSION.zip\" -OutFile wordpress.zip; \
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
    New-WebHandler -Name 'PHP-FastCGI' -Path '*.php' -Verb '*' -Modules 'FastCgiModule' -ScriptProcessor \"$env:PHP_DIR\php-cgi.exe\" -ResourceType 'File'; \
    Add-WebConfigurationProperty -PSPath 'IIS:\' -Filter '/system.webServer/fastCgi' -Name '.' -Value @{'fullPath'=\"$env:PHP_DIR\php-cgi.exe\";'activityTimeout'=600;'requestTimeout'=600;'instanceMaxRequests'=10000}; \
    Set-WebConfigurationProperty -PSPath 'IIS:\' -Filter '/system.webServer/fastCgi/application[@fullPath=\"""$env:PHP_DIR\php-cgi.exe\""]/environmentVariables' -Name '.' -Value @{Name='PHP_FCGI_MAX_REQUESTS';Value='10000'}

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD powershell -command \
        try { \
            $response = Invoke-WebRequest -Uri http://localhost/wp-admin/install.php -UseBasicParsing; \
            if ($response.StatusCode -eq 200) { return 0 } \
            else { return 1 } \
        } catch { return 1 }

# Start IIS
CMD ["C:\\ServiceMonitor.exe", "w3svc"]