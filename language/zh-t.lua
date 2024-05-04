return {
     warning={
         title="光敏性癲癇警告",
         txt="極小部分人可能會在看到特定視覺圖像（包括可能出現在電玩遊戲中的閃爍效果或圖案）時出現癲癇症狀。 \n此類症狀包括頭暈目眩、視線模糊、眼睛或臉部抽搐、四肢抽搐、迷失方向感、精神錯亂或短暫的意識喪失。 \n\n即使沒有癲癇史的人也可能出現此類症狀。 \n如果你出現任何上述症狀，請立即停止遊戲並儘快就醫。",
         txtScale=50/128,txtWidth=4000
     },
     modeName={
         ['40 lines']="40行",
         marathon="馬拉松",
         ['ice storm']="冰風暴",
         thunder="雷暴",
         smooth="絲滑40行",
         levitate="懸浮 40行",
         master="大師",
         multitasking="雙線程",
         sandbox="沙盒",
         ['dig 40']="挖掘 40行",
         laser="雷射",
         conf_test="設定 - 測試介面",
         idea_test="idea_test"
     },
     intro={
         start="按任一鍵開始",
         mode={"練習","挑戰","祕境","理堂"}
     },
     menu={
         illust="雙擊/按Enter鍵開始遊戲\n按R鍵隨機跳轉",
         iScale=.6
     },
     pause={
         resume="繼續",quit="退出",r="重開"
     },
     game={
         nowPlaying="目前播放 : ",
         paused="暫停",result="遊戲結束",
         theme={
             simple={win="勝利",lose="失敗"}
         }
     },
     conf={
         back="返回",test="測試",
         main={title="設定 - 首頁",audio="音訊設定",video="畫面設定",custom="主题設定",ctrl="控制設定",keys="鍵位設定",other=" 其它..."},
         audio={mus="音樂音量:",sfx="音效音量:",distract="失去焦點自動靜音",DOX=0},
         video={
             unableBG="禁用遊戲背景",unableTxt="若遊戲背景導致你身體不適，請開啟此選項。",
             fullScr="全螢幕",fullScrTxt="按F11可一鍵切換視窗狀態。",
             vsync="垂直同步",vsyncTxt="若感覺畫面嚴重撕裂，請嘗試調整此選項。一般不建議打開。",
             frameLim="最高繪製幀率:",frameTxt="建議將該值調整為與顯示器幀率相等。"
         },
         custom={
             texture="方塊材質",color="顏色設定",
             smooth="平滑運動[測試]",smoothTxt="注意，移動和旋轉沒有中間態，只要終點沒有障礙，操作就必定可以成功。",
             smoothOffX=0,smoothOffY=0,
             theme="主題",
             scale="場地縮放",scaleTxt="數值為1時，對於1920*1080的窗口，單元方塊大小為36*36。",
             sfx="音效包",sfxWarning={
                 otto="此音效包包含音量過大內容，謹慎選擇。"
             },
             colorSet={
                 title="調整方塊顏色",
                 rAll="重置所有",rCur="重置目前",
                 adjY="該皮膚可自由調整顏色。",
                 adjN="該皮膚不可調整顏色。"
             }
         },
         keys={
             keyName={'左移','右移','順轉','逆轉','翻轉','軟降','硬降','暫存','重開','暫停'} ,
             kScale=.5,
             info="點選新增鍵位綁定（最多3個）\nBackspace清空選定鍵位\n按下已綁定鍵位以刪除該綁定"
         },
         handling={
             ASD="自動移動延遲(ASD,舊稱DAS):",ASP="自動移動週期(ASP,舊稱ARR):",
             SD_ASD="軟降ASD:",SD_ASP="軟降ASP:"
         },
         other={title="其它設定",nothing="暫無內容"},
         lang={cur="當前語言：繁體中文"}
     },

     rule={
         dig={remain="剩餘行數",piece="使用塊數"}
     },

     tip={
        "Push是什麼 不知道",
        "賣弱的一律當5pps處理",
        "狗都sub30了",
        "c4w，爽！",
        "Lua天下第一！",
        "海蘭就是個彩筆打塊的，懂什麼代碼",
        "Bad argument #6623:Attempt to compare number with nil",
        "我是一條湊數tip",
        "你說得對，但是…",
        "打SDPC不接DPC，那我缺的這個spike這塊誰給我補啊",
        "這是海蘭，既沒實力又不可愛，只會在tip裡口嗨",
        "反正我不是第一個往方塊遊戲加tip的",
        "A Project 由 TEAM BLANKER",
        "遊戲的生日？2023年暑假的時候開發的，就定在8月14日吧",
        "Z醬銳評：「抄鐵殼抄的挺到位的」",
        "Carbon Fibre方塊皮膚的靈感來自於碳纖維貼紙魔術方塊",
        "Aquamino特色推箱",
        "雖然名字是水，但海蘭可不保證每個模式都和水有關係",
        "本遊戲的SRS經過修改，I旋對稱，並且加入了180°踢牆",
        "冰風暴模式來自於寶石迷陣3的同名模式",
        "在Aquamino，你可以做到T旋消四！",
        "最好不要在遊玩的時候拖曳遊戲視窗",
        "唉，weak table",
        "腦袋空空…",
        "少打方塊多讀書",
        "遠離現充。"
     },tipScale=.4,
     territory={info="空格/Enter 切換暫停/運轉狀態\nesc 退出"}
}