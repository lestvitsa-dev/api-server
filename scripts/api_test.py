#!/usr/bin/python3
import json
import requests

response = requests.get("http://localhost:8080/api/prayer_list_for_user?userKey=1234567890")
items = json.loads(response.text)

print(items)
#print(items['Valute'])
#print(items['Valute']['AUD'])
#print(items['Valute']['AUD']['Name'])

# for valuteName in items['Valute']:
	#print(valuteName)
	# print(items['Valute'][valuteName]['Name']+"\t\t"+str(items['Valute'][valuteName]['Value']))
