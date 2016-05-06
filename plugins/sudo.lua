do


function run(msg, matches)

  return [[ جهت اضافه کردن سودو :

سودو شماره ۱ 
@nort_admin

دستور اضافه کردن سودو شماره ۱

/addsudo1
________________________
سودو شماره ۲
@WebShark25

دستور اضافه کردن سودو شماره ۲
/addsudo2
________________________
در صورت بروز  مشکل اطلاع دهید.
@Nort_admin_bot ]]

end


return {

  description = "", 

  usage = "",

  patterns = {

    "^[!/#](sudo)$"

  }, 

  run = run 

}


end