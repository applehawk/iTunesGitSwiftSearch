//
//  Extensions.swift
//  iTunesSearchSwift
//
//  Created by Hawk on 08/02/16.
//  Copyright © 2016 Hawk. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    class func loadFromURL( url : NSURL, callback : (image: UIImage)->Void) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        
        dispatch_async(queue, {
            let imageData = NSData(contentsOfURL: url);
            dispatch_async(dispatch_get_main_queue(), {
                if let image : UIImage = UIImage(data: imageData!) {
                    callback(image: image);
                    
                }
            })
        });
    }
}

extension String {
    var length: Int { return characters.count    }  // Swift 2.0
    
    static func extractNumberFromText( text : String ) -> [String] {
        let nonDigitCharSet : NSCharacterSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet;
        return text.componentsSeparatedByCharactersInSet( nonDigitCharSet );
    }
}
