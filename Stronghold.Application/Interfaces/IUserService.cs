using Stronghold.Application.DTOs.Users;

namespace Stronghold.Application.Interfaces;

public interface IUserService : ICrudService<UserResponse, UserSearch, UserInsertRequest, UserUpdateRequest>
{
    Task<(byte[] Data, string ContentType)> GetImageAsync(int id);
}
