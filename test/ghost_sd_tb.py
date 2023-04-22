#============================================
# company: Tomsk State University
# developer: Simon Razenkov
# e-mail: sirazenkov@stud.tsu.ru
# description: Top module (GhostSD) testbench
#============================================

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles

import logging

from random import randint

from common import *

logging.basicConfig(level=logging.NOTSET)
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class GhostSD_BFM():
    def __init__(self):
        self.dut = cocotb.top

    async def start_operation(self):
        await FallingEdge(self.dut.oclk_sd)
        self.dut.istart_n.value = 0
        await FallingEdge(self.dut.oclk_sd)
        self.dut.istart_n.value = 1

    async def reset(self):
        await FallingEdge(self.dut.iclk)
        self.dut.irst_n.value    = 0 
        self.dut.iocmd_sd.value  = 1
        self.dut.iodata_sd.value = 0xF
        self.dut.istart_n.value  = 1
        await FallingEdge(self.dut.iclk)
        self.dut.irst_n.value = 1
        await FallingEdge(self.dut.iclk)

    async def check_cmd_field(self, field, length):
        field_ok = True
        for i in range(length):
            await FallingEdge(self.dut.oclk_sd)
            if(int(int(self.dut.iocmd_sd.value) == 1) != ((field >> (length-1-i)) & 1)):
                field_ok = False
        return field_ok

    async def send_response(self, index, resp, crc):
        if(index == 15):
            return
        await FallingEdge(self.dut.oclk_sd)
        self.dut.iocmd_sd.value = 0
        await ClockCycles(self.dut.oclk_sd, 2, rising=False)
        if(index == 2):
            self.dut.iocmd_sd.value = 1
            for i in range(133):
                if(i == 6):
                    self.dut.iocmd_sd.value = 0
                await FallingEdge(self.dut.oclk_sd)
        else:
            for i in range(6):
                if(index == 41):
                    self.dut.iocmd_sd.value = 1 
                else:
                    self.dut.iocmd_sd.value = 1 & (index >> (5-i))
                await FallingEdge(self.dut.oclk_sd)
            for i in range(32):
                self.dut.iocmd_sd.value = 1 & (resp >> (31-i)) 
                await FallingEdge(self.dut.oclk_sd)
            for i in range(7):
                if(index == 41):
                    self.dut.iocmd_sd.value = 1 
                else:
                    self.dut.iocmd_sd.value = 1 & (crc >> (6-i))
                await FallingEdge(self.dut.oclk_sd)
        self.dut.iocmd_sd.value = 1
        await FallingEdge(self.dut.oclk_sd)
        return

    async def send_blocks(self, blocks, crc_packets):
        for j in range(8):
            await FallingEdge(self.dut.oclk_sd)
            self.dut.iodata_sd.value = 0 # Start bit
            await FallingEdge(self.dut.oclk_sd)
            for i in range(1024):
                self.dut.iodata_sd.value = blocks[j][i]
                await FallingEdge(self.dut.oclk_sd)
            for i in range(16):
                self.dut.iodata_sd.value = crc_packets[j][i]
                await FallingEdge(self.dut.oclk_sd)
            self.dut.iodata_sd.value = 0xF # End bit

    async def receive_blocks(self):
        blocks = [[] for i in range(8)]
        for j in range(8):
            await FallingEdge(self.dut.odata0_sd)
            await ClockCycles(self.dut.oclk_sd, 2, rising=False)
            for i in range(1024):
                blocks[j].append(int(self.dut.odata_sd.value))
                await FallingEdge(self.dut.oclk_sd)
            for i in range(16):
                await FallingEdge(self.dut.oclk_sd)
            await FallingEdge(self.dut.oclk_sd)
            self.dut.iodata_sd.value = 0xE # Busy
            await self.random_delay(10);
            self.dut.iodata_sd.value = 0xF
        return blocks

    async def check_finish(self):
        return (int(self.dut.osuccess.value), int(self.dut.ofail.value)) == (1,0)

    async def random_delay(self, upper_bound):
        delay = randint(1,upper_bound)
        await ClockCycles(self.dut.oclk_sd, delay)

@cocotb.test()
async def ghost_sd_tb(_):
    """GhostSD testbench""" 
    passed = True
    bfm = GhostSD_BFM()
    cocotb.start_soon(Clock(bfm.dut.iclk, 27, units="ns").start())
    await bfm.reset()
    
    blocks = [[randint(0,15) for i in range(1024)] for j in range(8)]
    original_blocks = blocks
    crc_packets = [gen_crc16_packets(block) for block in blocks]

    for i in range(2): # Encrypt, decrypt
        await bfm.start_operation()
        for trans in transactions:
            await FallingEdge(bfm.dut.iocmd_sd)
            await ClockCycles(bfm.dut.oclk_sd, 2) 
            index_ok = await bfm.check_cmd_field(trans.index, 6)
            if(index_ok):
                logger.info(f"Command index {trans.index} received successfully during cycle {i}!") 
            else:
                logger.error(f"Failed receiving command index {trans.index} during cycle {i}!") 
                passed = False
                break
            arg_ok = await bfm.check_cmd_field(trans.arg, 32)
            if(arg_ok):
                logger.info(f"Command argument for (A)CMD{trans.index} received successfully during cycle {i}!") 
            else:
                logger.error(f"Failed receiving command argument for (A)CMD{trans.index} during cycle {i}!") 
                passed = False
                break
            crc_ok = await bfm.check_cmd_field(trans.cmd_crc, 7)
            if(crc_ok):
                logger.info(f"Command CRC for (A)CMD{trans.index} received successfully during cycle {i}!") 
            else:
                logger.error(f"Failed CRC check for (A)CMD{trans.index} during cycle {i}!") 
                passed = False
                break
            await FallingEdge(bfm.dut.oclk_sd)
            if(int(bfm.dut.iocmd_sd.value) == 1):
                logger.info(f"End bit set after (A)CMD{trans.index} during cycle {i}!") 
            else:
                logger.error(f"End bit not set after (A)CMD{trans.index} during cycle {i}!") 
                passed = False
                break
            await bfm.random_delay(10)
            await bfm.send_response(trans.index, trans.resp, trans.resp_crc)
            logger.info(f"Response {trans.resp} for {trans.index} sent!");
            if(trans.index == 18 and trans.arg == 0):
                await bfm.send_blocks(blocks, crc_packets)
                logger.info(f"Blocks of data sent!");
            elif(trans.index == 25):
                received_blocks = await bfm.receive_blocks()
                logger.info(f"Blocks of data received!");
                if(i == 1):
                    if(received_blocks == original_blocks):
                        logger.info("GhostSD operation is valid!")
                    else:
                        logger.error("GhostSD operation is invalid!")
                        passed = False
                        break
                else:
                    blocks = received_blocks
                    crc_packets = [gen_crc16_packets(block) for block in blocks]
        if(not passed):
            break 
        await ClockCycles(bfm.dut.oclk_sd, 2, rising=False)
        if(await bfm.check_finish()):
            logger.info("GhostSD operation succeeded!")
        else:
            logger.error("GhostSD operation failed!")
            passed = False
            break
    assert passed

