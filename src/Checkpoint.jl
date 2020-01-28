module Checkpoint

using Serialization
using JSON
using SHA

export checkpoint, resume

function checkpoint(conf, data; path=".")
    confstr = json(conf)
    dirname = bytes2hex(sha256(confstr))

    try
        mkdir("$path/$dirname")
        write("$path/$dirname/conf.json", confstr)
    catch err
        if err.errnum != 17
            @error "Error while creating $path/$dirname: $err"
            exit(err.errnum)
        end
    end

    @info "Serializing data on path: $path/$dirname/data.jld"
    serialize("$path/$dirname/data.jld", data)
end

function resume(conf; path=".")
    confstr = json(conf)
    dirname = bytes2hex(sha256(confstr))

    @info "Deserializing data from paht: $path/$dirname/data.jld"
    deserialize("$path/$dirname/data.jld")
end

end