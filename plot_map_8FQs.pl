#!/usr/bin/perl -w
# make fakequakes plots

#\rm .gmtdefaults4
`gmt defaults > gmt.conf`; #get original defaults
`gmt gmtset MAP_FRAME_TYPE fancy`;
`gmt gmtset FONT_HEADING 1 HEADER_FONT_SIZE 20 MAP_TITLE_OFFSET 0.0p`;
`gmt gmtset PS_MEDIA a2`;
#gmt gmtset FONT_LABEL 1 LABEL_FONT_SIZE 10 LABEL_OFFSET 0.1i
#gmt gmtset FONT_ANNOT 1 ANNOT_FONT_SIZE 10 ANNOT_OFFSET 0.1i


$stafile='/Users/jtlin/Documents/Project/MLARGE/data/Chile_GNSS.gflist';  #All the Chile GPS stations

$fault='/Users/jtlin/Documents/Project/MLARGE/data/chile.fault';
#set grdlarge='/Users/timlin/Documents/Project/GMTplot/Grdfiles/topo15.grd' #input a large GRD file
#grdcut $grdlarge -G$grdfile -R$area
$grdfile='/Users/jtlin/Documents/Project/GMTplot/Grdfiles/chile.grd';  #cut the $grdlarge and use this file
$grdgrad='/Users/jtlin/Documents/Project/GMTplot/Chile/chile.gradient';
#`gmt grdgradient $grdfile -G$grdgrad -A90 -Ne0.5`;

$SLAB='/Users/jtlin/Documents/Project/MLARGE/data/chile.mshout';
$timeseries='/Users/jtlin/Documents/Project/GMTplot/Chile_MLARGE/Inputs/Timeseries/timeseries.026898.txt';


$cmap='/Users/jtlin/Documents/Project/GMTplot/Cpts/color_linear_slip.cpt';#colormap for slip

#set area='-77/-65/-45.0/-17'
#set area_L='-71.0/-31/-29.5/-14/8' #used by -JL
$area='-78/-65.5/-45.0/-17';
#set area_L='-125.0/45/40/50/8' #used by -JL
#$area_L='-71.0/-31/-15/-14/8'; #used by -JL
$area_L='-71.0/-31/-20/-10/8'; #used by -JL
#$fileout="Cascadia_2_${run_num}";
#$EQID="000001";
#---Illapel---
#$evlo=-71.674;
#$evla=-31.573;
##-------------
#
##---Maule-----
#$evlo=-72.898;
#$evla=-36.122;
#$scale_velo=1.8; #scale for vector plot
#
##---Melinka-----
#$evlo=-73.941;
#$evla=-43.406;
#$scale_velo=15.0; #scale for vector plot

#---ID:026898---
#$evlo=-74.157584;
#$evla=-40.519849;
#$evdp=23.38;
#$scale_velo=1.0; #scale for vector plot
#$mag=9.3;

$fileout = 'Chile_rupts_base.ps';

