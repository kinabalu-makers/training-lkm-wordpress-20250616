# Use Windows Server Core as base
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Install MariaDB (MySQL-compatible)
# RUN powershell -Command "Invoke-WebRequest 'https://downloads.mariadb.org/rest-api/mariadb/10.6.22/16590' -OutFile mariadb.msi; Start-Process -FilePath msiexec.exe -ArgumentList '/i mariadb.msi /quiet /norestart' -NoNewWindow -Wait"

RUN powershell -Command "Invoke-WebRequest -Uri 'https://downloads.mariadb.org/rest-api/mariadb/10.6.22/16590' -OutFile mariadb.msi; Start-Process -FilePath msiexec.exe -ArgumentList '/i mariadb.msi /quiet /norestart' -NoNewWindow -Wait"

# Expose MySQL port
EXPOSE 3306

# Start MariaDB
CMD ["C:\\Program Files\\MariaDB 10.6\\bin\\mysqld.exe", "--console"]

