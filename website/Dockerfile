FROM mcr.microsoft.com/windows/servercore/iis:ltsc2022
# Delete all default files in the IIS directory
RUN powershell -Command "Remove-Item -Recurse C:\\inetpub\\wwwroot\\*"
# Copy the website files to the IIS directory
COPY ./website/ /inetpub/wwwroot/
# Set the default document for IIS
RUN powershell -Command "Set-ItemProperty -Path 'IIS:\\Sites\\Default Web Site' -Name 'defaultDocument' -Value 'index.html'"
# Expose port 80 for HTTP traffic
EXPOSE 80