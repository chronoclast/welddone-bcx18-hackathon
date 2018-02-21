import paho.mqtt.client as mqtt
import time
import socket

client = mqtt.Client()

client.connect("100.102.4.11", 1883, 60)

while True:
    try:
        while True:
			#0=off 1=on 2=random
            client.publish("PRC7008/start",'{"startWelding":{"spot":5, "partId":"A","spatter":2,"error":2}}')
            print "Triggered."
            time.sleep(4)

       
    except socket.error:
        client.reconnect()
        print "Reconnecting.."
        pass