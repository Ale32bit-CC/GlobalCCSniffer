print(os.getComputerID()) 
if fs.exists(".controller") then
    if fs.exists("startup") then
        shell.run("startup")
    elseif fs.exists("startup.lua") then
        shell.run("startup.lua")
    end
    return
end

local cSide = "bottom"
local modems = {}

local cM = peripheral.wrap(cSide)
cM.open(0)
--cM.open(1)

for k,v in ipairs(peripheral.getNames()) do
    if peripheral.getType(v) == "modem" and cSide ~= v then
        table.insert(modems,v)
    end
end

while true do
    local ev = {os.pullEvent()}
    if ev[1] == "modem_message" then
        if ev[2] == cSide and ev[3] == 0 and ev[4] == 0 then
            if type(ev[5]) == "table" then
                local msg = ev[5]
                if msg.target == os.getComputerID() then
                    print(msg.action)
                    if msg.action == "fetchmodems" then
                        cM.transmit(0,os.getComputerID(),#modems)
                    elseif msg.action == "open" then
                        for i = 1,#msg.modems do
                            for c = 1,#msg.modems[i] do
                                peripheral.wrap(modems[i]).open(msg.modems[i][c])
                                print("Opened "..msg.modems[i][c].." on "..modems[i])
                            end
                        end
                    end
                end
            end
        elseif ev[2] ~= cSide then --just to be sure
            cM.transmit(1,os.getComputerID(),{
                channel = ev[3],
                reply = ev[4],
                content = ev[5]
            })
        end        
    end
end
