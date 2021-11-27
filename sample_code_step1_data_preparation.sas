

/*The sample code is based NIS 2010 data*/
/*NIS data, merged from Core, Hospital, and Severity raw data*/

libname nis 'X:\data\nis'; /*Directory for NIS Core, Hospital, and Severity raw data*/
libname tka 'X:\data\tka'; /*Directory for TKA data*/

/*Remove format*/

proc datasets lib=nis memtype=data;
   modify nis_core;
     attrib _all_ label=' ';
     attrib _all_ format=;
contents data=nis.nis_core;
run;
quit;

/*Identify TKA patients*/

data nis.nis_core;
set nis.nis_core;
array pr{15}  pr1-pr15;

do i=1 to 15 until (pr8154=1);
	if pr{i}='8154' then pr8154=1;
	else pr8154=0;
	end;
drop i;
run;


data tka.tka_data;
set nis.nis_core;
where pr8154=1;
run;

/*Create variables*/

data tka.tka_data;
set tka.tka_data;
array dx{25}  DX1-DX25;

*converting diagnosis of pneumonia into a binary outcome;
do k=1 to 25 until (dxpneumonia=1);
	if dx{k} in('4800','4801','4802','4808','4809','481','482','483','485','486','487','99731') then dxpneumonia=1;
	else dxpneumonia=0;
	end;
drop k;

*converting diagnosis of pulmonary complications into a binary outcome;
do l=1 to 25 until (dxpulmonary=1);
	if dx{l} in('466','5121','514','5180','5184','5185','51881','51882','79910','9973') then dxpulmonary=1;
	else dxpulmonary=0;
	end;
drop l;

*converting diagnosis of cardiopulmonary complications into a binary outcome;
do m=1 to 25 until (dxcardio=1);
	if dx{m} in('410','426','4273','4274','4275','4294','78551','9971') then dxcardio=1;
	else dxcardio=0;
	end;
drop m;

*converting diagnosis of haemorrhage/hematoma complications into a binary outcome;
do n=1 to 25 until (dxhema=1);
	if dx{n} in('9981') then dxhema=1;
	else dxhema=0;
	end;
drop n;

*converting diagnosis of stroke into a binary outcome;
do o=1 to 25 until (dxstroke=1);
	if dx{o} in('43301','43311','43321','43331','43381','43391','43401','43411','43491','99702') then dxstroke=1;
	else dxstroke=0;
	end;
drop o;

*converting diagnosis of sepsis complications into a binary outcome;
do p=1 to 25 until (dxsepsis=1);
	if dx{p} in('038','79070','78552','9954','99802') then dxsepsis=1;
	else dxsepsis=0;
	end;
drop p;

*converting diagnosis of wounds into a binary outcome;
do q=1 to 25 until (dxwound=1);
	if dx{q} in('72992','99812','99813','9983','99851','9986','99883') then dxwound=1;
	else dxwound=0;
	end;
drop q;

*converting diagnosis of venous thromboembolism into a binary outcome;
do r=1 to 25 until (dxembolism=1);
	if dx{r} in('4151','451','4532','4534','4538','4539') then dxembolism=1;
	else dxembolism=0;
	end;
drop r;

*converting diagnosis of inpatient falls into a binary outcome;
do s=1 to 25 until (dxfalls=1);
	if dx{s} in('E8497','E8844') then dxfalls=1;
	else dxfalls=0;
	end;
drop s;

*converting diagnosis of renal complications into a binary outcome;
do t=1 to 25 until (dxrenal=1);
	if dx{t} in('584','586','591','5991','59960','99750') then dxrenal=1;
	else dxrenal=0;
	end;
drop t;

*converting diagnosis of infections into a binary outcome;
do u=1 to 25 until (dxinfection=1);
	if dx{u} in('9985','5670','5901','5902','5908','5909'
                '5950','5959','5990','9980','9584','99889',
                '785','9993','038','790') then dxinfection=1;
	else dxinfection=0;
	end;
drop u;

*converting diagnosis of opiod abuse into a bnary variable;
do v=1 to 25 until (dxopiod=1);
	if dx{v} in('30400','30401','30402','30403','30470','30471',
                '30472','30473','30550','30551','30552','30553',
                '96500','96509','E8502','E9352') then dxopiod=1;
	else dxopiod=0;
	end;
drop v;

***************DETECTING SUBSTRINGS FOR COMPLICATIONS*************
*996 complications;
do i=1 to 25 until (dx996=1);
   if substr(dx{i},1,3) = "996" then dx996=1;
   else dx996=0;
   end;
drop i;

