set sig_list [list rst clk data crc\[15:0\]]
gtkwave::addSignalsFromList $sig_list
gtkwave::highlightSignalsFromList "top.crc7_tb.crc\[15:0\]"
gtkwave::/Edit/Data_Format/Binary
