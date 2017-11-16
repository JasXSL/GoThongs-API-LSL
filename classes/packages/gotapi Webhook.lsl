#include "../../_core.lsl"

#ifndef JSON_KEY
	#error You must define a JSON_KEY. Use #define JSON_KEY "<key>" See "classes/gotapi Webhook.lsl" for more info
#endif

#ifndef USE_ADVANCED
list ERRORS;
list NOTICES;
#endif

string MY_URL;
key FETCH_URL;
key VALIDATE_URL;

#define requestUrl() \
    FETCH_URL = llRequestSecureURL()

#define urlCheck() \
    VALIDATE_URL = llHTTPRequest(MY_URL, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], "CHECK")

timerEvent( string id, string data ){
    
    if( id == "URL_CHECK" )
        urlCheck();
    
}

respond( key id, list data, list errors, list notices ){

    llHTTPResponse(id, 200, llList2Json(JSON_OBJECT, [
        "errors", mkarr(errors),
        "notices", mkarr(notices),
        "data", mkarr(data)
    ]));
	
}

default{
    
    state_entry(){
        
        llReleaseURL(llList2String(llGetPrimitiveParams([PRIM_TEXT]), 0));
        // Validate the URL every 5 minutes
        multiTimer(["URL_CHECK", "", 300, TRUE]);
        requestUrl();
        
    }
    
    
    
    http_request( key id, string method, string body ){
        
        if(id == FETCH_URL){
            
            if( method == URL_REQUEST_GRANTED ){
                
                MY_URL = body;
                llSetText(MY_URL, ZERO_VECTOR, 0);
                gotapiRequest$sendApiRequest(JSON_KEY, [
                    gotapiRequest$buildApiTask(
                        "SetWebhook",
                        "",
                        llList2Json(JSON_OBJECT, [
                            "url", MY_URL
                        ]),
                        ""
                    )
                ]);
                
            }
        
        }
        
        else if( body == "CHECK" )
            llHTTPResponse(id, 200, "SUCCESS");
            
        else if( method == "POST" ){
            
			// Start by validating our mod
            string token = j(body, "Got-Mod-Token");
            if( token != JSON_KEY )
                return respond(id, [], ["Invalid mod token"], []);
            
            list reqs = llJson2List(j(body, "data"));
            
            #ifdef USE_ADVANCED
                AssetsRequested(id, reqs);
            #else
                list out = [];
                list_shift_each( reqs, req,
                    
                    string resp = AssetData( j(req, "type"), (int)j(req, "asset_id"), j(req, "uuid") );
                    if( llJsonValueType(resp, []) == JSON_OBJECT )
                        out+= llList2Json(JSON_OBJECT, [ "id", j(req, "id"), "data", resp ]);  
                        
                )
                respond(id, out, ERRORS, NOTICES);
                ERRORS = NOTICES = [];
            #endif
            
        }        
        
    }
    
    http_response( key id, integer status, list meta, string body ){
        
        if( id == VALIDATE_URL ){
            
            if( body != "SUCCESS" )
                requestUrl();
            
        }
        
    }
    
    timer(){ multiTimer([]); }
    
}
