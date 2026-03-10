namespace Stronghold.Application.Interfaces;

public interface IFileService
{
    Task<string> UploadAsync(Stream fileStream, string fileName, string folder);
    void Delete(string filePath);
}
