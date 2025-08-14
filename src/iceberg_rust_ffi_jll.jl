# Use baremodule to shave off a few KB from the serialized `.ji` file
baremodule iceberg_rust_ffi_jll
using Base
using Base: UUID
import JLLWrappers

JLLWrappers.@generate_main_file_header("iceberg_rust_ffi")
JLLWrappers.@generate_main_file("iceberg_rust_ffi", UUID("6bd5c94f-693c-53e3-983d-a09fad412f22"))
end  # module iceberg_rust_ffi_jll
