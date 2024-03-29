from random import randint

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
    block_len = len(block)
    for i in range(block_len):
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

class Transaction:
    def __init__(self, index, arg, resp):
        self.index = index
        self.arg   = arg
        self.resp  = resp
        self.cmd_crc = crc7(1 << 38 | index << 32 | arg)
        self.resp_crc = crc7(index << 32 | resp)

RCA = randint(0, 1 << 16)

transactions = (#index|          argument          |       response
    Transaction(55,    (1 << 15) - 1,               1 << 5),                                 # CMD55
    Transaction(41,    1 << 31 | 3 << 20,           (1 << 31) | (3 << 20)),                  # ACDM41
    Transaction(2,     (1 << 32) - 1,               0),                                      # CMD2
    Transaction(3,     (1 << 32) - 1,               RCA << 16),                              # CMD3
    Transaction(9,     RCA << 16 | ((1 << 15) - 1), 9 << (80-6) | (1 << (47-6))),            # CMD9
    Transaction(7,     RCA << 16 | ((1 << 15) - 1), 3 << 9),                                 # CMD7
    Transaction(55,    RCA << 16 | ((1 << 15) - 1), (4 << 9) | (1 << 5)),                    # CMD55
    Transaction(6,     (1 << 32) - 2,               4 << 9),                                 # ACMD6
    Transaction(6,     (1 << 31) + 1,               4 << 9),                                 # CMD6
    Transaction(13,    RCA << 16 | ((1 << 15) - 1), (5 << 9) | (1 << 8)),                    # CMD13 (data state)
    Transaction(13,    RCA << 16 | ((1 << 15) - 1), (4 << 9) | (1 << 8)),                    # CMD13 (tran state)
    Transaction(18,    0,                           4 << 9),                                 # CMD18
    Transaction(12,    (1 << 32) - 1,               5 << 9),                                 # CMD12
    Transaction(55,    RCA << 16 | ((1 << 15) - 1), (4 << 9) | (1 << 5)),                    # CMD55
    Transaction(23,    ((1 << 9) - 1) << 23 | 8,    4 << 9),                                 # ACMD23
    Transaction(25,    0,                           4 << 9),                                 # CMD25
    Transaction(13,    RCA << 16 | ((1 << 15) - 1), (6 << 9) | (1 << 8)), # Receive 8 blocks # CMD13 (rcv state)
    Transaction(13,    RCA << 16 | ((1 << 15) - 1), (6 << 9) | (1 << 8)),                    # same
    Transaction(13,    RCA << 16 | ((1 << 15) - 1), (6 << 9) | (1 << 8)),
    Transaction(13,    RCA << 16 | ((1 << 15) - 1), (6 << 9) | (1 << 8)),
    Transaction(13,    RCA << 16 | ((1 << 15) - 1), (6 << 9) | (1 << 8)),
    Transaction(13,    RCA << 16 | ((1 << 15) - 1), (6 << 9) | (1 << 8)),
    Transaction(13,    RCA << 16 | ((1 << 15) - 1), (6 << 9) | (1 << 8)),
    Transaction(13,    RCA << 16 | ((1 << 15) - 1), (6 << 9) | (1 << 8)),
    Transaction(12,    (1 << 32) - 1,               6 << 9),                                 # CMD12
    Transaction(13,    RCA << 16 | ((1 << 15) - 1), (4 << 9) | (1 << 8)),                    # CMD13
    Transaction(15,    RCA << 16 | ((1 << 15) - 1), 0)                                       # CMD15
)
