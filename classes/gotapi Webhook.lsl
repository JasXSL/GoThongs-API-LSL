/*
	
	API KEY
	Use #define JSON_KEY "<my key>" at the top of the document
	You can get your key from the GoThongs mod panel at http://jasx.org/lsl/got

*/

/*
	
	BASIC MODE

	In basic mode everything is synchronous. Each asset is passed through a single function, which should return a JSON object specifying the data that should override the default asset params set in the GoThongs editor:
	
	
	- Type: Asset type, see https://github.com/JasXSL/GoThongs/wiki/JSON-Webhooks-%7C-Supported-Asset-Types
	- Id: The id of the asset data is being requested for
	- Uuid: The second life user key of the player the item is being requested for. May be empty for some assets.
	
	string AssetData( string type, integer id, key uuid ){
		
		if( type == "GotBook" && id == 59 ){
			
			return llList2Json(JSON_OBJECT, [
				"pages", llList2Json(JSON_ARRAY, [
					"This is page one", 
					"This is page two"
				])
			]);
			
		}
		
		return "";
		
	}
	
*/




/*

	ADVANCED MODE
	In advanced mode you will have to loop through all requested assets and respond yourself.
	
	You will need to define the following function:
	
	AssetsRequested( key request, list assets ){ ... }
	
	request is the key of the http request to respond to
    assets is a list of assets containing {id:(string)id, type:(str)asset_type, asset_id:(int)asset_id, uuid:(key)user}
    
    Use respond(request, response_data, errors, notices) to respond when done
	
    response_data should be a list of JSON objects: {id:(str)id, data:(var)response}
    ID should be the same as you received for the asset and is used to map the asset to the request
        
	

*/
