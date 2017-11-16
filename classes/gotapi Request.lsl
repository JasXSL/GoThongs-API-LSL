#define gotapiRequest$REST_URL "http://jasx.org/lsl/got/app/mod_api/"

// Builds a request with multiple tasks
#define gotapiRequest$sendApiRequest(api_key, tasks) \
	llHTTPRequest( \
        gotapiRequest$REST_URL, \
        [ \
            HTTP_METHOD, "POST", \
            HTTP_MIMETYPE, "application/x-www-form-urlencoded", \
            HTTP_CUSTOM_HEADER, "Got-Mod-Token", api_key, \
            HTTP_BODY_MAXLENGTH, 16384 \
        ], \
        "tasks="+llEscapeURL(llList2Json(JSON_ARRAY, tasks)) \
    ) 

// Formats a task. Targets, data and callback can be JSON as well
#define gotapiRequest$buildApiTask(type, target, data, callback) \
    llList2Json(JSON_OBJECT, [ \
        "type", type, \
        "target", target, \
        "data", data, \
        "callback", callback \
    ])
   
   

// These deal with the response itself
#define gotapiRequest$response$getSuccess(response) (llJsonGetValue(response, ["errors"]) == JSON_INVALID)
#define gotapiRequest$response$getErrorsList(response) llJson2List(llJsonGetValue(response, ["errors"]))
#define gotapiRequest$response$getCallsList(response) llJson2List(llJsonGetValue(response, ["jsonapi"]))


#define gotapiRequest$call$getType(call) llJsonGetValue(call, ["meta", "type"])
#define gotapiRequest$call$getSuccess(call) (int)llJsonGetValue(call, ["meta", "success"])
#define gotapiRequest$call$getCallback(call) llJsonGetValue(call, ["meta", "callback"])
#define gotapiRequest$call$getErrorsList(call) llJson2List(llJsonGetValue(call, ["meta", "errors"]))
#define gotapiRequest$call$getDataList(call) llJson2List(llJsonGetValue(call, ["data"]))
#define gotapiRequest$call$getFatalErrorsList(call) llJson2List(llJsonGetValue(call, ["errors"]))
#define gotapiRequest$call$hasFatalErrors(call) (llJsonValueType(call, ["errors"]) == JSON_ARRAY)
#define gotapiRequest$call$getIncludedList(call) llJson2List(llJsonGetValue(call, ["included"]))
#define gotapiRequest$call$hasIncluded(call) (llJsonValueType(call, ["included"]) != JSON_INVALID) 
#define gotapiRequest$call$getIncludedItem(call, type, id) \
    _gotAPI_call_get_included_item(gotapiRequest$call$getIncludedList(call), type, id)

#define gotapiRequest$resource$hasAttributes(resource) (llJsonValueType(resource, ["attributes"]) != JSON_INVALID)
#define gotapiRequest$resource$getAttributes(resource) llJsonGetValue(resource, ["attributes"])
#define gotapiRequest$resource$getRelationships(resource) llJsonGetValue(resource, ["relationships"])
#define gotapiRequest$resource$getID(resource) llJsonGetValue(resource, ["id"])
#define gotapiRequest$resource$getType(resource) llJsonGetValue(resource, ["type"])

#define gotapiRequest$relationship$getDataList(relationship, type) llJson2List(llJsonGetValue(relationship, [type, "data"]))

string _gotAPI_call_get_included_item(list included, string type, string id){
    
    list_shift_each(included, resource,
        
        if( llJsonGetValue(resource, ["id"]) == id && llJsonGetValue(resource, ["type"]) == type )
            return resource;
        
    )
    
    return "";
}