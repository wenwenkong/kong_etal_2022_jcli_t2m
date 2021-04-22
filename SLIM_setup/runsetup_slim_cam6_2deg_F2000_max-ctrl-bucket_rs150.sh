#!/bin/bash
# 2021-04-01
# 

tagdir="/glade/work/kwenwen/SLIM/SimpleLand/cime/scripts/"
casebase="/glade/work/kwenwen/SLIM/SimpleLand_runs/coupled/"
case="slim_cam6_2deg_F2000_max-ctrl-bucket_rs150"
compset="2000_CAM60_CLM50%SP_CICE%PRES_DOCN%DOM_SROF_SGLC_SWAV"
res="f19_g16"
project="UCLA0037"
casedir=$casebase$case
rundir=/glade/scratch/kwenwen/$case/

# Create the case
cd $tagdir
./create_newcase --case $casedir --compset $compset --res $res --run-unsupported --project $project

# Edit env_run.xml
cd $casedir
./xmlchange STOP_OPTION="nyears"
./xmlchange STOP_N="5"
./xmlchange RESUBMIT=4

./xmlchange NTASKS_CPL=360
./xmlchange NTASKS_ATM=360
./xmlchange NTASKS_LND=360
./xmlchange NTASKS_ICE=360
./xmlchange NTASKS_OCN=360
./xmlchange NTASKS_ROF=360
./xmlchange NTASKS_GLC=360
./xmlchange NTASKS_WAV=360

# case setup
./case.setup

# Follow SLIM wiki and switch two lines in env_mach_specific.xml
# Copy the "correct" env_mach_specific.xml to the $casedir
cp /glade/work/kwenwen/SLIM/scripts/correct_env_mach_specific/env_mach_specific.xml $casedir

#-------CAM namelist---------
cp /glade/work/kwenwen/SLIM/scripts/slim_cam6_2deg_F2000_cases/max_ctrl_bucket_rs150/user_nl_cam $casedir

#-------CLM namelist --------
cp /glade/work/kwenwen/SLIM/scripts/slim_cam6_2deg_F2000_cases/max_ctrl_bucket_rs150/user_nl_clm $casedir

#-------------------------------

./xmlchange JOB_QUEUE=economy
./xmlchange JOB_WALLCLOCK_TIME=12:00:00
./xmlchange PROJECT=UCLA0037

# build the case
qcmd -A UCLA0037 -- ./case.build --skip-provenance-check

# submit the case
./case.submit
