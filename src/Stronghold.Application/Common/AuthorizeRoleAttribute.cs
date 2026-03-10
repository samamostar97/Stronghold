namespace Stronghold.Application.Common;

[AttributeUsage(AttributeTargets.Class, AllowMultiple = true)]
public class AuthorizeRoleAttribute : Attribute
{
    public string Role { get; }

    public AuthorizeRoleAttribute(string role)
    {
        Role = role;
    }
}
