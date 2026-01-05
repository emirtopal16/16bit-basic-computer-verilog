//Don't change the module I/O
module BC_I (
input clk,
input FGI,
output [11:0] PC,
output [11:0] AR,
output [15:0] IR,
output [15:0] AC,
output [15:0] DR,
output E
);

wire memory_write;

wire [2:0] alu_op_select, bus_select;

wire IEN_out, CO, OVF, N, Z;

wire AR_ld, PC_ld, DR_ld, AC_ld, IR_ld, TR_ld, E_ld, IEN_ld;
wire AR_incr, PC_incr, DR_incr, AC_incr, TR_incr, E_incr;
wire AR_clr, PC_clr, DR_clr, AC_clr, TR_clr, E_clr, IEN_clr;

// Instantiate your datapath and controller here, then connect them.
// YOU MUST NAME DATAPATH INSTANCE AS my_datapath
// YOU MUST NAME DATAPATH INSTANCE AS my_controller

//datapath my_datapath(YOUR CONNECTIONS HERE)
datapath my_datapath (
    .clock(clk),
    .memory_write(memory_write),
    .bus_select(bus_select), .alu_op_select(alu_op_select),
    .DR_out(DR), .AC_out(AC), .IR_out(IR), .AR_out(AR), .PC_out(PC),
    .IEN_out(IEN_out), .CO(CO), .OVF(OVF), .N(N), .Z(Z), .E_out(E), 
    .AR_ld(AR_ld), .PC_ld(PC_ld), .DR_ld(DR_ld), .AC_ld(AC_ld), .IR_ld(IR_ld), .TR_ld(TR_ld), .E_ld(E_ld), .IEN_ld(IEN_ld),
    .AR_incr(AR_incr), .PC_incr(PC_incr), .DR_incr(DR_incr), .AC_incr(AC_incr), .TR_incr(TR_incr), .E_incr(E_incr),
    .AR_clr(AR_clr), .PC_clr(PC_clr), .DR_clr(DR_clr), .AC_clr(AC_clr), .TR_clr(TR_clr), .E_clr(E_clr), .IEN_clr(IEN_clr)
);

//controller my_controller(YOUR CONNECTIONS HERE)
controller my_controller (
    .clock(clk),
    .memory_write(memory_write),
    .bus_select(bus_select), .alu_op_select(alu_op_select),
    .IR_out(IR), .DR_out(DR),
    .IEN(IEN_out), .N(N), .Z(Z), .E(E), .FGI(FGI),
    .AR_ld(AR_ld), .PC_ld(PC_ld), .DR_ld(DR_ld), .AC_ld(AC_ld), .IR_ld(IR_ld), .TR_ld(TR_ld), .E_ld(E_ld), .IEN_ld(IEN_ld),
    .AR_incr(AR_incr), .PC_incr(PC_incr), .DR_incr(DR_incr), .AC_incr(AC_incr), .TR_incr(TR_incr), .E_incr(E_incr),
    .AR_clr(AR_clr), .PC_clr(PC_clr), .DR_clr(DR_clr), .AC_clr(AC_clr), .TR_clr(TR_clr), .E_clr(E_clr), .IEN_clr(IEN_clr)
);

endmodule