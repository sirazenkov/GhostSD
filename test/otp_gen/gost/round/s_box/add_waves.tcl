set sig_list [list iword\[31:0\] oword\[31:0\]]
gtkwave::addSignalsFromList $sig_list
gtkwave::highlightSignalsFromList "top.s_box_tb.iword\[31:0\]"
gtkwave::highlightSignalsFromList "top.s_box_tb.oword\[31:0\]"
gtkwave::/Edit/Data_Format/Binary
