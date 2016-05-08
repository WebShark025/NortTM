local function run(msg, matches)
if is_momod(msg) and msg.to.type == "channel" then        
  local text = [[
🔴لیست کامند های سوپر گروه حفاظت شده توسد بات نورت

💢 !info
تمامی اطلاعات راجبع سوپر گروه را نشان میدهد

💢 !admins
لیست ادمین های سوپر گروه

💢!owner
نام صاحب سوپر گروه

💢 !modlist
لیست مدیر های سوپر گروه

💢!bots
لیست بات های سوپر گروه

!who
لیست تمامی افراد عضو سوپر گروه

💢 !block
اخراج کردن و بن کردن یک یوزر از سوپر گروه (بصورت رسمی از سوی تلگرام)

💢 !ban
بن کردن یک نفر از سوپرگروه (بصورت غیر رسمی از سمت بات)

💢 !unban
آن بن کردن یک نفر از سوپر گروه

💢 !id
نشان دادن آیدی سوپر گروه / آیدی شخص
- برای ایدی یوزر ها: !id @UserName

💢 !id from
دریافت آیدی از پیامی که فوروارد شده

💢 !kickme
اخراج کردن یک نفر از سوپر گروه

💢 !setowner
تعویض صاحب سوپر گروه

💢 !promote [username|id]
ترفیع درجه یک فرد به مدیر

💢 !demote [username|id]
تنزیل درجه یک فرد به عضو معمولی

💢 !setname
تعویض نام سوپر گروه

💢 !setphoto
تعویض عکس سوپر گروه

💢 !setrules
نوشتن قوانین سوپر گروه

💢!setabout
نوشتن "درباره" سوپر گروه (بالای لیست ممبر ها می آید)

💢 !save [value] <text>
ذخیره سازی  اطلاعات اضافه در رابطه با چت

💢 !get [value]
دریافت همون چیزی که تو کامند بالایی ست کردید 😐

💢 !newlink
ساخت لینک جدید

💢 !link
دریافت لینک گروه

💢 !rules
مشاهده قوانین گروه

💢 !lock [links|flood|spam|Arabic|member|rtl|sticker|contacts|strict]
قفل کردن ستینگ گروه
*RTL = راست چین (پیام های از راست به چپ)*
*strict: enable strict settings enforcement (violating user will be kicked)*

💢 !unlock [links|flood|spam|Arabic|member|rtl|sticker|contacts|strict]
باز کردن ستینگ گروه
*RTL = راست چین (پیام های از راست به چپ)*
*strict: disable strict settings enforcement (violating user will not be kicked)*

💢 !mute [all|audio|gifs|photo|video|service]
میوت (خفه) کردن
- پیام های میوت شده درجا پاک میشوند

💢 !unmute [all|audio|gifs|photo|video|service]
آن میوت کردن
💢 !setflood [value]
ست کردن تعداد پیام های پشت سر هم تا یوزر کیک شود
- مثلا اگر 10 باشد, فردی 10 پیام پشت هم بفرستد, کیک میشود.

💢 !settings
دریافت ستینگ سوپر گروه

💢 !muteslist
نشان دادن میوت های سوپر گروه

💢 !muteuser [username]
خفه کردن یک کاربر در سوپر گروه
- اگر کاربر خفه شده پیامی بفرستد, درجا پیام حذف میگردد

💢 !mutelist
لیست افراد میوت شده

💢 !banlist
لیست افراد بن شده

💢 !clean [rules|about|modlist|mutelist]
پاک کردن یکی از متغیر های بالا

💢 !del
پاک کردن یک مسیج (ریپلای کنید)

💢 !public [yes|no]
ویزیبیلیتی پیام ها

💢 !res [username]
دریافت نام و آیدی یک یوزر با یوزرنیم (مثلا @UserName)

💢 !addword [word]
سانسور کردن یک کلمه

💢 !remword [word]
پاک کردن یک کلمه از لیست سانسورها

💢 !badwords 
لیست کلمات سانسور شده. 

💢 !log
دریافت لاگ گروه
*مثلا سرچ کنید برای دلیل کیک شدن [#RTL|#spam|#lockmember]


🔴شما میتوانید از هر سه کاراکتر # و ! و / در آغاز کامند ها استفاده کنید.

🔴فقط صاحب سوپر گروه از طریق ادد ممبر میتواند کاربر ادد کند.

🔴فقط مدیر ها و صاحب سوپر گروه میتواند از بلاک, بن, آنبن, لینک جدید, دریافت لینک, ست کردن عکس, ست کردن نام, قفل, باز, ست کردن قوانین, ست کردن توضیحات و ستینگ استفاده کند.

🔴فقط صاحب گروه و ادمین ها میتواند از کامند های res, promote, setowner استفاده کند.

—فارسیسازی اختصاصی نورت—

لینک کانال: @NortTeaM
]]
    send_msg("channel#id"..msg.to.id, text, ok_cb, false)
  end
end 
return {
  description = "Help owner.  ", 
  usage = {
    "ownerhelp: Show help for owners.",
  },
  patterns = {
    "^([!/#]help_all)$",
  }, 
  run = run,
}
