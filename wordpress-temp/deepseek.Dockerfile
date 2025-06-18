# Use Windows Server Core 2022 as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Metadata
LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="WordPress on Windows Server Core 2022"

# Set environment variables
ENV WORDPRESS_VERSION=6.5.3
ENV PHP_VERSION=8.2.12
ENV PHP_DIR=C:\php
ENV WORDPRESS_ROOT=C:\inetpub\wwwroot\wordpress

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

# Configure PHP
RUN powershell -Command \
    if (!(Test-Path %PHP_DIR%)) { Write-Error 'PHP directory not found'; exit 1 }; \
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

# Download and install WordPress with directory validation
RUN powershell -Command \
    # Download and extract WordPress \
    Invoke-WebRequest -Uri \"https://wordpress.org/wordpress-%WORDPRESS_VERSION%.zip\" -OutFile wordpress.zip; \
    if (!(Test-Path wordpress.zip)) { Write-Error 'WordPress download failed'; exit 1 }; \
    Expand-Archive -Path wordpress.zip -DestinationPath C:\; \
    Remove-Item wordpress.zip; \
    \
    # Verify WordPress extraction \
    if (!(Test-Path C:\wordpress)) { Write-Error 'WordPress extraction failed'; exit 1 }; \
    Move-Item -Path C:\wordpress -Destination %WORDPRESS_ROOT%; \
    \
    # Create required directories if they don't exist \
    $requiredDirs = @('\wp-content', '\wp-content\uploads', '\wp-content\plugins', '\wp-content\themes'); \
    foreach ($dir in $requiredDirs) { \
        $fullPath = \"%WORDPRESS_ROOT%$dir\"; \
        if (!(Test-Path $fullPath)) { \
            Write-Host \"Creating directory: $fullPath\"; \
            New-Item -ItemType Directory -Path $fullPath ; \
            if (!(Test-Path $fullPath)) { Write-Error \"Failed to create directory: $fullPath\"; exit 1 } \
        } \
    }; \
    \
    # Set permissions \
    $acl = Get-Acl %WORDPRESS_ROOT%; \
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule('IIS_IUSRS','FullControl','ContainerInherit,ObjectInherit','None','Allow'); \
    $acl.SetAccessRule($accessRule); \
    Set-Acl %WORDPRESS_ROOT% $acl; \
    Set-Acl \"%WORDPRESS_ROOT%\wp-content\" $acl; \
    Set-Acl \"%WORDPRESS_ROOT%\wp-content\uploads\" $acl; \
    Set-Acl \"%WORDPRESS_ROOT%\wp-content\plugins\" $acl; \
    Set-Acl \"%WORDPRESS_ROOT%\wp-content\themes\" $acl

# Install and configure IIS with corrected syntax
RUN powershell -Command \
    # Install IIS features \
    Install-WindowsFeature Web-Server; \
    Install-WindowsFeature Web-Mgmt-Tools; \
    Install-WindowsFeature Web-Asp-Net45; \
    \
    # Configure website \
    Remove-Website -Name 'Default Web Site'; \
    New-Website -Name 'WordPress' -Port 80 -PhysicalPath '%WORDPRESS_ROOT%' -ApplicationPool '.NET v4.5'; \
    \
    # Verify PHP CGI exists \
    if (!(Test-Path \"%PHP_DIR%\php-cgi.exe\")) { Write-Error 'PHP CGI not found'; exit 1 }; \
    \
    # Configure PHP handler with corrected syntax
    Import-Module WebAdministration; \
    $fcgiSection = Get-WebConfiguration -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter 'system.webServer/fastCgi'; \
    $phpCgiPath = "%PHP_DIR%\php-cgi.exe"; \
    if (-not ($fcgiSection.Collection | Where-Object { $_.fullPath -eq $phpCgiPath })) { \
        Add-WebConfiguration -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter 'system.webServer/fastCgi' -Value @{ fullPath = $phpCgiPath; arguments = ""; maxInstances = 4 }; \
    }; \
    Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter "system.webServer/fastCgi/application[@fullPath='$phpCgiPath']/environmentVariables" -Name "." -Value @{name="PHP_FCGI_MAX_REQUESTS";value="10000"}; \
    \
    # Add handler mapping \
    if (-not (Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter 'system.webServer/handlers' -Name '.' | Where-Object { $_.name -eq "PHP-FastCGI" })) { \
        Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter 'system.webServer/handlers' -Name '.' -Value @{ name = "PHP-FastCGI"; path = "*.php"; verb = "*"; modules = "FastCgiModule"; scriptProcessor = $phpCgiPath; resourceType = "Either" \
        }; \
    }

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