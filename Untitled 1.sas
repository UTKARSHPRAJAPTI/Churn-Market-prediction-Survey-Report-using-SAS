/* Jig14947 */

/* Path :--   */

/* Select_Path */

libname final "Y:\Topic 13 Final_Case_Study";
run;

/* Import the file */

proc import datafile="Y:\Topic 13 Final_Case_Study\telecomfinal.csv"
DBMS=CSV out=final replace;
DATAROW = 2; 
GUESSINGROWS = 2000;
GETNAMES = YES;
Mixed = yes;
SCANTEXT = YES;
run;

/* Data Exploration */

proc contents data= final;
run;

/*

Observations 66297 
Variables 79
   
*/

/* 79-45=34 so 34 are numeric variables
45 variables are character and 34 are numeric. so we covert the charater 
variable to numeric variable by creating dummy variables and also create
buckets for the range variable 
*/

/*
But first check the missing values.
*/

proc means data=final N NMISS MEAN STD MIN MAX MODE MEDIAN;     */  for numeric varibles */
run;

proc freq data=final;                                           /*  76% is non defaulters (50438) and 24% is defaulters (15859) */
table churn;
run;


/* Data Preparation */


/* Missing values treatment */

data final1;
set final;
if income NE 'NA';
inc = income*1;
run;


proc means mean data=final1;
class CRCLSCOD;
var inc;
OUTPUT out = final.predp ( drop = _type_ _freq_ _stat_ );
run;

proc sort data=final;
by CRCLSCOD;
run;

data final2;
merge final (in=a) final.predp (in = b);
by crclscod;
if a and b;
run;

data final2;
set final2;
if income ='NA' then income = inc;
new_income = income*1;
run;

/*
 Convert character variables into numeric variables
*/

data final2;
set final2;
/* Create income bucket based on quartile values */
if new_income LE 4.9 then income_bkt = 1;
else if new_income LE 6 then income_bkt = 2;
else if new_income LE 7 then income_bkt = 3;
else income_pkt = 4;
/* for call wait */
if callwait_mean LE 0 then callwait_bkt = 1;
else if callwait_mean LE 6 then callwait_bkt= 2;
else if callwait_mean LE 7 then callwait_bkt = 3;
else callwait_bkt = 4;
/*create an indicator variable for roaming*/
if ROAM_MEAN > 0 then roam_ind = 1;
else roam_ind = 0;
/* create drop or block calls buckets using quartile values */
if DROP_BLK_MEAN LE 1.67 then drop_blk_bkt = 1;
else if DROP_BLK_MEAN LE 6 then drop_blk_bkt= 2;
else if DROP_BLK_MEAN LE 7 then drop_blk_bkt = 3;
else drop_blk_bkt = 4;
/* for placed voice calls */
if PLCD_VCE_MEAN LE 1.67 then plcd_vce_bkt = 1;
else if PLCD_VCE_MEAN LE 6 then plcd_vce_bkt= 2;
else if PLCD_VCE_MEAN LE 7 then plcd_vce_bkt = 3;
else plcd_vce_bkt = 4;
/* create charactor variables for area of customers */
area_iscity=0;
area_ismount=0;
area_isrural=0;
IF INDEX(area, 'DALLAS') > 0 OR INDEX(area, 'YORK') > 0 OR INDEX(area, 'HOUSTON') > 0 OR 
   INDEX(area, 'ANGELES') > 0 OR INDEX(area, 'CHICAGO') > 0 OR INDEX(area, 'PHILA') > 0 THEN
   area_iscity =1;
ELSE IF INDEX(area, 'ROCKY') > 0 THEN area_ismount = 1;
ELSE area_isrural = 1;
/* create chatator variables for asl-flag */
if asl_flag = 'Y' then aslflag = 1;
else aslflag = 0;

/* covert numeric variables  */
MRC = totmrc_mean*1;
age= age1*1;
handset_price=hnd_price*1;
mean_mou=mou_mean*1;
MOU6AVG = avg6mou*1;
changemou=change_mou*1;
mean_ovrmou = ovrmou_mean*1;
mean_roam=roam_mean*1;

/* create numeric variable for ethic */

isasian = 0;
ishisp=0;
isgerman=0;
isfrench=0;
isafro=0;

if ETHNIC='O' then isasian = 1;
else if ETHNIC = 'H' then ishisp=1;
else if ETHNIC = 'G' then isgerman=1;
else if ETHNIC = 'F' then isfrench=1;
else if ETHNIC = 'Z' then isafro=1;

/* numeric for working woman*/
woman_ind=0;
if wrkwoman = 'Y' then woman_ind = 1;

/* new handset */
hnd_new=0;
if refurb_new = 'N' then hnd_new = 1;

/* car buyer */
car_new=0;
if Car_buy = 'Y' then car_new = 1;

/* car types */
car_reg=0;
car_up=0;
if CARTYPE = 'E' then car_reg = 1;
if CARTYPE = 'F' then car_up = 1;

/* NO CHILDERN */
no_child=0;
if children = 'Y' then no_child = 1;


/* credit class A and AA */
credclass_a=0;
if STRIP(CRCLSCOD) = 'A' then credclass_a = 1;
if STRIP(CRCLSCOD) = 'Aa' then credclass_a = 1;

