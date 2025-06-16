FROM mcr.microsoft.com/windows/servercore/iis

# Delete all default files in the IIS directory
RUN powershell -Command "Remove-Item -Recurse C:\\inetpub\\wwwroot\\*"

# Install PHP
RUN powershell -Command " \
    Invoke-WebRequest -Uri https://windows.php.net/downloads/releases/php-8.1.0-Win32-vs16-x64.zip -OutFile C:\\php.zip; \
    Expand-Archive -Path C:\\php.zip -DestinationPath C:\\php; \
    Remove-Item -Path C:\\php.zip; \
    Remove-Item -Path C:\\php\\php.ini-production; \
    Rename-Item -Path C:\\php\\php.ini-development -NewName php.ini"

# Set environment variables for PHP
ENV PATH="C:\\php;${PATH}"

# Enable PHP in IIS
RUN powershell -Command " \
    Import-Module WebAdministration; \
    Add-WebConfigurationProperty -PSPath 'IIS:\\' -Filter 'system.webServer/handlers' -Name '.' -Value @{name='PHP_via_FastCGI'; path='*.php'; verb='*'; modules='FastCgiModule'; scriptProcessor='C:\\php\\php-cgi.exe'; resourceType='Unspecified'}; \
    Set-WebConfigurationProperty -PSPath 'IIS:\\' -Filter 'system.webServer/defaultDocument' -Name 'files' -Value @('index.php', 'index.html')"
# Expose port 80 for HTTP traffic
EXPOSE 80

# Copy the website files to the IIS directory
COPY ./website/ /inetpub/wwwroot/

# Set the default document for IIS
RUN powershell -Command " \
    Set-ItemProperty -Path 'IIS:\\Sites\\Default Web Site' -Name 'defaultDocument' -Value 'index.php'"

