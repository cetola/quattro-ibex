`timescale 1us / 1ns
module ibex_core_tb;

logic clk, reset;

//clock generator
//tbx clkgen
initial
begin
    clk = 0;
    forever
    begin
        #10 clk = ~clk; 
    end
end


//reset generator
//tbx clkgen
initial
begin
    reset = 1;
    #20 reset = 0;
end


import "DPI-C" context function void doReset();
import "DPI-C" context function void doFinish();
import "DPI-C" function void sendbuf (input bit [319:0] buffer, input int count);
import "DPI-C" function void getbuf(output bit [319:0] stream, output int count, output bit eom);

bit [47:0] buffer = 48'h68656c6c6f00;
bit eom = 0;
int remaining = 0;
bit [7:0] stream;

initial begin
    @(posedge clk);
    while(reset) @(posedge clk);
    doReset;
    sendbuf(buffer, 6);
end

always @(posedge clk) begin
    if (!reset) begin
        repeat (5000) @(posedge clk);
        doFinish;
        $finish();
    end
end


/*
    Create DUT
*/
    logic core_sleep;
    tbx_bfm bfm();
    
    assign bfm.clk_sys = clk;
    assign bfm.rst_sys_n = ~reset;

    ibex_core #(
    .DmHaltAddr(32'h00000000),
    .DmExceptionAddr(32'h00000000)
    ) u_core (
    .clk_i                 (bfm.clk_sys),
    .rst_ni                (bfm.rst_sys_n),
    
    .test_en_i             (1'b0),
    
    .hart_id_i             (32'b0),
    // First instruction executed is at 0x0 + 0x80
    .boot_addr_i           (32'h00000000),
    
    .instr_req_o           (bfm.instr_req),
    .instr_gnt_i           (bfm.instr_gnt),
    .instr_rvalid_i        (bfm.instr_rvalid),
    .instr_addr_o          (bfm.instr_addr),
    .instr_rdata_i         (bfm.instr_rdata),
    .instr_err_i           (1'b0),
    
    .data_req_o            (bfm.data_req),
    .data_gnt_i            (bfm.data_gnt),
    .data_rvalid_i         (bfm.data_rvalid),
    .data_we_o             (bfm.data_we),
    .data_be_o             (bfm.data_be),
    .data_addr_o           (bfm.data_addr),
    .data_wdata_o          (bfm.data_wdata),
    .data_rdata_i          (bfm.data_rdata),
    .data_err_i            (1'b0),
    
    .irq_software_i        (1'b0),
    .irq_timer_i           (1'b0),
    .irq_external_i        (1'b0),
    .irq_fast_i            (15'b0),
    .irq_nm_i              (1'b0),
    
    .debug_req_i           (1'b0),
    
    .fetch_enable_i        (1'b1),
    .core_sleep_o          (core_sleep)
    );
    
    // single port "RAM" block for instruction and data storage
    ram_1p #(
    .Depth(16384)
    ) sp_ram (
    .clk_i     ( bfm.clk_sys        ),
    .rst_ni    ( bfm.rst_sys_n      ),
    .req_i     ( bfm.mem_req        ),
    .we_i      ( bfm.mem_write      ),
    .be_i      ( bfm.mem_be         ),
    .addr_i    ( bfm.mem_addr       ),
    .wdata_i   ( bfm.mem_wdata      ),
    .rvalid_o  ( bfm.mem_rvalid     ),
    .rdata_o   ( bfm.mem_rdata      )
    );
    
endmodule
