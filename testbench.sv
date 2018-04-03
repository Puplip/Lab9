module testbench ();

timeprecision 1ns;
timeunit 10ns;

logic clk;

always begin : CLOCK_GENERATION
#1 clk = ~clk;
end

initial begin: CLOCK_INITIALIZATION
    clk = 0;
end 

logic CLK;
logic RESET;
logic AES_START;
logic AES_DONE;
logic [127:0] AES_KEY;
logic [127:0] AES_MSG_ENC;
logic [127:0] AES_MSG_DEC;

assign CLK = clk;

AES ke0(.*);

initial begin : test_stuff
AES_KEY = 128'h000102030405060708090a0b0c0d0e0f;
RESET = 1;
AES_START = 0;
AES_MSG_ENC = 128'hdaec3055df058e1c39e814ea76f6747e;
#4
RESET = 0;
#2
AES_START = 1;

end


endmodule
