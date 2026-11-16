module adc_ctrl(
    input clk,
    input start,
    input comp,
    input max,
    output reg inc,
    output reg clr,
    output reg load
);
    /*
    Control FSM for the ADC. It has four states, and starts in IDLE:

    IDLE:   Waiting for a conversion to start. All outputs are 0.
            If start is high, go to SETTLE. Otherwise stay in IDLE.
    SETTLE: Gives the DAC and comparator a clock cycle to settle on the
            new voltage. All outputs are 0.
            If comp is high or max is high, go to DONE. Otherwise go to INC.
    INC:    inc is high, so the datapath adds 1 to dac. Always go to SETTLE.
    DONE:   load and clr are high, so the datapath saves the result and
            sets dac back to 0. Always go to IDLE.

    This holds each DAC value for two clock cycles (SETTLE and then INC or
    DONE), and samples the comparator on the clock edge in between.

    comp is the comparator output. It is high when the DAC output voltage
    is higher than the analog input voltage.
    max is high when dac is 31, so the conversion stops instead of wrapping
    around to 0 if the input is higher than the DAC can go.
    */
    //Do not modify above this line
    localparam IDLE = 2'd0;
    localparam SETTLE = 2'd1;
    localparam INC = 2'd2;
    localparam DONE = 2'd3;

    reg[1:0] state;
    reg[1:0] next_state;

    initial begin
        state = IDLE;
    end
    always @(posedge clk) begin
        state <= next_state;
    end

    always @* begin
        case(state)
                IDLE: begin
                        if(start)
                                next_state = SETTLE;
                        else
                                next_state = IDLE;
                end
                SETTLE: begin
                        if(comp || max)
                                next_state = DONE;
                        else
                                next_state = INC;
                end
                INC: begin
                        next_state = SETTLE;
                end
                DONE: begin
                        next_state = IDLE;
                end
                default: begin
                        next_state = IDLE;
                end
        endcase
    end

    // Output Logic - make output 1 based on current state
    always @* begin
        inc = (state == INC);
        clr = (state == DONE);
        load = (state == DONE);
    end
endmodule
