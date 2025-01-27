//#include <stdbool.h>
//#include <stdint.h>
//#include <stddef.h>

typedef struct CCAsyncBot CCAsyncBot;

typedef struct CCBook CCBook;

typedef enum CCPiece {
    CC_I, CC_O, CC_T, CC_L, CC_J, CC_S, CC_Z
} CCPiece;

typedef enum CCTspinStatus {
    CC_NONE_TSPIN_STATUS,
    CC_MINI,
    CC_FULL,
} CCTspinStatus;

typedef enum CCMovement {
    CC_LEFT, CC_RIGHT,
    CC_CW, CC_CCW,
    /* Soft drop all the way down */
    CC_DROP
} CCMovement;

typedef enum CCMovementMode {
    CC_0G,
    CC_20G,
    CC_HARD_DROP_ONLY
} CCMovementMode;

typedef enum CCSpawnRule {
    CC_ROW_19_OR_20,
    CC_ROW_21_AND_FALL,
} CCSpawnRule;

typedef enum CCBotPollStatus {
    CC_MOVE_PROVIDED,
    CC_WAITING,
    CC_BOT_DEAD
} CCBotPollStatus;

typedef enum CCPcPriority {
    CC_PC_OFF,
    CC_PC_FASTEST,
    CC_PC_ATTACK
} CCPcPriority;

typedef struct CCPlanPlacement {
    CCPiece piece;
    CCTspinStatus tspin;

    /* Expected cell coordinates of placement, (0, 0) being the bottom left */
    uint8_t expected_x[4];
    uint8_t expected_y[4];

    /* Expected lines that will be cleared after placement, with -1 indicating no line */
    int32_t cleared_lines[4];
} CCPlanPlacement;

typedef struct CCMove {
    /* Whether hold is required */
    bool hold;
    /* Expected cell coordinates of placement, (0, 0) being the bottom left */
    uint8_t expected_x[4];
    uint8_t expected_y[4];
    /* Number of moves in the path */
    uint8_t movement_count;
    /* Movements */
    CCMovement movements[32];

    /* Bot Info */
    uint32_t nodes;
    uint32_t depth;
    uint32_t original_rank;
} CCMove;

typedef struct CCOptions {
    CCMovementMode mode;
    CCSpawnRule spawn_rule;
    CCPcPriority pcloop;
    uint32_t min_nodes;
    uint32_t max_nodes;
    uint32_t threads;
    bool use_hold;
    bool speculate;
} CCOptions;

typedef struct CCWeights {
    int32_t back_to_back;
    int32_t bumpiness;
    int32_t bumpiness_sq;
    int32_t row_transitions;
    int32_t height;
    int32_t top_half;
    int32_t top_quarter;
    int32_t jeopardy;
    int32_t cavity_cells;
    int32_t cavity_cells_sq;
    int32_t overhang_cells;
    int32_t overhang_cells_sq;
    int32_t covered_cells;
    int32_t covered_cells_sq;
    int32_t tslot[4];
    int32_t well_depth;
    int32_t max_well_depth;
    int32_t well_column[10];

    int32_t b2b_clear;
    int32_t clear1;
    int32_t clear2;
    int32_t clear3;
    int32_t clear4;
    int32_t tspin1;
    int32_t tspin2;
    int32_t tspin3;
    int32_t mini_tspin1;
    int32_t mini_tspin2;
    int32_t perfect_clear;
    int32_t combo_garbage;
    int32_t move_time;
    int32_t wasted_t;

    bool use_bag;
    bool timed_jeopardy;
    bool stack_pc_damage;
} CCWeights;

/* Launches a bot thread with a blank board, all seven pieces in the bag, and the specified queue
 * using the specified options and weights.
 *
 * You must pass the returned pointer with `cc_destroy_async` when you are done with the bot
 * instance.
 * 
 * If `count` is not 0, `queue` must not be `NULL`.
 * `book` may be `NULL` to indicate that no book should be used.
 * The book may be destroyed at any time after this function returns.
 * 
 * Lifetime: The returned pointer is valid until it is passed to `cc_destroy_async`.
 * 
 * 译：
 * 启动一个初始场地为空，特定序列，7块一包的 bot 线程，该线程使用特定设定与权重。
 * 该函数返回一指针，销毁对应的 bot 时，须将该指针传入 `cc_destroy_async` 函数。
 * 如果 `count` 不是0, `queue` 必须不能是 `NULL`。
 * `book` 可以是 `NULL`，以暗示 bot 无需使用棋谱。
 * 棋谱可能在该函数返回变量之后随时被销毁。
 * 
 * 生命周期：返回的指针直到被传进 `cc_destroy_async` 函数前一直有效。
*/
CCAsyncBot *cc_launch_async(CCOptions *options, CCWeights *weights, CCBook *book, CCPiece *queue,
    uint32_t count);

