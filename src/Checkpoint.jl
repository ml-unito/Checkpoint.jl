module Checkpoint

using Serialization
using JSON
using SHA

export initcheckpoint, checkpoint, resume

function __checkpointpath(conf, path)
    "$path/$(bytes2hex(sha256(json(conf))))"
end

function initcheckpoint(conf, data, path=".")
    confstr = json(conf)
    fullpath = __checkpointpath(conf, path)

    try
        mkdir("$fullpath")
        write("$fullpath/conf.json", confstr)

        @debug "Serializing initial data on path: $fullpath/data.jld"
        serialize("$fullpath/data.jld", data)    
    catch err
        if err.errnum != 17
            @error "Error while creating $fullpath: $err"
            exit(err.errnum)
        end
    end
end

function checkpoint(conf, data; path=".")
    fullpath = __checkpointpath(conf, path)
    @debug "Serializing data on path: $fullpath/data.jld"
    serialize("$fullpath/data.jld", data)
end

function resume(conf; path=".")
    fullpath = __checkpointpath(conf, path)

    @debug "Deserializing data from paht: $fullpath/data.jld"
    deserialize("$fullpath/data.jld")
end

end