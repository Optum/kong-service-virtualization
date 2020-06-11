local typedefs = require "kong.db.schema.typedefs"

return {
  name = "kong-service-virtualization",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { virtual_tests = { type = "string", required = true }, },
    }, }, },
  },
}
