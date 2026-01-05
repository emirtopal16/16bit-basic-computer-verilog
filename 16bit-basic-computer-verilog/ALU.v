module ALU
    #(parameter W = 16) (
        input   wire              E,
        input   wire      [2:0]   op_select,
        input   wire      [W-1:0] AC_input,
        input   wire      [W-1:0] DR_input,

        output  reg             CO,
        output  reg             OVF,
        output  wire            N,
        output  wire            Z,
        output  reg             E_next,
        output  reg     [W-1:0] ALU_out
);

    reg [W:0] internal_sum;

    initial begin
    CO = 1'b0;
    ALU_out = {W{1'b0}};
    E_next = 1'b0;
    end

    always @(*) begin
        CO      = 1'b0;
        OVF     = 1'b0;
        E_next  = 1'b0;

        case (op_select)

            // AND
            3'b000: begin
                ALU_out = AC_input & DR_input;
            end
            
            // ADD
            3'b001: begin
                internal_sum = AC_input + DR_input;
                ALU_out  = internal_sum[W-1:0];
                CO       = internal_sum[W];
                E_next = CO;
                OVF = (AC_input[W-1] == DR_input[W-1]) &&
                          (ALU_out[W-1] != AC_input[W-1]);
            end

            // DR to AC
            3'b010: begin
                ALU_out = DR_input;
            end

            // Complement AC
            3'b011: begin
                ALU_out = ~AC_input;
            end

            // Shift Right
            3'b100: begin
                ALU_out = {E, AC_input[W-1:1]};
                E_next  = AC_input[0];
            end

            // Shift Left
            3'b101: begin
                ALU_out = {AC_input[W-2:0], E};
                E_next  = AC_input[W-1];
            end

            // Transfer AC
            3'b110: begin
                ALU_out = AC_input;
            end

            // NOP
            default: begin
                ALU_out = {W{1'b0}};
            end

        endcase
    end

    assign Z = &(~AC_input);
    assign N = AC_input[W-1];
endmodule