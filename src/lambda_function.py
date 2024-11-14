import boto3
import json
from database_functions import GetRegularVisitorCount, GetUniqueVisitorCount
   # HTTP body check
   ## check if body is none, if it is, return an error response
   ## check if body doesn't have exactly "queryType" property, return an error response
   ## only if the request is valid, then call the ValidResponseHandlerFunction
   #  if event['httpMethod'] == "POST": # or if event.httpMethod event exists
   #     if event["body"] != None:
   #        try: load json body's queryType
   #        except: # no queryType property
   #           return error response
   #        if query == unique:
   #           return unique visitor count
   #        elif query == regular:
   #           return regular visitor count
   #        else: # query type is malformed
   #           return error response
   #     else: # is none
   #     return error response
   #  else:
   #     return error response
   
   # Returning visitor values
   ## should encapsulate the process of checking if item exists, if table initialized
   ## return value should be designed based on the response generation
   ## GetStat(visitorType) -> json {"VisitorCount": number}
   
   # DONE: handling response generation
   ## i saw aws template function using a function to generate the response, maybe i should do that
   ## I don't want to set status code, body, headers, error code from different places
   ## I want to set them in one place, so its easier to read
   ## CreateResponse(error, response, debug=False, debugMessage=Null) -> json {}
   ## also debug and debugMessage kwargs that prints debugMessage if debug is True 

def lambda_handler(event, context):
   key = "Visitors"
   attribute = "VisitorCount"
   body = {}
   
   match event['httpMethod']:
      case "POST":
         namespace = GetNamespace(context.function_name)
         dynamodb = boto3.resource('dynamodb')
         stat_table = dynamodb.Table(f"cloud-resume-stat_{namespace}")
         cache_table = dynamodb.Table(f"cloud-resume-cache_{namespace}")
         
         if event["body"] != None:
            query = None
            
            try:
               query = json.loads(event["body"])["queryType"]
            except:
               return respond("Bad request body")
            
            if query == "unique":
               body = GetUniqueVisitorCount(
                  event["headers"]["X-Forwarded-For"], # fix this line to handle when there's no X-Forwarded-For header
                  stat_table,
                  cache_table)
            else:
               return respond("Bad queryType parameter")
               
         else:
            body = GetRegularVisitorCount(stat_table, key, attribute)
      case _:
         return respond("Unsupported HTTP method")
   
   return respond(None, body)

def GetNamespace(functionName):
   return functionName.split("_")[1]

def respond(errMessage, res=None, debugMessage=None):
   body = debugMessage if debugMessage else json.dumps(res)
   return {
      'statusCode': 400 if errMessage else 200,
      'body': errMessage if errMessage else body,
      'headers': {
         'Content-Type': 'application/json',
         'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
         'Access-Control-Allow-Origin': '*',
         'Access-Control-Allow-Methods': 'OPTIONS,POST',
      },
   }





