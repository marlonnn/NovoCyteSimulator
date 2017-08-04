--故障诊断模块

function compareBit(l,m,n)  --判断数字l的第m为是否等于n；若等于n，返回true；若不等于n，返回false
  if math.floor(l/10^(m-1)%10) == n then return true
  else return false
  end
end

---[[
function analyse_error(errorcode)
  if compareBit(errorcode,9,0) or compareBit(errorcode,7,0) or compareBit(errorcode,2,0) or (compareBit(errorcode,3,1) and compareBit(errorcode,4,0)) or (compareBit(errorcode,5,1) and compareBit(errorcode,6,0)) then print(1)--errror_errorcode =  1
  elseif compareBit(errorcode,10,0) and compareBit(errorcode,9,1) then print(2)
  elseif math.floor(errorcode/10^6) == 1101 then print(3)
  elseif math.floor(errorcode/10^2) == 11111011 then print(4)
  elseif math.floor(errorcode/10^2) == 11111010 then print(5)
  elseif tonumber(errorcode) == 1111111110 then print(6)
  elseif tonumber(errorcode) == 1111111010 then print(7)
  elseif tonumber(errorcode) == 1111111011 then print(8)
  elseif tonumber(errorcode) == 1111001111 then print(9)
  elseif tonumber(errorcode) == 1111111111 then print(10)
  else print("****************************","no this errocode:",errorcode) return true
  end
end