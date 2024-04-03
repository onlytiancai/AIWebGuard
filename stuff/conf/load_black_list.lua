local resty_lrucache = require "resty.lrucache"
lrucache, err = resty_lrucache.new(100)
if not lrucache then
    ngx.log(ngx.ERR, "Failed to create lrucache: ", err)
end

local function load_config(premature)
    local json = require("cjson.safe")

    ngx.log(ngx.ERR, "load config:", ngx.worker.id())
    local file_path = "conf/black_countries.json"
    local file, err = io.open(file_path, "r")

    if not file then
        ngx.log(ngx.ERR, "failed to open black dict: ", err)
        return
    end

    local data = json.decode(file:read("*all"))
    file:close()
    if not data then
        ngx.log(ngx.ERR, "failed to decode data: ", err)
        return
    end

    lrucache:flush_all()
    for key,value in pairs(data) do
        lrucache:set(key, value)
    end
end

local events = ngx.shared.config_refresh_events

local function check_event(premature)
    if premature then
        return
    end
    local signal = events:get("event_signal_" .. ngx.worker.id())
    if signal == 1 then
        ngx.log(ngx.INFO, "Received event signal in worker ", ngx.worker.id())
        load_config()
        events:set("event_signal_" .. ngx.worker.id(), 0)
    end
end

local ok, err = ngx.timer.every(1, check_event)
if not ok then
    ngx.log(ngx.ERR, "failed to create the timer: ", err)
    return
end

load_config()
