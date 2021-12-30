module bcd2disp (bcd_in, disp_out);
    input [3:0] bcd_in;
    output reg [6:0] disp_out;

    always @(*) begin
        case (bcd_in)
           4'd0 : disp_out = 7'b1000000;
           4'd1 : disp_out = 7'b1111001;
           4'd2 : disp_out = 7'b0100100;
           4'd3 : disp_out = 7'b0110000;
           4'd4 : disp_out = 7'b0011001;
           4'd5 : disp_out = 7'b0010010;
           4'd6 : disp_out = 7'b0000010;
           4'd7 : disp_out = 7'b1111000;
           4'd8 : disp_out = 7'b0000000;
           4'd9 : disp_out = 7'b0010000;
           default: disp_out =  7'b1000000;
        endcase
    end
    
endmodule