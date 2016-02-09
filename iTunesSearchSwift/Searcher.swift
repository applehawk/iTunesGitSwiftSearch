//
//  Searcher.swift
//  iTunesSearchSwift
//
//  Created by Hawk on 09/02/16.
//  Copyright © 2016 Hawk. All rights reserved.
//

import Foundation
import UIKit

struct SearchAPIResult {
    init() {
        
    }
    init(title: String, image : String, description: String) {
        self.title = title;
        self.image = image;
        self.description = description;
    }
    var title : String = ""
    var image : String = ""
    var description : String = ""
}

protocol SearchHelper {
    func formatURL( url : String ) -> String
    func performJSONToResultByIndex( jsonResults : NSDictionary?, index: Int ) -> SearchAPIResult?
    func resultsCount( jsonResults : NSDictionary? ) -> Int
}

class SearchHelperITunes : SearchHelper {
    func formatURL(urlStr: String) -> String {
        return "https://itunes.apple.com/search?entity=software&term=" + urlStr;
    }
    func performJSONToResultByIndex( jsonResults : NSDictionary?, index: Int  ) -> SearchAPIResult? {
        if jsonResults == nil {
            return nil
        }
        
        let results = jsonResults!["results"] as! NSArray
        let rowData : NSDictionary = results[index] as! NSDictionary
        var result = SearchAPIResult()
        
        if let titleName = rowData.valueForKey("trackName") as? String {
            result.title = titleName as String!
        }
        
        if let description = rowData.valueForKey("sellerName") as? String {
            result.description = description as String!
        }
        
        //Choose best Artwork picture
        //dispatch_async( dispatch_get_main_queue(), {
            let dataKeys = rowData.allKeys as! [String];
            let artworkKeys = dataKeys.filter({ (match: String) -> Bool in
                return match.containsString("artworkUrl") ? true : false;
            })
            let sortedArtworkKeys = artworkKeys.sort({ ( s1 : String,  s2 : String) -> Bool in
                return Int( String.extractNumberFromText(s1).last! ) > Int( String.extractNumberFromText(s2).last!);
            })
            if let artworkUrlMaxRes = rowData.valueForKey( sortedArtworkKeys.first! ) as! String? {
                result.image = artworkUrlMaxRes
            }
        //});
        
        return result
    }
    func resultsCount( jsonResults : NSDictionary? ) -> Int {
        if jsonResults != nil {
            let results = jsonResults!["results"] as! NSArray
            return results.count
        } else {
            return 0
        }
    }
}

class SearchHelperGitHub : SearchHelper {
    func formatURL(urlStr : String) -> String {
        return "https://api.github.com/search/users?q=" + urlStr;
    }
    func performJSONToResultByIndex( jsonResults : NSDictionary?, index: Int  ) -> SearchAPIResult? {
        if jsonResults == nil {
            return nil
        }
        let results = jsonResults!["items"] as! NSArray
        
        /*let row = results[index]
        let result = SearchAPIResult(
            title: row["url"] as! String,
            image: row["avatar_url"] as! String,
            description: row["login"] as! String)*/
        
        let rowData : NSDictionary = results[index] as! NSDictionary
        var result = SearchAPIResult()
        
        if let titleName = rowData.valueForKey("url") as? String {
            result.title = titleName as String!
        }
        
        if let description = rowData.valueForKey("login") as? String {
            result.description = description as String!
        }
        
        if let avatarUrl = rowData.valueForKey("avatar_url") as? String {
            result.image = avatarUrl as String!
        }
        
        return result
    }
    func resultsCount( jsonResults : NSDictionary? ) -> Int {
        if jsonResults != nil {
            let results = jsonResults!["items"] as! NSArray
            return results.count
        } else {
            return 0
        }
    }
}


class APISearcher : NSObject, NSURLSessionDelegate {
    var searchHelper : SearchHelper
    var dataTask : NSURLSessionDataTask?
    var resultsJSON : NSDictionary?//From JSON
    
    init( searchHelper : SearchHelper ) {
        self.searchHelper = searchHelper
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?)
    {
        print(error)
        let alertController = UIAlertController(title: "Message", message: "Network Problem.", preferredStyle: UIAlertControllerStyle.Alert);
        
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil);
        
        alertController.addAction(alertAction);
        
        let viewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        viewController!.presentViewController(alertController, animated: true, completion: nil)

    }
    
    func resultsCount() -> Int {
        return searchHelper.resultsCount(resultsJSON)
    }
    
    func resultByIndex(index : Int) -> SearchAPIResult? {
        return searchHelper.performJSONToResultByIndex(resultsJSON, index: index)
    }
    func urlForQuery( searchQuery : String ) -> NSURL {
        var queryStr = searchQuery.stringByReplacingOccurrencesOfString(" ", withString: "+");
        queryStr = searchQuery.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        return NSURL(string: searchHelper.formatURL(queryStr))!;
    }
    
    func performSearch( query : String?, completeSearch : ( NSDictionary )->Void) {
        let session = NSURLSession.sharedSession()
        if dataTask != nil {
            dataTask!.cancel();
        }
        
        self.dataTask = session.dataTaskWithURL( urlForQuery(query!), completionHandler: { (data: NSData?, response: NSURLResponse?, error : NSError?) -> Void in
            if(error != nil) {
                if (error != -999) {
                    print(error);
                }
            } else {
                let parsedJSON = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary;
                let results = parsedJSON
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.resultsJSON = results
                    completeSearch(results);
                })
            }
        })
        if dataTask != nil {
            dataTask!.resume();
        }
    }
}