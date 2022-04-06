#!/opt/local/bin/perl -w

# plot the demo of full rupture, paramerized, and model prediction

#\rm .gmtdefaults4
`gmt defaults > gmt.conf`; #get original defaults
`gmt gmtset MAP_FRAME_TYPE fancy`;
`gmt gmtset FONT_HEADING 1 HEADER_FONT_SIZE 20 MAP_TITLE_OFFSET 0.0p`;
#gmt gmtset FONT_LABEL 1 LABEL_FONT_SIZE 10 LABEL_OFFSET 0.1i
#gmt gmtset FONT_ANNOT 1 ANNOT_FONT_SIZE 10 ANNOT_OFFSET 0.1i

#set stafile='/Users/timlin/Documents/Project/NASA/Cascadia/station_info.txt'  #All the Cascadia GPS stations
$stafile='/Users/jtlin/Documents/Project/MLARGE/data/Chile_GNSS.gflist';  #All the Chile GPS stations
#$stafile_exist='/Users/timlin/Documents/Project/NASA/LSTM_training/Chile/chile_GNSS/GMTout/Melinka2016/exist_sta.txt';

$fault='/Users/jtlin/Documents/Project/MLARGE/data/chile.fault';
$SLAB='/Users/jtlin/Documents/Project/MLARGE/data/chile.mshout';
#set grdlarge='/Users/timlin/Documents/Project/GMTplot/Grdfiles/topo15.grd' #input a large GRD file
#grdcut $grdlarge -G$grdfile -R$area
$grdfile='/Users/jtlin/Documents/Project/GMTplot/Grdfiles/chile.grd';  #cut the $grdlarge and use this file
$grdgrad='/Users/jtlin/Documents/Project/GMTplot/Chile/chile.gradient';
#grdgradient $grdfile -G$grdgrad -A90 -Ne0.5


#$timeseries='/Users/timlin/Documents/Project/NASA/LSTM_training/Chile/chile_GNSS/GMTout/Melinka2016/timeseries.txt';
#$timeseries='/Users/jtlin/Documents/Project/GMTplot/Chile_MLARGE/Inputs/Timeseries/timeseries.026898.txt';


$rupt_path='/Users/jtlin/Documents/Project/GMTplot/Chile_GM/output/ruptures'; #example rupture directory
$wave_path='/Users/jtlin/Documents/Project/GMTplot/Chile_GM/output/waveforms';
$prefix='Chile_full_new';
$run_num='024513'; #so that the path of rupt file=rupt_file+'/'+'subduction.'+run_num+'.rupt' # very long (1000+km)
#$run_num='024898'; # very different hypoclo and centroid
#$run_num='023494'; # also very different hypoclo and centroid
#$run_num='021761';
#$run_num='025413';
#$run_num='026294';

$rupt_file="${rupt_path}/${prefix}_subduction.${run_num}.rupt";
$log_file="${rupt_path}/${prefix}_subduction.${run_num}.log";
#$wave_file="${wave_path}/${prefix}_subduction.${run_num}/_summary.subduction.${run_num}.txt";
$wave_file="${wave_path}/${prefix}_subduction.${run_num}";
print "ruptfile=$rupt_file\n";
print "logfile=$log_file\n";
print "wavefile=$wave_file\n";
#$scale_velo=0.4; #scale the psvelo for PGD
#$scale_velo=1.2; #scale the psvelo for PGD

#$test_idx=233; #open the Run031_test_EQID.npy file and check the index manually!!
#use make_y_pred_GMT.py to generate file
$pred_file="./Test031_pred/${prefix}_${run_num}.txt";


# fault boundary
# to generate the fault file, run the python script: make_fault_GMT.py first
$fault_true = "${rupt_path}/${prefix}_subduction.${run_num}_true.fault";
$fault_model = "${rupt_path}/${prefix}_subduction.${run_num}_model.fault";


# convert sac files to one ascii file by python
#`python sac2ascii.py -path $wave_file`;
#$timeseries="${wave_file}/timeseries.txt";
#print "timeseries file:$timeseries\n";

$cmap='/Users/jtlin/Documents/Project/GMTplot/Cpts/color_linear_slip.cpt';#colormap for slip


$minlon=`cat $rupt_file  | awk '(\$9**2+\$10**2)>0{print(\$2)}' | sort -nk 1 |  head -n 1 `;chomp($minlon);
$maxlon=`cat $rupt_file  | awk '(\$9**2+\$10**2)>0{print(\$2)}' | sort -nk 1 |  tail -n 1 `;chomp($maxlon);
$minlat=`cat $rupt_file  | awk '(\$9**2+\$10**2)>0{print(\$3)}' | sort -nk 1 |  head -n 1 `;chomp($minlat);
$maxlat=`cat $rupt_file  | awk '(\$9**2+\$10**2)>0{print(\$3)}' | sort -nk 1 |  tail -n 1 `;chomp($maxlat);

