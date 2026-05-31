// Week 2 — Register File (4 x 8-bit)
// regs[0]=A, regs[1]=B, regs[2]=C, regs[3]=D
// Reads: asynchronous | Write: synchronous, gated by we
// Run: iverilog -o sim ../testbenches/tb_regfile.v regfile.v && vvp sim

module regfile(
    input        clk, we,
    input  [1:0] raddr0, raddr1, waddr,
    input  [7:0] wdata,
    output [7:0] rdata0, rdata1
);

    reg [7:0] regs [3:0];

    integer i;
    initial begin
        for (i = 0; i < 4; i = i + 1)
            regs[i] = 8'h00;
    end

    always @(posedge clk) begin
        if (we)
            regs[waddr] <= wdata;
    end

    assign rdata0 = regs[raddr0];
    assign rdata1 = regs[raddr1];

endmodule
