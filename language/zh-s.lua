return {
    warning={
        title="光敏性癫痫警告",
        txt="极小部分人可能会在看到特定视觉图像（包括可能出现在视频游戏中的闪烁效果或图案）时出现癫痫症状。\n此类症状包括头晕目眩、视线模糊、眼睛或面部抽搐、四肢抽搐、迷失方向感、精神错乱或短暂的意识丧失。\n\n即使没有癫痫史的人也可能出现此类症状。\n如果你出现任何上述症状，请立即停止游戏并尽快就医。",
        txtScale=50/128,txtWidth=4000
    },
    modeName={
        ['40 lines']="40 行",
        marathon="马拉松",
        ['ice storm']="冰风暴",
        thunder="雷暴",
        smooth="丝滑 40 行",
        levitate="悬浮 40 行",
        master="大师",
        multitasking="双线程",
        sandbox="无尽 - 沙盒",
        ['dig 40']="挖掘 40 行",
        laser="激光",
        backfire="回旋镖",
        conf_test="设置 - 测试界面",
        idea_test="idea_test"
    },
    modeDescription={
        ['40 lines']="以最快速度消除40行",
        marathon={{1,1,1},"消除150行，但方块下落速度会越来越快\n",{1,1,0},"参数限制：ASD=150ms ASP=30ms 软降ASP=30ms，随等级提升缩短"},
        ['ice storm']="利用All-spin机制抵御上升的冰柱",
        thunder="应对雷电的破坏",
        smooth={{1,1,1}," 真的有这么丝滑吗？\n",{1,1,0},"降落延迟为0，锁定延迟增加至3秒"},
        levitate={{1,1,0},"消行后场地内砖格不掉落"},
        master={{1,1,1}," 在最高下落速度下极限堆叠！\n",{1,.5,0},"降落延迟为0，锁定延迟随等级提升缩短\n",{1,1,0},"参数限制：ASD=150ms ASP=30ms"},
        multitasking={{1,1,1}," 嗯，嘛。啊？\n",{1,1,0},"参数限制：ASD=150ms ASP=30ms 软降ASP=30ms，随等级提升缩短"},
        sandbox="",
        ['dig 40']="静心思考，高效挖掘",
        laser="“有一束激光在你的场地上”",
        backfire="吃下自己打出的攻击",
    },
    intro={
        start="按任意键开始",
    },
    menu={
        noBestScore="暂无成绩"
    },
    about={
        engineText="使用LÖVE引擎制作",
        tool="使用工具",
        repo="使用库",
        time="游戏运行次数：%d\n总运行时间：%d 秒",
        staff="制作人员",
    },
    staff={
        program="程序",
        UI="UI & 视觉设计",
        music="音乐来自",
        sfx="音效",
        specialThanks="特别感谢",
        tester="以及其他所有内测成员"
    },
    pause={
        resume="继续",quit="退出",r="重开"
    },
    game={
        nowPlaying="当前播放 : ",
        paused="暂停",result="游戏结束",
        theme={
            simple={win="胜利",lose="失败"}
        }
    },
    conf={
        test="测试",
        main={title="设置 - 主页",audio="音频设置",video="画面设置",custom="主题设置",ctrl="控制设置",keys="键位设置"},
        audio={mus="音乐音量:",sfx="音效音量:",distract="失去焦点自动静音",DOX=0},
        video={
            unableBG="禁用游戏背景",unableTxt="若游戏背景导致你身体不适，请打开此选项。",
            fullScr="全屏",fullScrTxt="按F11可一键切换窗口状态。",
            vsync="垂直同步",
            vsyncTxt="本程序绘制代码与运算代码形式上分离，称绘制帧率为FPS，运算帧率为TPS。\n若设定的最高FPS小于等于垂直同步限制的FPS，则TPS不受限。\n本程序主要考虑PC端运行情况，该选项默认关闭。\n低性能设备可开启此选项优化运算代码运行。",
            frameLim="最高绘制帧率:",frameTxt="推荐将该值调整为与显示器帧率相等。"
        },
        custom={
            texture="方块材质",color="方块配色...",
            smooth="平滑运动",
            smoothScale=.35,smoothOffX=0,smoothTime="动画时长:",
            theme="场地风格",
            scale="场地缩放",scaleTxt="单格方块大小：",
            sfx="音效包",sfxWarning={
                otto="该音效包包含音量过大内容，谨慎选择。"
            },
            colorSet={
                title="调整方块颜色",
                rAll="重置所有",rCur="重置当前",
                adjY="该皮肤可自由调整颜色。",
                adjN="该皮肤不可调整颜色。"
            }
        },
        keys={
            keyName={'左移','右移','顺转','逆转','翻转','软降','硬降','暂存','重开','暂停'},
            kScale=.5,
            info="点击添加键位绑定（最多3个）\nBackspace清空选定键位\n按下已绑定键位以删除该绑定"
        },
        handling={
            ASD="自动移动延迟(ASD,旧称DAS):",ASP="自动移动周期(ASP,旧称ARR):",
            SD_ASD="软降ASD:",SD_ASP="软降ASP:"
        },
        other={title="其它设置",nothing="暂无内容"},
        lang={cur="当前语言：简体中文"}
    },

    rule={
        dig={remain="剩余行数",piece="使用块数"},
        backfire={remain="剩余垃圾行数",eff="效率"}
    },

    tip={
        "哦哦，哦哦哦！",
        "感觉……不如……Techmino……",
        "Push是什么 不知道",
        "卖弱的一律当5pps处理",
        "狗都sub30了",
        "吃四碗，爽！",
        "哇袄！！！",
        "Lua天下第一！",
        "海兰就是个彩笔打块的，懂什么代码",
        "Bad argument #6623:Attempt to compare number with nil",
        "我是一条凑数tip",
        "你说得对，但是……",
        "打SDPC不接DPC，那我缺的这个spike这块谁给我补啊",
        "这是海兰，既没实力又不可爱，只会在tip里口嗨",
        "反正我不是第一个往方块游戏里加tip的",
        "A Project by TEAM BLANKER",
        "游戏的生日？2023年暑假的时候开发的，就定在8月14日吧",
        "Z酱锐评：“抄铁壳抄的挺到位的”",
        "Carbon Fibre方块皮肤的灵感来自于碳纤维贴纸魔方",
        "Aquamino特色推箱子",
        "虽然名字是水，但海兰可不保证每个模式都和水有关系",
        "本游戏的SRS经过修改，I旋对称，并且加入了180°踢墙",
        "冰风暴模式来自于宝石迷阵3的同名模式",
        "在Aquamino，你可以做到T旋消四！",
        "唉，weak table",
        "脑袋空空……",
        "少打方块多读书",
        "远离现充。",
        "a and b or c and d or e and f or g"
    },tipScale=.4,
    territory={info="空格/Enter 切换暂停/运行状态\nesc 退出"}
}