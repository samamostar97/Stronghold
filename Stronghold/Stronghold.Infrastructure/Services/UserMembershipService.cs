using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Infrastructure.Services
{
    public class UserMembershipService: IUserMembershipService
    {
        private readonly IRepository<MembershipPaymentHistory, int> _paymentRepository;

        public UserMembershipService(IRepository<MembershipPaymentHistory, int> paymentRepository)
        {
            _paymentRepository = paymentRepository;
        }

        public async Task<IEnumerable<MembershipPaymentDTO>> GetMembershipPaymentHistory(int userId)
        {
            var paymentHistory = _paymentRepository.AsQueryable().Where(x => x.UserId == userId).Include(x => x.MembershipPackage);
            var resultDTO = await paymentHistory.Select(x => new MembershipPaymentDTO()
            {
                Id = x.Id,
                PackageName = x.MembershipPackage.PackageName,
                AmountPaid = x.AmountPaid,
                PaymentDate = x.PaymentDate,
                StartDate = x.StartDate,
                EndDate = x.EndDate

            }).ToListAsync();
            return resultDTO;
        }
    }
}
