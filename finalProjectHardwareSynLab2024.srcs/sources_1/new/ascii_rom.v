`timescale 1ns / 1ps

module ascii_rom(
	input clk, 
	input wire [11:0] addr,
	output reg [7:0] data
	);

	(* rom_style = "block" *)	// Infer ROM as Block RAM

	reg [11:0] addr_reg;
	reg [7:0] rom [4095:0];
	
	initial $readmemb("ascii5.txt", rom);
	
	always @(posedge clk)
		addr_reg <= addr;
	
	always@*
	   if(addr_reg >= 12'hA10) 
	       data = rom[addr_reg - 12'h200];
		else
		  data = rom[addr_reg];

endmodule