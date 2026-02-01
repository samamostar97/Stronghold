FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Stronghold.Worker/Stronghold.Worker.csproj", "Stronghold.Worker/"]
COPY ["Stronghold.Messaging/Stronghold.Messaging.csproj", "Stronghold.Messaging/"]
RUN dotnet restore "./Stronghold.Worker/Stronghold.Worker.csproj"
COPY . .
WORKDIR "/src/Stronghold.Worker"
RUN dotnet build "./Stronghold.Worker.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./Stronghold.Worker.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Stronghold.Worker.dll"]
