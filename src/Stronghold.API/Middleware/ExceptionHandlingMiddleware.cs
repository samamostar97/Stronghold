using System.Text.Json;
using FluentValidation;
using Stronghold.Domain.Exceptions;

namespace Stronghold.API.Middleware;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;

    public ExceptionHandlingMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }

    private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var (statusCode, errors) = exception switch
        {
            ValidationException validationEx => (400, validationEx.Errors.Select(e => e.ErrorMessage).ToList()),
            InvalidOperationException => (400, new List<string> { exception.Message }),
            UnauthorizedAccessException => (401, new List<string> { exception.Message }),
            ForbiddenException => (403, new List<string> { exception.Message }),
            NotFoundException => (404, new List<string> { exception.Message }),
            KeyNotFoundException => (404, new List<string> { exception.Message }),
            ConflictException => (409, new List<string> { exception.Message }),
            _ => (500, new List<string> { "Došlo je do greške na serveru." })
        };

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = statusCode;

        var response = new { errors, statusCode };
        var json = JsonSerializer.Serialize(response, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });

        await context.Response.WriteAsync(json);
    }
}