/* Launches a bot thread with a predefined field, empty queue, remaining pieces in the bag, hold
 * piece, back-to-back status, and combo count. This allows you to start CC from the middle of a
 * game.
 * 
 * The bag_remain parameter is a bit field indicating which pieces are still in the bag. Each bit
 * correspond to CCPiece enum. This must match the next few pieces provided to CC via
 * cc_add_next_piece_async later.
 * 
 * The field parameter is a pointer to the start of an array of 400 booleans in row major order,
 * with index 0 being the bottom-left cell.
 * 
 * The hold parameter is a pointer to the current hold piece, or `NULL` if there's no hold piece
 * now.
 * 
 * If `count` is not 0, `queue` must not be `NULL`.
 * `book` may be `NULL` to indicate that no book should be used.
 * The book may be destroyed at any time after this function returns.
 * 
 * Lifetime: The returned pointer is valid until it is passed to `cc_destroy_async`.
 *
 * 译：
 * 启动一个 bot 线程，包含预定义的场地、空队列、一包中剩下的块、暂存的块、B2B 状态和连击计数。
 * 该函数允许你从游戏中局时启动 CC。
 * 
 * 参数 bag_remain 是一个位字段，表示哪些块仍然在包里。每个比特对应 CCPiece 枚举值。
 * 该参数必须与稍后通过 cc_add_next_piece_async 提供给 CC 的接下来几块相匹配。
 * 
 * 参数 field 是一个指针，指向按行主顺序排列的 400 个布尔值的数组的开头，其中索引 0 是左下角的单元格。
 * （场地用一个大小为 400 的数组表示，索引 0 是左下角的格子，从左往右从下往上依次排序，例如第 5 行第 2 列对应的索引是 51）
 * 
 * 参数 hold 是一个指向当前暂存块的指针，没有暂存块则为 `NULL`。

 * （剩下的与前面那个函数相同）
 */
CCAsyncBot *cc_launch_with_board_async(CCOptions *options, CCWeights *weights, CCBook *book,
    bool *field, uint32_t bag_remain, CCPiece *hold, bool b2b, uint32_t combo, CCPiece *queue,
    uint32_t count);

/* Terminates the bot thread and frees the memory associated with the bot.
 */
void cc_destroy_async(CCAsyncBot *bot);

/* Resets the playfield, back-to-back status, and combo count.
 * 
 * This should only be used when garbage is received or when your client could not place the
 * piece in the correct position for some reason (e.g. 15 move rule), since this forces the
 * bot to throw away previous computations.
 * 
 * Note: combo is not the same as the displayed combo in guideline games. Here, it is the
 * number of consecutive line clears achieved. So, generally speaking, if "x Combo" appears
 * on the screen, you need to use x+1 here.
 * 
 * The field parameter is a pointer to the start of an array of 400 booleans in row major order,
 * with index 0 being the bottom-left cell.
 * 
 * 译：
 * 重置场地、B2B 状态和连击计数。
 * 
 * 该函数只能在场地收到垃圾，或你的 client(?) 因某些原因（例如，15 次移动重置用完了）未将方块放入正确位置时使用，
 * 因为这时必须让 bot 丢弃先前的运算结果。
 * 
 * 注：combo 不是准则方块游戏里显示的那个连击数，在此它代表连续消行的次数（消几次就是几 combo）。
 * 所以一般来说，如果屏幕上显示“x 连击”，你应当在此处使用 x+1。
 * 
 * field 参数是一个指针，与前述的 field 指针相同。
 */
void cc_reset_async(CCAsyncBot *bot, bool *field, bool b2b, uint32_t combo);

/* Adds a new piece to the end of the queue.
 * 
 * If speculation is enabled, the piece must be in the bag. For example, if you start a new
 * game with starting sequence IJOZT, the first time you call this function you can only
 * provide either an L or an S piece.
 * 
 * 译：
 * 将新的一块放进 next 序列末尾。
 * 
 * 若启用 speculation（预测），这一块必须在当前的包内。
 * 例如，你开了把新游戏，起始序列是 IJOZT，第一次调用该函数时你只能提供 L 或者 S 块。
 */
void cc_add_next_piece_async(CCAsyncBot *bot, CCPiece piece);

