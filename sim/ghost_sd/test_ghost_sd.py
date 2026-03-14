#============================================
# company: Tomsk State University
# developer: Simon Razenkov
# e-mail: sirazenkov@stud.tsu.ru
# description: Top module (GhostSD) testbench
#============================================

import sys
import os
import cocotb
from cocotb.clock import Clock
from cocotb_tools.runner import get_runner
from cocotb.triggers import ValueChange, FallingEdge, RisingEdge, ClockCycles

from random import randint

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from common import *

test_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(test_dir, '..', '..', 'rtl'))

RAM_BLOCKS = 8

async def reset(dut):
    await FallingEdge(dut.iclk_sd)
    dut.irst.value = 1 
    dut.iocmd_sd.value = 1
    dut.iodata_sd.value = 0xF
    dut.istart.value = 0
    await FallingEdge(dut.iclk_sd)
    dut.irst.value = 0
    await FallingEdge(dut.iclk_sd)

async def select_sd_clock(dut):
    sd_clock = cocotb.start_soon(Clock(dut.iclk_sd, 2500, unit="ns").start())
    current_sd_clock = 0

    while True:
        await FallingEdge(dut.iclk_sd)
        requested_sd_clock = int(dut.osel_clk_sd.value)
        if (requested_sd_clock != current_sd_clock):
            sd_clock.cancel()
            if (requested_sd_clock == 1):
                sd_clock = cocotb.start_soon(Clock(dut.iclk_sd, 20, unit="ns").start())
            else:
                sd_clock = cocotb.start_soon(Clock(dut.iclk_sd, 2500, unit="ns").start())
            current_sd_clock = requested_sd_clock

async def check_cmd_field(dut, field, length):
    field_ok = True
    for i in range(length):
        await FallingEdge(dut.iclk_sd)
        if(int(int(dut.iocmd_sd.value) == 1) != ((field >> (length-1-i)) & 1)):
            field_ok = False
    return field_ok

async def send_response(dut, index, resp, crc):
    if(index == 15):
        return
    await FallingEdge(dut.iclk_sd)
    dut.iocmd_sd.value = 0
    await ClockCycles(dut.iclk_sd, 2, rising=False)
    if(index == 9):
        dut.iocmd_sd.value = 1
        for i in range(6):
            await FallingEdge(dut.iclk_sd)
        for i in range(127):
            if(i == 44 or i == 47 or i == 80):
                dut.iocmd_sd.value = 1
            else:
                dut.iocmd_sd.value = 0
            await FallingEdge(dut.iclk_sd)
    elif(index == 2):
        dut.iocmd_sd.value = 1
        for i in range(6):
            await FallingEdge(dut.iclk_sd)
        dut.iocmd_sd.value = 0
        for i in range(127):
            await FallingEdge(dut.iclk_sd)
    else:
        for i in range(6):
            if(index == 41):
                dut.iocmd_sd.value = 1 
            else:
                dut.iocmd_sd.value = 1 & (index >> (5-i))
            await FallingEdge(dut.iclk_sd)
        for i in range(32):
            dut.iocmd_sd.value = 1 & (resp >> (31-i)) 
            await FallingEdge(dut.iclk_sd)
        for i in range(7):
            if(index == 41):
                dut.iocmd_sd.value = 1 
            else:
                dut.iocmd_sd.value = 1 & (crc >> (6-i))
            await FallingEdge(dut.iclk_sd)
    dut.iocmd_sd.value = 1
    await FallingEdge(dut.iclk_sd)
    return

async def send_status(dut):
    blocks = [randint(0,15) for i in range(128)]
    crc_packets = gen_crc16_packets(blocks)
    await FallingEdge(dut.iclk_sd)
    dut.iodata_sd.value = 0 # Start bit
    await FallingEdge(dut.iclk_sd)
    for i in range(128):
        dut.iodata_sd.value = blocks[i]
        await FallingEdge(dut.iclk_sd)
    for i in range(16):
        dut.iodata_sd.value = crc_packets[i]
        await FallingEdge(dut.iclk_sd)
    dut.iodata_sd.value = 0xF # End bit

async def send_blocks(dut, blocks, crc_packets):
    for j in range(RAM_BLOCKS):
        await FallingEdge(dut.iclk_sd)
        dut.iodata_sd.value = 0 # Start bit
        await FallingEdge(dut.iclk_sd)
        for i in range(1024):
            dut.iodata_sd.value = blocks[j][i]
            await FallingEdge(dut.iclk_sd)
        for i in range(16):
            dut.iodata_sd.value = crc_packets[j][i]
            await FallingEdge(dut.iclk_sd)
        dut.iodata_sd.value = 0xF # End bit

