using Microsoft.AspNetCore.Mvc;

namespace phoneshop.Controllers
{
    public class AboutController : Controller
    {
        public IActionResult About()
        {
            return View();
        }
    }
}
