                                                       
vlog -reportprogress 300 -f filelist.f

vopt +acc tb_async_fifo -o tb_async_fifo_opt
#vsim tb_TEST_SYNC_opt -l simulation.log
vsim tb_async_fifo_opt


add wave -radix unsigned -position insertpoint  \sim:/tb_async_fifo/async_fifo_inst/*
#add wave -radix hexadecimal -position insertpoint  \sim:/TB_SPI/sclk
#add wave -radix hexadecimal -position insertpoint  \sim:/TB_SPI/wdat
#add wave -radix hexadecimal -position insertpoint  \sim:/TB_SPI/LE_new

#add wave -radix unsigned -position insertpoint  \sim:/tb_SM_DET/U_SM_DET/U_PATTERN_CYC/corr_ocnt

#toggle full name of the signal
config wave -signalnamewidth 1

#save the waveform into spi.do file.
#write format wave -window .main_pane.wave.interior.cs.body.pw.wf ../../SYNC/run_script/spi.do

run -all
