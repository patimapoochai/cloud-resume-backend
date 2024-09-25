import boto3
from boto3.dynamodb.conditions import Key, Attr
import json
import hashlib
from datetime import datetime, timedelta

def lambda_handler(event, context):
   key = "Visitors"
   attribute = "VisitorCount"
   
   
   
   status = 200
   headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'OPTIONS,POST',
   }
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
               pass # this is where bad request body ends up
            
            if query == "unique":
               response = GetUniqueVisitorCount(
                  event["headers"]["X-Forwarded-For"], # fix this line to handle when there's no X-Forwarded-For header
                  stat_table,
                  cache_table)
               body = { "UniqueVisitors": str(response["VisitorCount"]) }
            else:
               status = 400
               body = {"error": "Bad request body"}
               
         else: # get regular visitor count
            # check if "Visitors" exists
            body = CheckItemExists(stat_table, "Stat", "Visitors")
            if body == None: #  initialize stat
               InitStat(stat_table, "Visitors", "VisitorCount", 1)
               response = GetStat(stat_table, "Visitors", "VisitorCount")["VisitorCount"]
               body = { f"{attribute}": str(response) }
            else:
               response =  IncrementStat(
                  stat_table, key, attribute)["Attributes"]["VisitorCount"]
               body = { f"{attribute}": str(response) }
      case _:
         status = 400
         body = {"error": "Unsupported HTTP method"}
      
   return {
      'statusCode': status,
      'headers': headers,
      #'body': body, #debug
      'body': json.dumps(body),
   }
   
def CheckItemExists(table, primary_key_name, primary_key_value):
    response = table.query(
        KeyConditionExpression=Key(primary_key_name).eq(primary_key_value)
    )['Items']
    return response if response else None
    
def GetExpirationTime(expired_in_days):
   return int((datetime.now() + timedelta(days=expired_in_days)).timestamp())
   
def GetNamespace(string):
    return string.split("_")[1]

def GetStat(table, key, attribute):
   item = {}
   try:
      item = table.get_item(Key={"Stat": key}, AttributesToGet=[attribute])["Item"]
   except KeyError:
      InitStat(table, key, attribute)
      item = table.get_item(Key={"Stat": key}, AttributesToGet=[attribute])["Item"]
   return item
   
def GetUniqueVisitorCount(user_ip, stat_table, cache_table):
   user_ip_hash = HashIP(user_ip)
   
   # check if user IP is in the cache table
   user = CheckItemExists(cache_table, "UserID", user_ip_hash)
   
   result = {}
   
   if user:
    # if user is in the IP cache table don't do anything, and return current stat
      result = CheckItemExists(stat_table, "Stat", "UniqueVisitors")
      if result == None:
         InitStat(stat_table, "UniqueVisitors", "VisitorCount", 1)
         result = GetStat(stat_table, "UniqueVisitors", "VisitorCount")
      else:
         result = result[0]
   else:
      # else add the IP hash to the table
      cache_table.put_item(Item={"UserID": user_ip_hash, "TTL": GetExpirationTime(7)})
      # and increment unique visitor count
      item = CheckItemExists(stat_table, "Stat", "UniqueVisitors")
      if item == None:
         # if Unique Visitors stat not initialized, put UniqueVisitors in there
         InitStat(stat_table, "UniqueVisitors", "VisitorCount")
      result = IncrementStat(
         stat_table, "UniqueVisitors", "VisitorCount")["Attributes"] # update the table if the row is there
   return result

   
def HashIP(user_ip_string):
    hasher = hashlib.sha256()
    user_ip = bytearray(user_ip_string, 'utf-8')
    hasher.update(user_ip)
    return hasher.hexdigest()
   
def InitStat(table, key, attribute, initialValue=0):
    return table.put_item(Item={"Stat": key, f"{attribute}": initialValue})
   
def IncrementStat(table, key, attribute):
   return table.update_item(Key={ "Stat": key },
      UpdateExpression=f"set {attribute} = {attribute} + :val",
      ExpressionAttributeValues={ ":val": 1 },
      ReturnValues="ALL_NEW")


