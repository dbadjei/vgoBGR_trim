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
    localparam MAX_T1_COUNT = 4'd13;
    localparam MAX_T2_COUNT = 4'd3;

    //Internal storage elements
    reg [11:0] trimcode_hold;
    reg [1:0] state;
    reg div_clk;
    reg [24:0] clk_count;
    reg [3:0] t1, t2;

    //Clock divider
    always @(posedge CLK50 or posedge RST) begin
        if (RST) begin 
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

    always @(negedge div_clk or posedge RST) begin
        //On reset, return to idle state
        if (RST) begin
            state <= STATE_IDLE;
            trimcode_hold <= 11'd0;
            TRIMCODE <= 11'd0;
            div_clk <= 1'b0;
            DOUT <= 0;
        end
        //Define the state transitions
        else begin
            case (state)
                STATE_IDLE: begin
                    if (START == 1'b1) begin
                        state <= STATE_LOAD;
                    end
                end 

                STATE_INITIAL: begin
                    trimcode_hold <= trimcode_hold + 1;
                    TRIMCODE <= 0;
                    DOUT <= 1'b0;
                    if (t2 == MAX_T2_COUNT) begin
                        state <= STATE_LOAD;
                    end
                end

                STATE_LOAD: begin
                    TRIMCODE <= trimcode_hold;
                    state <= STATE_SHIFT;
                end

                STATE_SHIFT: begin
                    if (t1 == MAX_T1_COUNT) begin
                        state <= STATE_INITIAL;
                    end
                end
            endcase
        end
    end

    always @(posedge div_clk or posedge RST) begin
        if (RST) begin
            t1 <= 4'd0;
        end
        else begin
            if (state == STATE_SHIFT) begin
                t1 <= t1 + 1;
            end
            else begin
                t1 <= 4'd0;
            end
        end
    end


    always @(posedge div_clk or posedge RST) begin
        if (RST) begin
            t2 <= 4'd0;
        end
        else begin
            if (state == STATE_INITIAL) begin
                t2 <= t2 + 1;
            end
            else begin
                t2 <= 4'd0;
            end
        end
    end

    always @(posedge div_clk or posedge RST) begin
        if ((state == STATE_SHIFT) & (t <= MAX_T1_COUNT)) begin
            TRIMCODE[10] <= TRIMCODE[11];
            TRIMCODE[9] <= TRIMCODE[10];
            TRIMCODE[8] <= TRIMCODE[9];
            TRIMCODE[7] <= TRIMCODE[8];
            TRIMCODE[6] <= TRIMCODE[7];
            TRIMCODE[5] <= TRIMCODE[6];
            TRIMCODE[4] <= TRIMCODE[5];
            TRIMCODE[3] <= TRIMCODE[4];
            TRIMCODE[2] <= TRIMCODE[3];
            TRIMCODE[1] <= TRIMCODE[2];
            TRIMCODE[0] <= TRIMCODE[1];
            DOUT <= TRIMCODE[0];
        end
    end


    assign ENCLK = ((state == STATE_SHIFT) & (t <= MAX_T1_COUNT)) ? div_clk : 0;

    
endmodule