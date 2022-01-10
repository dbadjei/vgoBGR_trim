module trim_gen (CLOCK_50,START,RST,ENCLK,DOUT,LEDR,HEX0,HEX1,HEX2,HEX3);
    input CLOCK_50, RST, START;
    output reg DOUT;
    output [17:0] LEDR; //Internal shift registers
    output ENCLK; //Clock signal for circuit
    output [6:0] HEX0, HEX1, HEX2, HEX3; //7-segment display
   

    //States
    localparam STATE_IDLE = 2'd0;
    localparam STATE_INITIAL = 2'd1;
    localparam STATE_LOAD = 2'd2;
    localparam STATE_SHIFT = 2'd3;

    //Max counts for clock divider
    localparam MAX_CLK_COUNT = 25'd12500000;
    localparam MAX_T1_COUNT = 4'd13;
    localparam MAX_T2_COUNT = 4'd3;

    //internal signals 
    wire [15:0] BCD_OUT;
    
    //Internal storage elements
    reg [11:0] TRIMCODE;
    reg [11:0] TRIM_CODE;
    reg [11:0] trimcode_hold;
    reg [1:0] state;
    reg div_clk;
    reg [24:0] clk_count;
    reg [3:0] t1, t2;

    //Clock divider
    always @(posedge CLOCK_50 or posedge RST) begin
        if (RST) begin 
            clk_count <= 25'd0;
            div_clk <= 1'b0;
        end
        else if (clk_count == MAX_CLK_COUNT) begin
            clk_count <= 25'd0;
            div_clk <= ~div_clk;
        end
        else begin
            clk_count <= clk_count + 25'd1;
        end
    end

    //Define the state transitions
    always @(negedge div_clk or posedge RST) begin
        //On reset, return to idle state
        if (RST) begin
            state <= STATE_IDLE;
        end
        else begin
            case (state)
                STATE_IDLE: begin
                    if (START == 1'b1) begin
                        state <= STATE_INITIAL;
                    end
                end 

                STATE_INITIAL: begin
                    if (t2 == MAX_T2_COUNT) begin
                        state <= STATE_LOAD;
                    end
                end

                STATE_LOAD: begin
                    state <= STATE_SHIFT;
                end

                STATE_SHIFT: begin
                    if (t1 == MAX_T1_COUNT) begin
                            state <= STATE_IDLE;
                        end
                    end
            endcase
        end
    end
    //Timer for ENCLK
    always @(posedge div_clk or posedge RST) begin
        if (RST) begin
            t1 <= 4'd0;
        end
        else begin
            if (state == STATE_SHIFT) begin
                t1 <= t1 + 4'd1;
            end
            else begin
                t1 <= 4'd0;
            end
        end
    end

    //Timer for wait time
    always @(posedge div_clk or posedge RST) begin
        if (RST) begin
            t2 <= 4'd0;
        end
        else begin
            if (state == STATE_INITIAL) begin
                t2 <= t2 + 4'd1;
            end
            else begin
                t2 <= 4'd0;
            end
        end
    end

    //Define operations in each state
    always @(posedge div_clk or posedge RST) begin
        if (RST) begin
            trimcode_hold <= 12'b011110111111;
            TRIMCODE <= 12'd0;
            DOUT <= 1'b0;
        end
        else if (state == STATE_INITIAL) begin
            if (t2 == 4'd1) begin
                TRIMCODE <= 12'd0;
                DOUT <= 1'b0;
            end
        end

        else if (state == STATE_LOAD) begin
            TRIMCODE <= trimcode_hold;
        end

        else if (state == STATE_SHIFT) begin
            if (t1 <= MAX_T1_COUNT) begin
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
    end

    //Mimick behaviour of circuit's internal shift registers
    always @(posedge ENCLK or posedge RST) begin
        if (RST) begin
            TRIM_CODE <= 12'd0;
        end
        else begin
	        TRIM_CODE[11] <= DOUT;
            TRIM_CODE[10] <= TRIM_CODE[11];
            TRIM_CODE[9] <= TRIM_CODE[10];
            TRIM_CODE[8] <= TRIM_CODE[9];
            TRIM_CODE[7] <= TRIM_CODE[8];
            TRIM_CODE[6] <= TRIM_CODE[7];
            TRIM_CODE[5] <= TRIM_CODE[6];
            TRIM_CODE[4] <= TRIM_CODE[5];
            TRIM_CODE[3] <= TRIM_CODE[4];
            TRIM_CODE[2] <= TRIM_CODE[3];
            TRIM_CODE[1] <= TRIM_CODE[2];
            TRIM_CODE[0] <= TRIM_CODE[1];
        end
    end

    assign ENCLK = ((state == STATE_SHIFT) & (t1 <= MAX_T1_COUNT)) ? div_clk : 1'b0;
    assign LEDR[11:0] = TRIM_CODE;
    assign LEDR[17:12] = 6'd0;

    bin2bcd M1(.bin(trimcode_hold),.bcd(BCD_OUT));
    bcd2disp X0(.bcd_in(BCD_OUT[3:0]),.disp_out(HEX0));
    bcd2disp X1(.bcd_in(BCD_OUT[7:4]),.disp_out(HEX1));
    bcd2disp X2(.bcd_in(BCD_OUT[11:8]),.disp_out(HEX2));
    bcd2disp X3(.bcd_in(BCD_OUT[15:12]),.disp_out(HEX3));
    
endmodule