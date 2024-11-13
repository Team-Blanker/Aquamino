return {
    warning={
        title="光敏性癲癇警告",
        txt="極小部分人可能會在看到特定視覺圖像（包括可能出現在電玩遊戲中的閃爍效果或圖案）時出現癲癇症狀。 \n此類症狀包括頭暈目眩、視線模糊、眼睛或臉部抽搐、四肢抽搐、迷失方向感、精神錯亂或短暫的意識喪失。 \n\n即使沒有癲癇史的人也可能出現此類症狀。 \n如果你出現任何上述症狀，請立即停止遊戲並儘快就醫。",
        txtScale=50/128,txtWidth=4000
    },
    modeName={
        ['40 lines']="40 行競速",
        marathon="馬拉松",
        ['ice storm']="冰風暴",
        thunder="雷暴",
        smooth="絲滑 40 行",
        levitate="懸浮 40 行",
        square="正方拼合",
        master="大師",
        multitasking="雙線程",
        sandbox="沙盒",
        ['dig 40']="挖掘 40 行",
        laser="激光",
        backfire="回旋鏢",
        battle="對戰",
        ['tower defense']="塔防",
        conf_test="設定 - 測試介面",
        idea_test="idea_test",

        ['core destruction']="[已廢棄模式]"
    },
    modeDescription={
        ['40 lines']="以最快速度消除40行",
        marathon={{1,1,1},"消除150行，但方塊下落越來越快\n",{1,1,0},"參數限製：ASD=150ms ASP=30ms 軟降ASP=30ms\n重力隨等級提升而增大"},
        ['ice storm']="利用All-spin機制抵禦上升的冰柱！",
        thunder="應對雷電的破壞",
        smooth={{1,1,1}," 眞的有這麽絲滑嗎？\n",{1,1,0},"降落延遲爲0，鎖定延遲增加至3秒"},
        levitate={{1,1,0},"消除后場地内磚格不掉落"},
        square={{1,1,1}," 你能在3分鐘内拼出多少4×4正方形？"},
        master={{1,1,1}," 在最高下落速度下極限堆疊！\n",{1,.5,0},"降落延遲爲0，鎖定延遲隨等級提升縮短\n",{1,1,0},"參數限製：ASD=150ms ASP=30ms"},
        multitasking={{1,1,1},"*Galaxy Brain Meme*\n",{1,1,0},"參數限製：ASD=150ms ASP=30ms 軟降ASP=30ms\n重力隨等級提升而增大"},
        sandbox={{1,1,0},"該模式不記錄成績"},
        ['dig 40']="靜心思考，高傚挖掘",
        laser={{1,1,1},"做人不要太攀比，踏踏實實做自己\n如果非要比一比，那就比比激光雨\n",{1,1,0},"節奏模式，强烈建議開啓音樂游玩"},
        backfire="吃下自己打出的攻擊",
        battle={{1,1,1}," 戰鬥，爽！\n",{1,1,0},"該模式不記錄成績"},
        ['tower defense']={{1,1,0},"該模式不記錄成績\n",{1,.2,.2}," 该模式不稳定。\n 啓動/重開該模式可能會讓程式卡死。"}
    },
    intro={
        start="按任一鍵開始",
    },
    menu={
        bestScore="最佳成績",
        noBestScore="暫無成績",
        arg={
            battle={
                bot_PPS="機器人PPS",
                player={
                    pos="玩家位置",
                    left="左侧",
                    right="右侧"
                }
            },
            ['tower defense']={
                bot_PPS="機器人PPS",
                player={
                    pos="玩家位置",
                    left="左侧",
                    right="右侧"
                }
            }
        }
    },
    about={
        engineText="使用LÖVE引擎製作",
        tool="使用工具",
        repo="使用庫",
        time="游戲運行次數 : %d\n縂運行時間 : %d 秒",
        staff="製作人員"
    },
    staff={
        program="程序",
        UI="UI & 視覺設計",
        music="音樂来自", hurtRecord="来自 HURT RECORD (https://www.hurtrecord.com) :",
        sfx="音效",
        translate="翻譯 & 本地化",
        specialThanks="特別感謝",
        tester="以及其他所有内測成員"
    },
    pause={
        resume="繼續",back="返回",r="重開"
    },
    game={
        nowPlaying="目前播放 : ",
        paused="暫停",result="遊戲結束",
        theme={
            simple={win="勝利",lose="失敗",newRecord="打破紀錄"}
        }
    },
    conf={
        test="測試",
        main={title="設定 - 首頁",audio="音頻設定",video="畫面設定",custom="主题設定",handling="控制設定",keys="鍵位設定"},
        audio={mus="音樂音量",distract="失去焦點自動靜音",DOX=0,
            sfx="音效音量",stereo="立体声"
        },
        video={
            unableBG="禁用遊戲背景",
            BGset="游戲背景設定...",
            fullScr="全螢幕",fullScrTxt="按F11可一鍵切換視窗狀態。",
            vsync="垂直同步",
            vsyncTxt="本程式繪製代碼與運算代碼形式上分離，稱繪製幀率為FPS，運算幀率為TPS。\n若設定的最高FPS小於等於垂直同步限制的FPS，則TPS不受限。\n本程式主要考慮PC端運行情況，該選項預設為關閉。\n低性能設備可開啟此選項優化運算代碼運行。",
            discardAfterDraw="顯存回收加速",
            DADTxt="每幀繪製完成后立刻回收對應顯存。用于移動端优化。",
            moreParticle="更多粒子特效",
            frameLim="最高繪製幀率",frameTxt="建議將該值調整為與顯示器幀率相等。"
        },
        custom={
            texture="方塊材質",color="方塊配色...",
            RS="旋轉系統",
            smooth="平滑運動",
            smoothTime="動畫時長",
            boardBounce="版面晃动...",
            theme="版面風格",
            scale="版面縮放",scaleTxt="單元方塊大小：",
            sfx="音效包",sfxWarning={
                otto="此音效包包含音量過大內容，謹慎選擇。"
            },
            colorSet={
                title="調整方塊顏色",
                rAll="重置所有",rCur="重置目前",
                adjY="該材質可自由調整顏色。",
                adjN="該材質不可調整顏色。"
            },
            boardSet={
                title="版面晃动",

                presetLevel="預設等級",

                moveForce="移動推力",
                dropVel="硬降動量",
                clearFactor="消除動量倍率",
                velDamping="平移阻尼",
                elasticFactor="平移彈性係數",

                spinAngvel="扭轉角动量",
                angDamping="扭轉阻尼",
                spinFactor="扭轉彈性係數",
            }
        },
        keys={
            keyName={'左移','右移','順轉','逆轉','180°轉','軟降','硬降','暫存','重開','暫停'} ,
            kScale=.5,
            info="點選新增鍵位綁定 (最多3個)\nBackspace清空選定鍵位\n按下已綁定鍵位以刪除該綁定",
            virtualKey="觸控設定..."
        },
        virtualKey={
            enable="啓用虛擬擊鍵",enableTxtScale=.25,
            anim="按鈕動畫",animTxtScale=.25,
            preset="预設...",
            btsz="大小",
            tolerance="容錯",
            attach="網格對齊"
        },
        handling={
            ASD="自動移動延遲(ASD,舊稱DAS)",ASP="自動移動週期(ASP,舊稱ARR)",
            SD_ASD="軟降ASD",SD_ASP="軟降ASP"
        },
        other={title="其它設定",nothing="暫無內容"},
        lang={cur="當前語言：繁體中文"}
    },

    rule={
        dig={remain="剩餘行數",piece="使用塊數"},
        backfire={remain="剩餘垃圾行數",eff="效率"},
        square={time="剩餘时间",amount="構造正方數",remainTime={"2 分鐘","1 分鐘","30 秒"}}
    },

    tip={
        "Push是什麼 不知道",
        "賣弱的一律當5pps處理",
        "狗都sub30了",
        "c4w，爽！",
        "Lua天下第一！",
        "海蘭就是個彩筆打塊的，懂什麼代碼",
        "Bad argument #6623Attempt to compare number with nil",
        "Aquad = Aqua + Quad",
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
        "唉，weak table",
        "腦袋空空…",
        "少打方塊多讀書",
        "遠離現充。",
        "a and b or c and d or e and f or g",

        "任意五連塊均可以周期性密鋪整個平面"
    },tipScale=.4,
    territory={info="空格/Enter 切換暫停/運轉狀態\nesc 退出"},
    tracks={info="空格/Enter 切換暫停/運轉狀態\nesc 退出"}
}