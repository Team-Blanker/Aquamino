local FFI=require'ffi'

local bot=FFI.load(fs.getSaveDirectory()..'/bot/dllai.dll')
FFI.cdef([[
char* TetrisAI(int overfield[], int field[], int field_w, int field_h, int b2b, int combo,
               char next[], char hold, bool curCanHold, char active, int x, int y, int spin,
               bool canhold, bool can180spin, int upcomeAtt, int comboTable[], int maxDepth, int level, int player);
]])
--print(bot.TetrisAI)