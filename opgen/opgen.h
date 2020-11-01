#ifndef OPCODE_GENERATOR_H //Won't have duplicate definitions
#define OPCODE_GENERATOR_H

#include <stdint.h>
#ifndef NO_DPI
#include "svdpi.h"
#else
typedef uint32_t svBitVecVal;
#endif

#ifdef __cplusplus //For C++ compiler
extern "C" {
#endif

typedef enum
{
    OPCODE_LOAD = 0x03, //From ibex_pkg.sv - just the opcode field
    OPCODE_STORE = 0x23,
    OPCODE_OP = 0x33,
    OPCODE_BRANCH = 0x63,
    OPCODE_JAL = 0x6F,
} opcode_type_t;

typedef enum
{
    ARITH_ADD = 0x00000000, //R-Type opcode field funct7 and funct3 shown on page 19
    ARITH_SUB = 0x40000000,
    ARITH_SLL = 0x00001000,
    ARITH_XOR = 0x00004000,
    ARITH_SRL = 0x00005000,
    ARITH_OR = 0x00006000,
    ARITH_AND = 0x00007000,
} arithmetic_op_t;


extern void make_loadstore_test(svBitVecVal *buf, uint32_t buf_words);
extern void make_test(arithmetic_op_t op, svBitVecVal *buf, uint32_t buf_words);
extern void initGen();

int doReset();
int doFinish();
void setReg(uint32_t, uint32_t, uint32_t, uint32_t);
void setArith(uint32_t, uint32_t);
uint32_t get_arithmetic(arithmetic_op_t, uint32_t, uint32_t, uint32_t);
uint32_t get_load(uint32_t, uint32_t, uint32_t);
uint32_t get_load32(uint32_t, uint32_t, uint32_t);
uint32_t get_store(uint32_t, uint32_t, uint32_t);
uint32_t get_cond_branch(uint32_t, uint32_t, uint32_t);
uint32_t get_jal(uint32_t, uint32_t);

#ifdef __cplusplus
}
#endif

#endif
