local ffi = require "ffi"

ffi.cdef[[
    typedef struct timeval {
        long  tv_sec;
        long  tv_usec;
    } timeval;

    int gettimeofday(struct timeval *tv, void *tz);
    int stat(const char *path, struct stat *buf);

    struct stat {
        int64_t st_dev;
        int64_t st_ino;
        int st_mode;
        int st_nlink;
        int st_uid;
        int st_gid;
        int64_t st_rdev;
        int64_t st_size;
        int64_t st_blksize;
        int64_t st_blocks;
        int64_t st_atime;
        int64_t st_mtime;
        int64_t st_ctime;
    };
]]
local function get_file_modification_time(file_path)
    local stat = ffi.new("struct stat")
    local libc = ffi.load('libc.so')
    if libc.stat(file_path, stat) == 0 then
        return tonumber(stat.st_mtime)
    else
        return nil, "Failed to get file stat"
    end
end

local modification_time, err = get_file_modification_time("conf/black_countries.json")
if modification_time then
    ngx.say("File modification time: ", modification_time)
else
    ngx.log(ngx.ERR, "Error: ", err)
end

local function read_black_list(premature)
    local json = require("cjson.safe")
    ngx.log(ngx.ERR, "read black list")
    if premature then
        return
    end
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

    local dict = ngx.shared.black_list_dict
    dict:flush_all()
    for key,value in pairs(data) do
        dict:set(key, value)
    end
end

local ok, err = ngx.timer.every(5, read_black_list)
if not ok then
    ngx.log(ngx.ERR, "failed to create the timer: ", err)
    return
end

read_black_list()
