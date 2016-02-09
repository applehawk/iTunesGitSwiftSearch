//
//  Searcher.swift
//  iTunesSearchSwift
//
//  Created by Hawk on 09/02/16.
//  Copyright © 2016 Hawk. All rights reserved.
//

import Foundation

struct SearchAPIResult {
    init(title: String, image : String, description: String) {
        self.title = title;
        self.image = image;
        self.description = description;
    }
    let title : String
    let image : String
    let description : String
}

protocol SearchHelper {
    func formatURL( url : String ) -> String
    func performJSONToResultByIndex( jsonResults : NSDictionary?, index: Int ) -> SearchAPIResult?
}

class SearchHelperITunes : SearchHelper {
    func formatURL(urlStr: String) -> String {
        return "https://itunes.apple.com/search?entity=software&term=" + urlStr;
    }
    func performJSONToResultByIndex( jsonResults : NSDictionary?, index: Int  ) -> SearchAPIResult? {
        if jsonResults == nil {
            return nil
        }
        let results = jsonResults!["results"] as! NSDictionary?
        let row = results![index]
        let result = SearchAPIResult(
            title: row!["trackName"] as! String,
            image: row!["artworkUrl500"] as! String,
            description: row!["artistName"] as! String)
        
        return result
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
        let results = jsonResults!["results"] as! NSDictionary?
        let row = results![index]
        let result = SearchAPIResult(
            title: row!["trackName"] as! String,
            image: row!["artworkUrl500"] as! String,
            description: row!["artistName"] as! String)
        
        return result
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
    }
    
    func resultsCount() -> Int {
        return (resultsJSON?.count)!
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