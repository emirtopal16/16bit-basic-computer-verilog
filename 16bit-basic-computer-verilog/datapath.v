module datapath(
    input  wire        clock,
    input  wire        AR_ld, PC_ld, DR_ld, AC_ld, IR_ld, TR_ld,
    input  wire        AR_incr, PC_incr, DR_incr, AC_incr, TR_incr,
    input  wire        AR_clr, PC_clr, DR_clr, AC_clr, TR_clr,

    input  wire        E_ld, E_clr, E_incr,
    input  wire        IEN_ld, IEN_clr,

    input  wire        memory_write,

    input  wire [2:0]  bus_select,
    input  wire [2:0]  alu_op_select,

    output wire [11:0] AR_out,
    output wire [11:0] PC_out,

    output wire [15:0] DR_out,
    output wire [15:0] AC_out,
    output wire [15:0] IR_out,
    output wire [15:0] TR_out,

    output wire        E_out,
    output wire        IEN_out,

    output wire        CO, OVF, N, Z
);
    wire [15:0] memory_read_data;

    memory_unit mem_inst (
        .clk(clock),
        .we(memory_write),
        .address(AR_out),
        .write_data(bus_out),
        .read_data(memory_read_data)
    );
    wire [15:0] bus_out;

    //  Bus
    mux #(16) bus_mux (
        .bit_select(bus_select),
        .AR({{4'b0},AR_out}),
        .PC({{4'b0},PC_out}),
        .DR(DR_out),
        .AC(AC_out),
        .IR(IR_out),
        .TR(TR_out),
        .MEMORY(memory_read_data),
        .MUX_OUT(bus_out)
    );

    // AR
    register #(12) AR_reg (
        .clock(clock),
        .reset(AR_clr),
        .load(AR_ld),
        .incr(AR_incr),
        .input_data(bus_out[11:0]),
        .register_out(AR_out)
    );

    // PC
    register #(12) PC_reg (
        .clock(clock),
        .reset(PC_clr),
        .load(PC_ld),
        .incr(PC_incr),
        .input_data(bus_out[11:0]),
        .register_out(PC_out)
    );

    // DR
    register #(16) DR_reg (
        .clock(clock),
        .reset(DR_clr),
        .load(DR_ld),
        .incr(DR_incr),
        .input_data(bus_out),
        .register_out(DR_out)
    );

    // AC
    wire [15:0] alu_out;
    wire        alu_E_next;

    register #(16) AC_reg (
        .clock(clock),
        .reset(AC_clr),
        .load(AC_ld),
        .incr(AC_incr),
        .input_data(alu_out),
        .register_out(AC_out)
    );

    // IR
    register #(16) IR_reg (
        .clock(clock),
        .reset(1'b0),
        .load(IR_ld),
        .incr(1'b0),
        .input_data(bus_out),
        .register_out(IR_out)
    );

    // TR
    register #(16) TR_reg (
        .clock(clock),
        .reset(TR_clr),
        .load(TR_ld),
        .incr(TR_incr),
        .input_data(bus_out),
        .register_out(TR_out)
    );

    // E
    register #(1) E_reg (
        .clock(clock),
        .reset(E_clr),
        .load(E_ld),
        .incr(E_incr),
        .input_data(alu_E_next),
        .register_out(E_out)
    );

    // IEN
    register #(1) IEN_reg (
        .clock(clock),
        .reset(IEN_clr),
        .load(IEN_ld),
        .incr(1'b0),
        .input_data(1'b1),
        .register_out(IEN_out)
    );

    // ALU
    ALU #(16) alu (
        .E(E_out),
        .op_select(alu_op_select),
        .AC_input(AC_out),
        .DR_input(DR_out),

        .CO(CO),
        .OVF(OVF),
        .N(N),
        .Z(Z),

        .E_next(alu_E_next),

        .ALU_out(alu_out)
    );

endmodule
