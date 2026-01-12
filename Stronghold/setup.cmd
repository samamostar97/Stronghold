@echo off
setlocal enabledelayedexpansion

:: Read .env file and set variables
for /f "tokens=1,2 delims==" %%a in ('type .env ^| findstr /v "^#" ^| findstr /v "^$"') do (
    set "%%a=%%b"
)

:: Build connection string
set "CONNECTION_STRING=Server=%DB_SERVER%;Database=%DB_NAME%;User id=%DB_USER%;Password=%DB_PASSWORD%;TrustServerCertificate=True;"

:: Generate appsettings.json
(
echo {
echo   "ConnectionStrings": {
echo     "DefaultConnection": "%CONNECTION_STRING%"
echo   },
echo   "Jwt": {
echo     "Key": "%JWT_KEY%",
echo     "Issuer": "%JWT_ISSUER%",
echo     "Audience": "%JWT_AUDIENCE%"
echo   },
echo   "Logging": {
echo     "LogLevel": {
echo       "Default": "Information",
echo       "Microsoft.AspNetCore": "Warning"
echo     }
echo   },
echo   "AllowedHosts": "*"
echo }
) > Stronghold.API\appsettings.json

echo appsettings.json has been generated successfully!
endlocal