$minlon = $minlon-1.5;
$maxlon = $maxlon+2;
$minlat = $minlat-1;
$maxlat = $maxlat+1;

#set area='-77/-65/-45.0/-17'
#set area_L='-71.0/-31/-29.5/-14/8' #used by -JL
#$area='-78/-65.5/-45.0/-17';
$area="$minlon/$maxlon/$minlat/$maxlat";

print "area=$area\n";

#compass loc
$comp_lon = ($maxlon-$minlon)*0.88+$minlon;
$comp_lat = ($maxlat-$minlat)*0.90+$minlat;

#map scale loc
$map_scale_lon = ($maxlon-$minlon)*0.75+$minlon;
$map_scale_lat = ($maxlat-$minlat)*0.07+$minlat;


#set area_L='-125.0/45/40/50/8' #used by -JL
#$area_L='-71.0/-31/-20/-10/8'; #used by -JL
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

# get the source info from log file
$evlo=`cat $log_file | awk 'NR==17{print(\$3)}' | awk -F, '{print(\$1)}'`;chomp($evlo);
$evlo =~ s/[()]//g;; # remove the bracket
$evla=`cat $log_file | awk 'NR==17{print(\$3)}' | awk -F, '{print(\$2)}'`;chomp($evla);
$evdp=`cat $log_file | awk 'NR==17{print(\$3)}' | awk -F, '{print(\$3)}'`;chomp($evdp);
$evdp =~ s/[()]//g;; # remove the bracket
$mag=`cat $log_file | awk 'NR==16{print(\$4)}'`;chomp($mag);

$base_file = 'Chile_compare_base';

#
###################################This part only needs to be done once################################################
##make a base ps file, plot other things later
#--------------subplot 1-----------------
`gmt grdimage $grdfile -I$grdgrad -JM2.8i -R$area -Cgray_topo.cpt  -Y6.1i -X1i -P -t70  -K > ${base_file}".ps"`;
##########plot faults edge and slip#########
$line=2;
$line_slip=2;
$nfaults=3076;
## make slip_cpt
$minslip = `cat $rupt_file | awk 'NR>1{print(sqrt((\$9**2)+(\$10**2)))}' | sort -nk 1 | head -n 1`;
$maxslip = `cat $rupt_file | awk 'NR>1{print(sqrt((\$9**2)+(\$10**2)))}' | sort -nk 1 | tail -n 1`;
chomp($minslip);chomp($maxslip);
print "minslip=$minslip\n";
print "maxslip=$maxslip\n";

$rang_slip=$maxslip-$minslip;
$interv=$rang_slip/100;
$maxslip_add=$maxslip+$interv*2;
if ($maxslip<5){
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
$col_inc_scale = $col_inc*2;


`gmt makecpt -C$cmap -T$minslip/$maxslip_add/0.5 -Z -V0 > slip_compare.cpt`;

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
    `gmt psxy element.xy -R -J -L -Cslip_compare.cpt -O -K >> ${base_file}".ps"`; #Use GMT5 if this has issue (plot the triangle color)
    #`gmt psxy element.xy -R -J -W0.01p,100/100/100 -O -K >> $fileout`;
    `gmt psxy element.xy -R -J -W0.01p,200/200/200 -O -K >> ${base_file}".ps"`; #Plot triangle boundary
    if ($a1==50000){
        last;
    }
}
#plot hypoloc
open(PSXY,"|gmt psxy -R -J  -Sa0.25i -W1p,0/0/0 -G255/150/35 -O -K >>$base_file'.ps'");
print PSXY "$evlo $evla\n";
close(PSXY);

