import cocotb
from cocotb.clock import Clock
from cocotb.binary import BinaryValue
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles

import logging

import random

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
        self.dut.irst.value       = 1 
        self.dut.iocmd_sd.value   = BinaryValue('Z')
        self.dut.iodata_sd.value  = BinaryValue('ZZZZ')
        self.dut.istart.value     = 0
        await FallingEdge(self.dut.iclk)
        self.dut.irst.value = 0
        await FallingEdge(self.dut.iclk)

    async check_finish(self):
        return (int(self.dut.osuccess.value), int(self.dut.ofail.value))

    async def select_response(self, command, argument):

    async def receive_command(self):
        await FallingEdge(self.dut.iocmd_sd)
        await ClockCycles(self.dut.oclk_sd, 1) # Skip start bit
        await ClockCycles(self.dut.oclk_sd, 1)

    async def send_response(self):

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

def crc7(data):
    crc = 0
    for i in range(39): # transmission bit + command index (6 bits) + command argument (32 bits)
        data_bit = (data >> (38-i)) & 1
        last_bit = (crc >> 6) & 1
        xor_bit = last_bit ^ data_bit
        crc = crc << 1
        crc = crc & ((1 << 7) - 1)
        crc = crc ^ xor_bit ^ (xor_bit << 3)
    return crc

def crc16(data):
    crc = 0
    for i in range(1024): 
        data_bit = (data >> (1023-i)) & 1
        last_bit = (crc >> 15) & 1
        xor_bit = last_bit ^ data_bit
        crc = crc << 1
        crc = crc & ((1 << 16) - 1)
        crc = crc ^ xor_bit ^ (xor_bit << 5) ^ (xor_bit << 12)
    return crc

def gen_crc16_packets(block):
    lines_data = [0,0,0,0]
    for i in range(1024):
        for j in range(4):
            lines_data[j] = lines_data[j] << 1 | ((block[i] >> j) & 1)
    crc_values = [crc16(line_data) for line_data in lines_data]
    crc_packets = []
    for i in range(16):
        crc_packet = 0
        for j in range(4):
            crc_packet = crc_packet | (((crc_values[j] >> (15-i)) & 1) << j)
        crc_packets.append(crc_packet)
    return crc_packets

@cocotb.test()
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
        command_index = ({((1 << 38) - 1) & command_content) >> 32
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

        response = bfm.select_response(command_index, command_argument)

        success,fail = bfm.check_result()
        if(success != 0 || fail != 0):
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
    else if (success == 1)
        logger.info("GhostSD operation succeeded!")

    assert passed

