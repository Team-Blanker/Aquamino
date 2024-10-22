return {
    warning={
        title="Attenzione: Epilessia Fotosensbiile",
        txt="Una percentuale molto piccola di persone può manifestare sintomi di epilessia se esposta a immagini visive specifiche, comprese luci lampeggianti o schemi che possono apparire nei videogiochi. \nQuesti sintomi includono vertigini, visione offuscata, spasmi agli occhi o al viso,\nspasmi agli arti, disorientamento, confusione o addirittura perdita di coscienza. \nAnche le persone che non hanno precedenti di convulsioni o epilessia possono manifestare tali sintomi durante il gioco. \n\nSe riscontri qualsiasi sintomo, smetti immediatamente di giocare e consulta il tuo medico.",
        txtScale=40/128,txtWidth=4500
    },
    modeName={
        ['40 lines']="Sprint",
        marathon="Maratona",
        ['ice storm']="Tempesta di ghiaccio",
        thunder="Temporale",
        smooth="Sprint Liscio",
        levitate="Levitazione",
        square="Square",
        master="Maestro",
        multitasking="Multitasking",
        sandbox="Sandbox",
        ['dig 40']="Cheese",
        laser="Laser",
        battle="Battaglia",
        ['tower defense']="Difesa della torre",
        backfire="Boomerang",
        conf_test="conf_test",
        idea_test="idea_test"
    },
    modeDescription={
        ['40 lines']="Completa 40 righe\nil più velocemente possibile!",
        marathon={{1,1,1},"Completa 150 righe con velocità crescente.\n",{1,1,0},"Restrizioni del movimento:\nASD=150ms ASP=30ms SD ASP=30ms\nLa gravità aumenta ad ogni livello."},
        ['ice storm']="Usa le meccaniche All-spin\nper fermare la risalita dei ghiacciai!",
        thunder="Si prega di fare del proprio meglio per\nevitare la distruzione causata dai fulmini.",
        smooth={{1,1,1},"È davvero così liscio?\n",{1,1,0},"Il Ritardo di Caduta è 0\nmentre Il Ritardo di Blocco è aumentato a 3s"},
        levitate={{1,1,0},"I blocchi non cadono\ndopo aver completato linee"},
        square={{1,1,1}," How many 4*4 squares can you biuld \nin 3 minutes?"},
        master={{1,1,1},"Sopravvivi alla velocità più crudele!\n",{1,.5,0},"Il Ritardo di Caduta è 0\nmentre il Ritardo di Blocco\nsi riduce ad ogni livello.\n",{1,1,0},"Restrizioni del movimento: ASD=150ms ASP=30ms"},
        multitasking={{1,1,1},"*Galaxy Brain Meme*\n",{1,1,0},"Restrizioni del movimento:\nASD=150ms ASP=30ms SD ASP=30ms\nLa gravità aumenta ad ogni livello."},
        sandbox={{1,1,0},"Questa modalità non registra\nalcun punteggio."},
        ['dig 40']="Pensa. Scava. Sii Efficiente.",
        laser={{1,1,1},"U  N  D-E-R  G  R  O-U-N\nU  N  D-E-R  G  R  O-U-N-D\n",{1,1,0},"Questa è una modalità ritmica.\nSi consiglia vivamente di attivare la musica."},
        backfire="Ricevi l'attacco inviato da te stesso!",
        battle={{1,1,1},"Combattiamo!\n",{1,1,0},"Questa modalità non registra\nalcun punteggio."},
        ['tower defense']={{1,1,0},"Questa modalità non registra\nalcun punteggio.\n",{1,.2,.2},"L'avvio/riavvio di questa modalità potrebbe\ncausare il blocco del gioco per motivi sconosciuti"}
    },
    intro={
        start="Premi un tasto qualsiasi per iniziare",
    },
    menu={
        bestScore="Miglior Punteggio",
        noBestScore="Nessun Punteggio",
        arg={
            battle={
                bot_PPS="Bot PPS",
                player={
                    pos="Posto del giocatore",
                    left="sinistra",
                    right="destra"
                }
            },
            ['tower defense']={
                bot_PPS="Bot PPS",
                player={
                    pos="Player's place",
                    left="Sinistra",
                    right="Destra"
                }
            }
        }
    },
    about={
        engineText="Alimentato da LÖVE",
        tool="Strumenti utilizzati:",
        repo="Repositori Utilizzati:",
        time="Avviato %d volte\nTempo totale giocato: %ds",
        staff="Staff"
    },
    staff={
        program="Programmazione",
        UI="Interfaccia Utente & Progettazione Artistica",
        music="Musica composta da", hurtRecord="Of which from HURT RECORD (https://www.hurtrecord.com) :",
        sfx="Progettazione di effetti sonori",
        translate="Translation & Localization",
        specialThanks="Ringraziamenti Speciali",
        tester="...e tutti gli altri testers"
    },
    pause={
        resume="Riprendi",back="Esci",r="Riavvia"
    },
    game={
        nowPlaying="In riproduzione: ",
        paused="In pausa",result="Partita Finita",
        theme={
            simple={win="Vittoria!",lose="Sconfitta",newRecord="Nuovo record!"}
        }
    },
    conf={
        test="Test",
        main={title="Opzioni",audio="Audio",video="Video",custom="Personalizza",handling="Movimento",keys="Controlli"},

        audio={
            mus="Musica",distract="muta quando la finestra\nnon è focalizzata",DOX=-22,
            sfx="Effetti Sonori",stereo="Stereo"
        },
        video={
            unableBG="Disabilita Sfondi",
            BGset="Manage BGs...",
            fullScr="Schermo Intero",fullScrTxt="Premi F11 per andare a schermo intero.",
            vsync="VSync",
            vsyncTxt="Sincronizza la frequenza dei fotogrammi con la frequenza di aggiornamento del monitor.",
            discardAfterDraw="Aumento della VRAM",
            DADTxt="Elimina il contenuto dello schermo dopo aver disegnato ciascun fotogramma.",
            moreParticle="Più particelle\nin gioco",
            frameLim="FPS Massimi",frameTxt="Si consiglia un valore pari alla frequenza di aggiornamento del monitor."
        },
        custom={
            texture="Texture dei blocchi",color="Regolazione del colore...",
            RS="Sistema di rotazione",
            smooth="Movimento Liscio",
            smoothTime="Tempo di movimento",
            boardBounce="Board Bounce...",
            theme="Tema della griglia",
            scale="Scala della griglia",scaleTxt="Dimensione della cella",
            sfx="Effetti Sonori",sfxWarning={
                otto="LOUD SOUND WARNING. TAKE AT YOUR OWN RISK."
            },

            colorSet={
                title="Regolazione del colore",
                rAll="Ripristina tutto",rCur="Ripristina",
                adjY="Questa texture supporta la regolazione libera del colore.",
                adjN="Questa texture non supporta la regolazione libera del colore."
            },
            boardSet={
                title="Board bounce",

                moveForce="Move force",
                dropVel="Drop momentum",
                clearFactor="Clear momentom factor",
                velDamping="Velocity damping",
                elasticFactor="Elastic factor",

                spinAngvel="Spin angular momentum",
                angDamping="Spin damping",
                spinFactor="Spin elastic factor",
            }
        },
        keys={
            keyName={"Muovi a Sinistra","Muovi a Destra","Ruota in senso\norario","Ruota in senso\nantiorario","Ruota a 180°",'Soft drop','Hard Drop','Riserva','Riavvia','Pausa'},
            kScale=.25,
            info="- Fai clic associare i tuoi controlli.\n- Premi Backspace per cancellare il set di controlli selezionato.\n- Premi un tasto associato per rimuoverlo dai controlli.",
            virtualKey="Impostazioni touchscreen..."
        },
        virtualKey={
            enable="Abilita i controlli virtuali",enableTxtScale=.2,
            anim="Animazioni controlli",animTxtScale=.2,
            preset="preimpostazioni...",
            btsz="Dimensione",
            tolerance="Margine",
            attach="Allineamento"
        },
        handling={
            ASD="Ritardo spostamento automatico (ASD)",ASP="Periodo di spostamento automatico(ASP)",
            SD_ASD="Soft drop ASD",SD_ASP="Soft drop ASP"
        },
        other={title="Other",nothing="Ancora nulla qua..."},
        lang={cur="Lingua attuale: Italiano"}
    },

    rule={
        dig={remain="Da scavare",piece="Tetrimini"},
        backfire={remain="Da ricevere",eff="Efficienza"},
        square={time="Time",amount="Squares",remainTime={"2 minutes","1 minute","30 SECONDS"}}
    },

    tip={
        "Bene bene bene...",
        "Cos'è \"Push\"?",
        "C4W è divertente",
        "AAAUUUGGGGGGGGGGGGGGGGHHH",
        "Lua No.1!",
        "Kairan è solo un noob in blocchi, non conosce nemmeno una riga di codice.",
        "Bad argument #6623: Attempt to compare number with nil",
        "Aquad = Aqua + Quad",
        "Sono sono un consiglio...",
        "Questo è Kairan, né capace né carino, che dice solo sciocchezze al posto di consigli",
        "n ogni caso, non sono il primo ad aggiungere suggerimenti in un gioco a blocchi",
        "Un progetto creato da TEAM BLANKER",
        "Il 14 agosto è il compleanno del gioco ed anche il compleanno di Kairan.",
        "La skin dei blocchi \"Carbon Fibre\" è inspirata dai cubi di Rubik che usano stickers in fibra di carbonio.",
        "Prova la meccanica Push di Aquamino in modalità Sandbox!",
        "Non tutte le modalità sono legate all'acqua, anche se il gioco si chiamava \"Aqua\".",
        "L'SRS in questo gioco ha l'I-spin simmetrico e potenti kicktables da 180.",
        "\"Quanto simile a Techmino ma con un bel colore\"",
        "La modalità \"Tempesta di ghiaccio\" deriva dalla modalità con lo stesso nome in Bejeweled 3",
        "Puoi fare un T-spin Aquad in Aquamino!",
        "...weak table...",
        "a e b o c e d o e e f o g",

        "Ogni singolo pentamino può periodicamente affiancare il piano."
    },tipScale=.3,
    territory={info="Spazio,Enter=Pausa/run\nesc=Esci"},
    tracks={info="Spazio,Enter=Pausa/run\nesc=Esci"}
}
