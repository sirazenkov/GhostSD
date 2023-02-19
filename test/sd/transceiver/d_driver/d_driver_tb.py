import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles

import random

from libscrc import crc7

def gen_rand_block():
    block = [random.randint(0,15) for i in range(1024)]
    return block

def initialize_signals(dut):
    dut.idata_sd.value = 1
    dut.istart.value   = 0
    dut.irdata.value   = 0
    return

def form_crc_packets(block):
    lines_data = [0,0,0,0]
    for i in range(1024):
        for j in range(4):
            lines_data[j] = lines_data[j] << 1 | ((block >> j) & 1)
    crc_values = [crc7(bytes(line_data)) for line_data in lines_data]
    crc_packets = []
    for i in range(7):
        crc_packet = 0
        for j in range(4):
            crc_packet = crc_packet | (((crc_values[j] >> (7-i)) & 1) << j)
        crc_packets.append(crc_packet)
    return crc_packets

def send_sd_block(dut, block):
    dut.istart.value = 1
    await FallingEdge(dut.iclk)
    dut.idata_sd.value = 0 # Start bit
    dut.istart.value = 0
    for i in range(1024):
        await FallingEdge(dut.iclk)
        dut.idata_sd.value = block[i]
    crc_packets = form_crc_packets(crc)
    for i in range(7):
        await FallingEdge(dut.iclk)
        dut.idata_sd.value = crc_packets[i]
    await FallingEdge(dut.iclk)
    dut.idata_sd.value = 0xF # End bit
    return

def receive_sd_block(dut)
    dut.istart.value = 1
    await FallingEdge(dut.odata_sd) # Start bit
    await ClockCycles(dut.iclk, 1)
    for i in range(1024):
    await FallingEdge(dut.iclk) 
 
def process_sd_block(dut, block):
    send_block(dut, block)
    assert int(dut.ocrc_fail) == 0, "CRC7 check for input data failed!"
    assert int(dut.odone) == 1, "Module did not receive data correctly!" 
    received_block = receive_block(dut, block)

@cocotb.test()
async def d_driver_tb(dut):
    """D line's driver testbench""" 
    initialize_signals()

    await cocotb.start_soon(Clock(dut.iclk, 55, units="ns").start())

    dut.irst.value = 1 
    await FallingEdge(dut.iclk)
    dut.irst.value = 0 

    transactions = random.randint(0,5)
    for i in range(transactions):
        block = gen_rand_block()
        process_block(dut, block)
