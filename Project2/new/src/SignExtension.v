 `timescale 1ns/1ps
module SignExtension (
    input  wire [5:0]  immediate,
    input  wire        mode,  // 1 => sign-extend, 0 => zero-extend
    output wire [15:0] extended_immediate
);
    assign extended_immediate = (mode)
        ? {{10{immediate[5]}}, immediate}
        : {10'b0, immediate};
endmodule
