set sig_list [list rst clk start new_otp addr\[9:0\] wdata\[3:0\] write_en done]
gtkwave::addSignalsFromList $sig_list
gtkwave::highlightSignalsFromList "top.otp_gen_tb.addr\[9:0\]"
gtkwave::highlightSignalsFromList "top.otp_gen_tb.wdata\[3:0\]"
gtkwave::/Edit/Data_Format/Binary
