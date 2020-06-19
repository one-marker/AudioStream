import UIKit
import Foundation

class MainController: UIViewController{
    
    
    
    @IBOutlet weak var fragment_main_uri: UITextField!
    
    @IBOutlet weak var fragment_main_connect_btn: UIButton!
    
    @IBOutlet weak var fragment_main_current_status: UILabel!
    
    
    let audioController = AudioController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        
        
        
           
    }

    @IBAction func connect(_ sender: Any) {
        var urlstring = "localhost"
        
        if (self.fragment_main_uri.text != "") {
            urlstring = self.fragment_main_uri.text!
        }
       
        audioController.getConnection(url: urlstring)
        
    }
    
}
