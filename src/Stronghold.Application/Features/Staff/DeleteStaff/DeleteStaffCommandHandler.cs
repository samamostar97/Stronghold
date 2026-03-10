using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Staff.DeleteStaff;

public class DeleteStaffCommandHandler : IRequestHandler<DeleteStaffCommand, Unit>
{
    private readonly IStaffRepository _staffRepository;

    public DeleteStaffCommandHandler(IStaffRepository staffRepository)
    {
        _staffRepository = staffRepository;
    }

    public async Task<Unit> Handle(DeleteStaffCommand request, CancellationToken cancellationToken)
    {
        var staff = await _staffRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Osoblje", request.Id);

        _staffRepository.Remove(staff);
        await _staffRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
