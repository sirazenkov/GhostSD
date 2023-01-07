set sig_list [list rst clk oblock\[63:0\] done]
gtkwave::addSignalsFromList $sig_list
gtkwave::highlightSignalsFromList "top.gost_tb.oblock\[63:0\]"
gtkwave::/Edit/Data_Format/Binary
