using Microsoft.AspNetCore.Mvc;
using phoneshop.Models;

namespace phoneshop.Controllers
{
    public class CartController : Controller
    {

        static List<Cart> cartItems = new List<Cart>();

        public IActionResult Index()
        {
            return View(cartItems);
        }

        public IActionResult AddToCart(int id, string name, decimal price, string image)
        {
            var item = cartItems.FirstOrDefault(x => x.Id == id);

            if (item != null)
            {
                item.Quantity++;
            }
            else
            {
                cartItems.Add(new Cart
                {
                    Id = id,
                    ProductName = name,
                    Price = price,
                    Image = image,
                    Quantity = 1
                });
            }

            return RedirectToAction("Index");
        }

        public IActionResult Remove(int id)
        {
            var item = cartItems.FirstOrDefault(x => x.Id == id);

            if (item != null)
            {
                cartItems.Remove(item);
            }

            return RedirectToAction("Index");
        }
    }
}