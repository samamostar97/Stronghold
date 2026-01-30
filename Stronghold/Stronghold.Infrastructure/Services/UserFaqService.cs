using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Services
{
    public class UserFaqService : IUserFaqService
    {
        private readonly IRepository<FAQ, int> _faqRepository;

        public UserFaqService(IRepository<FAQ, int> faqRepository)
        {
            _faqRepository = faqRepository;
        }

        public async Task<IEnumerable<UserFaqDTO>> GetAllFaqs()
        {
            var faqs = await _faqRepository.AsQueryable()
                .OrderBy(f => f.CreatedAt)
                .Select(f => new UserFaqDTO
                {
                    Id = f.Id,
                    Question = f.Question,
                    Answer = f.Answer
                })
                .ToListAsync();

            return faqs;
        }
    }
}
