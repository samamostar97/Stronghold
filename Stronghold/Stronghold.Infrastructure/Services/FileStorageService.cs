using Stronghold.Application.Common;
using Stronghold.Application.IServices;

namespace Stronghold.Infrastructure.Services
{
    public class FileStorageService : IFileStorageService
    {
        private readonly string _webRootPath;

        public string[] AllowedExtensions => new[] { ".jpg", ".jpeg", ".png", ".gif" };
        public long MaxFileSizeBytes => 5 * 1024 * 1024; // 5MB

        public FileStorageService(string webRootPath)
        {
            _webRootPath = webRootPath;
        }

        public async Task<FileUploadResult> UploadAsync(FileUploadRequest request, string category, string uniqueId)
        {
            if (request.FileStream == null || request.FileSize == 0)
            {
                return new FileUploadResult
                {
                    Success = false,
                    ErrorMessage = "Fajl nije proslijeđen"
                };
            }

            if (request.FileSize > MaxFileSizeBytes)
            {
                return new FileUploadResult
                {
                    Success = false,
                    ErrorMessage = $"Veličina fajla prelazi maksimalnih {MaxFileSizeBytes / (1024 * 1024)}MB"
                };
            }

            var extension = Path.GetExtension(request.FileName).ToLowerInvariant();
            if (!AllowedExtensions.Contains(extension))
            {
                return new FileUploadResult
                {
                    Success = false,
                    ErrorMessage = $"Dozvoljene ekstenzije su: {string.Join(", ", AllowedExtensions)}"
                };
            }

            var uploadsFolder = Path.Combine(_webRootPath, "uploads", category);
            Directory.CreateDirectory(uploadsFolder);

            var fileName = $"{uniqueId}_{Guid.NewGuid()}{extension}";
            var filePath = Path.Combine(uploadsFolder, fileName);

            using (var fileStream = new FileStream(filePath, FileMode.Create))
            {
                await request.FileStream.CopyToAsync(fileStream);
            }

            var fileUrl = $"/uploads/{category}/{fileName}";

            return new FileUploadResult
            {
                Success = true,
                FileUrl = fileUrl
            };
        }

        public Task<bool> DeleteAsync(string? fileUrl)
        {
            if (string.IsNullOrEmpty(fileUrl))
            {
                return Task.FromResult(false);
            }

            var relativePath = fileUrl.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
            var filePath = Path.Combine(_webRootPath, relativePath);

            if (File.Exists(filePath))
            {
                File.Delete(filePath);
                return Task.FromResult(true);
            }

            return Task.FromResult(false);
        }
    }
}
