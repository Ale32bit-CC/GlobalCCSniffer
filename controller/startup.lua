local m = peripheral.find("modem")
m.open(0) --control channel
m.open(1) --listen channel
local slaves = {}
for k,v in ipairs(peripheral.getNames()) do
    if peripheral.getType(v) == "computer" then
        if peripheral.wrap(v).getID() ~= os.getComputerID() then
            table.insert(slaves,peripheral.wrap(v).getID())
            peripheral.wrap(v).turnOn()
            print(v)
        end
    end
end

local slavesM = {}

local channels = 65535

local chPerM = 120

local co = 0

for k,v in ipairs(slaves) do
    --print(v)
    m.transmit(0,0,{
        target = v,
        action = "fetchmodems",
    })
    local _,_,ch,rch,msg = os.pullEvent("modem_message")
    if rch == v then
        slavesM[v] = msg
        print(v.." has "..msg.." modems")
    end
    local toOpen = {} --sides{channels{x,x,x,x}}
    for i = 1,msg do
        local t = {}
        for i=1,chPerM do
            table.insert(t,co)
            co=co+1
            if co > channels then
                break
            end
        end
        --textutils.tabulate(t)
        table.insert(toOpen,t)
        if co > channels then
            break
        end
    end
    m.transmit(0,0,{
        target=v,
        modems=toOpen,
        action="open"
    })
end

while true do
    local ev = {os.pullEvent()}
    if ev[1]== "modem_message" then
        if ev[3] == 1 then
            local msg = ev[5]
            if type(msg) == "table" then
                if msg.channel and msg.reply and msg.content then
                    if type(msg.content)  == "table" then
                        msg.content = textutils.serialise(msg.content)
                    end
                    print(msg.reply.."@"..msg.channel)
                    print(msg.content)
                    print("---------------------")
                end
            end
        end
    end
end
