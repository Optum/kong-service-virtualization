local _M = {}
local resty_sha256 = require "resty.sha256"
local str = require "resty.string"
local json = require('cjson')
local kong = kong

local function sha256aValue(value)
  local sha256 = resty_sha256:new()
  sha256:update(value)
  return str.to_hex(sha256:final())
end

local function virtualResponse(conf)
  ngx.status = conf.responseHttpStatus
  if conf.response and conf.responseContentType then
    local decodedResponse = ngx.decode_base64(conf.response)
    ngx.header["Content-Type"] = conf.responseContentType
    ngx.header["Content-Length"] = #decodedResponse
    ngx.print(decodedResponse)
  else
    ngx.print()
  end

  return ngx.exit(200)
end

local function virtualNoMatch(expectedSha256, foundSha256)
  if expectedSha256 and foundSha256 then
    return kong.response.exit(404, { message = "No virtual request match found, your request yeilded: " .. foundSha256 .. " expected " .. expectedSha256 })
  else
    return kong.response.exit(404, { message = "No matching virtual request found!" })
  end
end

function _M.execute(conf)
--Get the List of Virtual Test Cases
local virtualTests = json.decode(conf.virtual_tests)
 if ngx.req.get_headers()["X-VirtualRequest"] then
   for i in pairs(virtualTests) do
      if (ngx.req.get_headers()["X-VirtualRequest"] == virtualTests[i].name and virtualTests[i].requestHttpMethod == ngx.req.get_method()) then
          if virtualTests[i].requestHash then
            local foundQueryParameters
            if ngx.var.request_uri:find('?') then --Is this a URL QUERY based request?
              foundQueryParameters = ngx.var.request_uri:sub(ngx.var.request_uri:find('?') + 1, ngx.var.request_uri:len())
            end

            if foundQueryParameters and foundQueryParameters:len() > 2 then -- minimum a=b 3 chars for a URL QUERY based request
                local sha256foundQueryParameters = sha256aValue(foundQueryParameters)
                if virtualTests[i].requestHash ~= sha256foundQueryParameters then
                  virtualNoMatch(virtualTests[i].requestHash, sha256foundQueryParameters)
                end
            else
                ngx.req.read_body()
                local req_body  = ngx.req.get_body_data()
                local sha256FoundHttpBody = ""
                if req_body == nil then
                  virtualNoMatch(virtualTests[i].requestHash, sha256FoundHttpBody)
                end

                sha256FoundHttpBody = sha256aValue(req_body)
                if virtualTests[i].requestHash ~= sha256FoundHttpBody then
                  virtualNoMatch(virtualTests[i].requestHash, sha256FoundHttpBody)
                end
            end
          end

        return virtualResponse(virtualTests[i])
      end
   end
   return virtualNoMatch(nil, nil)
 end

 return
end

return _M
