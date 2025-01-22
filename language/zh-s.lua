return {
    warning={
        title="光敏性癫痫警告",
        txt="极小部分人可能会在看到特定视觉图像（包括可能出现在视频游戏中的闪烁效果或图案）时出现癫痫症状。\n此类症状包括头晕目眩、视线模糊、眼睛或面部抽搐、四肢抽搐、迷失方向感、精神错乱或短暂的意识丧失。\n\n即使没有癫痫史的人也可能出现此类症状。\n如果你出现任何上述症状，请立即停止游戏并尽快就医。",
        txtScale=50/128,txtWidth=4000
    },
    modeName={
        ['40 lines']="40 行竞速",
        marathon="马拉松",
        ['ice storm']="冰风暴",
        thunder="雷暴",
        smooth="丝滑 40 行",
        levitate="悬浮 40 行",
        square="正方拼合",
        master="大师",
        multitasking="双线程",
        sandbox="无尽 - 沙盒",
        ['dig 40']="挖掘 40 行",
        laser="激光",
        backfire="回旋镖",
        battle="对战",
        ['tower defense']="塔防",
        overdose="致幻",
        conf_test="设置 - 测试界面",
        idea_test="idea_test",

        ['pento 40']="五连块竞速",

        ['core destruction']="[已废弃模式]"
    },
    modeDescription={
        ['40 lines']="以最快速度消除40行",
        marathon={{1,1,1},"消除150行，但方块下落越来越快\n",{1,1,0},"参数限制：ASD=150ms ASP=30ms 软降ASP=30ms\n重力随等级提升而增大"},
        ['ice storm']="利用All-spin机制抵御上升的冰柱",
        thunder="应对雷电的破坏",
        smooth={{1,1,1}," 真的有这么丝滑吗？\n",{1,1,0},"降落延迟为0，锁定延迟增加至3秒"},
        levitate={{1,1,0},"消行后场地内砖格不掉落"},
        square={{1,1,1}," 你能在3分钟内拼出多少4×4正方形？"},
        master={{1,1,1}," 在最高下落速度下极限堆叠！\n",{1,.5,0},"降落延迟为0，锁定延迟随等级提升缩短\n",{1,1,0},"参数限制：ASD=150ms ASP=30ms"},
        multitasking={{1,1,1},"妈妈生的.mp4\n",{1,1,0},"参数限制：ASD=150ms ASP=30ms 软降ASP=30ms\n重力随等级提升而增大"},
        sandbox={{1,1,0},"该模式不记录成绩"},
        ['dig 40']="静心思考，高效挖掘",
        laser={{1,1,1},"做人不要太攀比，踏踏实实做自己\n如果非要比一比，那就比比激光雨\n",{1,1,0},"节奏模式，强烈建议开启音乐游玩"},
        backfire="吃下自己打出的攻击",
        battle={{1,1,1}," 战斗，爽！\n",{1,1,0},"该模式不记录成绩"},
        ['tower defense']={{1,1,0},"该模式不记录成绩\n",{1,.2,.2}," 该模式不稳定。\n 启动/重开该模式可能会让程序卡死。"},
        overdose={{1,1,1},"“也许我只不过是溜大了”\n",{1,.2,.2}," 游玩过程中若出现任何不适，\n 请立刻关闭游戏。"},
    },
    intro={
        start="按任意键进入游戏",
    },
    menu={
        bestScore="最佳成绩",
        noBestScore="暂无成绩",
        arg={
            battle={
                bot_PPS="机器人PPS",
                player={
                    pos="玩家位置",
                    left="左侧",
                    right="右侧"
                }
            },
            ['tower defense']={
                bot_PPS="机器人PPS:",
                player={
                    pos="玩家位置:",
                    left="左侧",
                    right="右侧"
                }
            }
        }
    },
    about={
        engineText="使用LÖVE引擎制作",
        tool="使用工具",
        repo="使用库",
        time="游戏运行次数 : %d\n总运行时间 : %d 秒",
        staff="制作人员",
    },
    staff={
        program="程序",
        UI="UI & 视觉设计",
        music="音乐", hurtRecord="来自 HURT RECORD (https://www.hurtrecord.com) :",
        sfx="音效",
        translate="翻译 & 本地化",
        specialThanks="特别感谢",
        tester="以及其他所有内测成员"
    },
    pause={
        resume="继续",back="返回",r="重开"
    },
    game={
        nowPlaying="当前播放 : ",
        curMode="当前模式 : ",
        paused="暂停",result="游戏结束",
        theme={
            simple={win="胜利",lose="失败",newRecord="打破纪录"}
        }
    },
    conf={
        test="测试",
        main={title="设置 - 主页",audio="音频设置",video="画面设置",custom="偏好设置",handling="控制设置",keys="键位设置"},
        audio={
            mus="音乐音量",distract="失去焦点自动静音",DOX=0,
            sfx="音效音量",stereo="立体声"
        },
        video={
            unableBG="禁用游戏背景",
            BGset="游戏背景设置...",
            fullScr="全屏",fullScrTxt="按F11可一键切换窗口状态。",
            vsync="垂直同步",
            vsyncTxt="本程序绘制代码与运算代码形式上分离，称绘制帧率为FPS，运算帧率为TPS。\n若设定的最高FPS小于等于垂直同步限制的FPS，则TPS不受限。\n本程序主要考虑PC端运行情况，该选项默认关闭。\n低性能设备可开启此选项优化运算代码运行。",
            discardAfterDraw="显存回收加速",
            DADTxt="每帧绘制完成后立刻丢弃对应显存。用于移动端优化。",
            moreParticle="更多粒子特效",
            frameLim="最高绘制帧率",frameTxt="推荐将该值调整为与显示器帧率相等。"
        },
        custom={
            texture="方块材质",color="方块配色...",
            RS="旋转系统",
            smooth="平滑运动",
            smoothTime="动画时长",
            boardBounce="版面晃动...",
            theme="版面风格",
            scale="版面缩放",scaleTxt="单格方块大小",
            sfx="音效包",sfxWarning={
                otto="该音效包包含音量过大内容，谨慎选择。"
            },
            colorSet={
                title="调整方块颜色",
                rAll="重置所有",rCur="重置当前",
            },
            boardSet={
                title="版面晃动",

                presetLevel="预设等级",

                moveForce="移动推力",
                dropVel="硬降动量",
                clearFactor="消除动量倍率",
                velDamping="平移阻尼",
                elasticFactor="平移弹性系数",

                spinAngvel="扭转角动量",
                angDamping="扭转阻尼",
                spinFactor="扭转弹性系数",
            }
        },
        keys={
            keyName={'左移','右移','顺转','逆转','180°转','软降','硬降','暂存','重开','暂停'},
            kScale=.4,
            info="点击添加键位绑定 (最多3个)\nBackspace清空选定键位\n按下已绑定键位以删除该绑定",
            virtualKey="触控设置..."
        },
        virtualKey={
            enable="启用虚拟按键",enableTxtScale=.25,
            anim="按钮动画",animTxtScale=.25,
            preset="预设...",
            btsz="大小",
            tolerance="容错",
            attach="网格对齐"
        },
        handling={
            ASD="自动移动延迟(ASD,旧称DAS)",ASP="自动移动周期(ASP,旧称ARR)",
            SD_ASD="软降ASD",SD_ASP="软降ASP"
        },
        other={title="其它设置",nothing="暂无内容"},
        lang={cur="当前语言：简体中文"}
    },

    rule={
        dig={remain="剩余行数",piece="使用块数"},
        backfire={remain="剩余垃圾行数",eff="效率"},
        square={time="剩余时间",amount="构造正方数",remainTime={"2 分钟","1 分钟","30 秒"}}
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
        "Bad argument #6623: Attempt to compare number with nil",
        "Aquad = Aqua + Quad",
        "我是一条凑数tip",
        "你说得对，但是……",
        "打SDPC不接DPC，那我缺的这个spike这块谁给我补啊",
        "这是海兰，既没实力又不可爱，只会在tip里口嗨",
        "反正我不是第一个往方块游戏里加tip的",
        "A Project by TEAM BLANKER",
        "游戏的生日？2023年暑假的时候开发的，就定在8月14日吧",
        "Z酱锐评：“抄铁壳抄的挺到位的”",
        "Carbon Fibre 方块材质的灵感来自于碳纤维贴纸魔方",
        "Aquamino特色推箱子",
        "虽然名字是水，但海兰可不保证每个模式都和水有关系",
        "本游戏的SRS经过修改，I旋对称，并且加入了180°踢墙",
        "冰风暴模式来自于宝石迷阵3的同名模式",
        "在Aquamino，你可以做到T旋消四！",
        "唉，weak table",
        "脑袋空空……",
        "少打方块多读书",
        "远离现充。",
        "a and b or c and d or e and f or g",

        {{1,0,0},"游戏名不是等长条，这不是什么好笑的玩笑。"},
        {{1,0,0},"不是速度快就是开外挂。"},

        "任意五连块均可以周期性密铺整个平面。"
    },tipScale=.4,
    territory={info="空格/Enter 切换暂停/运行状态\nesc 退出"},
    tracks={info="空格/Enter 切换暂停/运行状态\nesc 退出"}
}