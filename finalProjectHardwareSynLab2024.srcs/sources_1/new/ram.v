`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 01:03:36 PM
// Design Name: 
// Module Name: ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dual_port_ram
    #(
        parameter DATA_SIZE = 8,
        parameter ADDR_SIZE = 12
    )
    (
    input clk,
    input we,
    input [ADDR_SIZE-1:0] addr_a, addr_b,
    input [DATA_SIZE-1:0] din_a,
    input reset,
    output [DATA_SIZE-1:0] dout_a, dout_b
    );

    // Infer the RAM as block RAM
    (* ram_style = "block" *) reg [DATA_SIZE-1:0] ram [2**ADDR_SIZE-1:0];
    (* ram_style = "block" *) reg [DATA_SIZE-1:0] ram2 [2**ADDR_SIZE-1:0];

    reg [ADDR_SIZE-1:0] addr_a_reg, addr_b_reg;
    wire resetPulser;

    // Instantiate the singlePulsers module (ensure it's correctly implemented elsewhere)
    singlePulsers pulserReset(
        resetPulser,
        reset,
        clk
    );

    // Write operation and address latching
    integer i;
    always @(posedge clk) begin
        if (resetPulser) begin
//            // Reset all RAM contents to 0
            for (i = 0; i < 2**ADDR_SIZE; i = i + 1) begin
                ram[i] <= 0;
            end
        end else 
          if (we) begin
            // Write operation
            if(din_a!=8'h0d)
                ram[addr_a] <= din_a;
            end

//         Latch addresses for read operations
        addr_a_reg <= addr_a;
        addr_b_reg <= addr_b;
    end

    // Read operations
    assign dout_a = ram[addr_a_reg];
    assign dout_b = ram[addr_b_reg];

endmodule
