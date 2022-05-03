module counter #(parameter QUEUE_SIZE = 32'hffffffff) (
  input clock,
  input reset,
  input increment,
  input decrement,
  output full,
  output empty
);
logic increment;
logic decrement;
logic full;
logic empty;
logic [31:0] count;

always @(posedge clock) begin
  if(reset) begin 
    count <= 32'b0;
    full <= 1'b0;
    empty <= 1'b1;
  end
  else begin
    /*
    * Increment given precendence over decrement if both are asserted simultaneously
    * Counter may overflow or underflow
    */
    if(increment) count <= count + 1'b1;
    else if(decrement) count <= count - 1'b1;
    if(count == QUEUE_SIZE) full <= 1'b1;
    else full <= 1'b0;
    if(count == 32'b0) empty <= 1'b1;
    else empty <= 1'b0;
  end
end

endmodule