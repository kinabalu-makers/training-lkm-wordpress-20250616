# Use Windows Server Core as base
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Install MariaDB (MySQL-compatible)
RUN powershell -Command "Invoke-WebRequest -Uri https://downloads.mariadb.org/rest-api/mariadb-10.6.2/16590 -OutFile C:\\mariadb.msi; Start-Process msiexec.exe -ArgumentList '/i C:\\mariadb.msi /quiet norestart' -NoNewWindow -Wait; Remove-Item -Path C:\\mariadb.msi

# Set environment variables (modify as needed)
ENV MYSQL_ROOT_PASSWORD="rootpassword"
ENV MYSQL_DATABASE="my_database"
ENV MYSQL_USER="my_user"
ENV MYSQL_PASSWORD="mypassword"

# Expose MySQL port
EXPOSE 3306

# Start MariaDB
CMD ["C:\\Program Files\\MariaDB 10.6\\bin\\mysqld.exe", "--console"]