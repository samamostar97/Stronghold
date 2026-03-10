using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Reports.UsersReport;

public class UsersReportQueryHandler : IRequestHandler<UsersReportQuery, ReportResult>
{
    private readonly IUserRepository _userRepository;
    private readonly IReportService _reportService;

    public UsersReportQueryHandler(IUserRepository userRepository, IReportService reportService)
    {
        _userRepository = userRepository;
        _reportService = reportService;
    }

    public async Task<ReportResult> Handle(UsersReportQuery request, CancellationToken cancellationToken)
    {
        var users = await _userRepository.Query()
            .Where(u => u.Role == Role.User)
            .Where(u => u.CreatedAt >= request.From && u.CreatedAt <= request.To)
            .OrderByDescending(u => u.CreatedAt)
            .ToListAsync(cancellationToken);

        var data = new UsersReportData
        {
            From = request.From,
            To = request.To,
            TotalNewUsers = users.Count(),
            Users = users.Select(u => new UserReportItem
            {
                Id = u.Id,
                FullName = $"{u.FirstName} {u.LastName}",
                Email = u.Email,
                CreatedAt = u.CreatedAt
            }).ToList()
        };

        return request.Format.ToLower() == "excel"
            ? _reportService.GenerateUsersReportExcel(data)
            : _reportService.GenerateUsersReportPdf(data);
    }
}
