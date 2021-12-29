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

    //Internal signals
    wire [11:0] trim_code
    //Internal storage elements
    reg [11:0] trimcode_hold;
    reg [1:0] state;
    reg div_clk;
    reg [24:0] clk_count;
    reg [3:0] t;
    reg load, enable;

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

    always @(posedge div_clk or posedge RST) begin
        
        //On reset, return to idle state
        if (RST) begin
            state <= STATE_IDLE;
        end
        //Define the state transitions
        else begin
            case (state)
                STATE_IDLE: begin
                    trimcode_hold <= 11'd0;
                    TRIMCODE <= 11'd0;
                    div_clock <= 1'b0;
                    clk_count <= 25'd0;
                    DOUT <= 0;

                    if (START == 1'b1) begin
                        state <= STATE_INITIAL;
                    end
                end 

                STATE_INITIAL: begin
                    trimcode_hold <= trimcode_hold + 1;
                    TRIMCODE <= 0;
                    DOUT <= 1'b0;
                    state <= STATE_LOAD;
                end

                STATE_LOAD: begin
                    state <= STATE_SHIFT;
                end

                STATE_SHIFT: begin
                    if (t == MAX_T_COUNT) begin
                        state <= STATE_INITIAL;
                    end
                end
            endcase
        end
    end

    always @(posedge div_clk or posedge RST) begin
        if (RST) begin
            t <= 4'd0;
        end
        else begin
            if (state == STATE_SHIFT) begin
                t <= t + 1;
            end
            else begin
                t <= 4'd0;
            end
        end
    end


    always @(*) begin
        if (state == STATE_LOAD) begin
            load = 1'b1;
        end
        else begin
            load = 1'b0;
        end

        if (state == STATE_SHIFT) begin
            enable = 1'b1;
        end
        else begin
            enable = 1'b0;
        end
    end




    
endmodule