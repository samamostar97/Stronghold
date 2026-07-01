FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY Stronghold.Worker/Stronghold.Worker.csproj Stronghold.Worker/
RUN dotnet restore Stronghold.Worker/Stronghold.Worker.csproj

COPY Stronghold.Worker/ Stronghold.Worker/
RUN dotnet publish Stronghold.Worker/Stronghold.Worker.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/runtime:8.0
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Stronghold.Worker.dll"]