/* Request the bot to provide a move as soon as possible.
 * 
 * In most cases, "as soon as possible" is a very short amount of time, and is only longer if
 * the provided lower limit on thinking has not been reached yet or if the bot cannot provide
 * a move yet, usually because it lacks information on the next pieces.
 * 
 * For example, in a game with zero piece previews and hold enabled, the bot will never be able
 * to provide the first move because it cannot know what piece it will be placing if it chooses
 * to hold. Another example: in a game with zero piece previews and hold disabled, the bot
 * will only be able to provide a move after the current piece spawns and you provide the piece
 * information to the bot using `cc_add_next_piece_async`.
 * 
 * It is recommended that you call this function the frame before the piece spawns so that the
 * bot has time to finish its current thinking cycle and supply the move.
 * 
 * Once a move is chosen, the bot will update its internal state to the result of the piece
 * being placed correctly and the move will become available by calling `cc_poll_next_move`.
 * 
 * The incoming parameter specifies the number of lines of garbage the bot is expected to receive
 * after placing the next piece.
 * 
 * 译：
 * 要求 bot 尽快提供如何移动当前方块（下一步）。
 * 
 * 大多数情况下，“尽快” 是一段非常短的时间，
 * 并且只有当提供的思考下限尚未达到或机器人还不能提供下一步时才会更长，通常是因为它缺少下一块的信息。
 * 
 * 例如，在一场没有预览、启用暂存的游戏里，bot 永远不可能提供第一块怎么放，
 * 因为如果它选择了暂存，它无法知道下一块该放在哪里。
 * 又例如，在一场没有预览、禁用暂存的游戏里，bot 只能在当前块出现，并且你使用 `cc_add_next_piece_async` 传给 bot 信息后，提供一步。
 * 
 * 建议您在方块生成前调用此函数，以便 bot 有时间完成其当前的思考周期并提供下一步。
 * 
 * 一旦选择了某个移动，机器人就会将其内部状态更新为方块被正确放置的结果。
 * 通过调用 `cc_poll_next_move`，使这一步变为可用。
 * 
 * 参数 incoming 表示下一块放置后 bot 收到的垃圾行数量。
 */
void cc_request_next_move(CCAsyncBot *bot, uint32_t incoming);

/* 检查机器人是否已提供先前要求的一步。
 * 
 * 返回的移动包含路径和放置方块的预期位置。
 * 返回的路径相当不错，但你可能希望使用自己的路径查找器，例如，利用正在玩的游戏中复杂的移动。
 * 
 * 若方块未按预期位置摆放，须调用 `cc_reset_async` 重置场地、B2B 状态和连击计数。
 * 
 * 如果 `plan` 和 `plan_length` 都不是 `NULL` ，且该函数提供了一步，一个摆放计划将返回到指向的数组中。
 * `plan_length` 应该指向数组的长度，并且提供的计划位置数量将通过此指针返回。
 * 
 * 若 bot 已提供这一步，该函数返回 `CC_MOVE_PROVIDED`；
 * 若 bot 暂未提供结果，该函数返回 `CC_WAITING`；
 * 若 bot 发现自己无法生存，该函数返回 `CC_BOT_DEAD`。
 */
CCBotPollStatus cc_poll_next_move(
    CCAsyncBot *bot,
    CCMove *move,
    CCPlanPlacement* plan,
    uint32_t *plan_length
);

/* This function is the same as `cc_poll_next_move` except when `cc_poll_next_move` would return
 * `CC_WAITING` it instead waits until the bot has made a decision.
 *
 * If the move has been provided, this function will return `CC_MOVE_PROVIDED`.
 * If the bot has found that it cannot survive, this function will return `CC_BOT_DEAD`
 * 
 * 译：
 * 
 * 该函数与 `cc_poll_next_move` 类似，但它在 bot 暂未提供结果时会硬等，直到 bot 做出抉择。
 * 
 * 若 bot 已提供这一步，该函数返回 `CC_MOVE_PROVIDED`；
 * 若 bot 暂未提供及如果，该函数返回 `CC_WAITING`；
 * 若 bot 发现自己无法生存，该函数返回 `CC_BOT_DEAD`。
 */
CCBotPollStatus cc_block_next_move(
    CCAsyncBot *bot,
    CCMove *move,
    CCPlanPlacement* plan,
    uint32_t *plan_length
);

/* Returns the default options in the options */
/* 在参数 options 中返回默认设定 */
void cc_default_options(CCOptions *options);

/* Returns the default weights in the weights parameter */
/* 在参数 weights 中返回默认权重 */
void cc_default_weights(CCWeights *weights);

/* Returns the fast game config weights in the weights parameter */
/* 在参数 weights 中返回较快速的权重配置 */
void cc_fast_weights(CCWeights *weights);

/*
 * Loads an opening book from the specified file path.
 * This supports both `.ccbook` and `.ccdb` books.
 * If an error occurs, `NULL` is returned instead.
 * 
 * Lifetime: The returned pointer is valid until it is passed to `cc_destroy_book`.
 */
CCBook *cc_load_book_from_file(const char *path);

/*
 * Loads an opening book from the specified book file contents.
 * This only supports `.ccbook` books.
 * If an error occurs, `NULL` is returned instead.
 * 
 * Lifetime: The returned pointer is valid until it is passed to `cc_destroy_book`.
 */
CCBook *cc_load_book_from_memory(uint8_t *data, uint32_t length);

/* Unloads a previously loaded book. */
void cc_destroy_book(CCBook *book);
