using Stronghold.Application.DTOs.AdminSeminarDTO;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IAdminSeminarService:IService<Seminar,SeminarDTO,CreateSeminarDTO,UpdateSeminarDTO,SeminarQueryFilter,int>
    {
    }
}
