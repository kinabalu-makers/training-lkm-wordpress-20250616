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

RUN Invoke-WebRequest 'https://wordpress.org/latest.zip' -UserAgent '' -OutFile C:\wordpress.zip
RUN Expand-Archive -Path c:\wordpress.zip -DestinationPath C:\wordpress


FROM mcr.microsoft.com/windows/servercore/iis
 
COPY --from=php84 ["/php/", "/php/"]
COPY --from=php84 ["/vc_redist-x64.exe", "/vc_redist-x64.exe"]

RUN powershell -Command "Invoke-WebRequest -Uri 'https://downloads.mariadb.org/rest-api/mariadb/10.6.22/16590' -OutFile mariadb.msi; Start-Process -FilePath msiexec.exe -ArgumentList '/i mariadb.msi /quiet /norestart' -NoNewWindow -Wait"

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

COPY --from=php84 ["/wordpress/wordpress", "/inetpub/wwwroot/"]
COPY \php.ini C:\PHP\php.ini
COPY wp-config.php C:\inetpub\wwwroot\wp-config.php
# Optional: Add a starter page
# RUN powershell.exe -Command "'<?php phpinfo(); ?>' | Out-File C:\inetpub\wwwroot\index.php -Encoding UTF8"

EXPOSE 80

# Start MariaDB
# CMD ["C:\\Program Files\\MariaDB 10.6\\bin\\mysqld.exe", "--console"]
# ENTRYPOINT [ "C:\\Program Files\\MariaDB 10.6\\bin\\mysqld.exe --console" ]