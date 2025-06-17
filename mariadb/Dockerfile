# Use Windows Server Core as base
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Install MariaDB (MySQL-compatible)
# RUN powershell -Command "Invoke-WebRequest 'https://downloads.mariadb.org/rest-api/mariadb/10.6.22/16590' -OutFile mariadb.msi; Start-Process -FilePath msiexec.exe -ArgumentList '/i mariadb.msi /quiet /norestart' -NoNewWindow -Wait"

RUN powershell -Command "Invoke-WebRequest -Uri 'https://downloads.mariadb.org/rest-api/mariadb/10.6.22/16591' -OutFile mariadb.zip"
RUN powershell -Command "Expand-Archive -Path mariadb.zip -DestinationPath C:\\mariadb-temp
# Move the extracted folder to C:\mariadb
RUN powershell -Command "New-Item -Path C:\\mariadb -ItemType Directory -Force"
RUN powershell -Command "Copy-Item -Path C:\\mariadb-temp\\mariadb-10.6.22-winx64\\* -Destination C:\\mariadb -Recurse -Force"

RUN powershell -Command "Remove-Item -Path C:\\mariadb-temp -Recurse -Force"
RUN powershell -Command "Remove-Item -Path mariadb.zip"

COPY my.ini C:\\mariadb\\my.ini
# Expose MySQL port
EXPOSE 3306

RUN powershell -Command "Set-ExecutionPolicy Unrestricted -Scope Process -Force; $env:PATH += ';C:\\mariadb\\bin'; $env:MYSQL_HOME = 'C:\\mariadb'; & 'C:\\mariadb\\bin\\mysql_install_db.exe'"
COPY init.sql C:\\mariadb\\init.sql
# Start MariaDB
CMD ["powershell", "-Command", "C:\\mariadb\\bin\\mysqld.exe --console --init-file=C:\\mariadb\\init.sql"]

