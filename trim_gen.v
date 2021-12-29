module trim_gen (CLK50,START,RST,ENCLK,DOUT,TRIMCODE);
    input CLK50, RST, START;
    output reg DOUT;
    output reg [11:0] TRIMCODE;
    output ENCLK;

    //States
    localparam STATE_IDLE = 2'd0;
    localparam STATE_INITIAL = 2'd1;
    localparam STATE_LOAD = 2'd2;
    localparam STATE_SHIFT = 2'd3;

    //Max counts for clock divider
    localparam MAX_CLK_COUNT = 25'd25000000;
    localparam MAX_T_COUNT = 4'd12;

    //Internal storage elements
    reg [11:0] trimcode_hold;
    reg [1:0] state;
    reg div_clk;
    reg [24:0] clk_count;

    //Clock divider
    always @(posedge CLK50 or posedge RST) begin
        if RST begin 
            clk_count <= 25'b0;
        end
        else if (clk_count == MAX_CLK_COUNT) begin
            clk_count <= 25'b0;
            div_clk <= ~div_clk;
        end
        else begin
            clk_count <= clk_count + 1;
        end
    end





    
endmodule