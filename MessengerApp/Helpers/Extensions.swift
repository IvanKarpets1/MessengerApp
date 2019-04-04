import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{

    func loadImageFromCacheWithURL(urlString: String){
        
     self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }
        
            let url = URL(string: urlString)
            URLSession.shared.dataTask(with: url!) { (data, response, err) in
                if err != nil{
                    print(err as Any)
                    return
                }
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!){
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        self.image = UIImage(data: data!)
                    }
                    
                }
        }.resume()
    }
    
}
