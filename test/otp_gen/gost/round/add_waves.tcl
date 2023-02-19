set sig_list [list iblock\[63:0\] oblock\[63:0\]]
gtkwave::addSignalsFromList $sig_list
gtkwave::highlightSignalsFromList "top.round_tb.iblock\[63:0\]"
gtkwave::highlightSignalsFromList "top.round_tb.oblock\[63:0\]"
gtkwave::/Edit/Data_Format/Binary
