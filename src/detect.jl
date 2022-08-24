
export filecoding
export transcode


function filecoding(filepath)
    encoding_p = ccall(detect_enc_key,Ptr{UInt8},(Ptr{UInt8},),pointer(filepath))
    encoding = Base.unsafe_string(encoding_p)
    return encoding
end # segment()

function transcode(filepath::String,input_encoding::String,detect::Bool = true)
    if detect == true
        primary_encoding = filecoding(filepath)
        if primary_encoding == "UTF-8"
            return filepath
        else 
        encoding = "UTF-8"
        output_path = string(filepath,".unicode")
        println("Detected Encoding: $primary_encoding, using UTF-8 input file: $output_path.")
        end
    else
        if input_encoding == "UTF-8"
            return filepath
        else
            output_path = string(filepath,".unicode")
            primary_encoding = input_encoding
            encoding = "UTF-8"
            println("Encoding: $primary_encoding, using UTF-8 input file: $output_path.")
        end
    end

    f = Base.FS.open(output_path,Base.JL_O_WRONLY|Base.JL_O_CREAT,Base.S_IRUSR | Base.S_IWUSR | Base.S_IRGRP | Base.S_IROTH)
    run(`iconv -f $primary_encoding -t $encoding $filepath` |> f)
    Base.FS.close(f)
    return output_path
end

