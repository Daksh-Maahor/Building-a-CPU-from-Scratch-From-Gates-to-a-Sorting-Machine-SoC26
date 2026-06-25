// FSM with 2 states:
//   LEFT  - Lemming is walking left
//   RIGHT - Lemming is walking right

module lemmings_1(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    output walk_left,
    output walk_right
);

    parameter LEFT = 1'b0,
              RIGHT = 1'b1;

    reg state, next_state;

    always @(*) begin
        case (state)
            LEFT:  next_state = bump_left  ? RIGHT : LEFT;
            RIGHT: next_state = bump_right ? LEFT  : RIGHT;
            default: next_state = LEFT;
        endcase
    end

    always @(posedge clk or posedge areset) begin
        if (areset)
            state <= LEFT;
        else
            state <= next_state;
    end

    assign walk_left  = (state == LEFT);
    assign walk_right = (state == RIGHT);

endmodule

// FSM with 4 states:
//   LEFT       - Lemming is walking left on solid ground
//   RIGHT      - Lemming is walking right on solid ground
//   FALL_LEFT  - Lemming is falling, will resume walking left when it lands
//   FALL_RIGHT - Lemming is falling, will resume walking right when it lands

module lemmings_2(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    output walk_left,
    output walk_right,
    output aaah
);

    parameter LEFT       = 2'd0,
              RIGHT      = 2'd1,
              FALL_LEFT  = 2'd2,
              FALL_RIGHT = 2'd3;

    reg [1:0] state, next_state;

    always @(*) begin
        case (state)
            LEFT: begin
                if (!ground)
                    next_state = FALL_LEFT;
                else if (bump_left)
                    next_state = RIGHT;
                else
                    next_state = LEFT;
            end

            RIGHT: begin
                if (!ground)
                    next_state = FALL_RIGHT;
                else if (bump_right)
                    next_state = LEFT;
                else
                    next_state = RIGHT;
            end

            FALL_LEFT: begin
                if (ground)
                    next_state = LEFT;
                else
                    next_state = FALL_LEFT;
            end

            FALL_RIGHT: begin
                if (ground)
                    next_state = RIGHT;
                else
                    next_state = FALL_RIGHT;
            end

            default: next_state = LEFT;
        endcase
    end

    always @(posedge clk or posedge areset) begin
        if (areset)
            state <= LEFT;
        else
            state <= next_state;
    end

    assign walk_left  = (state == LEFT);
    assign walk_right = (state == RIGHT);

    assign aaah = (state == FALL_LEFT) ||
                  (state == FALL_RIGHT);

endmodule

// FSM with 6 states:
//   LEFT       - Lemming is walking left on solid ground
//   RIGHT      - Lemming is walking right on solid ground
//   FALL_LEFT  - Lemming is falling, will resume walking left when it lands
//   FALL_RIGHT - Lemming is falling, will resume walking right when it lands
//   DIG_LEFT   - Lemming is digging downward, was last walking left
//   DIG_RIGHT  - Lemming is digging downward, was last walking right

module lemmings_3(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging
);

    parameter LEFT       = 3'd0,
              RIGHT      = 3'd1,
              FALL_LEFT  = 3'd2,
              FALL_RIGHT = 3'd3,
              DIG_LEFT   = 3'd4,
              DIG_RIGHT  = 3'd5;

    reg [2:0] state, next_state;

    always @(*) begin
        case (state)

            LEFT: begin
                if (!ground)
                    next_state = FALL_LEFT;
                else if (dig)
                    next_state = DIG_LEFT;
                else if (bump_left)
                    next_state = RIGHT;
                else
                    next_state = LEFT;
            end

            RIGHT: begin
                if (!ground)
                    next_state = FALL_RIGHT;
                else if (dig)
                    next_state = DIG_RIGHT;
                else if (bump_right)
                    next_state = LEFT;
                else
                    next_state = RIGHT;
            end

            FALL_LEFT:
                next_state = ground ? LEFT : FALL_LEFT;

            FALL_RIGHT:
                next_state = ground ? RIGHT : FALL_RIGHT;

            DIG_LEFT:
                next_state = ground ? DIG_LEFT : FALL_LEFT;

            DIG_RIGHT:
                next_state = ground ? DIG_RIGHT : FALL_RIGHT;

            default:
                next_state = LEFT;
        endcase
    end

    always @(posedge clk or posedge areset) begin
        if (areset)
            state <= LEFT;
        else
            state <= next_state;
    end

    assign walk_left  = (state == LEFT);
    assign walk_right = (state == RIGHT);

    assign aaah =
        (state == FALL_LEFT) ||
        (state == FALL_RIGHT);

    assign digging =
        (state == DIG_LEFT) ||
        (state == DIG_RIGHT);