async def receive_block(dut):
    block = []
    await ValueChange(dut.odata_sd)
    await ClockCycles(dut.iclk_sd, 2, rising=False)
    for i in range(1024):
        block.append(int(dut.odata_sd.value))
        await FallingEdge(dut.iclk_sd)
    for i in range(16):
        await FallingEdge(dut.iclk_sd)
    return block

async def random_delay(dut, upper_bound):
    delay = randint(1, upper_bound)
    await ClockCycles(dut.iclk_sd, delay)

@cocotb.test()
async def ghost_sd_tb(dut):
    """GhostSD testbench"""

    dut.ikey.value = 0x34d20ac43f554f1d2fd101496787e3954e39d417e33528f13c005501aa1a9e47
    dut.iiv.value  = 0xb97b7f46

    otp_clock = cocotb.start_soon(Clock(dut.iclk_otp, 5, unit="ns").start())
    cocotb.start_soon(select_sd_clock(dut))

    await reset(dut) 
    blocks = [[randint(0,15) for i in range(1024)] for j in range(RAM_BLOCKS)]
    original_blocks = blocks
    crc_packets = [gen_crc16_packets(block) for block in blocks]
    for i in range(2): # Encrypt, decrypt
        received_blocks = []
        
        await reset(dut) 

        await FallingEdge(dut.iclk_sd)
        dut.istart.value = 1
        await FallingEdge(dut.iclk_sd)
        dut.istart.value = 0

        for trans in transactions:
            await FallingEdge(dut.iocmd_sd)
            await ClockCycles(dut.iclk_sd, 2)

            index_ok = await check_cmd_field(dut, trans.index, 6)
            assert index_ok, f"Failed receiving command index {trans.index} during cycle {i}!"

            arg_ok = await check_cmd_field(dut, trans.arg, 32)
            assert arg_ok, f"Failed receiving command argument for (A)CMD{trans.index} during cycle {i}!"

            crc_ok = await check_cmd_field(dut, trans.cmd_crc, 7)
            assert crc_ok, f"Failed CRC check for (A)CMD{trans.index} during cycle {i}!"

            await FallingEdge(dut.iclk_sd)
            assert int(dut.iocmd_sd.value) == 1, f"End bit not set after (A)CMD{trans.index} during cycle {i}!"

            await random_delay(dut, 10)
            await send_response(dut, trans.index, trans.resp, trans.resp_crc)

            if(trans.index == 6 and (trans.arg & 1)):
                cocotb.start_soon(send_status(dut))
            if(trans.index == 18):
                await send_blocks(dut, blocks, crc_packets)
            elif(trans.index == 25 or (trans.index == 13 and ((trans.resp >> 9) == 6))):
                if (len(received_blocks) < 8):
                    received_blocks.append(await receive_block(dut))
        if(i == 1):
            assert received_blocks == original_blocks, "GhostSD operation is invalid!"
        else:
            blocks = received_blocks
            crc_packets = [gen_crc16_packets(block) for block in blocks]
        await ClockCycles(dut.iclk_sd, 2, rising=False)
        assert (int(dut.osuccess.value), int(dut.ofail.value)) == (1,0), "GhostSD operation failed!"

def test_ghost_sd():
    sim = os.getenv("SIM", "icarus")

    verilog_sources = [os.path.join(rtl_dir, 'crc7.v'),
                       os.path.join(rtl_dir, 'cmd_driver.v'),
                       os.path.join(rtl_dir, 'crc16.v'),
                       os.path.join(rtl_dir, 'd_driver.v'),
                       os.path.join(rtl_dir, 'sd_fsm.v'),
                       os.path.join(rtl_dir, 'sd.v'),
                       os.path.join(rtl_dir, 's_box.v'),
                       os.path.join(rtl_dir, 'round.v'),
                       os.path.join(rtl_dir, 'gost.v'),
                       os.path.join(rtl_dir, 'otp_gen.v'),
                       os.path.join(rtl_dir, 'ram_4k_block.v'),
                       os.path.join(rtl_dir, 'ghost_sd.v')]

    build_args = []

    test_args = [
        "--vcd=on",
        "--wave=waveforms"
    ]
    
    runner = get_runner(sim)
    runner.build(
            sources=verilog_sources,
            hdl_toplevel="ghost_sd",
            always=True,
            build_args=build_args,
    )

    runner.test(
        hdl_toplevel="ghost_sd",
        test_module="test_ghost_sd",
        build_dir="sim_build",
        waves=True,
    )

if __name__ == "__main__":
    test_ghost_sd()
