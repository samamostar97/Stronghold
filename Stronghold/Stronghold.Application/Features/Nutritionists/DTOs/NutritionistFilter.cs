using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Nutritionists.DTOs;

public class NutritionistFilter : PaginationRequest
{
    public string? Search { get; set; }
    public string? OrderBy { get; set; }
}
