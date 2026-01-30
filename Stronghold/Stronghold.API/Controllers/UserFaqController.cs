using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/user/faq")]
    [Authorize]
    public class UserFaqController : UserControllerBase
    {
        private readonly IUserFaqService _faqService;

        public UserFaqController(IUserFaqService faqService)
        {
            _faqService = faqService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserFaqDTO>>> GetAll()
        {
            var result = await _faqService.GetAllFaqs();
            return Ok(result);
        }
    }
}
