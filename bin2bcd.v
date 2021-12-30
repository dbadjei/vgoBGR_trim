module bin2bcd(bin, bcd);
    //input ports and their sizes
    input [11:0] bin;
    //output ports and, their size
    output [15:0] bcd;
    //Internal variables
    reg [15 : 0] bcd; 
    reg [3:0] i;   
     
     //Always block - implement the Double Dabble algorithm
     always @(bin)
        begin
            bcd = 15'd0; //initialize bcd to zero.
            for (i = 4'd0; i < 4'd12; i = i + 4'd1) //run for 12 iterations
            begin
                bcd = {bcd[14:0],bin[11-i]}; //concatenation
                    
                //if a hex digit of 'bcd' is more than 4, add 3 to it.  
                if(i < 4'd11 && bcd[3:0] > 4'd4) 
                    bcd[3:0] = bcd[3:0] + 4'd3;
                if(i < 4'd11 && bcd[7:4] > 4'd4)
                    bcd[7:4] = bcd[7:4] + 4'd3;
                if(i < 4'd11 && bcd[11:8] > 4'd4)
                    bcd[11:8] = bcd[11:8] + 4'd3; 
					 if(i < 4'd11 && bcd[15:12] > 4'd4)
                    bcd[15:12] = bcd[15:12] + 4'd3; 
            end
        end     
                
endmodule