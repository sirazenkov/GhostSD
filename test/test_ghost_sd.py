#============================================
# company: Tomsk State University
# developer: Simon Razenkov
# e-mail: sirazenkov@stud.tsu.ru
# description: Top module (GhostSD) testbench
#============================================

import os
import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles

from random import randint

from common import *

test_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(test_dir, '..', 'src'))

RAM_BLOCKS = 8

async def reset(dut):
    await FallingEdge(dut.iclk)
    dut.irst.value = 1 
    dut.iocmd_sd.value = 1
    dut.iodata_sd.value = 0xF
    dut.istart.value = 0
    await FallingEdge(dut.iclk)
    dut.irst.value = 0
    await FallingEdge(dut.iclk)

async def check_cmd_field(dut, field, length):
    field_ok = True
    for i in range(length):
        await FallingEdge(dut.oclk_sd)
        if(int(int(dut.iocmd_sd.value) == 1) != ((field >> (length-1-i)) & 1)):
            field_ok = False
    return field_ok

async def send_response(dut, index, resp, crc):
    if(index == 15):
        return
    await FallingEdge(dut.oclk_sd)
    dut.iocmd_sd.value = 0
    await ClockCycles(dut.oclk_sd, 2, rising=False)
    if(index == 9):
        dut.iocmd_sd.value = 1
        for i in range(6):
            await FallingEdge(dut.oclk_sd)
        for i in range(127):
            if(i == 44 or i == 47 or i == 80):
                dut.iocmd_sd.value = 1
            else:
                dut.iocmd_sd.value = 0
            await FallingEdge(dut.oclk_sd)
    elif(index == 2):
        dut.iocmd_sd.value = 1
        for i in range(6):
            await FallingEdge(dut.oclk_sd)
        dut.iocmd_sd.value = 0
        for i in range(127):
            await FallingEdge(dut.oclk_sd)
    else:
        for i in range(6):
            if(index == 41):
                dut.iocmd_sd.value = 1 
            else:
                dut.iocmd_sd.value = 1 & (index >> (5-i))
            await FallingEdge(dut.oclk_sd)
        for i in range(32):
            dut.iocmd_sd.value = 1 & (resp >> (31-i)) 
            await FallingEdge(dut.oclk_sd)
        for i in range(7):
            if(index == 41):
                dut.iocmd_sd.value = 1 
            else:
                dut.iocmd_sd.value = 1 & (crc >> (6-i))
            await FallingEdge(dut.oclk_sd)
    dut.iocmd_sd.value = 1
    await FallingEdge(dut.oclk_sd)
    return

async def send_status(dut):
    blocks = [randint(0,15) for i in range(128)]
    crc_packets = gen_crc16_packets(blocks)
    await FallingEdge(dut.oclk_sd)
    dut.iodata_sd.value = 0 # Start bit
    await FallingEdge(dut.oclk_sd)
    for i in range(128):
        dut.iodata_sd.value = blocks[i]
        await FallingEdge(dut.oclk_sd)
    for i in range(16):
        dut.iodata_sd.value = crc_packets[i]
        await FallingEdge(dut.oclk_sd)
    dut.iodata_sd.value = 0xF # End bit

async def send_blocks(dut, blocks, crc_packets):
    for j in range(RAM_BLOCKS):
        await FallingEdge(dut.oclk_sd)
        dut.iodata_sd.value = 0 # Start bit
        await FallingEdge(dut.oclk_sd)
        for i in range(1024):
            dut.iodata_sd.value = blocks[j][i]
            await FallingEdge(dut.oclk_sd)
        for i in range(16):
            dut.iodata_sd.value = crc_packets[j][i]
            await FallingEdge(dut.oclk_sd)
        dut.iodata_sd.value = 0xF # End bit

async def receive_block(dut):
    block = []
    await FallingEdge(dut.odata0_sd)
    await ClockCycles(dut.oclk_sd, 2, rising=False)
    for i in range(1024):
        block.append(int(dut.odata_sd.value))
        await FallingEdge(dut.oclk_sd)
    for i in range(16):
        await FallingEdge(dut.oclk_sd)
    return block

async def random_delay(dut, upper_bound):
    delay = randint(1, upper_bound)
    await ClockCycles(dut.oclk_sd, delay)

@cocotb.test()
async def ghost_sd_tb(dut):
    """GhostSD testbench""" 

    cocotb.start_soon(Clock(dut.iclk, 27, units="ns").start())

    await reset(dut) 
    blocks = [[randint(0,15) for i in range(1024)] for j in range(RAM_BLOCKS)]
    original_blocks = blocks
    crc_packets = [gen_crc16_packets(block) for block in blocks]

    for i in range(2): # Encrypt, decrypt
        received_blocks = []
        
        await reset(dut) 

        await FallingEdge(dut.oclk_sd)
        dut.istart.value = 1
        await FallingEdge(dut.oclk_sd)
        dut.istart.value = 0

        for trans in transactions:
            await FallingEdge(dut.iocmd_sd)
            await ClockCycles(dut.oclk_sd, 2) 

            index_ok = await check_cmd_field(dut, trans.index, 6)
            assert index_ok, f"Failed receiving command index {trans.index} during cycle {i}!"

            arg_ok = await check_cmd_field(dut, trans.arg, 32)
            assert arg_ok, f"Failed receiving command argument for (A)CMD{trans.index} during cycle {i}!"

            crc_ok = await check_cmd_field(dut, trans.cmd_crc, 7)
            assert crc_ok, f"Failed CRC check for (A)CMD{trans.index} during cycle {i}!"

            await FallingEdge(dut.oclk_sd)
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
        await ClockCycles(dut.oclk_sd, 2, rising=False)
        assert (int(dut.osuccess.value), int(dut.ofail.value)) == (1,0), "GhostSD operation failed!"

def test_ghost_sd():
    sim = os.getenv("SIM", "icarus")

    verilog_sources = [os.path.join(rtl_dir, 'sd', 'cmd_driver', 'crc7.v'),
                       os.path.join(rtl_dir, 'sd', 'cmd_driver', 'cmd_driver.v'),
                       os.path.join(rtl_dir, 'sd', 'd_driver',   'crc16.v'),
                       os.path.join(rtl_dir, 'sd', 'd_driver',   'd_driver.v'),
                       os.path.join(rtl_dir, 'sd', 'sd_fsm.v'),
                       os.path.join(rtl_dir, 'sd', 'sd.v'),
                       os.path.join(rtl_dir, 'otp_gen', 'gost', 'round', 's_box.v'),
                       os.path.join(rtl_dir, 'otp_gen', 'gost', 'round', 'round.v'),
                       os.path.join(rtl_dir, 'otp_gen', 'gost', 'gost.v'),
                       os.path.join(rtl_dir, 'otp_gen', 'otp_gen.v'),
                       os.path.join(rtl_dir, 'clock_divider.v'),
                       os.path.join(rtl_dir, 'ram_4k_block.v'),
                       os.path.join(rtl_dir, 'ghost_sd.v')]
    runner = get_runner(sim)
    runner.build(
            verilog_sources=verilog_sources,
            hdl_toplevel="ghost_sd",
            always=True,
    )

    runner.test(hdl_toplevel="ghost_sd", test_module="test_ghost_sd",)

if __name__ == "__main__":
    test_ghost_sd()
