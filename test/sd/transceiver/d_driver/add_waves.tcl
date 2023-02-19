set sig_list [list iclk irst istart idata_sd\[3:0\] odata_sd\[3:0\] oaddr\[9:0\] owdata\[3:0\] owrite_en irdata\[3:0\] ocrc_fail odone]
gtkwave::addSignalsFromList $sig_list
gtkwave::highlightSignalsFromList "top.d_driver_tb.idata_sd\[3:0\]"
gtkwave::highlightSignalsFromList "top.d_driver_tb.odata_sd\[3:0\]"
gtkwave::highlightSignalsFromList "top.d_driver_tb.oaddr\[9:0\]"
gtkwave::highlightSignalsFromList "top.d_driver_tb.owdata\[3:0\]"
gtkwave::highlightSignalsFromList "top.d_driver_tb.irdata\[3:0\]"
gtkwave::/Edit/Data_Format/Binary
