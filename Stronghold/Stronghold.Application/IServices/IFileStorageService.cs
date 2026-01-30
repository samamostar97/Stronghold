using Stronghold.Application.Common;

namespace Stronghold.Application.IServices
{
    public interface IFileStorageService
    {
        Task<FileUploadResult> UploadAsync(FileUploadRequest request, string category, string uniqueId);
        Task<bool> DeleteAsync(string? fileUrl);
        string[] AllowedExtensions { get; }
        long MaxFileSizeBytes { get; }
    }
}
