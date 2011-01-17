module Anachronism
  IAC = Hash.new {|h, k| k}
  
  [:SE,   :NOP, :DM,   :BRK,
   :IP,   :AO,  :AYT,  :EC,
   :EL,   :GA,  :SB,   :WILL,
   :WONT, :DO,  :DONT, :IAC
  ].each_with_index do |sym, i|
    i += 240
    IAC[sym], IAC[i] = i, sym
  end
end
