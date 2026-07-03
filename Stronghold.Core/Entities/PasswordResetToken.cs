namespace Stronghold.Core.Entities;

/// <summary>
/// Kod za reset lozinke - cuva se hashiran (nikad plain text) i ima istek.
/// </summary>
public class PasswordResetToken : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public string CodeHash { get; set; } = null!;
    public string CodeSalt { get; set; } = null!;
    public DateTime ExpiresAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UsedAt { get; set; }
}
