using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Features.Faqs.DTOs;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Repositories;
using Stronghold.Infrastructure.Tests.TestHelpers;

namespace Stronghold.Infrastructure.Tests;

public class FaqRepositoryTests
{
    [Fact]
    public async Task GetPagedAsync_ShouldApplySearchOrderingAndPaging()
    {
        await using var context = TestDbContextFactory.Create();
        var repository = new FaqRepository(context);

        context.FAQs.AddRange(
            new FAQ { Question = "Alpha question", Answer = "A1" },
            new FAQ { Question = "Beta question", Answer = "B1" },
            new FAQ { Question = "Gamma question", Answer = "C1" });
        await context.SaveChangesAsync();

        var filter = new FaqFilter
        {
            Search = "question",
            OrderBy = "questiondesc",
            PageNumber = 1,
            PageSize = 2
        };

        var result = await repository.GetPagedAsync(filter, CancellationToken.None);

        Assert.Equal(3, result.TotalCount);
        Assert.Equal(2, result.Items.Count);
        Assert.Equal("Gamma question", result.Items[0].Question);
        Assert.Equal("Beta question", result.Items[1].Question);
    }

    [Fact]
    public async Task DeleteAsync_ShouldSoftDeleteEntity()
    {
        await using var context = TestDbContextFactory.Create();
        var repository = new FaqRepository(context);

        var faq = new FAQ
        {
            Question = "How to train?",
            Answer = "Stay consistent."
        };

        await repository.AddAsync(faq, CancellationToken.None);
        await repository.DeleteAsync(faq, CancellationToken.None);

        var foundByRepository = await repository.GetByIdAsync(faq.Id, CancellationToken.None);
        var rawEntity = await context.FAQs
            .IgnoreQueryFilters()
            .SingleAsync(x => x.Id == faq.Id);

        Assert.Null(foundByRepository);
        Assert.True(rawEntity.IsDeleted);
    }
}
