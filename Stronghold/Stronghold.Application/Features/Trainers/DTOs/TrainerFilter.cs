using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Trainers.DTOs;

public class TrainerFilter : PaginationRequest
{
    public string? Search { get; set; }
    public string? OrderBy { get; set; }
}
