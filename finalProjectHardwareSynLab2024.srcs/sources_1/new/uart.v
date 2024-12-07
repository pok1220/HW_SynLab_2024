`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2024 10:14:31 AM
// Design Name: 
// Module Name: uart
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


module uart(
    input clk,
    input RsRx,
    input [7:0] data_in,
    input mode,
    output RsTx,
    output [7:0] data_out,
    output received
 
    );
    
    reg en, last_rec;
    wire sent, received, baud;
    
    wire [7:0] data;
    assign data = (mode) ? data_in : data_out;
    
    baudrate_gen baudrate_gen(clk, baud);
    uart_rx receiver(baud, RsRx, received, data_out);
    uart_tx transmitter(baud, data, en, sent, RsTx); //it push tmp into data
    
    //325 clocks change, 1 baud changes
    always @(posedge baud) begin
        if (en) en = 0;
        if ((~last_rec & received) || mode) begin // if received or pass enable
            en = 1;
        end
        last_rec = received;
    end
    
endmodule