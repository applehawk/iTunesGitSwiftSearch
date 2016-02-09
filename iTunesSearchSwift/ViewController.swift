//
//  ViewController.swift
//  iTunesSearchSwift
//
//  Created by Hawk on 28/01/16.
//  Copyright © 2016 Hawk. All rights reserved.
//

import UIKit



class ViewController: UIViewController,
    UITableViewDataSource, UITableViewDelegate,
    UISearchBarDelegate {

    @IBOutlet weak var searchTableResults: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let searchLeftCellId = "LeftSearchCellId";
    private let searchRightCellId = "RightSearchCellId";
    
    var searchCellNib : UINib?
    
    var searcher : APISearcher = APISearcher(searchHelper: SearchHelperITunes())
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
                self.searcher.searchHelper = SearchHelperITunes()
                self.performSearch( self.searchBar.text )
        case 1:
                self.searcher.searchHelper = SearchHelperGitHub()
                self.performSearch( self.searchBar.text )
        default: break
        }
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
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty) {
            return;
        }
        if ((searchText as NSString).length <= 3) {
            self.searchTableResults.reloadData();
        } else {
            self.performSearch(searchText)
        }
        
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        performSearch( searchBar.text );
        searchBar.resignFirstResponder()
    }
    
    func performSearch( query : String? ) {
        searcher.performSearch(query) { (results:NSDictionary?) -> Void in
            self.searchTableResults.reloadData();
        }
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
        
        if let result = searcher.resultByIndex( indexPath.row ) as SearchAPIResult? {
            cell.title?.text = result.title
            cell.author?.text = result.description
            if result.image != "" {
                UIImage.loadFromURL(NSURL(string: result.image)!, callback: { (image) -> Void in
                    cell.thumbnail?.image = image
                })
            }
        }

        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searcher.resultsCount()
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
}

