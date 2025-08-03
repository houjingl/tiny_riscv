module ff_en (
  input wire clk,
  input wire en,
  input wire rstn,
  input wire [31:0] d,
  output reg [31:0] q
);

always @(posedge clk) begin
  if (!rstn) begin
    q <= 32'b0;
  end 
  else if (en) begin
    q <= d;
  end
end

endmodule