module mux 
  #(parameter W = 16) (
    input  [2:0]  bit_select,
    input  [W-1:0] AR,
    input  [W-1:0] PC,
    input  [W-1:0] DR,
    input  [W-1:0] AC,
    input  [W-1:0] IR,
    input  [W-1:0] TR,
    input  [W-1:0] MEMORY,
    
    output [W-1:0] MUX_OUT
);

    assign MUX_OUT = (bit_select == 3'b000) ? 16'b0 :
        (bit_select == 3'b001) ? AR :
        (bit_select == 3'b010) ? PC :
        (bit_select == 3'b011) ? DR :
        (bit_select == 3'b100) ? AC :
        (bit_select == 3'b101) ? IR :
        (bit_select == 3'b110) ? TR :
        (bit_select == 3'b111) ? MEMORY :  16'b0;

endmodule