`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY -3p`;
`gmt psbasemap -R -J -Ba0f0g0wsen:."Rupture #$run_num": -O -K >> ${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p`;
`gmt psbasemap -R -J -Ba5f2.5g2.5WSen -O -K >> ${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 2.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
`gmt pscoast -R$area -J -Df -W1.0 -N1 -Tdg${comp_lon}/${comp_lat}+w0.4i+f1+l",,,N" -Lg${map_scale_lon}/${map_scale_lat}+c${evlo}/${evla}+w200k+l"km"+f -O -K >>${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default

#plot colorbar for slip
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 0.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
#`gmt psscale -Dx0.4i/3.2i/0.8i/0.12i -Ba${col_inc_scale}f${col_inc}:"slip(m)": -Cslip_compare.cpt -E  -O -K >> ${base_file}".ps"`;
`gmt psscale -Dx0.2i/3.5i/1.2i/0.14i -Ba20f10:"slip(m)": -Cslip_compare.cpt -E  -O -K >> ${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default gmtsetting

#--------------subplot 2-----------------
`gmt grdimage $grdfile -I$grdgrad -JM2.8i -R$area -Cgray_topo.cpt   -X3.2i -P -t70 -O  -K >> ${base_file}".ps"`;
#########plot faults edge and slip#########
$line=2;
$line_slip=2;
$nfaults=3076;
## make rupt_time_cpt
$minrtime = `cat $rupt_file | awk 'NR>1{print(\$13)}' | sort -nk 1 | head -n 1`;
$maxrtime = `cat $rupt_file | awk 'NR>1{print(\$13)}' | sort -nk 1 | tail -n 1`;
chomp($minrtime);chomp($maxrtime);
print "minrtime=$minrtime\n";
print "maxrtime=$maxrtime\n";

$rang_rtime=$maxrtime-$minrtime;
$interv=$rang_rtime/100;
$maxrtime_add=$maxrtime+$interv*2;
if ($maxrtime<50){
    $col_inc=10;
}elsif($maxrtime>=50 && $maxrtime<100){
    $col_inc=20;
}elsif($maxrtime>=100 && $maxrtime<200){
    $col_inc=40;
}elsif($maxrtime>=200 && $maxrtime<400){
    $col_inc=100;
}elsif($maxrtime>=400 && $maxrtime<600){
    $col_inc=150;
}elsif($maxrtime>=600){
    $col_inc=200;
}
`gmt makecpt -Crtime.cpt -T$minrtime/$maxrtime_add/$interv  -Z -V0 > slip_compare_rtime.cpt`;

for ($a1=0;$a1<$nfaults;$a1++){
    #Get current line
    print "$line\n";
    `cat $SLAB | awk '(NR==$line){print(\$0)}' >slab.tmp`;
    $line=$line+1;
    `cat $rupt_file | awk '(NR==$line_slip){print(">-Z" \$13)}' >element.xy`;
    $line_slip=$line_slip+1;
    #Extracxt node coordinates
    `awk '{print \$5,\$6}' slab.tmp >> element.xy`;
    `awk '{print \$8,\$9}' slab.tmp >> element.xy`;
    `awk '{print \$11,\$12}' slab.tmp >> element.xy`;
    `awk '{print \$5,\$6}' slab.tmp >> element.xy`;
    `gmt psxy element.xy -R -J -L -Cslip_compare_rtime.cpt -O -K >> ${base_file}".ps"`; #Use GMT5 if this has issue (plot the triangle color)
    #`gmt psxy element.xy -R -J -W0.01p,100/100/100 -O -K >> $fileout`;
    `gmt psxy element.xy -R -J -W0.01p,200/200/200 -O -K >> ${base_file}".ps"`; #Plot triangle boundary
    if ($a1==50000){
        last;
    }
}

#plot hypoloc
open(PSXY,"|gmt psxy -R -J  -Sa0.25i -W1p,0/0/0 -G255/150/35 -O -K >>$base_file'.ps'");
print PSXY "$evlo $evla\n";
close(PSXY);

`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY -3p`;
`gmt psbasemap -R -J -Ba0f0g0wsen:."Rupture #$run_num": -O -K >> ${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p`;
`gmt psbasemap -R -J -Ba5f2.5g2.5wSen -O -K >> ${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 2.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
`gmt pscoast -R$area -J -Df -W1.0 -N1 -Tdg${comp_lon}/${comp_lat}+w0.4i+f1+l",,,N" -Lg${map_scale_lon}/${map_scale_lat}+c${evlo}/${evla}+w200k+l"km"+f -O -K >>${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default

#plot colorbar for rupt_time
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 0.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
#`gmt psscale -Dx0.4i/3.2i/0.8i/0.12i -Ba${col_inc_scale}f${col_inc}:"slip(m)": -Cslip_compare.cpt -E  -O -K >> ${base_file}".ps"`;
`gmt psscale -Dx0.2i/3.5i/1.2i/0.14i -Ba100f50:"rupture time (s)": -Cslip_compare_rtime.cpt -E  -O -K >> ${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default gmtsetting


#--------------subplot 3-----------------
`gmt grdimage $grdfile -I$grdgrad -JM2.8i -R$area -Cgray_topo.cpt  -Y-5.8i -X-3.2i -P -t70 -O  -K >> ${base_file}".ps"`;
#`gmt grdimage $grdfile -I$grdgrad -JM2.8i -R$area -Cgray_topo.cpt  -Y-5.2i -X-3.2i -P -t70 -O  -K >> ${base_file}".ps"`;
#plot parameterized fault
for ($nepo=0;$nepo<102;$nepo++){
    $time = $nepo*5+5;
    $line = `cat $fault_true | awk 'NR==${nepo}{print(\$0)}'`;
    #print "NR=$nepo\n";
#    print "line=$line";
    $line_color = `cat slip_compare_rtime.cpt| awk '\$1>=${time}{print(\$0)}'  | head -n 1 | awk '{print(\$2)}'`;
    chomp($line_color);
    if ($line_color eq 'white'){
        $line_color='black';
    }
    #print "$line_color\n";
    `echo "$line" | gmt psxy -R -J -W1p,"$line_color" -O -K >>$base_file'.ps'`;
}

#plot hypoloc
open(PSXY,"|gmt psxy -R -J  -Sa0.25i -W1p,0/0/0 -G255/150/35 -O -K >>$base_file'.ps'");
print PSXY "$evlo $evla\n";
close(PSXY);
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY -3p`;
`gmt psbasemap -R -J -Ba0f0g0wsen:."Parameterized": -O -K >> ${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p`;
`gmt psbasemap -R -J -Ba5f2.5g2.5WSen -O -K >> ${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 2.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
`gmt pscoast -R$area -J -Df -W1.0 -N1 -Tdg${comp_lon}/${comp_lat}+w0.4i+f1+l",,,N" -Lg${map_scale_lon}/${map_scale_lat}+c${evlo}/${evla}+w200k+l"km"+f -O -K >>${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default

#plot colorbar for rupt_time
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 0.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
#`gmt psscale -Dx0.4i/3.2i/0.8i/0.12i -Ba${col_inc_scale}f${col_inc}:"slip(m)": -Cslip_compare.cpt -E  -O -K >> ${base_file}".ps"`;
`gmt psscale -Dx0.2i/3.5i/1.2i/0.14i -Ba100f50:"rupture time (s)": -Cslip_compare_rtime.cpt -E  -O -K >> ${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default gmtsetting


#--------------subplot 4-----------------
`gmt grdimage $grdfile -I$grdgrad -JM2.8i -R$area -Cgray_topo.cpt   -X3.2i -P -t70 -O  -K >> ${base_file}".ps"`;
#plot model predicted fault
for ($nepo=0;$nepo<102;$nepo++){
    $time = $nepo*5+5;
    $line = `cat $fault_model | awk 'NR==${nepo}{print(\$0)}'`;
    #print "NR=$nepo\n";
#    print "line=$line";
    $line_color = `cat slip_compare_rtime.cpt| awk '\$1>=${time}{print(\$0)}'  | head -n 1 | awk '{print(\$2)}'`;
    chomp($line_color);
    if ($line_color eq 'white'){
        $line_color='black';
    }
    #print "$line_color\n";
    `echo "$line" | gmt psxy -R -J -W1p,"$line_color" -O -K >>$base_file'.ps'`;
}

#plot hypoloc
open(PSXY,"|gmt psxy -R -J  -Sa0.25i -W1p,0/0/0 -G255/150/35 -O -K >>$base_file'.ps'");
print PSXY "$evlo $evla\n";
close(PSXY);
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY -3p`;
`gmt psbasemap -R -J -Ba0f0g0wsen:."Model": -O -K >> ${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p`;
`gmt psbasemap -R -J -Ba5f2.5g2.5wSen -O -K >> ${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 2.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
`gmt pscoast -R$area -J -Df -W1.0 -N1 -Tdg${comp_lon}/${comp_lat}+w0.4i+f1+l",,,N" -Lg${map_scale_lon}/${map_scale_lat}+c${evlo}/${evla}+w200k+l"km"+f -O -K >>${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default


#plot colorbar for rupt_time
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 0.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
#`gmt psscale -Dx0.4i/3.2i/0.8i/0.12i -Ba${col_inc_scale}f${col_inc}:"slip(m)": -Cslip_compare.cpt -E  -O -K >> ${base_file}".ps"`;
`gmt psscale -Dx0.2i/3.5i/1.2i/0.14i -Ba100f50:"rupture time (s)": -Cslip_compare_rtime.cpt -E  -O -K >> ${base_file}".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default gmtsetting


# ending the file
open(PSXY,"|gmt psxy -R -J -O  >>$base_file'.ps'");
close(PSXY);


`gmt ps2raster ${base_file}".ps" -Tg`; #convert file.ps to file.png
`open ${base_file}".png"`;

last;
#########plot faults edge and slip#########
$line=2;
$line_slip=2;
$nfaults=3076;
## make slip_cpt
$minslip = `cat $rupt_file | awk 'NR>1{print(sqrt((\$9**2)+(\$10**2)))}' | sort -nk 1 | head -n 1`;
$maxslip = `cat $rupt_file | awk 'NR>1{print(sqrt((\$9**2)+(\$10**2)))}' | sort -nk 1 | tail -n 1`;
chomp($minslip);chomp($maxslip);
print "minslip=$minslip\n";
print "maxslip=$maxslip\n";

$rang_slip=$maxslip-$minslip;
$interv=$rang_slip/100;
$maxslip_add=$maxslip+$interv*2;
if ($maxslip<5){
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
`gmt makecpt -C$cmap -T$minslip/$maxslip_add/0.5 -Z -V0 > slip_compare.cpt`;

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
    `gmt psxy element.xy -R -J -L -Cslip_compare.cpt -O -K >> ${base_file}".ps"`; #Use GMT5 if this has issue (plot the triangle color)
    #`gmt psxy element.xy -R -J -W0.01p,100/100/100 -O -K >> $fileout`;
    `gmt psxy element.xy -R -J -W0.01p,200/200/200 -O -K >> ${base_file}".ps"`; #Plot triangle boundary
    if ($a1==50000){
        last;
    }
}
######################################This part only needs to be done once##########################################




`gmt defaults > gmt.conf`; #get original defaults
`gmt gmtset MAP_FRAME_TYPE fancy`;
`gmt gmtset FONT_HEADING 1 HEADER_FONT_SIZE 20 MAP_TITLE_OFFSET 0.0p`;

$fileout="Chile_compare_final";



#------instead of creating a new map every time, copy the base map--------
#`gmt grdimage $grdfile -I$grdgrad -JL$area_L -R$area -Ctopo.cpt -Y2i -X1i -P -t70 -K  > $fileout".ps"`;
`cp Chile_rupts_base.ps $fileout".ps"`;
    
    #pscoast -R$area -JL$area_L -Df -W2 -N1  -S217/231/237 -Lf-128/40/45/200k+l"km"+f -P  -K > $fileout
    #gmt pscoast -R$area -JL$area_L -Df -W2 -N1 -Td -Lg-128/40/40/200k+l"km"+f -O  -K >> $fileout

    #pscoast -R$area -JL$area_L -Df -W2 -N1  -Lf-68/-43/-43/400k+l"km"+f -P -O -K >> $fileout
    `gmt psbasemap -R$area -JL$area_L -Ba5f2.5g2.5WSen -O -K >> $fileout".ps"`;

    #------plot USGS finite fault---------
    #`gmt psxy Melinka_cos2m.xy -W1.2p,255/0/255 -R -J -O -K >>$fileout".ps"`;

    
#    #-----------plot prediction fault on map----------
#    $pred_fault = `ls /Users/timlin/TEST_MLARGE/Pred_finite_026898/fault_${epo}.txt`; chomp($pred_fault);
#    print "current fault file:$pred_fault\n";
#    `cat $pred_fault | awk '{print(\$2,\$3)}' |gmt psxy -R -J -G0/0/255 -W0.3p,255/255/255 -Ss0.1c -t60 -O -K >>$fileout".ps"`;
#    # -------------------------------------------------

    #-----plot time mark on the map-----
#    open(PSTEXT,"|gmt pstext -R -J  -C10%/10% -O -K >>$fileout'.ps'");
#    print PSTEXT "-75.6 -24 12 0 1 2 Time = ${epo_sec} s";
#    close(PSTEXT);


    #makecpt -Cjet -T4/54/1 -Z  > depth.cpt
    #`gmt makecpt -Cjet -T6/32/1 -Z >depth.cpt`;
    #cat $fault | awk 'NR>1{print($2,$3,$4)}' |gmt psxy -R -J -G100/100/100  -Ss0.15 -Cdepth.cpt -O -K >>$fileout".ps"

    #plot hypoloc
    open(PSXY,"|gmt psxy -R -J  -Sa0.25i -W1p,255/0/0 -O -K >>$fileout'.ps'");
    print PSXY "$evlo $evla\n";
    close(PSXY);

    #plot fault depth contour
    `cat $fault | awk 'NR>1{print(\$2,\$3,\$4)}' | gmt pscontour -R -J  -A10,20,30+u" km"+r2.0 -C10,20,30 -W0.5p,50/50/50,-- -O -K >>$fileout".ps"`;
    `cat $fault | awk 'NR>1{print(\$2,\$3,\$4)}' | gmt pscontour -R -J  -A20,30+u" km"+r0.5 -C10,20,30 -W0.5p,50/50/50,-- -O -K >>$fileout".ps"`;
    
    #plot rupture time contour
#    `cat $rupt_file | awk '(NR>1 && \$13>0){print(\$2,\$3,\$13)}' | gmt pscontour -R -J  -A100,200,300,400,500+u" s" -C100,200,300,400,500 -W0.5p,50/50/50,-- -O -K >>$fileout".ps"`;

    ##plot stations color-coded with their PGD
    ##$minPGD = `cat $wave_file | awk 'NR>1{print(\$7)}' | sort -nk 1 | head -n 1`;chomp($minPGD);
    #$maxPGD = `cat $wave_file | awk 'NR>1{print(\$7)}' | sort -nk 1 | tail -n 1`; chomp($maxPGD);
    #$maxPGD_plot= $maxPGD + ($maxPGD/100)*2;
    ##print "min,max slip=$minPGD $maxPGD\n";
    #`gmt makecpt -Cjet -T0/$maxPGD_plot/0.1 -Z -V0 > PGD.cpt`; #change the boundary manually
    `cat $stafile | awk 'NR>1{print(\$2,\$3)}' |gmt psxy -R -J -G200/200/200 -W0.3p,0/0/0 -St0.3c -O -K >>$fileout".ps"`;

    # ---plot timeseries vector---
#    $minZ = `cat $timeseries | awk 'NR>1{print(\$7)}' | sort -nk 1 | head -n 1`;chomp($minZ);
#    $maxZ = `cat $timeseries | awk 'NR>1{print(\$7)}' | sort -nk 1 | tail -n 1`; chomp($maxZ);
#    print "minZ,maxZ=$minZ $maxZ\n";
#    `gmt makecpt -Cseis -T-2/2/0.01 -Z -V0 > Z.cpt`; #change the boundary manually
#    `cat $timeseries | awk '(NR>1 && \$4==${epo_sec}){print(\$1,\$2,\$7)}' |gmt psxy -R -J -CZ.cpt -W0.3p,0/0/0 -St0.3c -O -K >>$fileout".ps"`; #station colorcoded by the Z value
#    `cat $timeseries | awk '\$4==${epo_sec}{print(\$1,\$2,\$5*${scale_velo},\$6*${scale_velo},0,0,0)}' | gmt psvelo -R -J -A0.033/0.25/0.06 -G50/50/50  -Se0.16/0.95/0 -O -K  >>$fileout".ps"`;

    #plot disp. scale
#    open(PSVELO,"|gmt psvelo -R -J -A0.033/0.25/0.06 -G50/50/50  -Se0.16/0.95/0 -O -K -N >> $fileout'.ps'");
#    $tmpscale=3*${scale_velo};
#    print PSVELO "-77 -25.6 $tmpscale 0 0 0 0\n";
#    close(PSVELO);
#    open(PSTEXT,"|gmt pstext -R -J -O -K >>$fileout'.ps'");
#    print PSTEXT "-76.3 -26.2 12 0 1 2 3m";
#    close(PSTEXT);

#    #---plot colorscale for Z disp.---
#    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 0.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
#    `gmt psscale -Dx0.42i/4.7i/0.8i/0.12i -Ba1f0.5:"Z (m)": -CZ.cpt -E  -O  -K >> $fileout".ps"`;
#    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default

    
    
    #####plot historical earthquakes########
    #open(PSXY,"|psxy -R -J -G255/0/0 -W0.5p,0/0/0 -Sa0.2i -O -K  >>$fileout");
    open(PSXY,"|gmt psxy -R -J -W1p,0/0/0 -Sa0.2i -O -K  >>${fileout}.ps"); #open circle
    print PSXY "-70.769 -19.610\n";#Iquique2014 M8.2
    print PSXY "-70.493 -20.571\n";#Iquique M7.7 aftershock
    print PSXY "-71.674 -31.573\n";#Illapei2015 M8.3
    print PSXY "-72.898 -36.122\n";#Maule2010 M8.8
    print PSXY "-73.941 -43.406\n";#Melinka2016 M7.6
   
    close(PSXY);
    open(PSMECA,"|gmt psmeca -C -Sc0.5/12/0 -G0/0/0 -R -J -O -K -N >> ${fileout}.ps");
    print PSMECA "-70.769 -19.610 25 358 12 107 161 79 87 8.2 0 -75 -24.5 Iquique (M8.2)\n";
    print PSMECA "-70.493 -20.571 30.5  356 15 100 166 75 87  7.7 0 -74.0 -27.0 IquiqueAft (M7.7)\n";
    print PSMECA "-71.674 -31.573 22.4 353 19 83 180 71 92 8.3 0  -67.8 -31.5 Illapel (M8.3)\n";
    print PSMECA "-72.898 -36.122 22.9  178 77 86  17 14 108   8.8  0 -68 -36.5 Maule (M8.8)\n";
    print PSMECA "-73.941 -43.406 38 356 16 83 183 74 92 7.6 0 -68.8 -41.0 Melinka (M7.6)\n";
    
    close(PSMECA);
    ###########################################
    
    
    
    #########Plot coast#########
    #+c-125/43 set the scale accurate at -125/43
    #-Lglon/lat
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 2.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
    `gmt pscoast -R$area -JL$area_L -Df -W0.5 -N1 -Tdg-67.2/-19.5+w0.5i+f1+l",,,N" -Lg-68.5/-43+c-72.0/-30+w400k+l"km"+f -O -K >>$fileout".ps"`;
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default
    #############################


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
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 0.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
    `gmt psscale -Dx0.4i/3.2i/0.8i/0.12i -Ba15f7.5:"slip(m)": -Cslip_compare.cpt -E  -O -K >> $fileout".ps"`;
#`gmt psscale -Dx0.4i/4.0i/0.8i/0.12i -Ba3f1.5:"PGD(m)": -CPGD.cpt -E  -O -K >> $fileout".ps"`;
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default gmtsetting



    #####Plot Hemisphere map###############
    #`psbasemap -Rd -JA$hypo[0]/$hypo[1]/50/1.6i -Ba20f10g10 -K -O -Y5.8i -X-0.8i >>$fileout`; #-Rg or -Rd is the shorthand for "global" g=0/360 d=-180/180
    #`pscoast -Rd -JA$hypo[0]/$hypo[1]/50/1.6i -Ba20f10g10 -Dl -Gwhite -S200/200/200 -W0.8 -N1 -O -K >>$fileout`;
    #`psbasemap -Rd -JA-71/-20/50/1.6i -Ba20f10g10 -K -O -Y5.8i -X-0.8i >>$fileout`; #-Rg or -Rd is the shorthand for "global" g=0/360 d=-180/180
    `gmt psbasemap -Rd -JA-71/-20/50/1.7i -Ba20f10g10 -K -O -Y6.3i -X-0.5i >>${fileout}.ps`; #-Rg or -Rd is the shorthand for "global" g=0/360 d=-180/180
    `gmt pscoast -Rd -JA -Ba30f15g15 -Dl -Gwhite -S200/200/200 -W0.2 -N1 -O -K >>${fileout}.ps`;
    open(PSXY,"|gmt psxy -R -J -Sa0.36c -W0.8p,255/0/0 -O -K >>${fileout}.ps");
    print PSXY "$evlo $evla\n";
    close(PSXY);
    open(PSTEXT,"|gmt pstext -R -J -F+f12p,Helvetica,blue -O -K >>$fileout'.ps'");
    $Mw_text=sprintf '%.2f', $mag;
    $tmp_evla1=$evla+15;
    $tmp_evla2=$evla+5;
    print PSTEXT "$evlo $tmp_evla1 12 0 1 2 ID:${run_num}\n";
    print PSTEXT "$evlo $tmp_evla2 12 0 1 2 Mw${Mw_text}\n";
    close(PSTEXT);
    ####################



    ###### plot time series ########
    #East/North/Up
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 2.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p FONT_TITLE 16p`;
    $tcs_lat_min=$evla-5;
    $tcs_lat_max=$evla+5;
    `gmt psbasemap -R0/510/$tcs_lat_min/$tcs_lat_max -JX2.5i/3.1i -Ba200f100g100:"Time(s)":/a2.5f1.25:"Lat.":WSen:."Surface deformation": -G255/255/255 -K -O -X4.5i -Y-1.65i >>${fileout}.ps`;
    #`cat $timeseries | awk '(NR>1 && \$4<=500){print(\$4,\$2+\$5)}' |gmt psxy -R -J -G0/0/0 -Sc0.01c -W0.01p,0/0/200 -O -K >>${fileout}.ps`;
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p FONT_TITLE 20p`; #the default gmtsetting

    # get all uniq stations to group together
    #`cat timeseries.txt | awk '(NR>1 && $4<500){print($3)}' | sort | uniq;`;
    #`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default

    @all_sta=`cat $timeseries | awk 'NR>1{print(\$3)}' | sort | uniq`;
    $tcs_scale = 0.1;
    chomp(@all_sta);
    for ($a0=0;$a0<@all_sta;$a0++){
        $curr_sta = $all_sta[$a0];
        print "dealing with:$all_sta[$a0]\n";
        `cat $timeseries | awk '(NR>1 && \$4<=${epo_sec} && \$3=="$curr_sta"){print(\$4,\$2+\$5*$tcs_scale)}' |gmt psxy -R -J  -W0.8p,200/0/0 -O -K >>${fileout}.ps`;
        `cat $timeseries | awk '(NR>1 && \$4<=${epo_sec} && \$3=="$curr_sta"){print(\$4,\$2+\$6*$tcs_scale)}' |gmt psxy -R -J  -W0.8p,0/0/200 -O -K >>${fileout}.ps`;
        `cat $timeseries | awk '(NR>1 && \$4<=${epo_sec} && \$3=="$curr_sta"){print(\$4,\$2+\$7*$tcs_scale)}' |gmt psxy -R -J  -W0.8p,0/200/0 -O -K >>${fileout}.ps`;
    }
    #---plot tcs scale---
    $tmp_loc1=$evla-4-0.5;
    $tmp_loc2=$evla-4+0.5;
    $tmp_loc_mid=($tmp_loc1+$tmp_loc2)*0.5;
    open(PSXY,"|gmt psxy -R -J -W1.2p,0/0/0 -O -K >>${fileout}.ps");
    print PSXY "420 $tmp_loc2 \n";
    print PSXY "420 $tmp_loc1 \n";
    close(PSXY);
    $value=1/$tcs_scale; #where 1 is the diff(-38,-39)
    open(PSTEXT,"|gmt pstext -R -J -C10%/10% -G255/255/255 -O -K >>$fileout'.ps'");
    print PSTEXT "460 $tmp_loc_mid 10 0 1 2 ${value}m";
    close(PSTEXT);
    
 

    
    ###### plot parameter predictions #######
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 2.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p FONT_TITLE 16p`;
    `gmt psbasemap -R0/510/0/200 -JX2.5i/0.6i -Ba200f100g100:"Time(s)":/a100f50:"Width":WSen -G255/255/255 -K -O -Y-4.52i >>${fileout}.ps`;
    # make true v.s. model
    `cat $pred_file | awk '(NR>1 && \$1<=${epo_sec}){print(\$1,\$11)}' | gmt psxy -R -J  -W2p,0/0/0,- -O -K >>${fileout}.ps`;
    `cat $pred_file | awk '(NR>1 && \$1<=${epo_sec}){print(\$1,\$6)}' | gmt psxy -R -J  -W2p,255/0/0 -O -K >>${fileout}.ps`;
    
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 5.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p FONT_TITLE 16p`;
    `gmt psbasemap -R0/510/0/1200 -JX2.5i/0.6i -Ba200f100g100/a500f250:"Length":Wsen -G255/255/255 -K -O -Y0.745i >>${fileout}.ps`;
    `cat $pred_file | awk '(NR>1 && \$1<=${epo_sec}){print(\$1,\$10)}' | gmt psxy -R -J  -W2p,0/0/0,- -O -K >>${fileout}.ps`;
    `cat $pred_file | awk '(NR>1 && \$1<=${epo_sec}){print(\$1,\$5)}' | gmt psxy -R -J  -W2p,255/0/0 -O -K >>${fileout}.ps`;
    
    
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 2.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p FONT_TITLE 16p`;
    `gmt psbasemap -R0/510/-37.5/-31.5 -JX2.5i/0.6i -Ba200f100g100/a2.5f1.25:"Lat.":Wsen -G255/255/255 -K -O -Y0.745i >>${fileout}.ps`;
    `cat $pred_file | awk '(NR>1 && \$1<=${epo_sec}){print(\$1,\$9)}' | gmt psxy -R -J  -W2p,0/0/0,- -O -K >>${fileout}.ps`;
    `cat $pred_file | awk '(NR>1 && \$1<=${epo_sec}){print(\$1,\$4)}' | gmt psxy -R -J  -W2p,255/0/0 -O -K >>${fileout}.ps`;
    
    
    `gmt psbasemap -R0/510/-75/-70 -JX2.5i/0.6i -Ba200f100g100/a2f1:"Lon.":Wsen -G255/255/255 -K -O -Y0.745i >>${fileout}.ps`;
    `cat $pred_file | awk '(NR>1 && \$1<=${epo_sec}){print(\$1,\$8)}' | gmt psxy -R -J  -W2p,0/0/0,- -O -K >>${fileout}.ps`;
    `cat $pred_file | awk '(NR>1 && \$1<=${epo_sec}){print(\$1,\$3)}' | gmt psxy -R -J  -W2p,255/0/0 -O -K >>${fileout}.ps`;
    
    
    `gmt psbasemap -R0/510/7.0/9.6 -JX2.5i/0.6i -Ba200f100g100/a1f0.5:"Mw":Wsen:."Model prediction": -G255/255/255 -K -O -Y0.745i >>${fileout}.ps`;
    `cat $pred_file | awk '(NR>1 && \$1<=${epo_sec}){print(\$1,\$7)}' | gmt psxy -R -J  -W2p,0/0/0,- -O -K >>${fileout}.ps`;
    `cat $pred_file | awk '(NR>1 && \$1<=${epo_sec}){print(\$1,\$2)}' | gmt psxy -R -J  -W2p,255/0/0 -O -K >>${fileout}.ps`;
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p FONT_TITLE 20p`; #the default gmtsetting
    
    
       open(PSXY,"|gmt psxy -R -J -O  >>$fileout'.ps'");
       close(PSXY);
       
    `gmt ps2raster $fileout".ps" -Tg`; #convert file.ps to file.png
    #`gmt ps2raster $fileout".ps" -Tg`;
    #`sips -s format png $fileout".pdf" --out $fileout".png"`;
    #remove the .pdf,ps files
    `rm $fileout".ps"`;
    last; #stop running the rest of the later OLD part!!
   


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
    
    last;
#} #end of epo loop

