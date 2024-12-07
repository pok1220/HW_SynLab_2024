`timescale 1ns / 1ps

module text_screen_gen(
    input clk, reset,
    input video_on,
    input set,
    input up,
    input down,
    input left,
    input right,
    input [7:0] sw,
    input [9:0] x, y,
    output reg [11:0] rgb,
    input [7:0] data_for_show,
    input en
    );
    
    // signal declaration
    // ascii ROM
    wire [11:0] rom_addr;
    wire [7:0] char_addr;
    wire [3:0] row_addr;
    wire [2:0] bit_addr;
    wire [7:0] font_word;
    wire ascii_bit;
    wire we; // write enable
    wire [11:0] addr_r, addr_w;
    wire [7:0] din, dout;
    // 80-by-30 tile map
    parameter MIN_X=  20;
    parameter MAX_X = 60;   // 640 pixels / 8 data bits = 80
    parameter MIN_Y=  12;
    parameter MAX_Y = 20;   // 480 pixels / 16 data rows = 30
    
    // cursor
    reg [6:0] cur_x_reg;
    wire [6:0] cur_x_next;
    reg [4:0] cur_y_reg;
    wire [4:0] cur_y_next;
    wire move_xl_tick, move_yu_tick, move_xr_tick, move_yd_tick, cursor_on;
    
    // delayed pixel count
    reg [9:0] pix_x1_reg, pix_y1_reg;
    reg [9:0] pix_x2_reg, pix_y2_reg;
    // object output signals
    wire [11:0] text_rgb, text_rev_rgb;
    wire en;
    
    
    wire [1:0] enable;
    singlePulsers single_en(enable,en,clk);
    
    // instantiate the ascii / font rom
    //step4 readRAM->step1 ReadROM
    ascii_rom a_rom(.clk(clk), .addr(rom_addr), .data(font_word));
    
    //step1 dout read from RAM
    dual_port_ram dual_p_ram(.clk(clk), .we(enable), .addr_a(addr_w), .addr_b(addr_r),
                         .din_a(data_for_show), .dout_a(), .dout_b(dout),.reset(reset));
    
    
    // registers
    always @(posedge clk or posedge reset)
        if(reset) begin
            cur_x_reg <= MIN_X;
            cur_y_reg <= MIN_Y;
            pix_x1_reg <= 0;
            pix_x2_reg <= 0;
            pix_y1_reg <= 0;
            pix_y2_reg <= 0;
        end    
        else begin
            cur_x_reg <= cur_x_next;
            cur_y_reg <= cur_y_next;
            pix_x1_reg <= x;
            pix_x2_reg <= pix_x1_reg;
            pix_y1_reg <= y;
            pix_y2_reg <= pix_y1_reg;
        end
    
    // tile RAM write
    assign addr_w = {cur_y_reg, cur_x_reg};
    assign we = set;
    assign din = sw;
    
    // use nondelayed coordinates to form tile RAM address
    assign addr_r = {y[8:4], x[9:3]}; //
    assign char_addr = dout; //step2 read RAM
    
    //step3 readRam
    assign row_addr = y[3:0]; // font ROM
    assign rom_addr = {char_addr, row_addr};  //step3 write RAM   
    assign bit_addr = pix_x2_reg[2:0];// use delayed coordinate to select a bit
    assign ascii_bit = font_word[~bit_addr];//step2 readRom
    
    // new cursor position
    assign cur_x_next = (enable && cur_x_reg == MAX_X - 1) ? MIN_X : (enable && data_for_show[7:4] == 4'b0000 && data_for_show[3:0] == 4'b1101) ? MIN_X : (enable) ? cur_x_reg + 1 : cur_x_reg;
    assign cur_y_next = (cur_y_reg == MAX_Y -1) ? MIN_Y : ((enable && cur_x_reg == MAX_X - 1) || (enable && data_for_show[7:4] == 4'b0000 && data_for_show[3:0] == 4'b1101)) ? cur_y_reg + 1 : cur_y_reg;
                                              
    // green over black and reversed video for cursor
    //step3 readROM display
    assign text_rgb = (ascii_bit) ? 12'h000 : (enable) ? 12'h000 : 12'hFFF; //left character right background
    assign text_rev_rgb = (ascii_bit) ? 12'h000 : 12'h000; // right cursor
    // use delayed coordinates for comparison
    assign cursor_on = (pix_y2_reg[8:4] == cur_y_reg) &&
                       (pix_x2_reg[9:3] == cur_x_reg);
                       
    // rgb multiplexing circuit
    always @*
        if(~video_on)
            rgb = 12'h000;     // blank
        else
            if(cursor_on)
                rgb = text_rev_rgb;
            else
                rgb = text_rgb;
      
endmodule