module register
    #(parameter W = 16)(
    input wire             clock,
    input wire             reset,
    input wire             load,
    input wire             incr,
    input wire     [W-1:0] input_data,
    output reg     [W-1:0] register_out
);

initial begin
    register_out = {W{1'b0}};
end

    always @(posedge clock) begin
        if (reset) 
            register_out <= {W{1'b0}};
        else if (load) 
            register_out <= input_data;
        else if (incr) 
            register_out <= register_out + 1'b1;
        else 
            register_out <= register_out;
    end

endmodule