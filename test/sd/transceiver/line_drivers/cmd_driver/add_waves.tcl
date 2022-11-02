set sig_list [list cmd_sd response\[119:0\] done]
gtkwave::addSignalsFromList $sig_list
gtkwave::highlightSignalsFromList "top.cmd_driver_tb.response\[119:0\]"
gtkwave::/Edit/Data_Format/Binary
