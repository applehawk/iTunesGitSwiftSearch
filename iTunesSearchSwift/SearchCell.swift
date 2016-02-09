//
//  SearchCellTableViewCell.swift
//  iTunesSearchSwift
//
//  Created by Hawk on 30/01/16.
//  Copyright © 2016 Hawk. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var title : UILabel?
    @IBOutlet weak var thumbnail : UIImageView?
    @IBOutlet weak var author : UILabel?
    
    var isFullScreen : Bool = false
    var imageTap : UITapGestureRecognizer? = nil
    
    var animatedImage : UIImageView?
    
    let screenBounds = UIScreen.mainScreen().bounds
    
    var controllerView : UIView?
    
    func tapImageDetected() {
        
        if (!isFullScreen) {
            self.animatedImage! = UIImageView(image: self.thumbnail!.image);
            self.controllerView?.addSubview(self.animatedImage!);
            
            let positionBounds = CGRectMake(
                thumbnail!.frame.origin.x + self.frame.origin.x + (self.superview?.frame.origin.x)!,
                thumbnail!.frame.origin.y + self.frame.origin.y + (self.superview?.frame.origin.y)!,
                
                thumbnail!.frame.width, thumbnail!.frame.height)
            
            animatedImage!.frame = positionBounds;
            
            animatedImage!.bounds = self.animatedImage!.frame;
            
            
            animatedImage?.hidden = false;
            thumbnail!.hidden = true
            
            UIView.animateWithDuration(1.5, delay: 0.0, options: [],
                animations: { () -> Void in
                    
                    self.animatedImage!.contentMode = UIViewContentMode.ScaleAspectFit;
                    self.animatedImage!.frame = self.screenBounds;
                    
                    self.thumbnail!.backgroundColor = UIColor.blackColor();
                }) { (completion: Bool) -> Void in
                    self.isFullScreen = true
                }
        } else {
            
            UIView.animateWithDuration(1.5, delay: 0.0, options: [],
                animations: { () -> Void in
                    
                    self.animatedImage?.frame = (self.imageView?.frame)!;
                    
                    
                    self.thumbnail!.backgroundColor = UIColor.whiteColor();
                }) { (completion: Bool) -> Void in
                    self.thumbnail!.hidden = false;
                    self.animatedImage?.hidden = true;
                    self.isFullScreen = false
                }
        }
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        var shouldReceiveTouch = true
        if (gestureRecognizer == imageTap) {
            shouldReceiveTouch = (touch.view == thumbnail);
        }
        return shouldReceiveTouch;
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imageTap = UITapGestureRecognizer(target: self, action: Selector("tapImageDetected"))
        imageTap!.numberOfTapsRequired = 1;
        imageTap!.delegate = self;
        thumbnail?.userInteractionEnabled = true;
        thumbnail?.addGestureRecognizer(imageTap!);
        
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
