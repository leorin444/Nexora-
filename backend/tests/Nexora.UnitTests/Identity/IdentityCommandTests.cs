using FluentAssertions;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Moq;
using Nexora.Application.Common.Exceptions;
using Nexora.Application.Common.Interfaces;
using Nexora.Application.Identity.Commands.Login;
using Nexora.Application.Identity.Commands.Register;
using Nexora.Domain.Identity;
using Xunit;

namespace Nexora.UnitTests.Identity;

public class IdentityCommandTests
{
    private readonly Mock<UserManager<ApplicationUser>> _userManagerMock;
    private readonly Mock<ITokenService> _tokenServiceMock;
    private readonly Mock<ILogger<RegisterCommandHandler>> _registerLoggerMock;
    private readonly Mock<ILogger<LoginCommandHandler>> _loginLoggerMock;

    public IdentityCommandTests()
    {
        var store = new Mock<IUserStore<ApplicationUser>>();
        _userManagerMock = new Mock<UserManager<ApplicationUser>>(
            store.Object, null!, null!, null!, null!, null!, null!, null!, null!);

        _tokenServiceMock = new Mock<ITokenService>();
        _registerLoggerMock = new Mock<ILogger<RegisterCommandHandler>>();
        _loginLoggerMock = new Mock<ILogger<LoginCommandHandler>>();
    }

    [Fact]
    public async Task Register_WithValidData_ShouldCreateUserAndReturnTokens()
    {
        // Arrange
        var command = new RegisterCommand("test@nexora.local", "P@ssword123!", "John", "Doe");

        _userManagerMock.Setup(x => x.FindByEmailAsync(command.Email))
            .ReturnsAsync((ApplicationUser?)null);

        _userManagerMock.Setup(x => x.CreateAsync(It.IsAny<ApplicationUser>(), command.Password))
            .ReturnsAsync(IdentityResult.Success);

        _userManagerMock.Setup(x => x.AddToRoleAsync(It.IsAny<ApplicationUser>(), "User"))
            .ReturnsAsync(IdentityResult.Success);

        _userManagerMock.Setup(x => x.GetRolesAsync(It.IsAny<ApplicationUser>()))
            .ReturnsAsync(["User"]);

        _tokenServiceMock.Setup(x => x.GenerateAccessToken(It.IsAny<ApplicationUser>(), It.IsAny<IList<string>>()))
            .Returns("valid.jwt.token");

        _tokenServiceMock.Setup(x => x.GenerateRefreshToken())
            .Returns(("raw-refresh-token", "hashed-refresh-token"));

        var handler = new RegisterCommandHandler(
            _userManagerMock.Object,
            _tokenServiceMock.Object,
            _registerLoggerMock.Object);

        // Act
        var result = await handler.Handle(command, CancellationToken.None);

        // Assert
        result.Should().NotBeNull();
        result.AccessToken.Should().Be("valid.jwt.token");
        result.RefreshToken.Should().Be("raw-refresh-token");
        result.User.Email.Should().Be("test@nexora.local");
        result.User.FullName.Should().Be("John Doe");
        result.User.Roles.Should().Contain("User");
    }

    [Fact]
    public async Task Register_WithExistingEmail_ShouldThrowValidationException()
    {
        // Arrange
        var command = new RegisterCommand("existing@nexora.local", "P@ssword123!", "Jane", "Doe");
        var existingUser = new ApplicationUser { Email = command.Email, UserName = command.Email };

        _userManagerMock.Setup(x => x.FindByEmailAsync(command.Email))
            .ReturnsAsync(existingUser);

        var handler = new RegisterCommandHandler(
            _userManagerMock.Object,
            _tokenServiceMock.Object,
            _registerLoggerMock.Object);

        // Act & Assert
        var act = () => handler.Handle(command, CancellationToken.None);
        await act.Should().ThrowAsync<ValidationException>()
            .Where(e => e.Errors.ContainsKey("Email"));
    }

    [Fact]
    public async Task Login_WithValidCredentials_ShouldReturnTokens()
    {
        // Arrange
        var command = new LoginCommand("test@nexora.local", "P@ssword123!", "127.0.0.1");
        var user = new ApplicationUser
        {
            Id = Guid.NewGuid(),
            Email = command.Email,
            UserName = command.Email,
            FirstName = "John",
            LastName = "Doe",
            IsActive = true
        };

        _userManagerMock.Setup(x => x.FindByEmailAsync(command.Email))
            .ReturnsAsync(user);

        _userManagerMock.Setup(x => x.CheckPasswordAsync(user, command.Password))
            .ReturnsAsync(true);

        _userManagerMock.Setup(x => x.GetRolesAsync(user))
            .ReturnsAsync(["User"]);

        _tokenServiceMock.Setup(x => x.GenerateAccessToken(user, It.IsAny<IList<string>>()))
            .Returns("valid.jwt.token");

        _tokenServiceMock.Setup(x => x.GenerateRefreshToken())
            .Returns(("raw-refresh-token", "hashed-refresh-token"));

        var handler = new LoginCommandHandler(
            _userManagerMock.Object,
            _tokenServiceMock.Object,
            _loginLoggerMock.Object);

        // Act
        var result = await handler.Handle(command, CancellationToken.None);

        // Assert
        result.Should().NotBeNull();
        result.AccessToken.Should().Be("valid.jwt.token");
        result.RefreshToken.Should().Be("raw-refresh-token");
        result.User.Email.Should().Be("test@nexora.local");
    }

    [Fact]
    public async Task Login_WithWrongPassword_ShouldThrowValidationExceptionWithoutRevealingSpecifics()
    {
        // Arrange
        var command = new LoginCommand("test@nexora.local", "WrongPassword123!", "127.0.0.1");
        var user = new ApplicationUser
        {
            Email = command.Email,
            UserName = command.Email,
            IsActive = true
        };

        _userManagerMock.Setup(x => x.FindByEmailAsync(command.Email))
            .ReturnsAsync(user);

        _userManagerMock.Setup(x => x.CheckPasswordAsync(user, command.Password))
            .ReturnsAsync(false);

        var handler = new LoginCommandHandler(
            _userManagerMock.Object,
            _tokenServiceMock.Object,
            _loginLoggerMock.Object);

        // Act & Assert
        var act = () => handler.Handle(command, CancellationToken.None);
        await act.Should().ThrowAsync<ValidationException>()
            .Where(e => e.Errors.ContainsKey("Credentials"));
    }

    [Fact]
    public async Task Login_WithInactiveUser_ShouldThrowForbiddenAccessException()
    {
        // Arrange
        var command = new LoginCommand("banned@nexora.local", "P@ssword123!", "127.0.0.1");
        var user = new ApplicationUser
        {
            Email = command.Email,
            UserName = command.Email,
            IsActive = false
        };

        _userManagerMock.Setup(x => x.FindByEmailAsync(command.Email))
            .ReturnsAsync(user);

        _userManagerMock.Setup(x => x.CheckPasswordAsync(user, command.Password))
            .ReturnsAsync(true);

        var handler = new LoginCommandHandler(
            _userManagerMock.Object,
            _tokenServiceMock.Object,
            _loginLoggerMock.Object);

        // Act & Assert
        var act = () => handler.Handle(command, CancellationToken.None);
        await act.Should().ThrowAsync<ForbiddenAccessException>();
    }
}
