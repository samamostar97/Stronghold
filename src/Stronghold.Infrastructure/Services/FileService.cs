using Stronghold.Application.Interfaces;

namespace Stronghold.Infrastructure.Services;

public class FileService : IFileService
{
    private readonly string _basePath;

    public FileService()
    {
        _basePath = Environment.GetEnvironmentVariable("FILE_STORAGE_PATH") ?? "./uploads";
    }

    public async Task<string> UploadAsync(Stream fileStream, string fileName, string folder)
    {
        var folderPath = Path.Combine(_basePath, folder);
        Directory.CreateDirectory(folderPath);

        var uniqueFileName = $"{Guid.NewGuid()}{Path.GetExtension(fileName)}";
        var filePath = Path.Combine(folderPath, uniqueFileName);

        using var stream = new FileStream(filePath, FileMode.Create);
        await fileStream.CopyToAsync(stream);

        return $"/{folder}/{uniqueFileName}";
    }

    public void Delete(string filePath)
    {
        var fullPath = Path.Combine(_basePath, filePath.TrimStart('/'));
        if (File.Exists(fullPath))
            File.Delete(fullPath);
    }
}
