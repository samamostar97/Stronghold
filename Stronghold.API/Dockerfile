FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY Stronghold.Core/Stronghold.Core.csproj Stronghold.Core/
COPY Stronghold.Application/Stronghold.Application.csproj Stronghold.Application/
COPY Stronghold.Infrastructure/Stronghold.Infrastructure.csproj Stronghold.Infrastructure/
COPY Stronghold.API/Stronghold.API.csproj Stronghold.API/
RUN dotnet restore Stronghold.API/Stronghold.API.csproj

COPY Stronghold.Core/ Stronghold.Core/
COPY Stronghold.Application/ Stronghold.Application/
COPY Stronghold.Infrastructure/ Stronghold.Infrastructure/
COPY Stronghold.API/ Stronghold.API/
RUN dotnet publish Stronghold.API/Stronghold.API.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Stronghold.API.dll"]
