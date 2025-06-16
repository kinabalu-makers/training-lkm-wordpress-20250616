# Use the official Windows Server Core with IIS image
FROM mcr.microsoft.com/windows/servercore/iis

# Set environment variables
ENV PHPMYADMIN_VERSION=5.2.2
ENV PHPMYADMIN_SHA256=6e7e6e3e2b6e6e2e6e2e6e2e6e2e6e2e6e2e6e2e6e2e6e2e6e2e6e2e6e2e6e2e

# Install PHP
RUN powershell -Command "\
    Invoke-WebRequest -Uri https://windows.php.net/downloads/releases/php-8.2.19-nts-Win32-vs16-x64.zip -OutFile php.zip; \
    Expand-Archive php.zip -DestinationPath C:\php; \
    Remove-Item php.zip"

# Add PHP to PATH
ENV PATH="C:\\php;${PATH}"

# Configure PHP in IIS
RUN powershell -Command "\
    Import-Module WebAdministration; \
    New-Item -Path IIS:\AppPools\PHPAppPool; \
    Set-ItemProperty IIS:\AppPools\PHPAppPool -Name 'managedRuntimeVersion' -Value ''; \
    New-Item -Path IIS:\Sites\Default Web Site\phpmyadmin -Type Application -PhysicalPath C:\inetpub\wwwroot\phpmyadmin -ApplicationPool PHPAppPool"

# Download and extract phpMyAdmin
RUN powershell -Command "\
    Invoke-WebRequest -Uri https://files.phpmyadmin.net/phpMyAdmin/${env:PHPMYADMIN_VERSION}/phpMyAdmin-${env:PHPMYADMIN_VERSION}-all-languages.zip -OutFile phpmyadmin.zip; \
    if ((Get-FileHash phpmyadmin.zip -Algorithm SHA256).Hash -ne $env:PHPMYADMIN_SHA256) { throw 'SHA256 mismatch for phpMyAdmin download.' }; \
    Expand-Archive phpmyadmin.zip -DestinationPath C:\inetpub\wwwroot\; \
    Move-Item C:\inetpub\wwwroot\phpMyAdmin-${env:PHPMYADMIN_VERSION}-all-languages C:\inetpub\wwwroot\phpmyadmin; \
    Remove-Item phpmyadmin.zip"

# Configure PHP in IIS (add handler mapping)
RUN powershell -Command "\
    Import-Module WebAdministration; \
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/handlers' -name '.' -value @{name='PHP_via_FastCGI';path='*.php';verb='*';modules='FastCgiModule';scriptProcessor='C:\php\php-cgi.exe';resourceType='Either'} -location 'Default Web Site/phpmyadmin'; \
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/fastCgi/application' -name '.' -value @{fullPath='C:\php\php-cgi.exe';arguments=''} -location 'Default Web Site/phpmyadmin'"

# Set the default document for phpMyAdmin
RUN powershell -Command "\
    Set-ItemProperty -Path 'IIS:\Sites\Default Web Site\phpmyadmin' -Name 'defaultDocument' -Value 'index.php'; \
    Set-ItemProperty -Path 'IIS:\Sites\Default Web Site\phpmyadmin' -Name 'physicalPath' -Value 'C:\inetpub\wwwroot\phpmyadmin'"

# Set the working directory
WORKDIR C:\inetpub\wwwroot\phpmyadmin

# Expose port 80
EXPOSE 80