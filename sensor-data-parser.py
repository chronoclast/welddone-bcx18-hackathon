"""
DESCRIPTION:
	

SENSOR(S) USED IN THIS EXAMPLE:
	Reference: 
	Type:
"""

import requests
import json
import time

# Publishing frequency (i.e. how often are readings obtained from the sensor).
freq = 0.5

# IP address and port of the IO-Link master
ip_addr = 'http://192.168.1.1/dprop.jsn'

# The header "content-length" is mandatory according to the ifm specifications.
headers = {'content-type': 'text/json'}

# The temperature transmitter is connected in port 2; "gpd" stands for "get process data".
# The index "i" and subindex "s" are to be provided but should be 0. 
# data = {'p': 2, 'req': 'gpd', 'i': 0, 's': 0}

while True:

	#try:
	r = requests.get(ip_addr, headers=headers)
	response = json.loads(r.text)
	print response[0]['ProcessInputs'][0:5]
	# Uncomment the line below for debugging
	# print response

	# Parse the value in raw hexadecimal format from the JSON object
	# raw_hex_value = response['v']
	# Convert the value from hexadecimal (base 16) to integer (base 10)
	#scaled_int_value = int(raw_hex_value, 16)
	# Apply the scale factor to get the actual value
	#int_value = scaled_int_value * 0.1
	# Print the current value on the terminal
	#print int_value

	# except:
	#	print "Unable to read from device! Check the IP address and the IO-Link port!"
	
	# This sets the polling frequency 
	time.sleep(freq)