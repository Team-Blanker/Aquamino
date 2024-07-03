return {
    order={
    ['40 lines']={'time'},--未通关不记录成绩
    marathon={'level','line','time'},
    ['ice storm']={'level','time'},
    thunder={'score','time'},
    smooth={'time'},--未通关不记录成绩
    levitate={'time'},--未通关不记录成绩
    master={'level','line','time'},
    multitasking={'level','line','time'},
    ['dig 40']={'time'},--未通关不记录成绩
    laser={'score','time'},
    backfire={'time','eff'},
    },
    format={
    ['40 lines']='%.3fs',
    marathon='Level %d  %d lines  %.3fs',
    ['ice storm']='Level %d  %.3fs',
    thunder='%dp  %.3fs',
    smooth='%.3fs',
    levitate='%.3fs',
    master='Level %d  %d lines  %.3fs',
    multitasking='Level %d  %d lines  %.3fs',
    ['dig 40']='%.3fs',
    laser='%dp  %.3fs',
    backfire='%.3fs  x%.2f',
    }
}