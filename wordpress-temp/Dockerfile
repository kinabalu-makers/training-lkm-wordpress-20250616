# Use Windows Server Core 2022 as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Metadata
LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="WordPress on Windows Server Core 2022"

# Set environment variables
ENV WORDPRESS_VERSION 6.5.3
ENV WORDPRESS_SHA1 b5f9df0b9595d0f940f8a6a0e3a1a1c3a1e1a1a1
ENV PHP_VERSION 8.2.12
ENV PHP_SHA256 abc123def456ghi789jkl012mno345pqr678stu901vwx234yza567bcd890efgh

# Install Chocolatey (Windows package manager)
RUN powershell -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install required dependencies
RUN choco install -y php --version %PHP_VERSION% \
    && choco install -y php-curl \
    && choco install -y php-mbstring \
    && choco install -y php-mysql \
    && choco install -y php-xml \
    && choco install -y php-zip \
    && choco install -y php-gd \
    && choco install -y php-intl \
    && choco install -y php-soap \
    && choco install -y php-imagick \
    && choco install -y wget \
    && choco install -y unzip

# Configure PHP
RUN powershell -Command \
    # Enable required PHP extensions \
    Enable-PhpExtension curl \
    Enable-PhpExtension mbstring \
    Enable-PhpExtension mysqli \
    Enable-PhpExtension openssl \
    Enable-PhpExtension xml \
    Enable-PhpExtension zip \
    Enable-PhpExtension gd \
    Enable-PhpExtension intl \
    Enable-PhpExtension soap \
    Enable-PhpExtension imagick \
    \
    # Configure php.ini \
    (Get-Content C:\tools\php\php.ini-production) -replace ';extension=curl', 'extension=curl' `
    -replace ';extension=mbstring', 'extension=mbstring' `
    -replace ';extension=mysqli', 'extension=mysqli' `
    -replace ';extension=openssl', 'extension=openssl' `
    -replace ';extension=xml', 'extension=xml' `
    -replace ';extension=zip', 'extension=zip' `
    -replace ';extension=gd', 'extension=gd' `
    -replace ';extension=intl', 'extension=intl' `
    -replace ';extension=soap', 'extension=soap' `
    -replace ';extension=imagick', 'extension=imagick' `
    -replace ';date.timezone =', 'date.timezone = UTC' `
    -replace 'upload_max_filesize = 2M', 'upload_max_filesize = 64M' `
    -replace 'post_max_size = 8M', 'post_max_size = 64M' `
    -replace 'max_execution_time = 30', 'max_execution_time = 300' `
    -replace 'memory_limit = 128M', 'memory_limit = 256M' | Set-Content C:\tools\php\php.ini

# Download and install WordPress
RUN powershell -Command \
    $ErrorActionPreference = 'Stop'; \
    Invoke-WebRequest -Uri "https://wordpress.org/wordpress-%WORDPRESS_VERSION%.zip" -OutFile wordpress.zip; \
    if ((Get-FileHash wordpress.zip -Algorithm sha1).Hash -ne $env:WORDPRESS_SHA1) { exit 1 }; \
    Expand-Archive -Path wordpress.zip -DestinationPath C:\; \
    Remove-Item wordpress.zip; \
    Move-Item -Path C:\wordpress -Destination C:\inetpub\wwwroot; \
    # Create uploads directory and set permissions \
    New-Item -ItemType Directory -Path C:\inetpub\wwwroot\wordpress\wp-content\uploads; \
    # Set permissions for WordPress directories \
    $acl = Get-Acl C:\inetpub\wwwroot\wordpress; \
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule('IIS_IUSRS','FullControl','ContainerInherit,ObjectInherit','None','Allow'); \
    $acl.SetAccessRule($accessRule); \
    Set-Acl C:\inetpub\wwwroot\wordpress $acl; \
    Set-Acl C:\inetpub\wwwroot\wordpress\wp-content $acl; \
    Set-Acl C:\inetpub\wwwroot\wordpress\wp-content\uploads $acl; \
    Set-Acl C:\inetpub\wwwroot\wordpress\wp-content\plugins $acl; \
    Set-Acl C:\inetpub\wwwroot\wordpress\wp-content\themes $acl

# Copy WordPress configuration template
COPY wp-config.php C:/inetpub/wwwroot/wordpress/

# Install and configure IIS
RUN powershell -Command \
    Install-WindowsFeature Web-Server; \
    Install-WindowsFeature Web-Mgmt-Tools; \
    Install-WindowsFeature Web-Asp-Net45; \
    Remove-Website -Name 'Default Web Site'; \
    New-Website -Name 'WordPress' -Port 80 -PhysicalPath 'C:\inetpub\wwwroot\wordpress' -ApplicationPool '.NET v4.5'

# Configure IIS to use PHP
RUN powershell -Command \
    New-WebHandler -Name 'PHP-FastCGI' -Path '*.php' -Verb '*' -Modules 'FastCgiModule' -ScriptProcessor 'C:\tools\php\php-cgi.exe' -ResourceType 'File'; \
    Add-WebConfigurationProperty -PSPath 'IIS:\' -Filter '/system.webServer/fastCgi' -Name '.' -Value @{'fullPath'='C:\tools\php\php-cgi.exe';'activityTimeout'=600;'requestTimeout'=600;'instanceMaxRequests'=10000}; \
    Set-WebConfigurationProperty -PSPath 'IIS:\' -Filter '/system.webServer/fastCgi/application[@fullPath="C:\tools\php\php-cgi.exe"]/environmentVariables' -Name '.' -Value @{Name='PHP_FCGI_MAX_REQUESTS';Value='10000'}

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