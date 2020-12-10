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

logic [32:0] count = 0;

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

        export "DPI-C" function ibex_check_mem;
        function void ibex_check_mem(input int err);
            begin
                err = 0;
                for(integer i=0; i < 6; i=i+1)
                begin
                    $display("check_data(data = %h, address = %h)",mem[i],i);
                end
                $display("check_data(data = %d, address = %h)",mem[255],255); //0x3FC
                if(mem[255] != 356) begin
                    err = err + 1;
                end
            end
        endfunction

        export "DPI-C" function ibex_set_mem;
        function void ibex_set_mem(input int index, input bit[31:0] val);
            $display("Set mem at index: %d value: %h", index, val);
            if (index < 16384) begin
                mem[index] <= val;
            end
        endfunction

        `ifdef SRAM_INIT_FILE
            localparam MEM_FILE = `"`SRAM_INIT_FILE`";
            initial begin
                $display("Initializing SRAM from %s", MEM_FILE);
                $readmemh(MEM_FILE, mem);
            end
        `endif
endmodule
