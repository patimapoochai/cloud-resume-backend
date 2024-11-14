from boto3.dynamodb.conditions import Key, Attr
import hashlib
from datetime import datetime, timedelta

def GetUniqueVisitorCount(user_ip, stat_table, cache_table):
   # 4 cases to test this function: 
   
   # 3) IP doesn't exists, UniqueVisitor stat doesn't exists
   # 4) IP doesn't exists, UniqueVisitor stat exists
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
         stat_table, "UniqueVisitors", "VisitorCount")["Attributes"]
   res = { "VisitorCount": str(result["VisitorCount"]) } # update the table if the row is there
   return res

def GetRegularVisitorCount(tableName, statKeyName, statDataName):
   body = CheckItemExists(tableName, "Stat", "Visitors")
   if body == None: #  initialize stat
      InitStat(tableName, "Visitors", "VisitorCount", 1)
      response = GetStat(tableName, "Visitors", "VisitorCount")["VisitorCount"]
      body = { "VisitorCount": str(response) }
   else:
      response =  IncrementStat(
      tableName, statKeyName, statDataName)["Attributes"]["VisitorCount"]
      body = { "VisitorCount": str(response) }
   return body
   
def CheckItemExists(table, partition_key_name, primary_key_value):
    response = table.query(
        KeyConditionExpression=Key(partition_key_name).eq(primary_key_value)
    )['Items']
    return response if response else None
    
def GetExpirationTime(expired_in_days):
   return int((datetime.now() + timedelta(days=expired_in_days)).timestamp())
   
def GetStat(table, key, attribute):
   item = {}
   try:
      item = table.get_item(Key={"Stat": key}, AttributesToGet=[attribute])["Item"]
   except KeyError:
      InitStat(table, key, attribute)
      item = table.get_item(Key={"Stat": key}, AttributesToGet=[attribute])["Item"]
   return item
      
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
