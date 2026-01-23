using Stronghold.Application.DTOs.AdminNutritionistDTO;
using Stronghold.Application.DTOs.AdminTrainerDTO;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IAdminTrainerService : IService<Trainer,TrainerDTO,CreateTrainerDTO,UpdateTrainerDTO,TrainerQueryFilter,int>
    {
    }
}
