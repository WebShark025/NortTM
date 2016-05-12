do
    function run(msg, matches)
        
  local text = [[
 ______________
|Bot Is ON      |
|@anti_Spam_nort|
| ______________|

]]
    return text
  end
end 

return {
  description = "Help owner.  ", 
  usage = {
    "ownerhelp: Show help for owners.",
  },
  patterns = {
    "^([/!#]test)$",
  }, 
  run = run,
}
