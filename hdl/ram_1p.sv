// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE fo
// SPDX-License-Identifier: Apache-2.0

/**
 * Single-port RAM with 1 cycle read/write delay, 32 bit words
 */
module ram_1p #(
    parameter int Depth = 16384
) (
    input               clk_i,
    input               rst_ni,

    input               req_i,
    input               we_i,
    input        [ 3:0] be_i,
    input        [31:0] addr_i,
    input        [31:0] wdata_i,
    output logic        rvalid_o,
    output logic [31:0] rdata_o
);

  localparam int Aw = $clog2(Depth);

  logic [31:0] mem [16384]; // pragma attribute mem ram_block 1

  logic [14-1:0] addr_idx;
  assign addr_idx = addr_i[14-1+2:2];
  logic [31-14:0] unused_addr_parts;
  assign unused_addr_parts = {addr_i[31:14+2], addr_i[1:0]};

  always @(posedge clk_i) begin
    if (req_i) begin
      if (we_i) begin
        for (int i = 0; i < 4; i = i + 1) begin
          if (be_i[i] == 1'b1) begin
            mem[addr_idx][i*8 +: 8] <= wdata_i[i*8 +: 8];
          end
        end
      end
      rdata_o <= mem[addr_idx];
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid_o <= '0;
    end else begin
      rvalid_o <= req_i;
    end
  end

   task simutil_verilator_memload;
     input string file;
     $readmemh(file, mem);
   endtask

    /*
    This function is for debugging purposes. By simply forcing the system to
    loop adding 1 to a register and to memory, we can observe a very basic
    functionality completely removing the testbench code.
   */
   task init_basic_memory;
        mem[0] = 32'h 3fc00093; //       li      x1,1020 (0x3FC)    // store the address (0x3FC) in register #1
        mem[1] = 32'h 0000a023; //       sw      x0,0(x1)           // stores the value "0" in memory (at 0x3FC)
        mem[2] = 32'h 0000a103; // loop: lw      x2,0(x1)           // reading from memory, into register #2
        mem[3] = 32'h 00110113; //       addi    x2,x2,1            // adding 1 to register #2
        mem[4] = 32'h 0020a023; //       sw      x2,0(x1)           // store register #2 in memory
        mem[5] = 32'h ff5ff06f; //       j       <loop>             // loop back to "read from memory"
    endtask

  `ifdef VERILATOR
    // Task for loading 'mem' with SystemVerilog system task $readmemh()
    export "DPI-C" task simutil_verilator_memload;
    // Function for setting a specific 32 bit element in |mem|
    // Returns 1 (true) for success, 0 (false) for errors.
    export "DPI-C" function simutil_verilator_set_mem;
  `endif

    // TODO: Allow 'val' to have other widths than 32 bit
    function int simutil_verilator_set_mem(input int index,
                                           input logic[31:0] val);
      if (index >= 16384) begin
        return 0;
      end

      mem[index] = val;
      return 1;
    endfunction

  `ifdef SRAM_INIT_FILE
    localparam MEM_FILE = `"`SRAM_INIT_FILE`";
    initial begin
      $display("Initializing SRAM from %s", MEM_FILE);
      $readmemh(MEM_FILE, mem);
    end
  `endif
endmodule
