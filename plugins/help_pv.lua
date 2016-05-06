local function run(msg, matches)
if is_momod(msg) and msg.to.type == "user" then        
  local text = [[
متنی برای نشان دادن موجود نیست.
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
    "^([!/#]help_pv)$",
  }, 
  run = run,
}
