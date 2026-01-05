module controller(
    input wire clock,
    input wire FGI,

    input wire [15:0] DR_out,
    input wire [15:0] IR_out,

    input wire N, Z,
    input wire E, IEN,

    output wire memory_write,
    output reg [2:0] bus_select, alu_op_select,

    output wire AR_ld, PC_ld, DR_ld, AC_ld, IR_ld, TR_ld,
    output wire AR_incr, PC_incr, DR_incr, AC_incr, TR_incr,
    output wire AR_clr, PC_clr, DR_clr, AC_clr, TR_clr,

    output wire E_ld, E_incr, E_clr,
    output wire IEN_ld, IEN_clr
);

wire ind;
reg halt = 1'b0;
wire R_data, R_ld, R_clr;
register #(1) R (.clock(clock),
    .reset(R_clr),
    .load(R_ld),
    .incr(1'b0),
    .input_data(1'b1),
    .register_out(R_data));

reg [7:0] T;
reg [3:0] T_current = 4'b0000;
wire [3:0] T_next; // initially T_next was a reg, but I changed it to wire, which is completely fine(I guess), to obtain RTL view on Quartus
wire T_ld, T_incr, T_clr;
register #(4) timing_signal (.clock(clock),
    .reset(T_clr),
    .load(T_ld),
    .incr(T_incr),
    .input_data(T_current),
    .register_out(T_next));

reg [7:0] op_code = 8'b00000000;

