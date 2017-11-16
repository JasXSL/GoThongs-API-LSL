/*
	
	This is an example of basic mode for GoThongs API webhooks.
	https://github.com/JasXSL/GoThongs/wiki/JSON-Webhooks
	
	For this script to work, you must create a GoT Mod and make sure "Allow remote webhook URL updates" is checked.
	This script will automatically update the webhook URL for your mod whenever the LSL HTTP_IN URL is changed.

*/
// Get this key from your mod panel on http://jasx.org/lsl/got
#define JSON_KEY ""

// This is where you handle your response data
string AssetData( string type, integer id, key uuid ){
    
	// This is a a book of id 59 was requested. You can find the ID in the URL bar when editing a book in your mod.
    if( type == "GotBook" && id == 59 ){
        
		// Default pages to present
		list pages = [
			"This is page one",
			"This is page two"
		];
		
		// If this book was requested by Jasdac, we can put something else in the book
		if( uuid == "cf2625ff-b1e9-4478-8e6b-b954abde056b" )
			pages = ["Hello there you handsome shoober"];
			
		// The expected output for each asset type can be found here: https://github.com/JasXSL/GoThongs/wiki/JSON-Webhooks-%7C-Supported-Asset-Types
        return llList2Json(JSON_OBJECT, [
            "pages", pages
        ]);
        
    }
    
    return "";
    
}


#include "GoThongs-API-LSL/classes/packages/gotapi Webhook.lsl"

