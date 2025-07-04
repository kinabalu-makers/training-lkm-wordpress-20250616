# escape=`

#
# This Dockerfile is provided for demonstration purposes only and it is not supported by Microsoft
# PHP 7.1 x64 running on IIS
#

FROM mcr.microsoft.com/windows/servercore/iis AS php84

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

# WORKDIR C:\

# COPY /php/ C:\php\

# RUN ls

ENV UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'

# Install PHP
RUN Invoke-WebRequest 'https://windows.php.net/downloads/releases/archives/php-8.4.3-nts-Win32-vs17-x64.zip' -UserAgent '${UserAgent}' -OutFile 'C:\php.zip'
RUN Expand-Archive -Path c:\php.zip -DestinationPath C:\PHP
# Install VC Redistributable
RUN Invoke-WebRequest 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -UserAgent '' -OutFile 'C:\vc_redist-x64.exe'

RUN Invoke-WebRequest 'https://files.phpmyadmin.net/phpMyAdmin/5.2.2/phpMyAdmin-5.2.2-all-languages.zip' -UserAgent '' -OutFile 'C:\phpmyadmin.zip'
RUN Expand-Archive -Path c:\phpmyadmin.zip -DestinationPath C:\phpmyadmin
# RUN `
#     try { `
#         # Install PHP `
#         Invoke-WebRequest 'https://windows.php.net/downloads/releases/archives/php-8.4.3-nts-Win32-vs17-x64.zip' -UserAgent '' -OutFile 'C:\php.zip' ; `
#         Invoke-WebRequest 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -UserAgent '' -OutFile 'C:\vc_redist-x64.exe' ; `
#         Invoke-WebRequest 'https://sourceforge.net/projects/wincache/files/wincache-2.0.0/wincachewpi-2.0.0.8-7.1-nts-vc14-x64.exe/download' -UserAgent '' -OutFile C:\php_wincache.exe; `
#         Invoke-WebRequest 'https://files.phpmyadmin.net/phpMyAdmin/4.9.11/phpMyAdmin-4.9.11-all-languages.zip' -UserAgent '' -OutFile 'C:\phpmyadmin.zip' ; `
#         Expand-Archive -Path php.zip -DestinationPath C:\PHP; `
#         Expand-Archive -Path c:\phpmyadmin.zip -DestinationPath C:\phpmyadmin; `
#         `
#         Install PHP Win Cache `
#         C:\php_wincache.exe /Q /C "/T:C:\php_wincache_msi"; `
#         Start-Process -FilePath msiexec -ArgumentList '/a C:\php_wincache_msi\wincache71x64wpi.msi /qb TARGETDIR=C:\php_wincache_msi\extracted' -NoNewWindow -PassThru -Wait; `
#         Copy-Item C:\php_wincache_msi\extracted\PFiles\php_wincache.dll c:\PHP\ext; `
#         `
#         # Configure PHP `
#         Copy-Item C:\PHP\php.ini-production C:\PHP\php.ini; `
#     } `
#     catch { `
#         $_.Exception; `
#         $_; `
#         exit 1; `
#     }

FROM mcr.microsoft.com/windows/servercore/iis
 
COPY --from=php84 ["/php/", "/php/"]
COPY --from=php84 ["/vc_redist-x64.exe", "/vc_redist-x64.exe"]

#
# Enable required IIS Features
# Install VC Redist 14
# Configure IIS
# Configure system PATH
#
RUN dism.exe /Online /Enable-Feature /FeatureName:IIS-CGI /All && `
    C:\vc_redist-x64.exe /quiet /install && `
    del C:\vc_redist-x64.exe && `
    %windir%\system32\inetsrv\appcmd.exe set config /section:system.webServer/fastCgi /+[fullPath='c:\PHP\php-cgi.exe'] && `
    %windir%\system32\inetsrv\appcmd.exe set config /section:system.webServer/handlers /+[name='PHP_via_FastCGI',path='*.php',verb='*',modules='FastCgiModule',scriptProcessor='c:\PHP\php-cgi.exe',resourceType='Either'] && `
    %windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/fastCgi /[fullPath='c:\PHP\php-cgi.exe'].instanceMaxRequests:10000 && `
    %windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/fastCgi /+[fullPath='c:\PHP\php-cgi.exe'].environmentVariables.[name='PHP_FCGI_MAX_REQUESTS',value='10000'] && `
    %windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/fastCgi /+[fullPath='c:\PHP\php-cgi.exe'].environmentVariables.[name='PHPRC',value='C:\PHP'] && `
    %windir%\system32\inetsrv\appcmd.exe set config /section:defaultDocument /enabled:true /+files.[value='index.php'] && `
    setx PATH /M %PATH%;C:\PHP && `
    setx PHP /M "C:\PHP" && `
    del C:\inetpub\wwwroot\* /Q

COPY --from=php84 ["/phpmyadmin/phpMyAdmin-5.2.2-all-languages/", "/inetpub/wwwroot/"]

# Copy a config.inc.php file for phpMyAdmin
COPY config.inc.php C:\inetpub\wwwroot\config.inc.php

COPY \php.ini C:\PHP\php.ini
# Optional: Add a starter page
# RUN powershell.exe -Command "'<?php phpinfo(); ?>' | Out-File C:\inetpub\wwwroot\index.php -Encoding UTF8"

EXPOSE 80
#
#ADD any application content and perform any configuration below