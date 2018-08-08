local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.kong-service-virtualization.access"
local KongServiceVirtualizationHandler = BasePlugin:extend()
KongServiceVirtualizationHandler.PRIORITY = 3000 --Execute before logging plugins and such as to not impact their real metrics

function KongServiceVirtualizationHandler:new()
	KongServiceVirtualizationHandler.super.new(self, "kong-service-virtualization")
end

function KongServiceVirtualizationHandler:access(conf)
  KongServiceVirtualizationHandler.super.access(self)
  access.execute(conf)
end

return KongServiceVirtualizationHandler
