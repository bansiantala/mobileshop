using Microsoft.AspNetCore.Mvc;

namespace phoneshop.Controllers
{
    public class ContactController : Controller
    {
        public IActionResult Contact()
        {
            return View();
        }
    }
}
