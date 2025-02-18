`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2024 02:18:09 PM
// Design Name: 
// Module Name: singlePulsers
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


module singlePulsers(
    output reg d,
    input pushed,
    input clk
    );

    reg state;
    // 0 for unpushed
    // 1 for pushed and still pushed

    initial state=0;

    always @(posedge clk) begin
        d=0;
        case({pushed,state})
            2'b00: ;
            2'b01: state=0;
            2'b10: begin state=1; d=1; end // 1 only one clock
            2'b11: ;
        endcase
    end


endmodule