#$rupt_file = '/Users/jtlin/Documents/Project/GMTplot/Chile_GM/output/ruptures/Chile_small_new3_subduction.169953.rupt';
@rupt_files = `ls /Users/jtlin/Documents/Project/GMTplot/Chile_GM/output/ruptures/*.rupt`;
chomp(@rupt_files);
#
###################################################################################################################
##make a base ps file, plot other things later
@bottom_array=(0,1,2,3);
@top_array=(4,5,6,7);
for ($n_rupt=0;$n_rupt<@rupt_files;$n_rupt++){
#for ($n_rupt=0;$n_rupt<2;$n_rupt++){
    $rupt_file=$rupt_files[$n_rupt];
    print "working on:$rupt_file\n";
    if ($n_rupt==0){
        # plot grdimage. this is the first map so only -K
        `gmt grdimage $grdfile -I$grdgrad -JL$area_L -R$area -Ctopo.cpt -Y2i -X1i -P -t70  -K > $fileout`;
    }else{
        if ($n_rupt==4){
            # plot grdimage on the top of the earlier maps
            `gmt grdimage $grdfile -I$grdgrad -JL$area_L -R$area -Ctopo.cpt -X-11.1i -Y8.5i -t70  -K -O  >> $fileout`; #shift back x*3 (3.8*3)
        }else{
            # plot grdimage on the top of the earlier maps
            `gmt grdimage $grdfile -I$grdgrad -JL$area_L -R$area -Ctopo.cpt -X3.7i  -t70  -K -O  >> $fileout`;
        }
    }
    # plot coast
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p FONT_ANNOT_PRIMARY 18p MAP_LABEL_OFFSET 2.5p FONT_LABEL 20p FONT_ANNOT_PRIMARY 18p`; # map scale font
    `gmt pscoast -R$area -JL$area_L -Df -W0.5 -S204/229/255  -N1 -Tdg-67.3/-19.5+w0.5i+f1+l",,,N" -Lg-69.4/-43.5+c-72.0/-35+w400k+l"km"+f -O  -K >>$fileout`;
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p FONT_ANNOT_PRIMARY 12p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default
    # plot basemap
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 1.0p MAP_LABEL_OFFSET 3.5p FONT_LABEL 24p FONT_ANNOT_PRIMARY 24p`;
    if ($n_rupt~~@bottom_array){
        if ($n_rupt==0){
            `gmt psbasemap -R$area -JL$area_L -Ba5f2.5g2.5WSen -O  -K >> $fileout`;
        }else{
            `gmt psbasemap -R$area -JL$area_L -Ba5f2.5g2.5wSen -O  -K >> $fileout`;
        }
    }else{
        if ($n_rupt==4){
            `gmt psbasemap -R$area -JL$area_L -Ba5f2.5g2.5Wsen -O  -K >> $fileout`;
        }else{
            `gmt psbasemap -R$area -JL$area_L -Ba5f2.5g2.5wsen -O  -K >> $fileout`;
        }
    }
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default
    
    ##########plot faults edge and slip#########
    # 1.make slip_cpt
    $minslip = `cat $rupt_file | awk 'NR>1{print(sqrt((\$9**2)+(\$10**2)))}' | sort -nk 1 | head -n 1`;
    $maxslip = `cat $rupt_file | awk 'NR>1{print(sqrt((\$9**2)+(\$10**2)))}' | sort -nk 1 | tail -n 1`;
    chomp($minslip);chomp($maxslip);
    $rang_slip=$maxslip-$minslip;
    $interv=$rang_slip/100;
    $maxslip_add=$maxslip+$interv*2;
    if ($maxslip<3){
        $col_inc=0.5;
    }elsif($maxslip>=3 && $maxslip<5){
        $col_inc=1;
    }elsif($maxslip>=5 && $maxslip<10){
        $col_inc=2;
    }elsif($maxslip>=10 && $maxslip<20){
        $col_inc=4;
    }elsif($maxslip>=20 && $maxslip<40){
        $col_inc=8;
    }elsif($maxslip>=40 && $maxslip<60){
        $col_inc=15;
    }elsif($maxslip>=60){
        $col_inc=20;
    }
    $col_inc_half=$col_inc/2; # for psscale
    `gmt makecpt -C$cmap -T$minslip/$maxslip_add/0.05 -Z -V0 > slip.cpt`;
    # 2. plot slip
    $line=2;
    $line_slip=2;
    $nfaults=3076;
    for ($a1=0;$a1<$nfaults;$a1++){
        #Get current line
        print "$line\n";
        `cat $SLAB | awk '(NR==$line){print(\$0)}' >slab.tmp`;
        $line=$line+1;
        `cat $rupt_file | awk '(NR==$line_slip){print(">-Z" (\$10**2+\$9**2)**0.5)}' >element.xy`;
        $line_slip=$line_slip+1;
        #Extracxt node coordinates
        `awk '{print \$5,\$6}' slab.tmp >> element.xy`;
        `awk '{print \$8,\$9}' slab.tmp >> element.xy`;
        `awk '{print \$11,\$12}' slab.tmp >> element.xy`;
        `awk '{print \$5,\$6}' slab.tmp >> element.xy`;
        `gmt psxy element.xy -R -J -L -Cslip.cpt -O -K >>$fileout`; #Use GMT5 if this has issue (plot the triangle color)
        #`gmt psxy element.xy -R -J -W0.01p,100/100/100 -O -K >> $fileout`;
        `gmt psxy element.xy -R -J -W0.01p,200/200/200 -O -K >> $fileout`; #Plot triangle boundary
        if ($a1==50000){
            last;
        }
    }
    ##########plot faults edge and slip END#########
    
    #plot fault depth contour
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 0.5p FONT_LABEL 20p FONT_ANNOT_PRIMARY 18p`;
    `cat $fault | awk 'NR>1{print(\$2,\$3,\$4)}' | gmt pscontour -R -J  -A10,20,30+u" km"+f14p+v+r0.9 -C10,20,30 -W0.5p,50/50/50,-- -O -K >>$fileout`;
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default
    # plot scale
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 0.5p FONT_LABEL 20p FONT_ANNOT_PRIMARY 18p`;
    `gmt psscale -Dx0.4i/3.5i/1.2i/0.12i -Ba${col_inc}f${col_inc_half}:"slip(m)": -Cslip.cpt -E  -O -K  >> $fileout`;
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default

}


