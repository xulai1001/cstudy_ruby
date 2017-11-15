require "mkmf"

RbConfig::MAKEFILE_CONFIG["CC"] = ENV["CC"] if ENV["CC"]

extension_name = "RHUtils"

# create_header
create_makefile extension_name

