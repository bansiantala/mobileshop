using System.ComponentModel.DataAnnotations;

namespace phoneshop.Models
{
    public class User
    {


        
        
            public int Id { get; set; }

            public string FullName { get; set; }

            public string Email { get; set; }

            public string Password { get; set; }

            public string ConfirmPassword { get; set; }
        }
    }
    

