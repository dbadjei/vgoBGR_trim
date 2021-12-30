module trim_gen_tb;
    reg CLK50;
    reg RST;
    reg START;
    wire [11:0] trimCODE;
    wire DOUT;
    wire ENCLK;

    initial begin
        CLK50 = 0;
        RST = 1;
        START = 0;
    end

    always #10 CLK50 = ~CLK50;

    initial begin
        #50
        RST = 0;
        #10
        START = 1;
    end

    trim_gen M1 (.CLK50(CLK50),
                 .RST(RST),
                 .START(START),
                 .ENCLK(ENCLK),
                 .DOUT(DOUT),
                 .TRIM_CODE(trimCODE));
endmodule