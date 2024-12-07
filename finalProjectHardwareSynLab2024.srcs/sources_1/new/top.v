`timescale 1ns / 1ps

module top(
    input clk,              // 100MHz Basys 3
    input reset,            // sw[15] for reset
    input set,              // btnC
    input [7:0] sw,         // sw[7:0] sets ASCII value
    input ja1,              //uart Transmit signal
    output ja2,              //uart Recieve signal
    output wire RsTx,        //uart transmit
    input wire RsRx,         //uart recieve
    output hsync, vsync,      // VGA connector
    output [11:0] rgb,       // DAC, VGA connector
    output [6:0] seg,
    output dp,
    output [3:0] an
    );
    
    // signals
    wire [9:0] w_x, w_y;
    wire w_vid_on, w_p_tick;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    
    // instantiate vga controller
    vga_controller vga(.clk_100MHz(clk), .reset(), .video_on(w_vid_on),
                       .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), 
                       .x(w_x), .y(w_y));
    
    // instantiate text generation circuit
    text_screen_gen tsg(.clk(clk), .reset(reset), .video_on(w_vid_on), .set(set),
                        .up(up), .down(down), .left(left), .right(right),
                        .sw(sw), .x(w_x), .y(w_y), .rgb(rgb_next), .data_for_show(data_out), .en(en1));
                     
    wire [7:0] data_out, data_waste;
    wire en1, en2; //en2 is just dummy
    
    //Communicate from other to show in me data in not used , data out mode 0 RsRx from other and RsTx To show in my Screen
    uart uartMyKeyboardToMyBasys(.clk(clk), .RsRx(ja1), .RsTx(RsTx), .data_in(0), .data_out(data_out), .received(en1), .mode(1'b0));
    //Communicate (sent) from my board to other datain is from my switch daata out out to other
    uart uartBoardToBoard(.clk(clk), .RsRx(RsRx), .RsTx(ja2), .data_in(sw[7:0]), .data_out(data_waste), .received(en2), .mode(set));
    
    
    // div clk for display
    wire [18:0] tclk;
    assign tclk[0] = clk;
    //clock Divider
    genvar c;
    generate for(c=0;c<18;c=c+1)
    begin
        clockDiv div(tclk[c+1], tclk[c]);
    end
    endgenerate
    clockDiv ffdiv(targetClk, tclk[18]);
    
    // temporary dummy to hold sevensegment from click button
    reg [7:0] display_out,tmp_display;
    wire en2Wire;
    always@(posedge en2 or posedge set) begin
            if(set) begin 
                display_out <= sw; 
                tmp_display <= sw; 
            end
            else if(en2) display_out = data_waste; 
            else display_out <= tmp_display;
     end
    
    wire targetClk;
    wire an0,an1,an2,an3;
    //sevensegmentDisplay
    assign an = {an3,an2,an1,an0};
    quadSevenSeg tdm(seg,dp,an0,an1,an2,an3, data_out[3:0] , data_out[7:4], display_out[3:0], display_out[7:4], targetClk);
    
    // rgb buffer
    always @(posedge clk)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    // output
    assign rgb = rgb_reg;
    
endmodule