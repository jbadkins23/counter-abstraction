module abstract_counter #(parameter QUEUE_SIZE = 32'hffffffff) (
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

enum logic [1:0] {EMPTY, INTERMEDIATE, FULL} state_count;
logic free_1_above_empty;
logic free_1_below_full;

always @(posedge clock) begin
  if(reset) begin 
    state_count <= EMPTY;
    full <= 1'b0;
    empty <= 1'b1;
    count <= 32'b0;
  end
  else begin
    /*
    * Increment given precendence over decrement if both are asserted simultaneously
    * Counter may overflow or underflow
    */
    case (state_count) 
      EMPTY : begin
        empty <= 1'b1;
        full <= 1'b0;
        if(increment) begin 
          state_count <= INTERMEDIATE;
          count <= 1'b1;
        end
        // Underflow
        else if (decrement) begin
          state_count <= FULL;
          count <= QUEUE_SIZE;
        end
      end
      INTERMEDIATE : begin
        empty <= 1'b0;
        full <= 1'b0;
        if(increment && free_1_below_full) begin
          state_count <= FULL;
          count <= QUEUE_SIZE;
        end
        else if(increment) state_count <= INTERMEDIATE;
        else if(decrement && free_1_above_empty) begin
          state_count <= EMPTY;
          count <= 32'b0;
        end
        else if(decrement) state_count <= INTERMEDIATE;
      end
      FULL : begin
        empty <= 1'b0;        
        full <= 1'b1;
        // Overflow
        if (increment) begin
          state_count <= EMPTY;
          count <= 32'b0;
        end
        else if(decrement) begin
          state_count <= INTERMEDIATE;
          count <= 32'b1;
        end
      end
      default : begin
        state_count <= state_count;
      end
    endcase
  end
end

endmodule