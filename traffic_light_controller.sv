module traffic_light_controller (
    input  logic clk,
    input  logic reset,
    input  logic TAORB,
    output logic [2:0] LA, LB 
);
    parameter RED    = 3'b100;
    parameter YELLOW = 3'b010;
    parameter GREEN  = 3'b001;

    typedef enum logic [1:0] {S0, S1, S2, S3} state_t;
    state_t current_state, next_state;

    logic [3:0] timer;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= S0; 
            timer <= 0;
        end else begin
            current_state <= next_state;
            if ((current_state == S1 && next_state == S1) || 
                (current_state == S3 && next_state == S3))
                timer <= timer + 1;
            else
                timer <= 0;
        end
    end

    always_comb begin
        case (current_state)
            S0: next_state = (~TAORB) ? S1 : S0;

            S1: next_state = (timer < 4) ? S1 : S2; 

            S2: next_state = (TAORB) ? S3 : S2;

            S3: next_state = (timer < 4) ? S3 : S0;
            
            default: next_state = S0;
        endcase
    end

    always_comb begin
        case (current_state)
            S0: {LA, LB} = {GREEN,  RED};    
            S1: {LA, LB} = {YELLOW, RED};    
            S2: {LA, LB} = {RED,    GREEN};  
            S3: {LA, LB} = {RED,    YELLOW}; 
            default: {LA, LB} = {RED, RED};
        endcase
    end
endmodule