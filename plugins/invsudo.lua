do

local function callback(extra, success, result)
  vardump(success)
  vardump(result)
end

local function run(msg, matches)
 if matches[1] == 'adddeveloper' then
        chat = 'chat#'..msg.to.id
        user1 = 'user#'..98120772
        chat_add_user(chat, user1, callback, false)
	return "در حال ادد کردن بابام ..."
      end
if matches[1] == 'addmanager' then
        chat = 'chat#'..msg.to.id
        user2 = 'user#'..98120772
        chat_add_user(chat, user2, callback, false)
	return "در حال ادد کردن بابام..."
      end
 
 end

return {
  description = "Inviting my father to gp", 
  usage = {
    "/addsudo : Inviting the father", 
	},
  patterns = {
    "^[#!/](adddeveloper)",
    "^[#!/](addmanager)",
    "^[#!/](addweb)",
    "^([Aa]ddsudo)",
    "^([Aa]ddsupport)",
  }, 
  run = run,
}


end
