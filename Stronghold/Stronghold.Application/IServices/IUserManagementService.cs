using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IServices
{
    public interface IUserManagementService : IService<User, UserResponse, CreateUserRequest, UpdateUserRequest, UserQueryFilter, int>
    {
        Task<UserResponse> UploadImageAsync(int userId, FileUploadRequest fileRequest);
        Task<bool> DeleteImageAsync(int userId);
    }
}
