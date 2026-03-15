using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Reports.UsersReport;

[AuthorizeRole("Admin")]
public class UsersReportDataQuery : IRequest<UsersReportData>
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
}

public class UsersReportDataQueryHandler : IRequestHandler<UsersReportDataQuery, UsersReportData>
{
    private readonly IUserRepository _userRepository;

    public UsersReportDataQueryHandler(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public async Task<UsersReportData> Handle(UsersReportDataQuery request, CancellationToken cancellationToken)
    {
        var users = await _userRepository.Query()
            .Where(u => u.Role == Role.User)
            .Where(u => u.CreatedAt >= request.From && u.CreatedAt <= request.To)
            .OrderByDescending(u => u.CreatedAt)
            .ToListAsync(cancellationToken);

        return new UsersReportData
        {
            From = request.From,
            To = request.To,
            TotalNewUsers = users.Count,
            Users = users.Select(u => new UserReportItem
            {
                Id = u.Id,
                FullName = $"{u.FirstName} {u.LastName}",
                Email = u.Email,
                CreatedAt = u.CreatedAt
            }).ToList()
        };
    }
}
