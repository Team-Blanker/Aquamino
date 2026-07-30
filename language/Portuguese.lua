return {
    warning={
        title="Aviso de Fotossensibilidade",
        txt="Existe uma pequena porcentagem de pessoas experienciar sintomas de epilepsia quando expostas em imagens visuais específicas, incluindo luzes piscantes ou padrões que aparecem nos VideoGames.\nEsses sintomas incluem Tontura, Visão Borrada, Tremedeiras no Olhos, Rosto ou \nnos Membros, Desorientação, Confusão, ou até mesmo Perda de Consciência.\nPesssoas que não teve esses históricos também podem experienciar esses sintomas enquanto joga. \n\nSe você experienciar qualquer sintomas citados, pare de jogar imediatamente e consulte um médico.",
        txtScale=40/128,txtWidth=4500
    },

    modeName={
        ['40 lines']="Corrida",
        marathon="Maratona",
        ['ice storm']="Nevasca",
        thunder="Tempestade",
        smooth="Corrida Suave",
        levitate="Levitação",
        master="Mestre",
        multitasking="Multi-Tarefa",
        sandbox="Caixa de Areia",
        ['dig 40']="Escavar",
        laser="Lazer",
        battle="Batalha",
        ['tower defense']="Defesa de Torre",
        backfire="Bumerangue",
        overdose="Sobredose",
        conf_test="[Ajustes] Area de Teste",
        idea_test="[Ideia] Area de Testes",

        ['pento 40']="Corrida com Pentominos",
        square="Quadrado",
        ['core destruction']='[Modo Injogável]',
        ['dig bomb']="Escavada com  Bombas",
        multitasking_plus="Multi-Tarefa +",

        ['mech heart detector']="Detector de Mech",
    },

    modeDescription={
        ['40 lines']="Limpe 40 linhas o mais rápido que você conseguir!",
        marathon={{1,1,1},"Limpe 150 linhas com velocidade progressiva.\n",{1,1,0},"Ajuste Fixo"},
        ['ice storm']={"Use mecânicas de All-Spin\n", "para impedir que Pontas de Gelo cresçam."},
        thunder="Faça o melhor para evitar destruição\nde um trovão.",
        smooth={{1,1,1},"Isso realmente é suave?\n",{1,.5,0},"20G\n",{1,1,0},"Ajuste Fixo"},
        levitate="Blocos não irão cair depois de limpos",
        square={{1,1,1},"Quantos quadrados de 4*4 você pode construir \nem 3 minutos?"},
        master={{1,1,1},"Sobreviva em uma velocidade mais cruel!\n",{1,.5,0},"20G\n",{1,1,0},"Ajuste Fixo"},
        multitasking={{1,1,1},"*Galaxy Brain Meme*\n",{1,1,0},"Ajuste Fixo"},
        sandbox={{1,1,0},"Esse modo não registra nenhuma pontuação."},
        ['dig 40']={"Escave 40 linhas de lixo\n", "usando o menor número possível de blocos."},
        laser={{1,1,1},"U  N  D-E-R  G  R  O-U-N\nU  N  D-E-R  G  R  O-U-N-D\n",{1,1,0},"Esse modo é Rítimico.\nAjuste na Música é fortemente recomendado"},
        backfire="Receba ataques de você mesmo!",
        battle={{1,1,1},"Vamos Batalhar!\n",{1,1,0},"Esse modo não registra nenhuma pontuação"},
        ['tower defense']={{1,1,0},"Esse modo não registra nenhuma pontuação\n",{1,.2,.2},"Esse modo é instável. \n", "Risco de congelamento caso (ren)iniciar."},
        overdose={{1,1,1},"Aperta! Aperta! Aperta! Yeah!\n",{1,.2,.2},"Se sentir qualquer desconforto.\n", "Feche o jogo sem hesitação!"},

        ['mech heart detector']={{1,1,1},"Eu fiz um detector de Mech Hearts.\n7-Bag, sem qualquer punição.\n",{1,1,0},"Esse modo não registra nenhuma pontuação"},
    },

    intro={
        start="Pressione qualquer tecla.",
    },

    menu={
        bestScore="Melhor Pontuação",
        noBestScore="Sem Pontuação",
        notPlayable="Em Breve",
        arg={
            marathon={
                startLv="Velocidade inicial [LV]",
            },
            master={
                startLv="Velocidade inicial [LV]",
            },
            battle={
                bot_PPS="PPS do Bot",
                player={
                    pos="Posição do Jogador",
                    left="esquerda",
                    right="direita"
                },
                ruleSet="Tipos de Predefinidos",
                ruleSetName={
                    basic="Basico",
                    allspin="All-Spin",
                    allspin2="All-Spin 2",
                    shrink="Encolhido",
                    aqua="Aqua",
                    bomb="Bombas",
                }
            },
            ['tower defense']={
                bot_PPS="PPS do Bot",
                player={
                    pos="Posição do Jogador",
                    left="esqueda",
                    right="direita"
                }
            },
            ['ice storm']={
                iceOpacity="Opacidade do Gelo"
            }
        },

        button={
            setting="Ajustes",
            about="Sobre",
            links="Saiba Mais"
        },

        extLink={
            "Documento oficial de Aquamino",
            "Tetris Wiki da Hard Drop",
            "Tetris Wiki Chinês",
            "Tetris Wiki",
            "FOUR.LOL",
            "Guia O-Spin de Dunspixel",
        }
    },

    about={
        engineText="Desenvolvido no LÖVE",
        tool="Ferramentas Usadas:",
        repo="Repositórios Usados:",
        time="Vezes Iniciado: %d\nHoras de jogo: %ds",
        staff="Créditos"
    },

    staff={
        program="Programação",
        UI="UI & Design de Arte",
        music="Músicas por", hurtRecord="HURT RECORD (https://www.hurtrecord.com) :", dovaS="DOVA-SYNDROME (https://dova-s.jp) :",
        sfx="Design de SFX",
        translate="Tradução e Localização",
        multiPlatform="Multiplataforma",
        specialThanks="Agradecimentos Especiais",
        tester="...e para todos os testadores"
    },

    pause={
        resume="Continuar",back="Sair",r="Reniciar"
    },

    game={
        nowPlaying="Tocando Agora: ",
        curMode="Modo Atual: ",
        paused="Pausado",result="Fim do Jogo",
        theme={
            simple={win="Venceu!",lose="Perdeu",newRecord="Novo Recorde!"}
        }
    },

    conf={
        test="Teste",
        main={title="Ajustes",audio="Áudio",video="Vídeo",custom="Customização",handling="Ajuste",keys="Controles"},

        audio={
            mus="Música",distract="Mutar quando desfocado",DOX=-22,
            sfx="Efeitos Sonoros",stereo="Stereo"
        },

        video={
            unableBG="Desativar Fundos",
            BGBrightness="Brilho do Fundo",
            fullScr="Tela Cheia",fullScrTxt="Pressione F11 para alterar modo de janela instantaneamente!",
            vsync="VSync",
            vsyncTxt="A renderização do código e a computação desse programa são separados nessa forma. Quantas vezes o redenrizador de código executado em 1 segundo é FPS.\nJá o TPS se o máximo de FPS é baixo ou igual para VSync, o TPS não é limitado.\nEsse programa geralmente considera um desempenho de PC e essa opcão é desligada por padrão.\n Dispositivos de baixa potência podem ativar essa opção para otimizar a execução de código computado.",
            discardAfterDraw="Bosst no VRAM",
            DADTxt="Descarta (lixo) de conteúdo da tela depois que cada frame é renderizado. Se a tela estiver falhando não ative isso.",
            frameLim="Máx de renderização FPS",frameTxt="O valor igual para o FPS do seu monitor é recomendavel.",
            sysCursor="Usar cursor externo",
        },

        custom={
            texture="Textura do Bloco",color="Ajustar Cor...",
            RS="Sistema de Rotação",
            smooth="Suavização do Bloco",
            smoothTime="Tempo",
            fallAnimType="Tipo de suavização da Gravidade",
            rotationCenter="Rotação Centralizado",
            boardBounce="Tabuleiro Quicando...",
            theme="Tema do Tabuleiro",
            scale="Escala do Tabuleiro",
            sfx="Pacote de SFX",sfxWarning={
                otto="AVISO DE AUDIO ESTOURADO!"
            },

            colorSet={
                title="Ajustar Cores",
                rAll="Redefinir Todos",rCur="Redefinir o Atual",
                texType="Textura",
            },

            boardSet={
                title="Tabuleiro Quicando",

                presetLevel="Nível Predefinido",

                moveForce="Força de movimento",
                dropVel="Força ao largar",
                clearFactor="Fator ao Limpar",
                velDamping="Velocidade de Amortecimento",
                elasticFactor="Fator Elástico",

                spinAngvel="Momento de Giro angular",
                angDamping="Amortecimento do Giro",
                spinFactor="Fator do giro elástico",
            }
        },

        keys={
            keyName={"Esquerda","Direita","Rotação CW","Rotação CCW","Rotação 180",'Queda Suave','Queda Suave (1 célula)','Queda Forte','Manter Peça','Reiniciar','Pausa','Função 1','Função 2'},
            kScale=.25,
            info="Selecione um comando para (re)mapear com a tecla desejada.\nPressione BackSpace para apagar o comando mapeado.\nPressione uma tecla ativa para remover desse comando.",
            virtualKey="Configurações de Toque..."
        },

        virtualKey={
            enable="Ativar Controles Virtuais",enableTxtScale=.2,
            shade="Sombra",shadeTxtScale=.25,
            anim="Animações",animTxtScale=.2,
            preset="Predefinidos...",
            btsz="Tamanho",
            tolerance="Margem",
            attach="Alinhamento",
            info="Controles Virtuais são para apenas telas-sensíveis ao toque,\nmas você também pode usar para display de entrada."
        },

        handling={
            ASD="Atraso de Auto-Deslocamento (AAD / DAS)",ASP="Período de Auto-Deslocamento (PAD / ARR)",
            SD_ASD="Queda Leve AAD / DAS",SD_ASP="Queda Leve PAD / ARR",

            IM="Movimento Inicial",IR="Movimentação Inicial",IH="Hold Inicial",
            tap="Tap",hold="Hold",
        },

        other={title="Outro",nothing="Nada por enquanto..."},
        lang={cur="Idioma Atual: Português"}
    },

    rule={
        dig={remain="Para escavar",piece="Peça"},
        thunder={piece="Peça"},
        backfire={remain="Para receber",eff="Eficiência"},
        laser={punish="Arrastando\nPenalidade"},
        square={time="Tempo",amount="Pontos",record="Recorde",remainTime={"2 minutos","1 minuto","30 SEGUNDOS"}}
    },

    AquaMarbler={
        title={{1,1,1},"Welcome to ",{.5,1,.875},"AquaMarbler"},
        info="Miko of Aqua and Luminous    Presents",

        name={
            territory="Territory War",
            tracks="Occupying & Scoring",
            zombie="Zombie Tower Defense",
            square="Square Grid Battle",
        },

        desc={
            territory="Classic Multiply or Release battle\nDestroy other's cannon to win",
            tracks="Fight for tracks and receive bonus balls\nWho will get higher score?",
            zombie="Release zombies on lanes to attack opponent's base\n D u e l   C h a n n e l",
            square="Deploy cannons to destroy opponent's base\nWhen 4 cannons in same color formed a square...",
        },

        keyInfo="In simulation: Press space to pause/simulate, Press Esc to quit",
    },
}