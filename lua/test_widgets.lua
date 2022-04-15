--
-- (C) 2013-21 - ntop.org
--

local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path
package.path = dirs.installdir .. "/scripts/lua/modules/datasources/?.lua;" .. package.path

require "lua_utils"
local ts_utils = require("ts_utils")
local info = ntop.getInfo() 
local page_utils = require("page_utils")
local alerts_api = require("alerts_api")
local format_utils = require("format_utils")
local json = require "dkjson"
local rest_utils = require "rest_utils"
local datasources_utils = require "datasources_utils"
local datasource_keys = require "datasource_keys"

sendHTTPContentTypeHeader('text/html')

page_utils.print_header(i18n("about.about_x", { product=info.product }))

if not isAdministrator() then
  return
end

dofile(dirs.installdir .. "/scripts/lua/inc/menu.lua")

-- List all available datasource types
local all_datasource_types =  datasources_utils.get_all_source_types()
for _, ds_type in pairs(all_datasource_types) do
   tprint({ds_type.meta.i18n_title, ds_type.meta.rest_endpoint})

   local instance = ds_type:new()
   -- Do things with instance...
end

-- Attempt at getting a datasource by key
local ds = datasources_utils.get_source_type_by_key(datasource_keys.interface_packet_distro)
assert(ds.meta.datasource_key == datasource_keys.interface_packet_distro)

local packet_distro = require "interface.packet_distro"
local datasource = packet_distro:new()

-- REST examples
--
-- Datasource
-- $ curl --silent --insecure -u "admin:admin1" -H "Content-Type: application/json" -d '{"ifid":0}' "http://127.0.0.1:3000/lua/rest/v1/get/datasource/interface/packet_distro.lua"
--
--
-- Widget with multiple datasources
-- $ curl --silent --insecure -u "admin:admin1" -H "Content-Type: application/json" -d '{"transformation": "donut", "datasources":[{"ds_type":"interface_packet_distro", "params":{"ifid":0}}, {"ds_type":"interface_packet_distro", "params":{"ifid":0}}]}' "http://127.0.0.1:3000/lua/rest/v1/get/widget/data.lua"
--
--
-- Read data from the REST endpoint bound to the datasource
-- NOTE: Host is hardcoded here for test purposes, it will vary depending on what will be specified when creating the datasource
-- NOTE: The auth token will be necessary as well
-- local url = "http://127.0.0.1:3000"..datasource.meta.rest_endpoint
-- tprint(url)
-- local rsp = ntop.httpGet(url)

-- Deserialize the response into the datasource
-- datasource:deserialize(rsp)

-- Apply wanted transformations
-- local table_transf = datasource:transform("table")
-- local donut_transf = datasource:transform("donut")
-- local multibar_transf = datasource:transform("multibar")

dofile(dirs.installdir .. "/scripts/lua/inc/footer.lua")

