import Foundation

class Regex {
    let internalExpression: NSRegularExpression?
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        
        //var error: NSError?
        do {
            try self.internalExpression = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
        } catch {
            print(error);
            self.internalExpression = nil;
        }
    }
    
    func test(input: String) -> Bool {
        
        let matches = self.internalExpression!.matchesInString(input, options: [], range: NSRangeFromString(input));
        return matches.count > 0
    }
}