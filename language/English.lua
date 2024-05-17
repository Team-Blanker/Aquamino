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
        conf_test="conf_test",
        idea_test="idea_test"
    },
    intro={
        start="Press any key to start",
    },
    menu={
        illust="Double click or hit Enter to play.\nHit R to randomly choose a mode.",
        iScale=.4
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
        back="Back",test="Test",
        main={title="Settings",audio="Audio",video="Video",custom="Custom",ctrl="Handling",keys="Keys",other="Other..."},

        audio={mus="Music Volume:",sfx="SFX Volume:",distract="Mute when unfocus",DOX=-22},
        video={
            unableBG="Unable BGs",unableTxt="Turn on when ingame BGs discomfort you.",
            fullScr="Fullscreen",fullScrTxt="Press F11 to switch window mode immediately.",
            vsync="Vertical Sync",vsyncTxt="Usually,it's not recommended to open this option.",
            frameLim="Max draw FPS:",frameTxt="A value equal to your monitor's FPS is recommended."
        },
        custom={
            texture="Block texture",color="Color adjust",
            smooth="Smooth move\n[test]",smoothTxt="Note that there is no intemediate state in any move or rotations.",
            smoothOffX=-0,smoothOffY=-64*.3,
            theme="Theme",
            scale="Field scale",scaleTxt="1 means a single cell is 36px*36px in a 1920*1080 window.",
            sfx="SFX pack",sfxWarning={
                otto="LOUD SOUND WARNING. Please choose carefully."
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
            info="Click a key set to bind your keys.\nHit backspace to erase selected key set.\nHit a bound key to remove this bind."
        },
        handling={
            ASD="Auto Shift Delay(ASD):",ASP="Auto Shift Preiod(ASP):",
            SD_ASD="Soft drop ASD:",SD_ASP="Soft drop ASP:"
        },
        other={title="Other",nothing="Nothing yet..."},
        lang={cur="Current Language: English"}
    },

    rule={
        dig={remain="Lines",piece="Pieces"}
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
        "The game's' birthday...Kairan set it to August 14th!",
        "Block skin \"Carbon Fibre\" is inspired by Speedcubes that use carbon fibre stickers.",
        "Try Aquamino's Push mechanic in Sandbox mode!",
        "Not every modes are related to water,although the game was named \"Aqua\".",
        "Kairan had modified SRS in this game with symmetric I-spin,and powerful 180 kicktables.",
        "\"How similar to Techmino but with nice color\"",
        "\"Ice Storm\" mode is from the mode with same name in Bejeweled 3",
        "You can do a T-spin Aquad in Aquamino!",
        "It's best not to drag the game window while in game.",
        "...weak table..."
    },tipScale=.3,
    territory={info="Space,Enter=pause/run\nesc=exit"}
}