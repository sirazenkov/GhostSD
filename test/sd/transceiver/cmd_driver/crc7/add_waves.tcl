set sig_list [list rst clk data crc crc_reg\[6:0\]]
gtkwave::addSignalsFromList $sig_list
gtkwave::highlightSignalsFromList "top.crc7_tb.crc_reg\[6:0\]"
gtkwave::/Edit/Data_Format/Binary
