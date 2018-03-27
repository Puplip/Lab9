/************************************************************************
Avalon-MM Interface for AES Decryption IP Core

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department

Register Map:

 0-3 : 4x 32bit AES Key
 4-7 : 4x 32bit AES Encrypted Message
 8-11: 4x 32bit AES Decrypted Message
   12: Not Used
	13: Not Used
   14: 32bit Start Register
   15: 32bit Done Register

************************************************************************/

module avalon_aes_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [3:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [31:0] EXPORT_DATA		// Exported Conduit Signal to LEDs
);


logic [15:0][31:0] Regs;
logic [15:0] Chip_Selects;

register reg00(.*,.Data_In(AVL_WRITEDATA),.Data_Out(Regs[00]),.CS(Chip_Selects[00] && AVL_CS));
register reg01(.*,.Data_In(AVL_WRITEDATA),.Data_Out(Regs[01]),.CS(Chip_Selects[01] && AVL_CS));
register reg02(.*,.Data_In(AVL_WRITEDATA),.Data_Out(Regs[02]),.CS(Chip_Selects[02] && AVL_CS));
register reg03(.*,.Data_In(AVL_WRITEDATA),.Data_Out(Regs[03]),.CS(Chip_Selects[03] && AVL_CS));
register reg04(.*,.Data_In(AVL_WRITEDATA),.Data_Out(Regs[04]),.CS(Chip_Selects[04] && AVL_CS));
register reg05(.*,.Data_In(AVL_WRITEDATA),.Data_Out(Regs[05]),.CS(Chip_Selects[05] && AVL_CS));
register reg06(.*,.Data_In(AVL_WRITEDATA),.Data_Out(Regs[06]),.CS(Chip_Selects[06] && AVL_CS));
register reg07(.*,.Data_In(AVL_WRITEDATA),.Data_Out(Regs[07]),.CS(Chip_Selects[07] && AVL_CS));
register reg08(.*,.Data_In(AVL_WRITEDATA),.Data_Out(Regs[08]),.CS(Chip_Selects[08] && AVL_CS));
register reg09(.*,.Data_In(AVL_WRITEDATA),.Data_Out(Regs[09]),.CS(Chip_Selects[09] && AVL_CS));
register reg11(.*,.Data_In(AVL_WRITEDATA),.Data_Out(Regs[11]),.CS(Chip_Selects[11] && AVL_CS));
register reg12(.*,.Data_In(AVL_WRITEDATA),.Data_Out(Regs[12]),.CS(Chip_Selects[12] && AVL_CS));
register reg13(.*,.Data_In(AVL_WRITEDATA),.Data_Out(Regs[13]),.CS(Chip_Selects[13] && AVL_CS));
register reg14(.*,.Data_In(AVL_WRITEDATA),.Data_Out(Regs[14]),.CS(Chip_Selects[14] && AVL_CS));
register reg15(.*,.Data_In(AVL_WRITEDATA),.Data_Out(Regs[15]),.CS(Chip_Selects[15] && AVL_CS));

mux16 my_mux(.*,.Data_In(Regs),.Data_Out(AVL_WRITEDATA));
dec16 my_dec(.*,.Out(Chip_Selects));

endmodule
