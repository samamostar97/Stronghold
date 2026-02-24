using System.Net;
using System.Text.Json;
using FluentValidation;
using Stronghold.Application.Exceptions;

namespace Stronghold.API.Middleware
{
    public class ExceptionHandlerMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionHandlerMiddleware> _logger;

        public ExceptionHandlerMiddleware(RequestDelegate next, ILogger<ExceptionHandlerMiddleware> logger)
        {
            _next = next;
            _logger = logger;
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

        private async Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            var statusCode = exception switch
            {
                ValidationException => HttpStatusCode.BadRequest,
                KeyNotFoundException => HttpStatusCode.NotFound,
                ConflictException => HttpStatusCode.Conflict,
                InvalidOperationException => HttpStatusCode.BadRequest,
                ArgumentException => HttpStatusCode.BadRequest,
                UnauthorizedAccessException => HttpStatusCode.Unauthorized,
                _ => HttpStatusCode.InternalServerError
            };

            if (statusCode == HttpStatusCode.InternalServerError)
            {
                _logger.LogError(exception, "Unhandled exception occurred");
            }

            context.Response.ContentType = "application/json";
            context.Response.StatusCode = (int)statusCode;

            var response = new
            {
                error = statusCode == HttpStatusCode.InternalServerError
                    ? "Server error"
                    : exception.Message,
                validationErrors = exception is ValidationException validationException
                    ? validationException.Errors.Select(x => new
                    {
                        field = x.PropertyName,
                        message = x.ErrorMessage
                    })
                    : null,
                statusCode = (int)statusCode
            };

            await context.Response.WriteAsync(JsonSerializer.Serialize(response));
        }
    }
}
