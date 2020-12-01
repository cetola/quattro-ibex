#include <stdio.h>
#include "svdpi.h"
#include "tbxbindings.h"

void doInitRam();
FILE* in_msg = NULL;

void doInitRam() {
    uint32_t buf32[6];
    buf32[0] = 0x3fc00093; //       li      x1,1020 (0x3FC)    // store the address (0x3FC) in register #1
    buf32[1] = 0x0000a023; //       sw      x0,0(x1)           // stores the value "0" in memory (at 0x3FC)
    buf32[2] = 0x0000a103; // loop: lw      x2,0(x1)           // reading from memory, into register #2
    buf32[3] = 0x00110113; //       addi    x2,x2,1            // adding 1 to register #2
    buf32[4] = 0x0020a023; //       sw      x2,0(x1)           // store register #2 in memory
    buf32[5] = 0xff5ff06f; //       j       <loop>             // loop back to "read from memory"

    for (int i = 0; i < 6; ++i) {
        ibex_set_mem(i, (svBitVecVal *)&buf32[i]);
    }
}

/*
 * Fills the RAM with data
 */
void doReset() {
    svSetScope(svGetScopeFromName("ibex_core_tb.sp_ram"));
    printf("---reset---\n");
    doInitRam();
}

/*
 * Calls the checker. For now, simply looks at the end state of memory.
 */
void doFinish() {
    svSetScope(svGetScopeFromName("ibex_core_tb.sp_ram"));
    ibex_check_mem();
    printf("---All tests passed---\n");
}

/*
 * Provides PMP config and address range data for the checker
 * NOTE: RV32: the pmpaddr is the top 32 bits of a 34 bit PMP address
 */ 
void sendbuf(const svBitVecVal* buffer, int count) {

  svBitVecVal b = 0; 
  for(int i=count;i>0;i--) {
    svGetPartselBit(&b, buffer, (i-1)*8, 8);
    if(b==0) break;
    printf("%c", b);
    if(b=='\n') printf("HVL:");
  }
  if(b==0) printf("\nHVL: Complete message received.\n");
  fflush(stdout);
}

/*
 * Will eventually (possibly) look at the output of the checker and decide how
 * to "better" randomize the config and address ranges.
 */
void getbuf(svBitVecVal* buf, int* count, svBit* eom) {

}
