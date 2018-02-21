--[[---------------------------------------------------------------------------
  Script Name:
    WeldDone - A project built during the BCX 18 hackathon in Berlin, Germany.
    
  By team Boschebol:
    Emelie Hofland <emelie_hofland@hotmail.com>
    Jaime González-Arintero <a.lie.called.life@gmail.com>
  
  Description:
    This script retrieves an image every second using the SICK InspectorP631
    Flex 2D camera, and calculates the size of the area of the detected
    objects. The pictures are saved after 10s in the internal memory of the
    device, and made available to other systems via an FTP server.
    
  Guidelines:
    Before retrieving the images via FTP, remember to configure the transfers
    as binary, using the FTP command "bin".
-----------------------------------------------------------------------------]]


-- Global scope ---------------------------------------------------------------

require('BlobFeatures')

camera = Image.Provider.Camera.create()

config = Image.Provider.Camera.V2DConfig.create()
config:setBurstLength(0)    -- Continuous acquisition
config:setFrameRate(1)      -- Hz
config:setShutterTime(600)  -- us
config:setGainFactor(1.2)

camera:setConfig(config)

-- Initialize the counter for the image storage function.
counter = 0
-------------------------------------------------------------------------------


-- FTP Server -----------------------------------------------------------------
-- Create the FTP server instance.
handle = FTPServer.create()

-- Add the user "weld" to enable login and set start directory to public.
local success = FTPServer.addUser(handle, "weld", "done", "public")

-- Start the ftp server
if (success == true) then
  success = FTPServer.start(handle)
  if (success == true) then
    print("FTPServer is running. Connect to 127.0.0.1:21 with a FTP client")
  end
end
-------------------------------------------------------------------------------


-- Function and event scope ---------------------------------------------------

function main()
  camera:enable()
  camera:start()
end

Script.register("Engine.OnStarted", main)

-- Declare "im" as an image object.
im = Image

-- Function to store images periodically.
function saveImage(im)
  -- print("DEBUG - Saving image...")
  Image.save(im, "public/image.png")
end

function grabImage(im, metaData)
  -- viewer:view(im)
  -- print("DEBUG - Metadata:", metaData:toString())
  area(im)  
  -- Save the image only after 10 iterations (approx. 10s)
  -- print("DEBUG - Counter:", counter)
  if counter == 10 then
      counter = 0
      saveImage(im)
  else
      counter = counter + 1
  end
end

-- timerHandle = Timer.create()
-- Timer.register(timerHandle, "OnExpired", saveImage(im))
-- Timer.setExpirationTime(timerHandle, 5000)
-- Timer.setPeriodic(timerHandle, true)
-- Timer.start(timerHandle)

camera:register("OnNewImage", grabImage)
