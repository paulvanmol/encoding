%let path=/enable01-export/enable01-aks/homes/paul.van.mol@sas.com/encoding/; 


libname ordetail "&path/orionstar/ordetail" inencoding=wlatin1; 
libname orfmt "&path/orionstar/ordetail" inencoding=wlatin1; 
libname orstar "&path/orionstar/orstar" inencoding=wlatin1; 

libname ordetu8 "&path/orionstaru8/ordetail"; 
libname orstaru8 "&path/orionstaru8/orstar"; 
libname orfmtu8 "&path/orionstaru8/orfmt" ; 

/*step 1: investigate the detail data*/
proc contents data=ordetail.customer;
run;
proc print data=ordetail.customer (obs=15);
run;


/* 2. Expand the space of character variables with CVP engine */
libname ordetail CVP "&path/orionstar/ordetail" inencoding=wlatin1;
proc contents data=ordetail.customer;
run;
proc print data=ordetail.customer (obs=15);
run;

/* 3. Save the SAS data set to SAS with UTF-8 encoding using CVP engine libname */
libname ordetu8 "&path/orionstaru8/ordetail";
data ordetu8.customer;
	set ordetail.customer;
run;
proc contents data=ordetu8.customer;
run;
proc print data=ordetu8.customer (obs=20);
run;

/* 4. Migrate format catalogs to SAS UTF-8 */
libname orfmtu8 "&path/orionstaru8/orfmt" ;
libname orfmt cvp "&path/orionstar/orfmt" inencoding=wlatin1;
proc format cntlin=orfmt.formats lib=orfmtu8;
run;
option fmtsearch=(orfmtu8);
proc print data=ordetu8.customer (obs=20);
run;

/* 5. Migrate index to SAS Viya */
proc datasets lib=ordetu8 nolist;
	modify customer;
	Index create Make / Updatecentiles=5;
quit;
proc contents data = ordetu8.customer;
run;

/* 6. Reset the environment */
option fmtsearch=(work library);
libname u8lib "/enable01-export/enable01-aks/homes/paul.van.mol@sas.com/sgf2020/demos/SD503-Rhein-MigrateDataToUTF8/u8_data";
proc datasets lib = u8lib nolist kill;
quit;
libname euclib clear;
libname euclib2 clear;
libname u8lib clear;