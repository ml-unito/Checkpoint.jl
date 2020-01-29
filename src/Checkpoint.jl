module Checkpoint

using Serialization
using JSON
using SHA

export checkpointpath, checkpoint, resume

"""
    checkpointpath(conf, path)

    returns the complete path of the experiment identified by `conf`

    # Arguments

    * conf: the configuration of the experiment. Can be any data structure that
        can be serialized to json
    * path: path where the experiments need to be rooted
"""
function checkpointpath(conf, path)
    "$path/$(bytes2hex(sha256(json(conf))))"
end


"""
    __initcheckpoint(conf, data; path)

    Creates the directory where the checkpoints will be stored.
    For internal use only.
"""
function __initcheckpoint(conf, data; path=".")
    confstr = json(conf)
    fullpath = checkpointpath(conf, path)

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

"""
    Stores a new checkpoint for the experiment identified by `conf`.

    The checkpoint will contain the data contained in the `data` parameter.

    # Arguments

    * conf: the configuration of the experiment. Can be any data structure that
        can be serialized to json
    * data: the data for the checkpoint. It should contain every piece of 
        information needed to resume the eperiment.
    * path: path where the experiments need to be rooted
"""
function checkpoint(conf, data; path=".")
    fullpath = checkpointpath(conf, path)
    @debug "Serializing data on path: $fullpath/data.jld"
    serialize("$fullpath/data.jld", data)
end

"""
    Recovers the data stored in the checkpoint.

    # Arguments

    * conf: the configuration of the experiment. Can be any data structure that
        can be serialized to json
    * init: the initialization values for the experiment. They should be such
        that if the experiment were to be resumed from them, it would run
        from the start.
"""

function resume(conf; init, path=".")
    fullpath = checkpointpath(conf, path)

    if isdir(fullpath)
        @debug "Deserializing data from paht: $fullpath/data.jld"
        return deserialize("$fullpath/data.jld")
    else
        __initcheckpoint(conf, init, path=path)
        return init
    end
end

end