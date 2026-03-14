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
        context.Response.ContentType = "application/json";

        if (exception is ConflictException conflictEx && conflictEx.FieldErrors.Count > 0)
        {
            context.Response.StatusCode = 409;
            var response = new { fieldErrors = conflictEx.FieldErrors, statusCode = 409 };
            var json = JsonSerializer.Serialize(response, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });
            await context.Response.WriteAsync(json);
            return;
        }

        if (exception is ValidationException validationEx)
        {
            context.Response.StatusCode = 400;
            var fieldErrors = validationEx.Errors
                .GroupBy(e => e.PropertyName)
                .ToDictionary(g => ToCamelCase(g.Key), g => g.First().ErrorMessage);
            var response = new { fieldErrors, statusCode = 400 };
            var json = JsonSerializer.Serialize(response, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });
            await context.Response.WriteAsync(json);
            return;
        }

        var (statusCode, errors) = exception switch
        {
            InvalidOperationException => (400, new List<string> { exception.Message }),
            UnauthorizedAccessException => (401, new List<string> { exception.Message }),
            ForbiddenException => (403, new List<string> { exception.Message }),
            NotFoundException => (404, new List<string> { exception.Message }),
            KeyNotFoundException => (404, new List<string> { exception.Message }),
            ConflictException => (409, new List<string> { exception.Message }),
            _ => (500, new List<string> { "Došlo je do greške na serveru." })
        };

        context.Response.StatusCode = statusCode;

        var errorResponse = new { errors, statusCode };
        var errorJson = JsonSerializer.Serialize(errorResponse, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });
        await context.Response.WriteAsync(errorJson);
    }

    private static string ToCamelCase(string name)
    {
        if (string.IsNullOrEmpty(name)) return name;
        return char.ToLowerInvariant(name[0]) + name[1..];
    }
}