*997 complications;
do j=1 to 25 until (dx997=1);
   if substr(dx{j},1,3) = "997" then dx997=1;
   else dx997=0;
   end;
drop j;

*285 complications;
do k=1 to 25 until (dx285=1);
   if substr(dx{k},1,3) = "285" then dx285=1;
   else dx285=0;
   end;
drop k;

*415 complications;
do l=1 to 25 until (dx415=1);
   if substr(dx{l},1,3) = "415" then dx415=1;
   else dx415=0;
   end;
drop l;

*518 complications;
do m=1 to 25 until (dx518=1);
   if substr(dx{m},1,3) = "518" then dx518=1;
   else dx518=0;
   end;
drop m;

*451 complications;
do n=1 to 25 until (dx451=1);
   if substr(dx{n},1,3) = "451" then dx451=1;
   else dx451=0;
   end;
drop n;

*453 complications;
do o=1 to 25 until (dx453=1);
   if substr(dx{o},1,3) = "453" then dx453=1;
   else dx453=0;
   end;
drop o;

*********************BLOOD TRANSFUSION*************************;
array PR{15}  PR1-PR15;

*converting blood transfusion procedure into a binary variable;
do i=1 to 15 until (pr_blood=1);
	if pr{i} in('9903','9904','990','9900','9902') then pr_blood=1;
	else pr_blood=0;
	end;
drop i;
***************************************************************;

if dx996=1 OR dx997=1 OR dx285=1 OR dx415=1 
   OR dx518=1 OR dx451=1 OR dx453=1 then anycomp=1;
else anycomp = 0;

/*Categorizing discharge disposition*/
if dispuniform=1 then disp_cat=1; *Routine discharge;
else if dispuniform in (2,5,6,7,20,21,99) then disp_cat=0; *Non-routine discharge;
else if dispuniform = . then disp_cat=.;

/*Categorizing length of stay*/
if 0<=los<3 then los_cat=0; *Normal length of stay;
else if los>=3 then los_cat=1; *Prolonged length of stay;
else if los=. then los_cat=.;

/*Categorizing age*/
if 0<age<=44 then age_cat=0;
else if 44<age<=64 then age_cat=1;
else if 64<age<=74 then age_cat=2;
else if 75<=age then age_cat=3;
else if age=. then age_cat=.;

/*Categorizing admission type*/
if atype=3 then atype_cat=1; *Elective admission;
else if atype in (1,2,4,5,6) then atype_cat=2; *Non-elective admission;
else if atype=. then atype=.;

/*Categorizing primary expected payer*/
if pay1=1 then pay1_cat=1; *Medicare as primary payer;
else if pay1=2 then pay1_cat=2; *Medicaid as primary payer;
else if pay1=3 then pay1_cat=3; *Private/HMO insurance as primary payer;
else if pay1 in (4,5,6) then pay1_cat=4; *Other primary payers;
else if pay1=. then pay1_cat=.;

run;


/*Merge data*/

proc sql;
create table table tka.tka_data_pre as 
Select a.*, b.HOSP_BEDSIZE,  b.HOSP_LOCTEACH, b.HOSP_REGION, b.H_CONTRL, c.*
from tka.tka_data as a
left join nis.nis_hospital as b on a.HOSPID = b.HOSPID
left join nis.nis_severity as c on a.KEY = c.KEY

;
quit;


/*Get TKA data ready*/

data tka.tka_data_rdy;
set tka.tka_data_pre; 
keep 
	KEY AMONTH AWEEKEND   
	CM_ALCOHOL CM_ANEMDEF CM_ARTH CM_BLDLOSS   
	CM_CHF CM_CHRNLUNG CM_COAG CM_DEPRESS CM_DM CM_DMCX   
	CM_DRUG CM_HTN_C CM_HYPOTHY CM_LIVER CM_LYMPH   
	CM_LYTES CM_NEURO CM_OBESE CM_PARA CM_PERIVASC   
	CM_PSYCH CM_PULMCIRC CM_RENLFAIL CM_TUMOR    
	CM_VALVE CM_WGHTLOSS      
	HOSPID DISCWT NIS_STRATUM  
	FEMALE H_CONTRL HOSP_BEDSIZE HOSP_LOCTEACH PL_NCHS 
	RACE ZIPINC_QRTL     
	pr_blood   
	age_cat  pay1_cat anycomp los_cat disp_cat YEAR;

where 	age_cat ^=0 and 
	age_cat is not null and
	RACE is not null and 
	H_CONTRL is not null and 
	PL_NCHS is not null
	;
run;


/*Export TKA data ready*/

proc export data= tka.tka_data_rdy 
outfile="X:\data\tka\tka.tka_rdy.csv"
dbms=csv
replace;
run;




