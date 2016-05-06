local function run(msg, matches)
if is_member(msg) and msg.to.type == "" then        
  local text = [[
💠 دستورات ربات ضد اسپم نورت 💠
----------------------------
🔹لیست راهنمای پلاگین ها 
/helps

🔸لیست راهنمای کلی ربات 
/help_all

🔹 لیست راهنمای خصوصی 
/help_pv

------------------------------
@nortteam Anti Spam Nort
]]
    send_msg("chat#id"..msg.to.id, text, ok_cb, false)
  end
end 
return {
  description = "Help owner.  ", 
  usage = {
    "ownerhelp: Show help for owners.",
  },
  patterns = {
    "^([!/#]help)$",
  }, 
  run = run,
}
