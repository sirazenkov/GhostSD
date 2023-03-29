set sig_list [list irst iclk istart iblock\[63:0\] oblock\[63:0\] odone]
gtkwave::addSignalsFromList $sig_list
gtkwave::highlightSignalsFromList "top.round_tb.iblock\[63:0\]"
gtkwave::highlightSignalsFromList "top.round_tb.oblock\[63:0\]"
gtkwave::/Edit/Data_Format/Binary
