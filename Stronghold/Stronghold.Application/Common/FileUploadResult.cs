namespace Stronghold.Application.Common
{
    public class FileUploadResult
    {
        public bool Success { get; set; }
        public string? FileUrl { get; set; }
        public string? ErrorMessage { get; set; }
    }
}
