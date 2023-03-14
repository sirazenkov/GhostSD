import cocotb
from cocotb.clock import Clock
from cocotb.binary import BinaryValue
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles

import logging

import random

import sys
sys.path.insert(1, '.')
from common import *

logging.basicConfig(level=logging.NOTSET)
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class GhostSD_BFM():
    def __init__(self):
        self.dut = cocotb.top

    async def pull_up(self):
        while(True):
            if (self.dut.iocmd_sd.value == BinaryValue('Z')):
                self.dut.iocmd_sd.value = 1
            for i in range(4):
                if (self.dut.iodata_sd[i].value == BinaryValue('Z')):
                    self.dut.iodata_sd[i].value = 1

    async def start_operation(self):
        cocotb.start_soon(Clock(self.dut.iclk, 27, units="ns").start())
        cocotb.start_soon(self.pull_up()) 
        await FallingEdge(self.dut.iclk)
        self.dut.istart.value = 1
        await self.random_delay(10)
        self.dut.istart.value = 1

    async def reset(self):
        await FallingEdge(self.dut.iclk)
        self.dut.irst.value      = 1 
        self.dut.iocmd_sd.value  = BinaryValue('Z')
        self.dut.iodata_sd.value = BinaryValue('ZZZZ')
        self.dut.istart.value    = 0
        await FallingEdge(self.dut.iclk)
        self.dut.irst.value = 0
        await FallingEdge(self.dut.iclk)

    async def check_finish(self):
        return (int(self.dut.osuccess.value), int(self.dut.ofail.value))

    async def select_response(self, command, argument):

        return

    async def receive_command(self):
        crc_data = 0
        await FallingEdge(self.dut.iocmd_sd)
        await ClockCycles(self.dut.oclk_sd, 1) # Skip start bit
        crc_data = (crc_data << 1) | self.dut.iocmd_sd.value
        await ClockCycles(self.dut.oclk_sd, 1) # Skip transmission bit
        index = 0
        for i in range(6):
            await FallingEdge(self.dut.oclk_sd)
            index = (index << 1) | self.dut.iocmd_sd.value
            crc_data = (crc_data << 1) | self.dut.iocmd_sd.value
        argument = 0
        for i in range(32):
            await FallingEdge(self.dut.oclk_sd)
            argument = (index << 1) | self.dut.iocmd_sd.value
            crc_data = (crc_data << 1) | self.dut.iocmd_sd.value
        cmd_crc = crc7(crc_data)
        crc_fail = False
        for i in range(7):
            await FallingEdge(self.dut.oclk_sd)
            if((cmd_crci >> (7-i)) & 1 != self.dut.iocmd_sd.value):
                crc_fail = True
        await ClockCycles(self.dut.oclk_sd, 1) # Skip end bit
        return (index, argument, crc_fail)

    async def send_response(self, response, dummy):
        await FallingEdge(self.dut.iclk)
        self.dut.icmd_sd.value = 0
        await ClockCycles(self.dut.oclk_sd, 2) # Start bit and transmission bit
        if(dummy): # Dummy R2 response
            self.dut.icmd_sd.value = 0
            for i in range():
                await FallingEdge(self.dut.iclk) 
        else:
            for i in range(45):
                self.dut.icmd_sd.value = 1 & (response >> (45 - 1 - i))
                await FallingEdge(self.dut.iclk)
        self.dut.icmd_sd.value = 1
        await FallingEdge(self.dut.iclk) 
        return

    async def send_block(self, block, crc_packets):
        await FallingEdge(self.dut.iclk)
        self.dut.istart.value = 1
        await FallingEdge(self.dut.iclk)
        self.dut.idata_sd.value = 0 # Start bit
        self.dut.istart.value = 0
        await FallingEdge(self.dut.iclk)
        for i in range(1024):
            self.dut.idata_sd.value = block[i]
            await FallingEdge(self.dut.iclk)
        for i in range(16):
            self.dut.idata_sd.value = crc_packets[i]
            await FallingEdge(self.dut.iclk)
        self.dut.idata_sd.value = 0xF # End bit
        await RisingEdge(self.dut.odone)
        await FallingEdge(self.dut.iclk)

    async def receive_block(self, crc_packets):
        await FallingEdge(self.dut.iclk)
        self.dut.istart.value = 1
        await FallingEdge(self.dut.iclk)
        self.dut.istart.value = 0
        await FallingEdge(self.dut.iclk)
        block = []
        for i in range(1024):
            block.append(int(self.dut.odata_sd))
            await FallingEdge(self.dut.iclk)
        crc_failed = False
        for i in range(16):
            if(int(self.dut.odata_sd.value) != crc_packets[i]):
                crc_failed = True
            await FallingEdge(self.dut.iclk)
        await RisingEdge(self.dut.odone)
        return (block, crc_failed)

    async def random_delay(self, upper_bound):
        delay = random.randint(0,upper_bound)
        await ClockCycles(self.dut.iclk, delay)

#@cocotb.test()
async def ghost_sd_tb(_):
    """GhostSD testbench""" 
    passed = True
    bfm = GhostSD_BFM()
    await bfm.start_operation()
    await bfm.reset()
    
    success = 0
    fail = 0
    commands_counter = 0
    commands_sequence = (55, 41, 2, 3, 7, 55, 6)

    while(True):
        command_content, command_crc7 = bfm.receive_command()
        command_index = (((1 << 38) - 1) & command_content) >> 32
        command_argument = ((1 << 32) - 1) & command_content
        if(command_index == commands_sequence[commands_counter]):
            logger.info(f"Command with index {command_index} received!")
        else:
            logger.error(f"Command with index {command_index} received \
                           instead of {commands_sequence[commands_counter]}!")
            passed = False
            break

        if(crc7(command_content) == command_crc7):
            logger.info(f"Command CRC7 checksum is correct!")
        else:
            logger.error(f"Command CRC7 checksum is wrong!")
            passed = False
            break

        if(command_index == 2): # Dummy response for CMD2, since it's ignored
            bfm.send_response() 
        else:
            response = bfm.select_response(command_index, command_argument)

        success,fail = bfm.check_result()
        if(success != 0 or fail != 0):
            break


        block = [random.randint(0,15) for i in range(1024)]
        crc_packets = gen_crc_packets(block)
        await bfm.random_delay(10)
        await bfm.send_block(block, crc_packets)
        await bfm.random_delay(10)
        received_block, crc_failed = await bfm.receive_block(crc_packets)
        if(gost(block) == received_block):
            logger.info(f"Block {i} is successfully processed!") 
        else:
            logger.error(f"Block {i} is processed incorrectly!") 
            passed = False
            break
        if(not crc_failed):
            logger.info(f"Correct CRC in block {i} from the module!")
        else:
            logger.error(f"Wrong CRC in block {i} from the module!")
            break
        if(int(bfm.dut.odata_sd.value) == 0xF):
            logger.info(f"Finish bit set in block {i} from module!") 
        else:
            logger.error(f"Finish bit not set in block {i} from module!")
            passed = False
            break

    if (failed == 1):
        passed = False
        logger.error("GhostSD operation failed!")
    elif (success == 1):
        logger.info("GhostSD operation succeeded!")

    assert passed