/* DWELLING SIZE A */
dwell_a=0;
if STRIP(dwllsize) = 'A' then dwell_a = 1;

/* web capable handset */
webcap_ind=0;
if STRIP(hnd_webcap) = 'WCMB' then webcap_ind = 1;

/* INDICATOR VARIABLE FOR IF MODEL USED IS ONlY 1 */
one_model=0;
if models=1 then one_model=1;

/* INDICATOR VARIABLE  */
retcall_ind=1;
if STRIP(RETDAYS) = 'NA' then retcall_ind = 0;

/* BUCKETS FOR AGE */
if eqpdays LE 202 then eqp_age=1;
else if eqpdays LE 326 then eqp_age=2;
else if eqpdays LE  512  then eqp_age=3;
else eqp_age =4;

/* for length of relationship */
if months LE 11 then rship_age =1;
else if months LE  16 then rship_age=2;
else if months LE  24  then rship_age =3;
else rship_age = 4;

/* for avg mou */
if avgmou LE 176.67 then avgmou_bkt =1;
else if avgmou LE  362.5 then avgmou_bkt=2;
else if avgmou LE  660.9  then avgmou_bkt =3;
else avgmou_bkt =4;

/* for total calls  */
if TOTCALLS LE 860 then totalcalls_bkt =1;
else if TOTCALLS LE  1796 then totalcalls_bkt=2;
else if TOTCALLS LE  3508  then totalcalls_bkt =3;
else totalcalls_bkt =4;

/* for total revenue  */
if TOTREV LE 860 then totrev_bkt = 1;
else if TOTREV LE  1796 then totrev_bkt = 2;
else if TOTREV LE  3508  then totrev_bkt = 3;
else totrev_bkt = 4;
run;

/* SPLITTING THE DATA */
proc surveyselect data=final2
method = SRS
out=final_sample
samprate=0.5
outall;
run;

data final.training final.validate;
set final_sample;
if selected = 0 then output final.training;
else if selected = 1 then output final.validate;
run;

/*  NOW APPLYING AND BUILD THE MODEL USING LOGISTIC REGRESSION    */

/*  BECAUSE THE TARGET VARIABLE IS BINARY VARIABLE */

proc logistic data = final.training DESCENDING;
model churn = AVGMOU AVG3MOU plcd_vce_bkt drop_blk_bkt iwylis_vce_mean
              changemou drop_vce_range DROP_VCE_MEAN
              area_ismount aslflag mrc age isasian ishisp isafro handset_price
              mean_ovrmou mean_roam hnd_new no_child webcap_ind models actvsubs uniqsubs
              retcall_ind rship_age eqp_age
              totalcalls_bkt income_bkt callwait_bkt roam_ind
              area_iscity area_isrural mou6avg changemou woman_ind car_new car_reg
              car_up credclass_a dwell_a one_model / selection = forward ctable lackfit
                ;
run;

/*  NOW APPLYING AND BUILD THE MODEL USING LOGISTIC REGRESSION    */

/*  BECAUSE THE TARGET VARIABLE IS BINARY VARIABLE */

proc logistic data = final.validate DESCENDING;
model churn = AVGMOU AVG3MOU plcd_vce_bkt drop_blk_bkt iwylis_vce_mean
              changemou drop_vce_range DROP_VCE_MEAN
              area_ismount aslflag mrc age isasian ishisp isafro handset_price
              mean_ovrmou mean_roam hnd_new no_child webcap_ind models actvsubs uniqsubs
              retcall_ind rship_age eqp_age
              totalcalls_bkt income_bkt callwait_bkt roam_ind
              area_iscity area_isrural mou6avg changemou woman_ind car_new car_reg
              car_up credclass_a dwell_a one_model / selection = forward ctable lackfit
                ;
run;


/* Gain_Chart */

proc logistic data = final2 DESCENDING OUTMODEL = DMM ;
model CHURN = AVGMOU AVG3MOU plcd_vce_bkt drop_blk_bkt   /* iwylis_vce_mean */
              changemou drop_vce_range DROP_VCE_MEAN
              area_ismount aslflag mrc age isasian ishisp isafro handset_price
              mean_ovrmou mean_roam hnd_new no_child webcap_ind /* models */ actvsubs uniqsubs
              retcall_ind rship_age eqp_age
              totalcalls_bkt /* income_bkt callwait_bkt roam_ind
              area_iscity area_isrural mou6avg changemou woman_ind car_new car_reg
              car_up credclass_a dwell_a */ one_model / ctable lackfit ;
              
              SCORE OUT = DMP;
run;


/* Ranking the data  */
PROC RANK DATA = DMP out = final.mobicom_decile GROUPS = 10 TIES = MEAN;
VAR p_1;
RANKS decile;
run;

proc sort data = final.mobicom_decile;
by descending p_1;
run;

/* Export the data */

proc export data=final.mobicom_decile
outfile="Y:\Topic 13 Final_Case_Study\data_gain11.csv"
DBMS = csv;
run;


/* ACCURACY */

data final.mobicom_testacc;
set DMP;
if f_churn=0 and i_churn = 0 then out = "True Negative";
else if f_churn = 1 and i_churn = 0 then out = "False_Negative";
else if f_churn = 0 and i_churn = 1 then out = "False_Positive";
else if f_churn = 1 and i_churn = 1 then out = "True_Positive";
run;

proc freq;
tables out;
run;




