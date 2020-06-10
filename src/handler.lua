local access = require "kong.plugins.kong-service-virtualization.access"
local KongServiceVirtualizationHandler = {}

KongServiceVirtualizationHandler.PRIORITY = 3000 --Execute before logging plugins and such as to not impact their real metrics
KongServiceVirtualizationHandler.VERSION = "0.3"

function KongServiceVirtualizationHandler:access(conf)
  access.execute(conf)
end

return KongServiceVirtualizationHandler
