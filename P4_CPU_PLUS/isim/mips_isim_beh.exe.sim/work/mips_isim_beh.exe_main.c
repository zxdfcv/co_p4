/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

#include "xsi.h"

struct XSI_INFO xsi_info;



int main(int argc, char **argv)
{
    xsi_init_design(argc, argv);
    xsi_register_info(&xsi_info);

    xsi_register_min_prec_unit(-12);
    work_m_00000000001979860654_3092946469_init();
    work_m_00000000003995021129_3383896982_init();
    work_m_00000000001378847507_3037376393_init();
    work_m_00000000003784510532_4127636709_init();
    work_m_00000000000500878342_0010801604_init();
    work_m_00000000000275724691_2725559894_init();
    work_m_00000000001982655830_1277329626_init();
    work_m_00000000004156649186_0992325708_init();
    work_m_00000000003249127240_3935768532_init();
    work_m_00000000001386841999_2023561271_init();
    work_m_00000000002859872510_2847759833_init();
    work_m_00000000001982655830_1843695135_init();
    work_m_00000000000874832579_0833183191_init();
    work_m_00000000001483033199_1739518194_init();
    work_m_00000000001386841999_1096416315_init();
    work_m_00000000004097003758_1435293567_init();
    work_m_00000000000331144673_4195689644_init();
    work_m_00000000002645468561_0413476095_init();
    work_m_00000000002103225032_3027548060_init();
    work_m_00000000001481321991_3877310806_init();
    work_m_00000000004134447467_2073120511_init();


    xsi_register_tops("work_m_00000000001481321991_3877310806");
    xsi_register_tops("work_m_00000000004134447467_2073120511");


    return xsi_run_simulation(argc, argv);

}