# Plot Hemisphere map
`gmt psbasemap -Rd -JA-71/-20/50/1.7i -Ba20f10g10 -Y6.3i -X-11.1i -O -K >>$fileout`; #-Rg or -Rd is the shorthand for "global" g=0/360 d=-180/180
`gmt pscoast -Rd -JA -Ba30f15g15 -Dl -Gwhite -S200/200/200 -W0.5 -N1 -O -K >>$fileout`;
open(PSXY,"|gmt psxy -R -J -W2p,255/0/0 -O -K >>$fileout");
print PSXY "-78 -45\n";
print PSXY "-65.5 -45\n";
print PSXY "-65.5 -17\n";
print PSXY "-78 -17\n";
print PSXY "-78 -45\n";
close(PSXY);
####################

open(PSXY,"|gmt psxy -R -J -O  >>$fileout");
close(PSXY);

# make figure out
`gmt ps2raster $fileout -Tg`; #convert file.ps to file.png

`open Chile_rupts_base.png`;

last;

for ($epo=0;$epo<=101;$epo++){
    `gmt defaults > gmt.conf`; #get original defaults
    `gmt gmtset MAP_FRAME_TYPE fancy`;
    `gmt gmtset FONT_HEADING 1 HEADER_FONT_SIZE 20 MAP_TITLE_OFFSET 0.0p`;
    #$epo=101;
    $epo = sprintf "%03d",$epo;
    $epo_sec = $epo*5+5;
    print "epo=$epo\n";

    $fileout="Chile_rupts.${epo}_new";

    #make a large white background
    #`gmt psbasemap -R -J -Ba5f2.5g2.5WSen -O -K >> $fileout".ps"`;

    #------instead of creating a new map every time, copy the base map--------
    #`gmt grdimage $grdfile -I$grdgrad -JL$area_L -R$area -Ctopo.cpt -Y2i -X1i -P -t70 -K  > $fileout".ps"`;
    `cp Chile_rupts_base.ps $fileout".ps"`;
    
    #pscoast -R$area -JL$area_L -Df -W2 -N1  -S217/231/237 -Lf-128/40/45/200k+l"km"+f -P  -K > $fileout
    #gmt pscoast -R$area -JL$area_L -Df -W2 -N1 -Td -Lg-128/40/40/200k+l"km"+f -O  -K >> $fileout


    #pscoast -R$area -JL$area_L -Df -W2 -N1  -Lf-68/-43/-43/400k+l"km"+f -P -O -K >> $fileout
    `gmt psbasemap -R$area -JL$area_L -Ba5f2.5g2.5WSen -O -K >> $fileout".ps"`;


    #------plot USGS finite fault---------
    #`gmt psxy Melinka_cos2m.xy -W1.2p,255/0/255 -R -J -O -K >>$fileout".ps"`;

    
    #-----------plot prediction fault on map----------
    $pred_fault = `ls /Users/timlin/TEST_MLARGE/Pred_finite_026898/fault_${epo}.txt`; chomp($pred_fault);
    print "current fault file:$pred_fault\n";
    `cat $pred_fault | awk '{print(\$2,\$3)}' |gmt psxy -R -J -G0/0/255 -W0.3p,255/255/255 -Ss0.1c -t60 -O -K >>$fileout".ps"`;
    # -------------------------------------------------

    #-----plot time mark on the map-----
    open(PSTEXT,"|gmt pstext -R -J -O -K >>$fileout'.ps'");
    print PSTEXT "-75.6 -24 12 0 1 2 Time = ${epo_sec} s";
    close(PSTEXT);



    #makecpt -Cjet -T4/54/1 -Z  > depth.cpt
    #`gmt makecpt -Cjet -T6/32/1 -Z >depth.cpt`;
    #cat $fault | awk 'NR>1{print($2,$3,$4)}' |gmt psxy -R -J -G100/100/100  -Ss0.15 -Cdepth.cpt -O -K >>$fileout".ps"

    #plot hypoloc
    #$evlo=`cat $rupt_file | awk 'NR>1  && \$8!=0 && \$13==0{print(\$2)}'`;chomp($evlo);
    #$evla=`cat $rupt_file | awk 'NR>1  && \$8!=0 && \$13==0{print(\$3)}'`;chomp($evla);
    open(PSXY,"|gmt psxy -R -J  -Sa0.25i -W1p,255/0/0 -O -K >>$fileout'.ps'");
    print PSXY "$evlo $evla\n";
    close(PSXY);

    #plot fault depth contour
    `cat $fault | awk 'NR>1{print(\$2,\$3,\$4)}' | gmt pscontour -R -J  -A10,20+u" km" -C5,10,15,20 -W0.5p,50/50/50,-- -O -K >>$fileout".ps"`;

    ##plot stations color-coded with their PGD
    ##$minPGD = `cat $wave_file | awk 'NR>1{print(\$7)}' | sort -nk 1 | head -n 1`;chomp($minPGD);
    #$maxPGD = `cat $wave_file | awk 'NR>1{print(\$7)}' | sort -nk 1 | tail -n 1`; chomp($maxPGD);
    #$maxPGD_plot= $maxPGD + ($maxPGD/100)*2;
    ##print "min,max slip=$minPGD $maxPGD\n";
    #`gmt makecpt -Cjet -T0/$maxPGD_plot/0.1 -Z -V0 > PGD.cpt`; #change the boundary manually
    `cat $stafile | awk 'NR>1{print(\$2,\$3)}' |gmt psxy -R -J -G200/200/200 -W0.3p,0/0/0 -St0.3c -O -K >>$fileout".ps"`;
    # ---plot timeseries vector---
    $minZ = `cat $timeseries | awk 'NR>1{print(\$7)}' | sort -nk 1 | head -n 1`;chomp($minZ);
    $maxZ = `cat $timeseries | awk 'NR>1{print(\$7)}' | sort -nk 1 | tail -n 1`; chomp($maxZ);
    print "minZ,maxZ=$minZ $maxZ\n";
    `gmt makecpt -Cseis -T-2/2/0.01 -Z -V0 > Z.cpt`; #change the boundary manually
    `cat $timeseries | awk '(NR>1 && \$4==${epo_sec}){print(\$1,\$2,\$7)}' |gmt psxy -R -J -CZ.cpt -W0.3p,0/0/0 -St0.3c -O -K >>$fileout".ps"`; #station colorcoded by the Z value
    `cat $timeseries | awk '\$4==${epo_sec}{print(\$1,\$2,\$5*${scale_velo},\$6*${scale_velo},0,0,0)}' | gmt psvelo -R -J -A0.033/0.25/0.06 -G50/50/50  -Se0.16/0.95/0 -O -K  >>$fileout".ps"`;
    #plot disp. scale
    open(PSVELO,"|gmt psvelo -R -J -A0.033/0.25/0.06 -G50/50/50  -Se0.16/0.95/0 -O -K -N >> $fileout'.ps'");
    $tmpscale=3*${scale_velo};
    print PSVELO "-77 -25.6 $tmpscale 0 0 0 0\n";
    close(PSVELO);
    open(PSTEXT,"|gmt pstext -R -J -O -K >>$fileout'.ps'");
    print PSTEXT "-76.3 -26.2 12 0 1 2 3m";
    close(PSTEXT);
    #---plot colorscale---
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 0.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
    `gmt psscale -Dx0.42i/4.7i/0.8i/0.12i -Ba1f0.5:"Z (m)": -CZ.cpt -E  -O -K >> $fileout".ps"`;
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default

        
    # ---plot Wphase solution---
    #open(PSMECA,"|gmt psmeca -C -Sc0.5/12/0 -G0/0/0 -R -J -O -K >> ${fileout}.ps");
    #print PSMECA "-73.941 -43.406 38 356 16 83 183 74 92 7.6 0 -69.3 -41.0 Melinka (7.6)\n";
    #close(PSMECA);
    #-----------------------


    #`cat $wave_file | awk 'NR>1{print(\$2,\$3,\$7)}' |gmt psxy -R -J -CPGD.cpt -W0.4p,0/0/0 -Sc0.24 -N -O -K >>$fileout".ps"`;
    #
    #
    ##plot disp. vectors
    ##` cat $wave_file | awk 'NR>1{print(\$2,\$3,\$5,\$4,0,0,0)}' | gmt psvelo -R -J -A0.05/0.35/0.15 -G255/195/0 -W0.15p,0/0/0 -Se0.16/0.95/0 -O -K -N >> $fileout".ps" `;
    #` cat $wave_file | awk 'NR>1 && \$5<=-0.1 {print(\$2,\$3,\$5*${scale_velo},\$4*${scale_velo},0,0,0)}' | gmt psvelo -R -J -A0.033/0.25/0.06 -G50/50/50  -Se0.16/0.95/0 -O -K -N >> $fileout".ps" `;
    #
    ##plot disp. scale
    #open(PSVELO,"|gmt psvelo -R -J -A0.033/0.25/0.06 -G50/50/50  -Se0.16/0.95/0 -O -K -N >> $fileout'.ps'");
    #$tmpscale=5*${scale_velo};
    #print PSVELO "-128.3 43.60 $tmpscale 0 0 0 0\n";
    #close(PSVELO);
    #open(PSTEXT,"|gmt pstext -R -J -O -K >>$fileout'.ps'");
    #print PSTEXT "-127.92 43.68 12 0 1 2 5m";
    #close(PSTEXT);

    #`gmt psscale -Dx0.5i/1.8i/1.5i/0.15i -Ba10f5:"depth(km)": -Cdepth.cpt -E  -O -K >> $fileout".ps"`;
    #`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 0.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
    #`gmt psscale -Dx0.4i/2.9i/0.8i/0.12i -Ba15f7.5:"slip(m)": -Cslip.cpt -E  -O -K >> $fileout".ps"`;
    #`gmt psscale -Dx0.4i/4.0i/0.8i/0.12i -Ba3f1.5:"PGD(m)": -CPGD.cpt -E  -O -K >> $fileout".ps"`;
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default gmtsetting

    #########Plot coast#########
    #+c-125/43 set the scale accurate at -125/43
    #-Lglon/lat
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 2.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
    `gmt pscoast -R$area -JL$area_L -Df -W0.5 -N1 -Tdg-67.2/-19.5+w0.5i+f1+l",,,N" -Lg-68.5/-43+c-72.0/-30+w400k+l"km"+f -O  -K >>$fileout".ps"`;
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default
    #############################


    #####Plot Hemisphere map###############
    #`psbasemap -Rd -JA$hypo[0]/$hypo[1]/50/1.6i -Ba20f10g10 -K -O -Y5.8i -X-0.8i >>$fileout`; #-Rg or -Rd is the shorthand for "global" g=0/360 d=-180/180
    #`pscoast -Rd -JA$hypo[0]/$hypo[1]/50/1.6i -Ba20f10g10 -Dl -Gwhite -S200/200/200 -W0.8 -N1 -O -K >>$fileout`;
    #`psbasemap -Rd -JA-71/-20/50/1.6i -Ba20f10g10 -K -O -Y5.8i -X-0.8i >>$fileout`; #-Rg or -Rd is the shorthand for "global" g=0/360 d=-180/180
    `gmt psbasemap -Rd -JA-71/-20/50/1.7i -Ba20f10g10 -K -O -Y6.3i -X-0.5i >>${fileout}.ps`; #-Rg or -Rd is the shorthand for "global" g=0/360 d=-180/180
    `gmt pscoast -Rd -JA -Ba30f15g15 -Dl -Gwhite -S200/200/200 -W0.5 -N1 -O -K >>${fileout}.ps`;
    open(PSXY,"|gmt psxy -R -J -W2p,255/0/0 -O -K >>${fileout}.ps");
    print PSXY "-78 -45\n";
    print PSXY "-65.5 -45\n";
    print PSXY "-65.5 -17\n";
    print PSXY "-78 -17\n";
    print PSXY "-78 -45\n";
    close(PSXY);
    ####################


    ###### plot time series ########
    #East/North/Up
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 2.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
    `gmt psbasemap -R0/510/-45/-35 -JX2.5i/3.2i -Ba200f100g100:"Time(s)":/a5f2.5:"Lat.":WSen -G255/255/255 -K -O -Y-6.2i -X4.2i >>${fileout}.ps`;
    #`cat $timeseries | awk '(NR>1 && \$4<=500){print(\$4,\$2+\$5)}' |gmt psxy -R -J -G0/0/0 -Sc0.01c -W0.01p,0/0/200 -O -K >>${fileout}.ps`;

    # get all uniq stations to group together
    #`cat timeseries.txt | awk '(NR>1 && $4<500){print($3)}' | sort | uniq;`;
    #`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default

    @all_sta=`cat $timeseries | awk 'NR>1{print(\$3)}' | sort | uniq`;
    $tcs_scale = 0.2;
    chomp(@all_sta);
    for ($a0=0;$a0<@all_sta;$a0++){
        $curr_sta = $all_sta[$a0];
        print "dealing with:$all_sta[$a0]\n";
        `cat $timeseries | awk '(NR>1 && \$4<=${epo_sec} && \$3=="$curr_sta"){print(\$4,\$2+\$5*$tcs_scale)}' |gmt psxy -R -J  -W0.8p,200/0/0 -O -K >>${fileout}.ps`;
        `cat $timeseries | awk '(NR>1 && \$4<=${epo_sec} && \$3=="$curr_sta"){print(\$4,\$2+\$6*$tcs_scale)}' |gmt psxy -R -J  -W0.8p,0/0/200 -O -K >>${fileout}.ps`;
        `cat $timeseries | awk '(NR>1 && \$4<=${epo_sec} && \$3=="$curr_sta"){print(\$4,\$2+\$7*$tcs_scale)}' |gmt psxy -R -J  -W0.8p,0/200/0 -O -K >>${fileout}.ps`;
        
}
#---plot scale---
open(PSXY,"|gmt psxy -R -J -W1.2p,0/0/0 -O -K >>${fileout}.ps");
print PSXY "420 -38 \n";
print PSXY "420 -39 \n";
close(PSXY);
$value=1/$tcs_scale; #where 1 is the diff(-38,-39)
open(PSTEXT,"|gmt pstext -R -J -O -K >>$fileout'.ps'");
print PSTEXT "460 -38.8 10 0 1 2 ${value}m";
close(PSTEXT);


###### plot parameter predictions #######

$pred_file='/Users/timlin/TEST_MLARGE/pred_parameters_Test001.txt'; #model 001
$runID=2;
    
    
`gmt psbasemap -R0/510/0/195 -JX2.5i/0.6i -Ba200f100g100/a50f25WSen -G255/255/255 -K -O -Y3.55i >>${fileout}.ps`;
`cat $pred_file | awk '(NR>1 && \$1==${runID} && \$2<=${epo_sec}){print(\$2,\$8)}' | gmt psxy -R -J  -W1.2p,0/0/255 -O -K >>${fileout}.ps`;
open(PSTEXT,"|gmt pstext -R -J -O -K >>$fileout'.ps'");
print PSTEXT "460 32 10 0 1 2 Width";
close(PSTEXT);

    
`gmt psbasemap -R0/510/0/900 -JX2.5i/0.6i -Ba200f100g100/a200f100Wsen -G255/255/255 -K -O -Y0.71i >>${fileout}.ps`;
`cat $pred_file | awk '(NR>1 && \$1==${runID} && \$2<=${epo_sec}){print(\$2,\$7)}' | gmt psxy -R -J  -W1.2p,0/0/255 -O -K >>${fileout}.ps`;
open(PSTEXT,"|gmt pstext -R -J -O -K >>$fileout'.ps'");
print PSTEXT "460 195 10 0 1 2 Length";
close(PSTEXT);


`gmt psbasemap -R0/510/20/35 -JX2.5i/0.6i -Ba200f100g100/a5f2.5Wsen -G255/255/255 -K -O -Y0.71i >>${fileout}.ps`;
#---plot real value---
open(PSXY,"|gmt psxy -R -J  -W1.5p,255/0/255,-- -O -K >>${fileout}.ps");
print PSXY "0 $evdp\n";
print PSXY "510 $evdp\n";
close(PSXY);
`cat $pred_file | awk '(NR>1 && \$1==${runID} && \$2<=${epo_sec}){print(\$2,\$6)}' | gmt psxy -R -J  -W1.2p,0/0/255 -O -K >>${fileout}.ps`;
open(PSTEXT,"|gmt pstext -R -J -O -K >>$fileout'.ps'");
print PSTEXT "475 22.5 10 0 1 2 Dep.";
close(PSTEXT);


`gmt psbasemap -R0/510/-45/-35 -JX2.5i/0.6i -Ba200f100g100/a5f2.5Wsen -G255/255/255 -K -O -Y0.71i >>${fileout}.ps`;
#---plot real value---
open(PSXY,"|gmt psxy -R -J  -W1.5p,255/0/255,-- -O -K >>${fileout}.ps");
print PSXY "0 $evla\n";
print PSXY "510 $evla\n";
close(PSXY);
`cat $pred_file | awk '(NR>1 && \$1==${runID} && \$2<=${epo_sec}){print(\$2,\$5)}' | gmt psxy -R -J  -W1.2p,0/0/255 -O -K >>${fileout}.ps`;
open(PSTEXT,"|gmt pstext -R -J -O -K >>$fileout'.ps'");
print PSTEXT "480 -42.5 10 0 1 2 Lat.";
close(PSTEXT);

    
`gmt psbasemap -R0/510/-75/-70 -JX2.5i/0.6i -Ba200f100g100/a2f1Wsen -G255/255/255 -K -O -Y0.71i >>${fileout}.ps`;
#---plot real value---
open(PSXY,"|gmt psxy -R -J  -W1.5p,255/0/255,-- -O -K >>${fileout}.ps");
print PSXY "0 $evlo\n";
print PSXY "510 $evlo\n";
close(PSXY);
`cat $pred_file | awk '(NR>1 && \$1==${runID} && \$2<=${epo_sec}){print(\$2,\$4)}' | gmt psxy -R -J  -W1.2p,0/0/255 -O -K >>${fileout}.ps`;
open(PSTEXT,"|gmt pstext -R -J -O -K >>$fileout'.ps'");
print PSTEXT "480 -74.0 10 0 1 2 Lon.";
close(PSTEXT);


`gmt psbasemap -R0/510/7.45/9.65 -JX2.5i/0.6i -Ba200f100g100/a1f0.5Wsen -G255/255/255 -K -O -Y0.71i >>${fileout}.ps`;
#---plot real value---
open(PSXY,"|gmt psxy -R -J  -W1.5p,255/0/255,-- -O -K >>${fileout}.ps");
print PSXY "0 ${mag}\n";
print PSXY "510 ${mag}\n";
close(PSXY);
open(PSXY,"|gmt psxy -R -J  -W0.8p,255/0/255,-- -O -K >>${fileout}.ps");
$mag_up=$mag+0.3;
print PSXY "0 ${mag_up}\n";
print PSXY "510 ${mag_up}\n";
close(PSXY);
open(PSXY,"|gmt psxy -R -J  -W0.8p,255/0/255,-- -O -K >>${fileout}.ps");
$mag_low=$mag-0.3;
print PSXY "0 ${mag_low}\n";
print PSXY "510 ${mag_low}\n";
close(PSXY);
#-----------------------
`cat $pred_file | awk '(NR>1 && \$1==${runID} && \$2<=${epo_sec}){print(\$2,\$3)}' | gmt psxy -R -J  -W1.2p,0/0/255 -O -K >>${fileout}.ps`;
open(PSTEXT,"|gmt pstext -R -J -O -K >>$fileout'.ps'");
print PSTEXT "480 7.75 10 0 1 2 Mw";
close(PSTEXT);



open(PSXY,"|gmt psxy -R -J -O  >>$fileout'.ps'");
close(PSXY);

#`gmt ps2raster $fileout".ps" -Tf`; #convert file.ps to file.pdf
`gmt ps2raster $fileout".ps" -Tg`; #convert file.ps to file.png
#`gmt ps2raster $fileout".ps" -Tg`;
#`sips -s format png $fileout".pdf" --out $fileout".png"`;
#remove the .pdf,ps files
`rm $fileout".ps"`;
#`rm $fileout".pdf"`;
#`open $fileout".pdf"`;

`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default
    
} #end of epo loop

