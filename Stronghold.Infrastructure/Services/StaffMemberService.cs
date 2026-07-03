using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.StaffMembers;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;
using Stronghold.Infrastructure.Security;

namespace Stronghold.Infrastructure.Services;

public class StaffMemberService
    : BaseCrudService<StaffMember, StaffMemberResponse, StaffMemberSearch,
        StaffMemberUpsertRequest, StaffMemberUpsertRequest>,
      IStaffMemberService
{
    public StaffMemberService(StrongholdDbContext db) : base(db)
    {
    }

    protected override IQueryable<StaffMember> ApplyFilter(IQueryable<StaffMember> query, StaffMemberSearch search)
    {
        if (!string.IsNullOrWhiteSpace(search.Text))
        {
            var text = search.Text.Trim();
            query = query.Where(s => s.FirstName.Contains(text) || s.LastName.Contains(text));
        }
        if (search.StaffType.HasValue)
        {
            query = query.Where(s => s.StaffType == search.StaffType);
        }
        return query.OrderBy(s => s.LastName).ThenBy(s => s.FirstName);
    }

    protected override Task BeforeInsertAsync(StaffMember entity, StaffMemberUpsertRequest request)
    {
        ApplyImage(entity, request);
        return Task.CompletedTask;
    }

    protected override async Task BeforeUpdateAsync(StaffMember entity, StaffMemberUpsertRequest request)
    {
        ApplyImage(entity, request);

        // suzavanje radnog vremena ne smije ostaviti postojece aktivne termine van njega
        var conflictingAppointments = await Db.Appointments.AnyAsync(a =>
            a.StaffMemberId == entity.Id &&
            a.Status != AppointmentStatus.Cancelled &&
            a.Date >= DateOnly.FromDateTime(DateTime.UtcNow) &&
            (a.StartHour < request.WorkStartHour || a.StartHour >= request.WorkEndHour));
        if (conflictingAppointments)
        {
            throw new BusinessException(
                "Radno vrijeme se ne može promijeniti jer postoje zakazani termini van novog radnog vremena.");
        }
    }

    protected override async Task BeforeDeleteAsync(StaffMember entity)
    {
        if (await Db.Appointments.AnyAsync(a => a.StaffMemberId == entity.Id))
        {
            throw new BusinessException("Osoba se ne može obrisati jer ima evidentirane termine.");
        }
    }

    public async Task<(byte[] Data, string ContentType)> GetImageAsync(int id)
    {
        var image = await Db.StaffMembers.AsNoTracking()
            .Where(s => s.Id == id)
            .Select(s => s.ImageData)
            .FirstOrDefaultAsync();

        if (image == null)
        {
            throw new NotFoundException("Osoba nema sliku.");
        }
        return (image, ImageValidator.GetContentType(image) ?? "application/octet-stream");
    }

    private static void ApplyImage(StaffMember entity, StaffMemberUpsertRequest request)
    {
        if (!string.IsNullOrWhiteSpace(request.ImageBase64))
        {
            entity.ImageData = ImageValidator.DecodeAndValidate(request.ImageBase64);
        }
    }
}
