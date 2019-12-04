return function(filename)
    local fd = io.open(filename, "r")
    local contents = fd:read("*a")
    io.close(fd)
    return contents
end