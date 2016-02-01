//
//  ViewController.swift
//  iTunesSearchSwift
//
//  Created by Hawk on 28/01/16.
//  Copyright © 2016 Hawk. All rights reserved.
//

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

class ViewController: UIViewController,
    UITableViewDataSource, UITableViewDelegate,
    UISearchBarDelegate,
    NSURLSessionDelegate {

    @IBOutlet weak var searchTableResults: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let searchLeftCellId = "LeftSearchCellId";
    private let searchRightCellId = "RightSearchCellId";
    
    var searchCellNib : UINib?
    var session : NSURLSession?

    var dataTask : NSURLSessionDataTask?
    
    var resultsArray : NSArray?
    
    var albums : [NSDictionary]?;
    
    //MARK: NSURLSessionDelegate
    
    //Handle URLSession Error
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        let alertController = UIAlertController(title: "Message", message: "Network Problem.", preferredStyle: UIAlertControllerStyle.Alert);
        
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil);
        
        alertController.addAction(alertAction);
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty) {
            return;
        }
        if ((searchText as NSString).length <= 3) {
            self.resetSearch();
        } else {
            self.performSearch(searchText)
        }
        
    }
    func processResults( results : [NSDictionary] ) {
        if (self.albums == nil) {
            self.albums = [];
        }
        
        self.albums?.removeAll()
        self.albums?.appendContentsOf(results);
        
        searchTableResults.reloadData();
    }
    func performSearch( query : String? ) {
        if(dataTask != nil) {
            dataTask?.cancel();
        }
        
        self.dataTask = self.session!.dataTaskWithURL( urlForQuery(query!), completionHandler: { (data: NSData?, response: NSURLResponse?, error : NSError?) -> Void in
            if(error != nil) {
                print(error);
            } else {
                let parsedJSON : NSDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary;
                let results = parsedJSON["results"] as! [NSDictionary]?
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if(results != nil) {
                        self.processResults( results! );
                    }
                })
            }
        })
        if(dataTask != nil) {
            dataTask?.resume();
        }
    }
    
    func urlForQuery( var query : String ) -> NSURL {
        query = query.stringByReplacingOccurrencesOfString(" ", withString: "+");
        
        query = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL( string: "https://itunes.apple.com/search?entity=software&term=" + query);
        
        return url!;
    }
    
    func resetSearch() {
        self.albums?.removeAll();
        self.searchTableResults.reloadData();
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //performSearch( searchBar.text );
        searchBar.resignFirstResponder()
    }
    
    
    //MARK: UITableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 130;
    }
    
    func urlToImage( url : String ) -> UIImage? {
        return UIImage(data: NSData(contentsOfURL: NSURL(string: url)!)!);
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : SearchCell;
        var cellId : String = searchLeftCellId
        if( indexPath.row % 2 == 0) {
            cellId = searchRightCellId
        }
        
        cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
            as! SearchCell;
        
        if(self.albums != nil) {
            let rowData: NSDictionary = self.albums![indexPath.row]
            
            if let trackName = rowData.valueForKey("trackName") as! String? {
                cell.title?.text = trackName;
            }
            
            if let sellerName = rowData["sellerName"] {
                cell.author!.text = sellerName as! String
            }
            
            
            //Choose best Artwork picture
            dispatch_async( dispatch_get_main_queue(), {
                let dataKeys = rowData.allKeys as! [String];
                let artworkKeys = dataKeys.filter({ (match: String) -> Bool in
                    return match.containsString("artworkUrl") ? true : false;
                })
                let sortedArtworkKeys = artworkKeys.sort({ ( s1 : String,  s2 : String) -> Bool in
                    return Int( String.extractNumberFromText(s1).last! ) > Int( String.extractNumberFromText(s2).last!);
                })
                if let artworkUrlMaxRes = rowData.valueForKey( sortedArtworkKeys.first! ) as! String? {
                    cell.thumbnail?.image = nil;
                    UIImage.loadFromURL(NSURL(string: artworkUrlMaxRes)!, callback: { (image) -> Void in
                        cell.thumbnail?.image = image
                    })
                }
            });
        }
    
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.albums == nil ? 0 : self.albums!.count);
    }
    
    override func viewDidAppear(animated: Bool) {
        self.searchBar.becomeFirstResponder();
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if(searchBar.isFirstResponder()) {
            searchBar.resignFirstResponder();
        }
    }
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchTableResults.registerClass(SearchCell.self, forCellReuseIdentifier: searchLeftCellId);
        searchTableResults.registerClass(SearchCell.self, forCellReuseIdentifier: searchRightCellId);
        
        searchCellNib = UINib(nibName: "LeftSearchCell", bundle: nil);
        searchTableResults.registerNib(searchCellNib, forCellReuseIdentifier: searchLeftCellId);
        
        searchCellNib = UINib(nibName: "RightSearchCell", bundle: nil);
        searchTableResults.registerNib(searchCellNib, forCellReuseIdentifier: searchRightCellId);
        
        let sessionConfig : NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
        sessionConfig.HTTPAdditionalHeaders = [ "Accept" : "application/json" ];
        self.session = NSURLSession(configuration: sessionConfig);
        
        /*
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:self
        action:@selector(dismissKeyboard)];*/
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

