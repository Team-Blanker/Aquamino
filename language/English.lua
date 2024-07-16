return {
    warning={
        title="Photosensitive Seizure Warning",
        txt="A very small percent of people may experience epilepsy symptoms when exposed to specific visual images, including flashing lights or patterns that may appear in video games. \nThese symptoms include dizziness, blurred vision, eye or face twitching,\nlimb twitching, disorientation, confusion, or even loss of consciousness. \nEven people have no history of seizures or epilepsy may experience such symptoms while playing. \n\nIf you experience any symptoms, please stop playing immediately and consult your doctor.",
        txtScale=40/128,txtWidth=4500
    },
    modeName={
        ['40 lines']="Sprint",
        marathon="Marathon",
        ['ice storm']="Ice Storm",
        thunder="Thunder",
        smooth="Sprint Smooth",
        levitate="Levitate",
        master="Master",
        multitasking="Multitasking",
        sandbox="Sandbox",
        ['dig 40']="Cheese",
        laser="Laser",
        backfire="Boomerang",
        battle="Battle",
        conf_test="conf_test",
        idea_test="idea_test"
    },
    modeDescription={
        ['40 lines']="Clear 40 lines as fast as you can!",
        marathon={{1,1,1},"Clear 150 lines with increasing speed.\n",{1,1,0},"Handling Restriction: ASD=150ms ASP=30ms SD ASP=30ms, shortens with level increase"},
        ['ice storm']="Use All-spin mechanics to stop rising icicles!",
        thunder="Please do your best to avoid destruction from lightning.",
        smooth={{1,1,1},"Is it really that smooth?\n",{1,1,0},"Fall delay is 0, Lock delay is increased to 3s"},
        levitate={{1,1,0},"Blocks don't fall after clearing"},
        master={{1,1,1},"Survive in the cruelest speed!\n",{1,.5,0},"Fall delay is 0, lock delay shortens with level increase\n",{1,1,0},"Handling Restriction: ASD=150ms ASP=30ms SD ASP=30ms"},
        multitasking={{1,1,1},"Umm, uh. What??\n",{1,1,0},"Handling Restriction: ASD=150ms ASP=30ms SD ASP=30ms, shortens with level increase"},
        sandbox={{1,1,0},"This mode does not record any score"},
        ['dig 40']="Think calmly, dig efficiently.",
        laser="\"There's a laser on your lawn~\"",
        backfire="Receive the attack sent by yourself!",
        battle={{1,1,1},"Let's battle!\n",{1,1,0},"This mode does not record any score"}
    },
    intro={
        start="Press any key to start",
    },
    menu={
        bestScore="Best score",
        noBestScore="No score",
        arg={
            battle={
                bot_PPS="Bot PPS:",
                player={
                    pos="Player's place:",
                    left="left",
                    right="right"
                }
            }
        }
    },
    about={
        engineText="Powered by LÖVE",
        tool="Tools used:",
        repo="Repos used:",
        time="Times launched: %d\nTotal time played: %ds",
        staff="Staff"
    },
    staff={
        program="Programming",
        UI="UI & Art Design",
        music="Music by",
        sfx="SFX Design",
        specialThanks="Special Thanks",
        tester="...and all other testers"
    },
    pause={
        resume="Return",quit="Quit",r="Restart"
    },
    game={
        nowPlaying="Now playing: ",
        paused="Paused",result="Game over",
        theme={
            simple={win="Win!",lose="Lose"}
        }
    },
    conf={
        test="Test",
        main={title="Settings",audio="Audio",video="Video",custom="Custom",ctrl="Handling",keys="Keys"},

        audio={mus="Music Volume:",sfx="SFX Volume:",distract="Mute when unfocus",DOX=-22},
        video={
            unableBG="Disable BGs",
            fullScr="Fullscreen",fullScrTxt="Press F11 to switch window mode immediately.",
            vsync="Vertical Sync",
            vsyncTxt="The drawing code and computing code of this program are separated in form. How many times The drawing code executed in 1 second is FPS, so as TPS.\nIf the maximum FPS is lower than or equal to the vertical sync limit FPS, the TPS is not limited.\nThis program mainly considers PC performance, and this option is turned off by default.\nLow-performance devices can turn on this option to optimize the execution of the computing code.",
            frameLim="Max draw FPS:",frameTxt="A value equal to your monitor's FPS is recommended."
        },
        custom={
            texture="Block texture",color="Color adjust...",
            RS="Rotate system",
            smooth="Smooth move",
            smoothScale=.3,smoothOffX=-15,smoothTime="Time:",
            theme="Theme",
            scale="Field scale",scaleTxt="Cell size:",
            sfx="SFX pack",sfxWarning={
                otto="LOUD SOUND WARNING. TAKE AT YOUR OWN RISK."
            },

            colorSet={
                title="Color adjust",
                rAll="Reset all",rCur="Reset this",
                adjY="This texture can adjust color freely.",
                adjN="This texture cannot adjust color."
            }
        },
        keys={
            keyName={"Move Left","Move Right","Rotate CW","Rotate CCW","Rotate 180",'Soft drop','Hard Drop','Hold piece','Restart','Pause'},
            kScale=.26,
            info="Click a key set to bind your keys.\nHit backspace to erase selected key set.\nHit a bound key to remove this bind.",
            virtualKey="Touch settings..."
        },
        handling={
            ASD="Auto Shift Delay(ASD):",ASP="Auto Shift Preiod(ASP):",
            SD_ASD="Soft drop ASD:",SD_ASP="Soft drop ASP:"
        },
        other={title="Other",nothing="Nothing yet..."},
        lang={cur="Current Language: English"}
    },

    rule={
        dig={remain="To dig",piece="Pieces"},
        backfire={remain="To receive",eff="Effeciency"}
    },

    tip={
        "Well well well...",
        "Waht is \"Push\"?",
        "I like C4W :D",
        "AAAUUUGGGGGGGGGGGGGGGGHHH",
        "Lua No.1!",
        "Kairan is just a noob in blocks,not even know a line of code.",
        "Bad argument #6623:Attempt to compare number with nil",
        "I'm just a tip...",
        "This is Kairan,neither capable nor cute,only making nonsense in tips",
        "I'm not the first one who add tips into a block game,anyway",
        "A Project by TEAM BLANKER",
        "The game's birthday...Kairan set it to August 14th!",
        "Block skin \"Carbon Fibre\" is inspired by Speedcubes that use carbon fibre stickers.",
        "Try Aquamino's Push mechanic in Sandbox mode!",
        "Not every modes are related to water,although the game was named \"Aqua\".",
        "Kairan had modified SRS in this game with symmetric I-spin,and powerful 180 kicktables.",
        "\"How similar to Techmino but with nice color\"",
        "\"Ice Storm\" mode is from the mode with same name in Bejeweled 3",
        "You can do a T-spin Aquad in Aquamino!",
        "...weak table...",
        "a and b or c and d or e and f or g"
    },tipScale=.3,
    territory={info="Space,Enter=pause/run\nesc=exit"}
}