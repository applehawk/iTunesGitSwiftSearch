//
//  SearchAPI.swift
//  iTunesSearchSwift
//
//  Created by Hawk on 31/01/16.
//  Copyright © 2016 Hawk. All rights reserved.
//

import UIKit

struct SearchAPIResult {
    
    init() {
        title = ""
        image = ""
        author = ""
    }
    
    init(title: String, image : String, author: String) {
        self.title = title;
        self.image = image;
        self.author = author;
    }
    let title : String;
    let image : String;
    let author : String;
}

class SearchAPI : NSObject, NSURLSessionDelegate {
    
    var results : [NSDictionary]?
    private let delegateView : UIViewController
    
    init( view : UIViewController ) {
        delegateView = view
    }
    
    func searchResultByIndex (index : Int) -> SearchAPIResult? {
        let rowData = results![index] as NSDictionary?;
        
        if( rowData != nil) {
            let title = rowData!.valueForKey("name") as! String
            let image = rowData!.valueForKey("image") as! String
            let author = rowData!.valueForKey("author") as! String
        
            return SearchAPIResult(title: title, image: image, author: author);
        }
        return nil;
    }
  
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        let alertController = UIAlertController(title: "Message", message: "Network Problem.", preferredStyle: UIAlertControllerStyle.Alert);
        
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil);
        
        alertController.addAction(alertAction);
        
        delegateView.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func processResults( results : [NSDictionary] ) {
        
    }
    func performSearch( query : String ) {
        
    }
    
    func urlForQuery( var query : String ) -> NSURL?
    {
        return nil;
    }
    
    func resetSearch() {
        
    }
}

class SearchITunesAPI : SearchAPI {
    override func urlForQuery(var query: String) -> NSURL? {
        query = query.stringByReplacingOccurrencesOfString(" ", withString: "+");
        
        let url = NSURL( string: "https://itunes.apple.com/search?entity=software&term=" + query);
        
        return url!;
    }
}

class SearchGitHubAPI : SearchAPI {
    override func urlForQuery(var query: String) -> NSURL? {
        query = query.stringByReplacingOccurrencesOfString(" ", withString: "+");
        
        let url = NSURL( string: "https://itunes.apple.com/search?entity=software&term=" + query);
        
        return url!;
    }
}