always @(posedge clock) begin
    if (!halt && T[3] && (IR_out == 16'h7001))
        halt <= 1'b1;
end

    // Encodings and decodings
always @(*) begin
    case (alu_operation)
        8'h01: alu_op_select = 3'b000;
        8'h02: alu_op_select = 3'b001;
        8'h04: alu_op_select = 3'b010;
        8'h08: alu_op_select = 3'b011;
        8'h10: alu_op_select = 3'b100;
        8'h20: alu_op_select = 3'b101;
        8'h40: alu_op_select = 3'b110;
        8'h80: alu_op_select = 3'b111;
        default: alu_op_select = 3'b000;
    endcase

    case (current_bus)
        8'h01: bus_select = 3'b000;
        8'h02: bus_select = 3'b001;
        8'h04: bus_select = 3'b010;
        8'h08: bus_select = 3'b011;
        8'h10: bus_select = 3'b100;
        8'h20: bus_select = 3'b101;
        8'h40: bus_select = 3'b110;
        8'h80: bus_select = 3'b111;
        default: bus_select = 3'b000;
    endcase
    
    case(T_next)
        3'b000: T = 8'h01;
        3'b001: T = 8'h02;
        3'b010: T = 8'h04;
        3'b011: T = 8'h08;
        3'b100: T = 8'h10;
        3'b101: T = 8'h20;
        3'b110: T = 8'h40;
        3'b111: T = 8'h80;
        default: T = 8'h00;
    endcase

    case(IR_out[14:12])
        3'b000: op_code = 8'h01;
        3'b001: op_code = 8'h02;
        3'b010: op_code = 8'h04;
        3'b011: op_code = 8'h08;
        3'b100: op_code = 8'h10;
        3'b101: op_code = 8'h20;
        3'b110: op_code = 8'h40;
        3'b111: op_code = 8'h80;
        default: op_code = 8'h00;
    endcase
end

// op_code definitions, easier to follow the code
wire AND    = op_code[0];
wire ADD    = op_code[1];
wire LDA    = op_code[2];
wire STA    = op_code[3];
wire BUN    = op_code[4];
wire BSA    = op_code[5];
wire ISZ    = op_code[6];
wire REGREF = op_code[7];

// ALU and bus selections, I tried to make them through reg's however I couldn't manage to implement them, so I just used the wire way
wire [7:0] alu_operation;
assign alu_operation[0] = T[5] & AND;
assign alu_operation[1] = T[5] & ADD;
assign alu_operation[2] = T[5] & LDA;
assign alu_operation[3] = T[3] & (IR_out == 16'h7200);
assign alu_operation[4] = T[3] & (IR_out == 16'h7080);
assign alu_operation[5] = T[3] & (IR_out == 16'h7040);
assign alu_operation[6] = T[4] & LDA;
assign alu_operation[7] = 1'b0;

wire [7:0] current_bus;
assign current_bus[0] = 1'b0;
assign current_bus[1] = (T[4] & BUN) | (T[5] & BSA);
assign current_bus[2] = (T[0] & ~halt & ~R_data) |
                        (T[4] & BSA)             |
                        (T[0] & ~halt &  R_data);
assign current_bus[3] = T[6] & ISZ;
assign current_bus[4] = T[4] & STA;
assign current_bus[5] = T[2] & ~R_data;
assign current_bus[6] = T[1] & R_data;
assign current_bus[7] = (T[1] & ~R_data) |
                        (T[3] & ~REGREF & IR_out[15]) |
                        (T[4] & AND) | (T[4] & ADD) | (T[4] & LDA) | (T[4] & ISZ);

// memory write
assign memory_write = (T[1] & R_data) |
                      (T[4] & STA)    |
                      (T[4] & BSA)    |
                      (T[6] & ISZ);
                    
// load signals
assign AR_ld  = (T[3] & ~REGREF & IR_out[15]) | ( (~R_data) & ( (T[0] & ~halt) | T[2] ) );
assign PC_ld  = (T[4] & BUN) | (T[5] & BSA);
assign DR_ld  = (T[4] & AND) |
                (T[4] & ADD) |
                (T[4] & LDA) |
                (T[4] & ISZ);
assign AC_ld  = (T[5] & AND) |
                (T[5] & ADD) |
                (T[5] & LDA) | (T[3] & ( (IR_out == 16'h7200) | (IR_out == 16'h7080) | (IR_out == 16'h7040) ));
assign IR_ld  = T[1] & ~R_data;
assign TR_ld  = T[0] & ~halt & R_data;
assign E_ld   = (T[5] & ADD) | (T[3] & ( (IR_out == 16'h7080) | (IR_out == 16'h7040) ));
assign IEN_ld = T[3] & (IR_out == 16'hF080);
assign R_ld   = (~T[0] & ~T[1] & ~T[2] & ~halt) & FGI & IEN;

// increment signals
assign AR_incr = T[4] & BSA;
assign PC_incr = (T[6] & ISZ & (DR_out == 16'h0000)) | 
                 (T[3] & ((IR_out == 16'h7010 & ~N) | (IR_out == 16'h7008 &  N) | (IR_out == 16'h7004 &  Z) | (IR_out == 16'h7002 & ~E))) |
                 (T[1] & ~R_data) | (T[2] &  R_data);
assign DR_incr = T[5] & ISZ;
assign AC_incr = T[3] & (IR_out == 16'h7020);
assign TR_incr = 1'b0;
assign E_incr  = T[3] & (IR_out == 16'h7300);
assign T_incr  = ~T_clr;

// clear signals
assign AR_clr  = T[0] & ~halt & R_data;
assign PC_clr  = T[1] & R_data;
assign DR_clr  = 1'b0;
assign AC_clr  = T[3] & (IR_out == 16'h7800);
assign TR_clr  = 1'b0;
assign E_clr   = T[3] & (IR_out == 16'h7400);
assign IEN_clr = (T[2] & R_data) | (T[3] & (IR_out == 16'hF040));
assign T_clr   = (T[2] & R_data) |(T[5] & AND) | (T[5] & ADD) |
                 (T[5] & LDA) | (T[4] & STA) | (T[4] & BUN) |
                 (T[5] & BSA) | (T[6] & ISZ) | (T[3] & REGREF) | halt;
assign R_clr   = T[2] & R_data;

endmodule