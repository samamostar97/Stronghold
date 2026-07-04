FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY Stronghold.Core/Stronghold.Core.csproj Stronghold.Core/
COPY Stronghold.Application/Stronghold.Application.csproj Stronghold.Application/
COPY Stronghold.Infrastructure/Stronghold.Infrastructure.csproj Stronghold.Infrastructure/
COPY Stronghold.Worker/Stronghold.Worker.csproj Stronghold.Worker/
RUN dotnet restore Stronghold.Worker/Stronghold.Worker.csproj

COPY Stronghold.Core/ Stronghold.Core/
COPY Stronghold.Application/ Stronghold.Application/
COPY Stronghold.Infrastructure/ Stronghold.Infrastructure/
COPY Stronghold.Worker/ Stronghold.Worker/
RUN dotnet publish Stronghold.Worker/Stronghold.Worker.csproj -c Release -o /app/publish --no-restore

# aspnet runtime jer Infrastructure koristi Microsoft.AspNetCore.App framework referencu
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Stronghold.Worker.dll"]
