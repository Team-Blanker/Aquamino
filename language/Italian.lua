return {
    warning={
        title="Attenzione: Epilessia Fotosensbiile",
        txt="Una percentuale molto piccola di persone può manifestare sintomi di epilessia se esposta a immagini visive specifiche, comprese luci lampeggianti o schemi che possono apparire nei videogiochi. \nQuesti sintomi includono vertigini, visione offuscata, spasmi agli occhi o al viso,\nspasmi agli arti, disorientamento, confusione o addirittura perdita di coscienza. \nAnche le persone che non hanno precedenti di convulsioni o epilessia possono manifestare tali sintomi durante il gioco. \n\nSe riscontri qualsiasi sintomo, smetti immediatamente di giocare e consulta il tuo medico.",
        txtScale=40/128,txtWidth=4500
    },
    modeName={
        ['40 lines']="Corsa",
        marathon="Maratona",
        ['ice storm']="Tempesta di ghiaccio",
        thunder="Temporale",
        smooth="Corsa Liscia",
        levitate="Levitazione",
        master="Maestro",
        multitasking="Multitasking",
        sandbox="Sandbox",
        ['dig 40']="Scava",
        laser="Laser",
        battle="Battaglia",
        ['tower defense']="Difesa della torre",
        backfire="Boomerang",
        overdose="Overdose",
        conf_test="conf_test",
        idea_test="idea_test",

        ['pento 40']="Corsa con Pentomini",
        square="Quadrati",
        ['core destruction']='[Deprecated mode]',
        ['dig bomb']="Scavo di bombe",

        ['mech heart detector']="MH Detector",
    },
    modeDescription={
        ['40 lines']="Completa 40 righe\nil più velocemente possibile!",
        marathon={{1,1,1},"Completa 150 righe con velocità crescente.\n",{1,1,0},"Restrizioni del movimento:\nASD=150ms ASP=30ms SD ASP=30ms\nLa gravità aumenta ad ogni livello."},
        ['ice storm']="Usa le meccaniche All-spin\nper fermare la risalita dei ghiacciai!",
        thunder="Si prega di fare del proprio meglio per\nevitare la distruzione causata dai fulmini.",
        smooth={{1,1,1},"È davvero così liscio?\n",{1,1,0},"Il Ritardo di Caduta è 0\nmentre Il Ritardo di Blocco è aumentato a 3s"},
        levitate={{1,1,0},"I blocchi non cadono\ndopo aver completato linee"},
        square={{1,1,1}," Quanti quadrati 4*4 puoi costruire \nin 3 minuti?"},
        master={{1,1,1},"Sopravvivi alla velocità più crudele!\n",{1,.5,0},"Il Ritardo di Caduta è 0\nmentre il Ritardo di Blocco\nsi riduce ad ogni livello.\n",{1,1,0},"Restrizioni del movimento: ASD=150ms ASP=30ms"},
        multitasking={{1,1,1},"*Galaxy Brain Meme*\n",{1,1,0},"Restrizioni del movimento:\nASD=150ms ASP=30ms SD ASP=30ms\nLa gravità aumenta ad ogni livello."},
        sandbox={{1,1,0},"Questa modalità non registra\nalcun punteggio."},
        ['dig 40']="Pensa. Scava. Sii Efficiente.",
        laser={{1,1,1},"U  N  D-E-R  G  R  O-U-N\nU  N  D-E-R  G  R  O-U-N-D\n",{1,1,0},"Questa è una modalità ritmica.\nSi consiglia vivamente di attivare la musica."},
        backfire="Ricevi l'attacco inviato da te stesso!",
        battle={{1,1,1},"Combattiamo!\n",{1,1,0},"Questa modalità non registra\nalcun punteggio."},
        ['tower defense']={{1,1,0},"Questa modalità non registra\nalcun punteggio.\n",{1,.2,.2},"L'avvio/riavvio di questa modalità potrebbe\ncausare il blocco del gioco per motivi sconosciuti"},
        overdose={{1,1,1},"\"Probabilmente ero sotto effetto di droga....\"\n",{1,.2,.2},"Se provi disagio,\nchiudi immediatamente il gioco."},

        ['mech heart detector']={{1,1,1},"I made a Mech Hearts detector.\n7-Bag, no any punishment.\n",{1,1,0},"Questa modalità non registra\nalcun punteggio."},
    },
    intro={
        start="Premi un tasto qualsiasi per iniziare",
    },
    menu={
        bestScore="Miglior Punteggio",
        noBestScore="Nessun Punteggio",
        notPlayable="Arriverà presto",
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
                    pos="Posto del giocatore",
                    left="Sinistra",
                    right="Destra"
                }
            },
            ['ice storm']={
                iceOpacity="Opacità della Colonna di Ghiaccio"
            }
        }
    },
    about={
        engineText="Sviluppato con LÖVE",
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
        multiPlatform="Multipiattaforma",
        specialThanks="Ringraziamenti Speciali",
        tester="...e tutti gli altri testers"
    },
    pause={
        resume="Riprendi",back="Esci",r="Riavvia"
    },
    game={
        nowPlaying="In riproduzione: ",
        curMode="Modalità corrente: ",
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
            BGBrightness="Luminosità",
            fullScr="Schermo Intero",fullScrTxt="Premi F11 per andare a schermo intero.",
            vsync="VSync",
            vsyncTxt="Sincronizza la frequenza dei fotogrammi con la frequenza di aggiornamento del monitor.",
            discardAfterDraw="Aumento della VRAM",
            DADTxt="Elimina il contenuto dello schermo dopo aver disegnato ciascun fotogramma.",
            moreParticle="Effetti particellari",
            frameLim="FPS Massimi",frameTxt="Si consiglia un valore pari alla frequenza di aggiornamento del monitor."
        },
        custom={
            texture="Texture dei blocchi",color="Regolazione colori...",
            RS="Sistema di rotazione",
            smooth="Animazione blocchi",
            smoothTime="Durata animazione",
            fallAnimType="Tipo di animazione\ndella gravità",
            rotationCenter="Asse di rotazione",
            boardBounce="Rimbalzo della griglia...",
            theme="Tema della griglia",
            scale="Scala della griglia",
            sfx="Effetti Sonori",sfxWarning={
                otto="ATTENZIONE: SUONI ALTI. USA A TUO RISCHIO."
            },

            colorSet={
                title="Regolazione del colore",
                rAll="Ripristina tutto",rCur="Ripristina",
                texType="Texture",
            },
            boardSet={
                title="Rimbalzo della griglia",

                presetLevel="Preimpostazione",

                moveForce="Forza di movimento",
                dropVel="Slancio in caduta",
                clearFactor="Fattore di slancio (completamento linee)",
                velDamping="Smorzamento velocità",
                elasticFactor="Fattore elastico",

                spinAngvel="Slancio angolare all-spin",
                angDamping="Smorzamento all-spin",
                spinFactor="Fattore elastico all-spin",
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
            attach="Allineamento",
            info="I tasti virtuali sono solo per l'uso touchscreen,\nma possono anche essere usati come display di input."
        },
        handling={
            ASD="Ritardo spostamento automatico (ASD)",ASP="Periodo di spostamento automatico(ASP)",
            SD_ASD="Soft drop ASD",SD_ASP="Soft drop ASP",

            IM="Initial Move",IR="Initial Rotate",IH="Initial Hold",
            tap="Tap",hold="Hold",
        },
        other={title="Other",nothing="Ancora nulla qua..."},
        lang={cur="Lingua attuale: Italiano"}
    },

    rule={
        dig={remain="Da scavare",piece="Tetramini"},
        thunder={piece="Tetramini"},
        backfire={remain="Da ricevere",eff="Efficienza"},
        laser={punish="Penalità"},
        square={time="Tempo",amount="Punti",remainTime={"2 minuti","1 minuto","30 SECONDI"}}
    },
    territory={info="Spazio,Enter=Pausa/run\nesc=Esci"},
    tracks={info="Spazio,Enter=Pausa/run\nesc=Esci"}
}
