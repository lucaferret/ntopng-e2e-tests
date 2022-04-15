--
-- (C) 2013-21 - ntop.org
--

local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path
if((dirs.scriptdir ~= nil) and (dirs.scriptdir ~= "")) then package.path = dirs.scriptdir .. "/lua/modules/?.lua;" .. package.path end

if ntop.isPro() then
   package.path = dirs.installdir .. "/scripts/lua/pro/modules/?.lua;" .. package.path
   package.path = dirs.installdir .. "/pro/scripts/callbacks/?.lua;" .. package.path
end
require "lua_utils"

package.path = dirs.installdir .. "/scripts/lua/modules/recipients/?.lua;" .. package.path
local json = require "dkjson"
local recipients = require "recipients"
local user_scripts = require "user_scripts"
local alert_consts = require "alert_consts"
local r = recipients

r.cleanup()

local res1 = r.add_recipient("ntop_mail", "ntop_mail_r", {}, nil, {}, {}, {email_recipient = "test@ntop.org"})
assert(res1.status == "OK")
local res1_get = r.get_recipient(res1.recipient_id)
assert(#res1_get.user_script_categories == table.len(user_scripts.script_categories))
assert(res1_get.minimum_severity == alert_consts.alert_severities.info.severity_id)
local res2 = r.add_recipient("ntop_mail", "ntop_mail_r", {}, nil, {}, {}, {email_recipient = "test2@ntop.org"})
assert(res2.status == "failed")
local res3 = r.add_recipient("ntop_mail", "ntop_mail_r3", {0,2}, alert_consts.alert_severities.warning.severity_id, {}, {}, {email_recipient = "test3@ntop.org"})
assert(res3.status == "OK")
local res3_get = r.get_recipient(res3.recipient_id)
assert(#res3_get.user_script_categories == 2)
assert(res3_get.user_script_categories[1] == 0)
assert(res3_get.user_script_categories[2] == 2)
assert(res3_get.minimum_severity == alert_consts.alert_severities.warning.severity_id)
local res4 = r.add_recipient("ntop_mail", "ntop_mail_r4", {}, nil, {}, {}, {email_recipient = "test4@ntop.org"})
assert(res4.status == "OK")
local res5 = r.add_recipient("ntop_mail", "ntop_mail_r5", {}, nil, {}, {}, {email_recipient = "test5@ntop.org"})
assert(res5.status == "OK")

local d3 = r.delete_recipient(res3.recipient_id)
local d4 = r.delete_recipient(res4.recipient_id)

local res6 = r.add_recipient("ntop_mail", "ntop_mail_r6", {}, {}, {}, {}, {email_recipient = "test6@ntop.org"})
assert(res6.status == "OK")
assert(res6.recipient_id == res3.recipient_id) -- ID reuse test

local res7 = r.add_recipient("ntop_mail", "ntop_mail_r7", {}, {}, {}, {}, {email_recipient = "test7@ntop.org"})
assert(res7.status == "OK")
assert(res7.recipient_id == res4.recipient_id) -- ID reuse test

local r1 = r.get_recipient(0)
local r2 = r.get_recipient(1)

local e1 = r.edit_recipient(res1.recipient_id, "ntop_mail_r_edited", {1,3}, alert_consts.alert_severities.error.severity_id, {}, {}, {}, {}, {email_recipient = "test4@ntop.org"})
local e1_get = r.get_recipient(res1.recipient_id)
assert(#e1_get.user_script_categories == 2)
assert(e1_get.user_script_categories[1] == 1)
assert(e1_get.user_script_categories[2] == 3)
assert(e1_get.minimum_severity == alert_consts.alert_severities.error.severity_id)

local t1 = "{test notification 1}"
local t2 = "{test notification 2}"

-- High priority
ntop.recipient_enqueue(res7.recipient_id, true, t1)
ntop.recipient_enqueue(res7.recipient_id, true, t2)
local n1 = ntop.recipient_dequeue(res7.recipient_id, true)
local n2 = ntop.recipient_dequeue(res7.recipient_id, true)
local n3 = ntop.recipient_dequeue(res7.recipient_id, true)
assert(n1 == t1)
assert(n2 == t2)
assert(not n3)

-- Low priority
ntop.recipient_enqueue(res7.recipient_id, false, t1)
ntop.recipient_enqueue(res7.recipient_id, false, t2)
local n1 = ntop.recipient_dequeue(res7.recipient_id, false)
local n2 = ntop.recipient_dequeue(res7.recipient_id, false)
local n3 = ntop.recipient_dequeue(res7.recipient_id, false)
assert(n1 == t1)
assert(n2 == t2)
assert(not n3)

-- local res = r.test_recipient("ntop_mail", {email_recipient = "test4@ntop.org", cc = ""})
-- tprint(res)
-- tprint(e1)
-- tprint(r.get_recipient(res1.recipient_id))
-- tprint(res2)
-- tprint(r1)
-- tprint(r2)
-- tprint(r.get_recipient_by_name("mainardi_mail"))

-- tprint(r.get_all_recipients())

print("OK\n")
