using Stronghold.Application.DTOs.AdminUsersDTO;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IAdminUserService:IService<User,UserDTO,CreateUserDTO,UpdateUserDTO,UserQueryFilter,int>
    {
    }
}
