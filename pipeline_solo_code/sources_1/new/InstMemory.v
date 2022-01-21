`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/02 14:55:09
// Design Name: 
// Module Name: InstMemory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 用多路选择器模拟ROM,也许可以改进用IP核实现
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module InstMemory(Address,Inst);
(* DONT_TOUCH= "TRUE" *) input [31:0] Address;
output reg [31:0] Inst;
parameter s0 = 5'd16;
parameter s1 = 5'd17;
parameter s2 = 5'd18;
parameter s4 = 5'd20;
parameter s5 = 5'd21;
parameter a0 = 5'd4;
parameter a1 = 5'd5;
parameter a2 = 5'd6;
parameter a3 = 5'd7;
parameter t0 = 5'd8;
parameter t1 = 5'd9;
parameter t2 = 5'd10;
parameter t3 = 5'd11;
parameter t4 = 5'd12;
parameter t5 = 5'd13;
parameter t6 = 5'd14;
parameter t7 = 5'd15;
parameter t8 = 5'd24;
parameter v0 = 5'd2;
parameter Interrupt = 26'd46;
parameter digital = 26'd139;
parameter exception = 26'd145;
always @(*) begin
    case (Address[9:2])
        // j main
        8'd0: Inst <= {6'h02,26'd3};
        // j interrupt
        8'd1: Inst <= {6'h02,Interrupt};
        // j exception
        8'd2: Inst <= {6'h02,exception};
        //lw $s0 0($0)
        8'd3: Inst <= {6'h23,5'd0,5'd16,16'd0};
        //lw $s1 4($0)
        8'd4: Inst <= {6'h23,5'd0,5'd17,16'd4};
        //lw $s2 8($0)
        8'd5: Inst <= {6'h23,5'd0,5'd18,16'd8};
        //lw $s5 12($0)
        8'd6: Inst <= {6'h23,5'd0,5'd21,16'd12};
        //lw $s4 16($0)
        8'd7: Inst <= {6'h23,5'd0,5'd20,16'd16};
        //addi $t0 $0 0
        8'd8: Inst <= {6'h08,5'd0,5'd8,16'd0};
        //addi $a0 $s4 0
        8'd9: Inst <= {6'h08,5'd20,5'd4,16'd0};
        //addi $a1 $s5 0
        8'd10: Inst <= {6'h08,5'd21,5'd5,16'd0};
        //dlp:
        //lw $a2 0($a0)
        8'd11: Inst <= {6'h23,5'd4,5'd6,16'd0};
        //lw $a3 0($a1) 
        8'd12: Inst <= {6'h23,5'd5,5'd7,16'd0};
        //addi $a0 $a0 4
        8'd13: Inst <= {6'h08,5'd4,5'd4,16'd4};
        //addi $a1 $a1 4
        8'd14: Inst <= {6'h08,5'd5,5'd5,16'd4};
        //addi $t1 $s1 0
        8'd15: Inst <= {6'h08,5'd17,5'd9,16'd0};
        //dip:
        //sub $t2 $t1 $a2
        8'd16: Inst <= {6'h00,t1,a2,t2,5'd0,6'h22};
        //bltz $t2 10
        8'd17: Inst <= {6'h01,t2,5'd0,16'd10};
        //sll $t2 $t2 2
        8'd18: Inst <= {6'h00,5'd0,t2,t2,5'd2,6'h00};
        //add $t2 $s0 $t2
        8'd19: Inst <= {6'h00,s0,t2,t2,5'd0,6'h20};
        //lw $t3 0($t2)
        8'd20: Inst <= {6'h23,t2,t3,16'd0};
        //add $t2 $t3 $a3
        8'd21: Inst <= {6'h00,t3,a3,t2,5'd0,6'h20};
        //sll $t3 $t1 2
        8'd22: Inst <= {6'h00,5'd0,t1,t3,5'd2,6'h00};
        //add $t3 $s0 $t3
        8'd23: Inst <= {6'h00,s0,t3,t3,5'd0,6'h20};
        //lw $t4 0($t3)
        8'd24: Inst <= {6'h23,t3,t4,16'd0};
        //sub $t5 $t4 $t2
        8'd25: Inst <= {6'h00,t4,t2,t5,5'd0,6'h22};
        //bgtz $t5 1
        8'd26: Inst <= {6'h07,t5,5'd0,16'd1};
        //sw $t2 0($t3)
        8'd27: Inst <= {6'h2b,t3,t2,16'd0};
        //goto:
        //addi $at $0 1
        8'd28: Inst <= {6'h08,5'd0,5'd1,16'd1};
        //sub $t1 $t1 $at
        8'd29: Inst <= {6'h00,t1,5'd1,t1,5'd0,6'h22};
        //addi $at $0 -1
        8'd30: Inst <= {6'h08,5'd0,5'd1,16'hffff};
        //sub $t5 $t1 $at
        8'd31: Inst <= {6'h00,t1,5'd1,t5,5'd0,6'h22};
        //bgtz $t5 dip
        8'd32: Inst <= {6'h07,t5,5'd0,16'hffef};
        //addi $t0 $t0 1
        8'd33: Inst <= {6'd08,t0,t0,16'd1};
        //sub $t5 $t0 $s2
        8'd34: Inst <= {6'h00,t0,s2,t5,5'd0,6'h22};
        //bltz $t5 dlp
        8'd35: Inst <= {6'h01,t5,5'd0,16'hffe7};
        //sll $t5 $s1 2
        8'd36: Inst <= {6'h00,5'd0,s1,t5,5'd2,6'h00};
        //add $t6 $s0 $t5
        8'd37: Inst <= {6'h00,s0,t5,t6,5'd0,6'h20};
        //lw $v0 0($t6)
        8'd38: Inst <= {6'h23,t6,v0,16'd0};
        //lui $t0 0x4000
        8'd39: Inst <= {6'h0f,5'd0,t0,16'h4000};
        //lw $t1 8($t0)
        8'd40: Inst <= {6'h23,t0,t1,16'd8};
        //addi $t2 $0 3
        8'd41: Inst <= {6'h08,5'd0,t2,16'd3};
        //or $t1 $t1 $t2
        8'd42: Inst <= {6'h00,t1,t2,t1,5'd0,6'h25};
        //sw $t2 8($t0)
        8'd43: Inst <= {6'h2b,t0,t2,16'd8};
        //wait: j wait
        8'd44: Inst <= {6'h02,26'd44};
        8'd45: Inst <= {6'h02,26'd44};
        //Interrupt:
        //lui $t0, 0x4000 
        8'd46: Inst <= {6'h0f,5'd0,t0,16'h4000};
        //addi $t2, $0, 9
        8'd47: Inst <= {6'h08,5'd0,t2,16'd9};
        //lw $t3, 8($t0)
        8'd48: Inst <= {6'h23,t0,t3,16'd8};
        //and $t3, $t3, $t2
        8'd49: Inst <= {6'h00,t3,t2,t3,5'd0,6'h24};
        //sw $t3, 8($t0)
        8'd50: Inst <= {6'h2b,t0,t3,16'd8};
        //lw $t4, 16($t0)
        8'd51: Inst <= {6'h23,t0,t4,16'd16};
        //andi $t5, $t4, 0x0100
        8'd52: Inst <= {6'h0c,t4,t5,16'h0100};
        //bne $t5, $0, AN1
        8'd53: Inst <= {6'h05,5'd0,t5,16'd5};
        //addi $t5, $0, 0x0d00
        8'd54: Inst <= {6'h08,5'd0,t5,16'h0d00}; 
        //add $t7, $0, $v0
        8'd55: Inst <= {6'h00,5'd0,v0,t7,5'd0,6'h20};
        //andi $t7, $t7, 0x00f0
        8'd56: Inst <= {6'h0c,t7,t7,16'h00f0};
        //srl $t7, $t7, 4 
        8'd57: Inst <= {6'h00,5'd0,t7,t7,5'd4,6'h02};
        //j Number
        8'd58: Inst <= {6'h02,26'd75};
        //AN1:
        //andi $t5, $t4, 0x0200
        8'd59: Inst <= {6'h0c,t4,t5,16'h0200};
        //bne $t5, $0, AN2
        8'd60: Inst <= {6'h05,5'd0,t5,16'd5};
        //addi $t5, $0, 0x0b00
        8'd61: Inst <= {6'h08,5'd0,t5,16'h0b00};
        //add $t7, $0, $v0
        8'd62: Inst <= {6'h00,5'd0,v0,t7,5'd0,6'h20};
        //andi $t7, $t7, 0x0f00
        8'd63: Inst <= {6'h0c,t7,t7,16'h0f00};
        //srl $t7, $t7, 8
        8'd64: Inst <= {6'h00,5'd0,t7,t7,5'd8,6'h02};
        //j Number
        8'd65: Inst <= {6'h02,26'd75};
        //AN2:
        //andi $t5, $t4, 0x0400
        8'd66: Inst <= {6'h0c,t4,t5,16'h0400};
        //bne $t5, $0, AN3
        8'd67: Inst <= {6'h05,5'd0,t5,16'd5};    
        //addi $t5, $0, 0x0700
        8'd68: Inst <= {6'h08,5'd0,t5,16'h0700};
        //add $t7,$0, $v0
        8'd69: Inst <= {6'h00,5'd0,v0,t7,5'd0,6'h20};
        //andi $t7, $t7, 0xf000
        8'd70: Inst <= {6'h0c,t7,t7,16'hf000};
        //srl $t7, $t7, 12
        8'd71: Inst <= {6'h00,5'd0,t7,t7,5'd12,6'h02};
        //j Number
        8'd72: Inst <= {6'h02,26'd75};
        //AN3:
        //addi $t5, $0, 0x0e00  
        8'd73: Inst <= {6'h08,5'd0,t5,16'h0e00};
        //add  $t7, $0,$v0  #t7 = V0
        8'd74: Inst <= {6'h00,5'd0,v0,t7,5'd0,6'h20};
        //andi $t7, $t7, 0x000f
        8'd75: Inst <= {6'h0c,t7,t7,16'h000f};
        //Number:
        //beq $t7, $0, zero
        8'd76: Inst <= {6'h04,5'd0,t7,16'd30};
        //addi $t8 $0 1
        8'd77: Inst <= {6'h08,5'd0,t8,16'd1};
        //beq $t7, $t8, one
        8'd78: Inst <= {6'h04,t8,t7,16'd30};
        //addi $t8 $0 2
        8'd79: Inst <= {6'h08,5'd0,t8,16'd2};
        //beq $t7, $t8, two
        8'd80: Inst <= {6'h04,t8,t7,16'd30};
        //addi $t8 $0 3
        8'd81: Inst <= {6'h08,5'd0,t8,16'd3};                
        //beq $t7, $t8, three
        8'd82: Inst <= {6'h04,t8,t7,16'd30};
        //addi $t8 $0 4
        8'd83: Inst <= {6'h08,5'd0,t8,16'd4};                
        //beq $t7, $t8, four
        8'd84: Inst <= {6'h04,t8,t7,16'd30};
        //addi $t8 $0 5
        8'd85: Inst <= {6'h08,5'd0,t8,16'd5};                
        //beq $t7, $t8, five
        8'd86: Inst <= {6'h04,t8,t7,16'd30};
        //addi $t8 $0 6
        8'd87: Inst <= {6'h08,5'd0,t8,16'd6};                
        //beq $t7, $t8, six
        8'd88: Inst <= {6'h04,t8,t7,16'd30};
        //addi $t8 $0 6
        8'd89: Inst <= {6'h08,5'd0,t8,16'd7};                
        //beq $t7, $t8, five
        8'd90: Inst <= {6'h04,t8,t7,16'd30};
                //addi $t8 $0 5
        8'd91: Inst <= {6'h08,5'd0,t8,16'd8};                
        //beq $t7, $t8, five
        8'd92: Inst <= {6'h04,t8,t7,16'd30};
                //addi $t8 $0 5
        8'd93: Inst <= {6'h08,5'd0,t8,16'd9};                
        //beq $t7, $t8, five
        8'd94: Inst <= {6'h04,t8,t7,16'd30};
                //addi $t8 $0 5
        8'd95: Inst <= {6'h08,5'd0,t8,16'd10};                
        //beq $t7, $t8, five
        8'd96: Inst <= {6'h04,t8,t7,16'd30};
                //addi $t8 $0 5
        8'd97: Inst <= {6'h08,5'd0,t8,16'd11};                
        //beq $t7, $t8, five
        8'd98: Inst <= {6'h04,t8,t7,16'd30};
                //addi $t8 $0 5
        8'd99: Inst <= {6'h08,5'd0,t8,16'd12};                
        //beq $t7, $t8, five
        8'd100: Inst <= {6'h04,t8,t7,16'd30};
                //addi $t8 $0 5
        8'd101: Inst <= {6'h08,5'd0,t8,16'd13};                
        //beq $t7, $t8, five
        8'd102: Inst <= {6'h04,t8,t7,16'd30};
                //addi $t8 $0 5
        8'd103: Inst <= {6'h08,5'd0,t8,16'd14};                
        //beq $t7, $t8, five
        8'd104: Inst <= {6'h04,t8,t7,16'd30};
                //addi $t8 $0 5
        8'd105: Inst <= {6'h08,5'd0,t8,16'd15};                
        //beq $t7, $t8, five
        8'd106: Inst <= {6'h04,t8,t7,16'd30};
        //zero:
        //addi $t6, $t5, 0xc0
        8'd107: Inst <= {6'h08,t5,t6,16'hc0};
        // j digital
        8'd108: Inst <= {6'h02,digital};
                //addi $t6, $t5, 0xc0
        8'd109: Inst <= {6'h08,t5,t6,16'hf9};
        // j digital
        8'd110: Inst <= {6'h02,digital};
                //addi $t6, $t5, 0xc0
        8'd111: Inst <= {6'h08,t5,t6,16'ha4};
        // j digital
        8'd112: Inst <= {6'h02,digital};
                //addi $t6, $t5, 0xc0
        8'd113: Inst <= {6'h08,t5,t6,16'hb0};
        // j digital
        8'd114: Inst <= {6'h02,digital};
                //addi $t6, $t5, 0xc0
        8'd115: Inst <= {6'h08,t5,t6,16'h99};
        // j digital
        8'd116: Inst <= {6'h02,digital};
                        //addi $t6, $t5, 0xc0
        8'd117: Inst <= {6'h08,t5,t6,16'h92};
        // j digital
        8'd118: Inst <= {6'h02,digital};
                        //addi $t6, $t5, 0xc0
        8'd119: Inst <= {6'h08,t5,t6,16'h82};
        // j digital
        8'd120: Inst <= {6'h02,digital};
                        //addi $t6, $t5, 0xc0
        8'd121: Inst <= {6'h08,t5,t6,16'hf8};
        // j digital
        8'd122: Inst <= {6'h02,digital};
                        //addi $t6, $t5, 0xc0
        8'd123: Inst <= {6'h08,t5,t6,16'h80};
        // j digital
        8'd124: Inst <= {6'h02,digital};
                        //addi $t6, $t5, 0xc0
        8'd125: Inst <= {6'h08,t5,t6,16'h90};
        // j digital
        8'd126: Inst <= {6'h02,digital};
                        //addi $t6, $t5, 0xc0
        8'd127: Inst <= {6'h08,t5,t6,16'h88};
        // j digital
        8'd128: Inst <= {6'h02,digital};
                        //addi $t6, $t5, 0xc0
        8'd129: Inst <= {6'h08,t5,t6,16'h83};
        // j digital
        8'd130: Inst <= {6'h02,digital};
                        //addi $t6, $t5, 0xc0
        8'd131: Inst <= {6'h08,t5,t6,16'hc6};
        // j digital
        8'd132: Inst <= {6'h02,digital};
                        //addi $t6, $t5, 0xc0
        8'd133: Inst <= {6'h08,t5,t6,16'ha1};
        // j digital
        8'd134: Inst <= {6'h02,digital};
                        //addi $t6, $t5, 0xc0
        8'd135: Inst <= {6'h08,t5,t6,16'h86};
        // j digital
        8'd136: Inst <= {6'h02,digital};
                        //addi $t6, $t5, 0xc0
        8'd137: Inst <= {6'h08,t5,t6,16'h8e};
        // j digital
        8'd138: Inst <= {6'h02,digital};
        // digital
        // sw $t6, 16($t0)
        8'd139: Inst <= {6'h2b,t0,t6,16'd16};
        // lw $t2, 8($t0) 
        8'd140: Inst <= {6'h23,t0,t2,16'd8};
        // addi $t3, $0, 0x0002
        8'd141: Inst <= {6'h08,5'd0,t3,16'h2};
        // or $t2, $t2, $t3 
        8'd142: Inst <= {6'h00,t2,t3,t2,5'd0,6'h25};
        // sw $t2, 8($t0)
        8'd143: Inst <= {6'h2b,t0,t2,16'd8};
        // jr $26
        8'd144: Inst <= {6'h00,5'd26,15'd0,6'h08};
        // Exception
        // j Exception
        8'd145: Inst <= {6'h02,exception};
        default : Inst <= {6'h02,26'd3};
endcase
end
endmodule
