/*
	
	This is an example of how to make requests to the GoThongs mod API.
	https://github.com/JasXSL/GoThongs/wiki/JSON-REST-API
	
	For this script to work, you must create a GoT Mod and make a note of your JSON key.

*/

#include "GoThongs-API-LSL/_core.lsl"

default
{
    state_entry(){
        
        // The JSON KEY of the mod you want to use
        string api_key = "";
        
        // Tasks to send. Each task calls a specific endpoint:
		// https://github.com/JasXSL/GoThongs/wiki/JSON%20REST%20API%20-%20Endpoint%20Identifiers
        list tasks = [
		
			// Builds a task
            gotapiRequest$buildApiTask(
                
                // Task type: 
				// https://github.com/JasXSL/GoThongs/wiki/JSON-REST-API---Endpoint-Identifiers
                "GetAssetData", 
                
                // Target(s)
                mkarr(([llGetOwner()])),
                
                // Data
				// In this case our task type is GetAssetData, which should contain a basetype (type) and the fields we cant to get
                llList2Json(JSON_OBJECT, ([
                
                    // We want user data so we'll set user as our basetype
					// https://github.com/JasXSL/GoThongs/wiki/JSON-REST-API---Data-Fetch-Types
                    "type", "user",
                    
                    // A data fetch object describing the data we want 
					// https://github.com/JasXSL/GoThongs/wiki/JSON%20REST%20API%20-%20Data%20Fetch%20Object
                    "fields", llList2Json(JSON_OBJECT, [
                        // We want to get the user's character key back
                        "charkey", "",
                        // We want a relational object with the user's thong asset
                        "active_thong", llList2Json(JSON_OBJECT, [
                            // We get the level of the user's thong as an attribute
                            "level", "",
                            // We want a relational object with some info about the thong class itself
                            "thong", llList2Json(JSON_OBJECT, [
                                // Get the class name and texture as attributes
                                "name", "",
                                "texture", ""
                            ])
                        ])
                    ])
                ])), 
                
                // Callback, you can set this to anything to make it easier to identify the purpose of a call
                "myCallback"
                
            )
        ];
        
        // Send the request
        gotapiRequest$sendApiRequest(api_key, tasks);

    }
    
    // Handle the response
    http_response( key id, integer status, list meta, string body ){

        // If the response is not valid JSON, something probably borked on the JasX end and you should report it
        if(llJsonValueType(body, []) != JSON_OBJECT){
            
            qd("Server error: "+body);
            return;
            
        }
        
        // Check if response was successful
        if( gotapiRequest$response$getSuccess(body) ){
            
            // Fetch a list of JSON API documents and loop through them : http://jsonapi.org/
            list calls = gotapiRequest$response$getCallsList(body);
            list_shift_each(calls, call,

                // This document has fatal errors
                if( gotapiRequest$call$hasFatalErrors(call) )
                    qd("Fatal errors:\n  "+implode("\n  ", gotapiRequest$call$getFatalErrorsList(call)));
                
                // No fatal errors
                else{
                
                    // Information about the request
                    string type = gotapiRequest$call$getType(call);
                    integer success = gotapiRequest$call$getSuccess(call);
                    string callback = gotapiRequest$call$getCallback(call);
                    list errors = gotapiRequest$call$getErrorsList(call);

                    // Output any non-fatal errors in chat
                    list_shift_each(errors, error,
                        qd(error);
                    )
                    
                    // Output some info about the document
                    qd(
                        "\n== Response ==\n  "+
                        implode("\n  ", ([
                            "type : "+type,
                            "success : "+(string)success,
                            "callback : "+callback
                        ]))
                    );

                    // Iterate over the assets returned
                    list dataList = gotapiRequest$call$getDataList(call);
                    list_shift_each(dataList, resource,
                        
                        // Data is a user object with some data we specified
                        
                        // Fetch attributes. We requested the user ID so we can fetch the ID attribute
                        string attributes = gotapiRequest$resource$getAttributes(resource);
                        key user_id = j(attributes, "charkey"); // character key
                        
                        // We also fetched a linkable object (user thong asset) as a JSON object, which means instead of getting the ID of the user thong asset, it gets added as a linked item.
                        
                        // We fetched all relationship assets here
                        string relationships = gotapiRequest$resource$getRelationships(resource);
                        
                        // The field name was active_thong, so the resource link ends up there. 
                        // Fetch the linkage object which tells us the type and ID of the linked resource
                        // This is a one to one relationship which is why we can simply fetch the first linkage object
                        string thongLinkageObject = llList2String(
                            gotapiRequest$relationship$getDataList(relationships, "active_thong"), 
                            0
                        );

                        // Find the the actual thong resource object by using the linkage object's id and type
                        string userThongResource = gotapiRequest$call$getIncludedItem(
                            call, // Call is the JSON API document
                            j(thongLinkageObject, "type"),
                            j(thongLinkageObject, "id")
                        );
                        
                        // We specfied that we wanted to get the level of the user thong as an attribute when we defined it as a non-object in the original call
                        integer thongLevel = (integer)j(
                            gotapiRequest$resource$getAttributes(userThongResource),
                            "level"
                        );
                        
                        // We did however specify that we wanted to get some thong class data from the user's asset
                        // We did so by defining the "thong" field as an object.
                        // This ends up in the user thong asset's relationships
                        string classRelationships = gotapiRequest$resource$getRelationships(userThongResource);
                        
                        // Since this is also a one to one linkage, we can just grab the first entry
                        // You might notice that this is basically the same as we did above, but this time for the class relationship object, and the field we requested was "thong"
                        string classLinkageObject = llList2String(
                            gotapiRequest$relationship$getDataList(classRelationships, "thong"), 
                            0
                        );
                        
                        // Fetch the thong class resource object by using the linkage object
                        string classResource = gotapiRequest$call$getIncludedItem(
                            call,
                            j(classLinkageObject, "type"),
                            j(classLinkageObject, "id")
                        );
                        
                        // For the thong (player class) resource we only specified that we wanted attributes
                        string classAttributes = gotapiRequest$resource$getAttributes(classResource);
                        
                        // Fetch these attributes
                        string className = j(classAttributes, "name");
                        key classTexture = j(classAttributes, "texture");
                        
                        qd(
                            "We fetched some data about secondlife:///app/agent/"+(str)user_id+"/about\n"+
                            "id : "+(string)user_id+"\n"+
                            "user_thong : \n"+
                            "  level : "+(str)thongLevel+"\n"+
                            "  class : \n"+
                            "    name : "+className+"\n"+
                            "    texture : "+(string)classTexture
                        );
                        
                    )

                }
                
            )

        }
        
        // Response was not successful, output errors
        else
            qd("Errors:\n  "+implode("\n  ", gotapiRequest$response$getErrorsList(body)));
        
        
    }


}
