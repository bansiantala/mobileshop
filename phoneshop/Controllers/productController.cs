using Microsoft.AspNetCore.Mvc;
using phoneshop.Models;

namespace phoneshop.Controllers
{
    public class ProductController : Controller
    {
        static List<Product> products = new()
        {
            new Product{ Id=1, Name="iPhone 17", Price=80000, Image="/images/iphone17.jpg", Rating=5, Description="Amazing Camera"},
            new Product{ Id=2, Name="Pixel 9", Price=70000, Image="/images/g8.jpg", Rating=4, Description="Best Android Experience"},
            new Product{ Id=3, Name="OnePlus 10 Pro", Price=60000, Image="/images/one10pro.jpg", Rating=4, Description="Fast Performance"},
            new Product{ Id=4, Name="Oppo Reno 15", Price=35000, Image="/images/opporeno15.jpg", Rating=3, Description="Good Design"}
        };

        static List<CartItem> cart = new();

        public IActionResult Index()
        {
            ViewBag.Cart = cart;
            return View(products);
        }

        public IActionResult AddToCart(int id)
        {
            var product = products.FirstOrDefault(p => p.Id == id);

            var item = cart.FirstOrDefault(c => c.Product.Id == id);

            if (item != null)
                item.Quantity++;
            else
                cart.Add(new CartItem { Product = product, Quantity = 1 });

            return RedirectToAction("Index");
        }

        public IActionResult Cart()
        {
            return View(cart);
        }

        public IActionResult IncreaseQty(int id)
        {
            var item = cart.FirstOrDefault(c => c.Product.Id == id);

            if (item != null)
                item.Quantity++;

            return RedirectToAction("Cart");
        }

        public IActionResult DecreaseQty(int id)
        {
            var item = cart.FirstOrDefault(c => c.Product.Id == id);

            if (item != null && item.Quantity > 1)
                item.Quantity--;

            return RedirectToAction("Cart");
        }

        public IActionResult RemoveFromCart(int id)
        {
            var item = cart.FirstOrDefault(c => c.Product.Id == id);

            if (item != null)
                cart.Remove(item);

            return RedirectToAction("Cart");
        }

        // Checkout Page
        public IActionResult Checkout()
        {
            int total = cart.Sum(x => x.Product.Price * x.Quantity);

            Order order = new Order();
            order.TotalAmount = total;

            return View(order);
        }

        // Place Order
        [HttpPost]
        public IActionResult Checkout(Order order)
        {
            cart.Clear();

            return RedirectToAction("Success");
        }

        public IActionResult Success()
        {
            return View();
        }
        public IActionResult Details(int id)
        {
            var product = products.FirstOrDefault(p => p.Id == id);
            if (product == null)
                return NotFound(); 

            return View(product); 
        }


    }
}