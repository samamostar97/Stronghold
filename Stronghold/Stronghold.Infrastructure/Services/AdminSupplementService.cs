using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.AdminSupplementsDTO;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Services
{
    public class AdminSupplementService : IAdminSupplementService
    {
        private readonly ISupplementRepository _supplementRepository;
        private readonly IMapper _mapper;

        public AdminSupplementService(IMapper mapper, ISupplementRepository supplementRepository)
        {
            _supplementRepository = supplementRepository;
            _mapper = mapper;
        }

        public async Task<int> AddAsync(CreateSupplementDTO createSupplementDTO)
        {
            if (string.IsNullOrEmpty(createSupplementDTO.Name))
                throw new ArgumentException("Supplement name is required");
            if (string.IsNullOrEmpty(createSupplementDTO.Description))
                throw new ArgumentException("Description is required");
            if (createSupplementDTO.Price <= 0)
                throw new ArgumentException("Price must be greater than zero");
            if (!await _supplementRepository.SupplierExists(createSupplementDTO.SupplierId))
                throw new ArgumentException("Supplier doesn't exist");
            if (!await _supplementRepository.CategoryExists(createSupplementDTO.SupplementCategoryId))
                throw new ArgumentException("Category doesn't exist");

            var supplement = _mapper.Map<Supplement>(createSupplementDTO);
            await _supplementRepository.AddAsync(supplement);
            return supplement.Id;
        }
        public async Task<SupplementDTO> GetSupplementByIdAsync(int id)
        {
            var supplement = await _supplementRepository.GetByIdAsync(id);
            return _mapper.Map<SupplementDTO>(supplement);
        }

        public async Task<IEnumerable<SupplementDTO>> GetSupplementsAsync(string? search)
        {
            var query = _supplementRepository.AsQueryable().AsNoTracking().Where(x => !x.IsDeleted);
            if (!string.IsNullOrWhiteSpace(search))
            {
                var s = search.Trim();
                query = query.Where(x => x.Supplier.Name.Contains(s) || x.SupplementCategory.Name.Contains(s) || x.Name.Contains(s));
            }
            var list = await query.ToListAsync();

            return _mapper.Map<IEnumerable<SupplementDTO>>(list);
        }

        public async Task<bool> SoftDeleteAsync(int id)
        {
            var supplement = await _supplementRepository.GetByIdAsync(id);
            // Return false if not found or already deleted - controller will return 404
            if (supplement == null || supplement.IsDeleted)
                return false;

            supplement.IsDeleted = true;
            await _supplementRepository.UpdateAsync(supplement);  // Save to database!
            return true;
        }

        public async Task<bool> UpdateAsync(int id, UpdateSupplementDTO dto)
        {
            var supplement = await _supplementRepository.GetByIdAsync(id);
            // Return false if not found or deleted - controller will return 404
            if (supplement == null || supplement.IsDeleted)
                return false;

            // Partial update: only update fields that were provided
            if (dto.Name != null)
                supplement.Name = dto.Name;

            if (dto.Price.HasValue)
                supplement.Price = dto.Price.Value;

            if (dto.Description != null)
                supplement.Description = dto.Description;

            await _supplementRepository.UpdateAsync(supplement);
            return true;
        }
    }



}
