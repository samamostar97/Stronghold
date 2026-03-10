using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Staff.UpdateStaffImage;

public class UpdateStaffImageCommandHandler : IRequestHandler<UpdateStaffImageCommand, StaffResponse>
{
    private readonly IStaffRepository _staffRepository;
    private readonly IFileService _fileService;

    public UpdateStaffImageCommandHandler(IStaffRepository staffRepository, IFileService fileService)
    {
        _staffRepository = staffRepository;
        _fileService = fileService;
    }

    public async Task<StaffResponse> Handle(UpdateStaffImageCommand request, CancellationToken cancellationToken)
    {
        var staff = await _staffRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Osoblje", request.Id);

        if (!string.IsNullOrEmpty(staff.ProfileImageUrl))
            _fileService.Delete(staff.ProfileImageUrl);

        staff.ProfileImageUrl = await _fileService.UploadAsync(request.FileStream, request.FileName, "staff-images");

        _staffRepository.Update(staff);
        await _staffRepository.SaveChangesAsync();

        return StaffMappings.ToResponse(staff);
    }
}