endmodule

// FSM with 7 states (plus a 5-bit fall counter):
//   LEFT       - Lemming is walking left on solid ground
//   RIGHT      - Lemming is walking right on solid ground
//   FALL_LEFT  - Lemming is falling, will resume walking left if fall <= 20 cycles
//   FALL_RIGHT - Lemming is falling, will resume walking right if fall <= 20 cycles
//   DIG_LEFT   - Lemming is digging downward, was last walking left
//   DIG_RIGHT  - Lemming is digging downward, was last walking right
//   SPLAT      - Lemming fell more than 20 cycles and hit the ground; all outputs
//                are 0 forever (terminal state, only areset can escape)

module lemmings_4(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging
);

    parameter LEFT       = 3'd0,
              RIGHT      = 3'd1,
              FALL_LEFT  = 3'd2,
              FALL_RIGHT = 3'd3,
              DIG_LEFT   = 3'd4,
              DIG_RIGHT  = 3'd5,
              SPLAT      = 3'd6;

    reg [2:0] state, next_state;
    reg [4:0] fall_count;

    always @(posedge clk or posedge areset) begin
        if (areset)
            fall_count <= 5'd0;
        else if (state == FALL_LEFT || state == FALL_RIGHT) begin
            if (fall_count < 5'd21)
                fall_count <= fall_count + 5'd1;
        end else
            fall_count <= 5'd0;
    end

    always @(*) begin
        case (state)
            LEFT: begin
                if (!ground)          next_state = FALL_LEFT;
                else if (dig)         next_state = DIG_LEFT;
                else if (bump_left)   next_state = RIGHT;
                else                  next_state = LEFT;
            end
            RIGHT: begin
                if (!ground)          next_state = FALL_RIGHT;
                else if (dig)         next_state = DIG_RIGHT;
                else if (bump_right)  next_state = LEFT;
                else                  next_state = RIGHT;
            end
            FALL_LEFT: begin
                if (!ground)                        next_state = FALL_LEFT;
                else if (fall_count >= 5'd20)       next_state = SPLAT;
                else                                next_state = LEFT;
            end
            FALL_RIGHT: begin
                if (!ground)                        next_state = FALL_RIGHT;
                else if (fall_count >= 5'd20)       next_state = SPLAT;
                else                                next_state = RIGHT;
            end
            DIG_LEFT:
                next_state = ground ? DIG_LEFT : FALL_LEFT;
            DIG_RIGHT:
                next_state = ground ? DIG_RIGHT : FALL_RIGHT;
            SPLAT:
                next_state = SPLAT;
            default:
                next_state = LEFT;
        endcase
    end

    always @(posedge clk or posedge areset) begin
        if (areset) state <= LEFT;
        else        state <= next_state;
    end

    assign walk_left  = (state == LEFT);
    assign walk_right = (state == RIGHT);
    assign aaah       = (state == FALL_LEFT)  || (state == FALL_RIGHT);
    assign digging    = (state == DIG_LEFT)   || (state == DIG_RIGHT);

endmodule
