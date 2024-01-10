*! version 1.1.1 22Jan2021
program define art, rclass
version 13

syntax varlist [if] [in]                                                        ///
               [, NOConstant                                                    ///
			      Model(string)                                                 /// 
				  MARgins                                                       ///
			      CLUSTer(string)                                               ///
			      Level(real 95)                                                ///
				  Signs(integer 999)                                            ///
				  TOLerance(real 0.025)                                         ///
				  Report(varlist)] 
 
//DESCRIPTION
//VARLIST				  
//- First variable is the outcome. 
//- Second variable onwards are covariates.
//OPTIONS
//- NOConstant determines whether constant is included in regression
//- Model - (regress, probit, logit)
//- MARgins - Provides marginal effects
//- CLUSTer - Variable that indexes group
//- Level - Confidence level, default is set to 95%
//- Signs - Number of random sign changes, default is set to 999
//- TOLerance - Error level for test inversion algorithm
//- Report - the covariates you want report results on

marksample touse 
gettoken outcome covariates :varlist                                            //Parsing outcome and covariates
tempname N q N_min N_max F_stat b_group S start N_group b_hat N_d pval pval_j   //Creating temporary names to store values
tempvar g_s                                                                     //Creating temporary variable


local vlist : word 1 of `covariates'											// NEW in v1.1. Remove duplicates in list of covariates
foreach varname of varlist `covariates' {
    local toadd = 1
	foreach newvar of varlist `vlist' {
	    if "`newvar'" == "`varname'" {
		    local toadd = 0
			//display "Duplicate " "`newvar'" " removed" 
			break
		}
	}
	if `toadd' == 1 {
	    local vlist `vlist' `varname'
	}
}
local covariates `vlist'



local var_count : word count `covariates'                                       //Counting number of variables
scalar `N_d' = `var_count'                                                      //Storing number of variables 

local constant_count : word count `noconstant'                                  //Counting if noconstant was specified in regression
local margin_count : word count `margins'                                       //Counting if margins was specified in regression
 
if `constant_count'==1 | `margin_count'==1 {
  matrix `S' = J(1, `N_d', 0)                                                   //If noconstant or margins specified then constant is absent in regression, i.e. matrix dimension only on number of variables
}
else {
  matrix `S' = J(1, `N_d'+1, 0)                                                 //Otherwise matrix dimension is number of variables + 1
}

matrix `N_group' = J(1,1,0)                                                     //Null matrix to store number of groups

qui egen `g_s' = group(`cluster')                                               //Generating unique group values
su `g_s', meanonly                                                              //
forvalues i = 1/`r(max)' {
  qui `model' `outcome' `covariates' if `g_s' == `i' & `touse', `noconstant'    //Withing each group run the model with or without constant and margins
  if `margin_count'==1 {
    qui margins, dydx(*)
    matrix `S' = `S' \ r(b)                                                     //Store estimate from model if margins
  }
  else {
    matrix `S' = `S' \ e(b)                                                     //Store estimate from model
  } 
  matrix `N_group' = `N_group' \ `e(N)'                                         //Store number of groups
}

qui `model' `outcome' `covariates' if  `touse', `noconstant'                    //Estimate model using all groups
if `margin_count'==1 {
  qui margins, dydx(*)
  matrix `b_hat' = r(b)                                                         //Store estimate from model if margins
  matrix `start' = r(V)
  }
else {
  matrix `b_hat' = e(b)
  matrix `start' = e(V)
  }
scalar `N' = `e(N)'                                                             //Store total number of observations

mata: crs_work("`report'", "`outcome'", "`covariates'", "`model'",              ///
               "`cluster'", "`touse'", `level', `signs', "`q'", "`N'",          ///
			   "`N_min'", "`N_max'", "`F_stat'", "`b_group'", "`S'", "`start'", ///
			   "`b_hat'", "`N_group'","`noconstant'", "`margins'", `tolerance', ///
			   "`pval'", "`pval_j'")

return scalar level  = `level'                                                  //storing significance level
return scalar pvalue_joint = `pval_j'                                           //storing pvalue of joint test
return scalar F_stat = `F_stat'                                                 //storing value of F statistic
return scalar P = `signs'                                                       //storing number of sign changes
return scalar N_max = `N_max'                                                   //storing maximum number of obs in a group
return scalar N_min = `N_min'                                                   //storing minimum number of obs in a group
return scalar q = `q'                                                           //storing number of groups
return scalar N = `N'                                                           //storing number of observations

return local cmd "crsreg"                                                       //storing command name
return local teststat "Wald"                                                    //storing test statistic used
return local model `model'                                                      //storing model used
return local depvar `covariates'                                                //storing covariate names
return local indepvars `outcome'                                                //storing independent variable name

return matrix pvalues `pval'                                                    //storing computed pvalues
return matrix b_cluster `b_group'                                               //storing estimated values per group
return matrix b `b_hat'                                                         //storing estimated coefficient				   

end


mata:

void crs_work(string scalar report_s, string scalar outcome_s,                  ///
              string scalar covariates_s, string scalar model_s,                ///
              string scalar gvariable_s, string scalar touse_s,                 ///
			  real scalar level_s, real scalar signs_s,                         ///
			  string scalar q_s, string scalar N_s,                             ///
			  string scalar N_min_s, string scalar N_max_s,                     ///
		   	  string scalar F_stat_s, string matrix b_group_s,                  ///
			  string matrix S_s, string matrix start_s,                         ///
			  string matrix b_hat_s, string matrix N_group_s,                   ///
			  string scalar noconstant, string scalar margins_s,                ///    
			  real scalar tolerance_s, string matrix pval_s,                    ///
			  string scalar pval_j_s) {

   rseed(12345)                                                                 //Setting seed for sign changes
   
   theta_reg = st_matrix(b_hat_s)                                               //storing full sample estimates
   S         = st_matrix(S_s)                                                   //storing outcome
   start     = st_matrix(start_s)                                               //
   start     = diagonal(start)'                                                 //              
   N_group   = st_matrix(N_group_s)                                             //storing observations in each group
   Q         = rows(S)                                                          //
   D         = cols(S)                                                          //
   S         = S[2..Q,.]                                                        //storing dataset of estimates, 1 column removed as it is initial condition of 0's
   N_group   = N_group[2..Q,.]                                                  //
   Q         = rows(S)                                                          //storing number of groups           
  
   N          = st_numscalar(N_s)                                               //
   N_min      = min(N_group)                                                    //Min no. of obs. over groups
   N_max      = max(N_group)                                                    //Max no. of obs. over groups
  
   P          = signs_s                                                         //No. of sign changes
   alpha_s    = (100-level_s)/100                                               //Significance level
   k          = ceil((1-alpha_s)*P)                                             //k value in sorted test statistics

   printf("   \n")
   printf("Approximate Randomization Test.\n")
   printf("Model used is {txt}%s.\n", model_s)
   if (margins_s == "") {
   }
   else {
   printf("{bf:Marginal effects are estimated.}\n")
   }
   
  //----------------------------------------------------------------------------
  //----Creating index for which variables to report----------------------------
  //----------------------------------------------------------------------------
   
   name_cov       = tokens(covariates_s)                                        //
   name_rep       = tokens(report_s)                                            //
   rep_ind        = J(1,D,0)                                                    //Start value for storing which index to report
   
   if (report_s == "") {
     rep_ind      = J(1,D,1)                                                    //If report is not specified all variables are reported
   }
   else {
     if ((noconstant,margins_s)==("" , "")) {
       rep_ind[1,D] = 1                                                         //Constant is always reported
	   for (i=1; i <= (D-1); i++) {      										//Indicates whether covariate is in reported variable
	     rep_ind[1,i] =  sum(name_cov[1,(i)] :== name_rep)                      // NEW in v1.1. Checks string equality rather than containment 
																				
       }   
     }
     else {
       rep_ind      = J(1,D,0)                                                  //
	   for (i=1; i <= D; i++) {
	     rep_ind[1,i] = sum(name_cov[1,(i)] :== name_rep)                       // NEW in v1.1. Checks string equality rather than containment 
       }
     }
   }
  
  //----------------------------------------------------------------------------
  //----Creating index for which variables are omitted due to no variation------
  //----------------------------------------------------------------------------
  
   ind       = J(1,D,0)                                                         //Index for storing which variable values are omitted
   for (i=1; i <= D; i++) {
      ind[.,i]  = 1 - allof(S[.,i],0)                                           //Index gets a value of 0 if variable is omitted, i.e. gets a value of 0 in every group
   }
   
  //----Creating matrix for joint test------------------------------------------
   
   ind_joint  = (ind' :* rep_ind')'                                             //Index for non-omitted+reported variables
   S_joint    = select(S, ind_joint[1,.])                                       //Selecting only above variables
   D_joint    = cols(S_joint)                                                   //Number of non omitted+reported variables 
   
   clust_num  = J(1,D_joint,0)                                                  //Index for storing number of cluster para. identified in nonomited+reported variables
   for (i=1; i <= D_joint; i++) {
      S_temp         = S_joint[.,i]
	  S_temp         = select(S_temp, S_temp[.,1])
	  clust_num[1,i] = rows(S_temp)  
   }
   if (min(clust_num) <= 6) {
     printf("{bf:(Warning: Number of clusters maybe too few for numerical perf. of non. rand. version of test) }\n") 
   }  
   
   select_joint = J(Q,1,0)                                                      //Index for storing which groups are not omitted in computing joint test statistic
   for (i=1; i <= Q; i++) {
      select_joint[i,.] = 1 - anyof(S_joint[i,.],0)                             //Gives value of 0 if any element in group is unidentified, i.e. is equal to 0
   }   
   S_joint   = select(S_joint, select_joint[.,1])                               //Selecting only groups where all parameters are identified
   Q_joint   = rows(S_joint)                                                    //Number of groups where all parameters are identified
   if (Q == Q_joint) {
   }
   else {
   printf("{bf:(Warning: Parameters unidentified in some groups, see stored estimates) }\n")
   }
  
  
  //----------------------------------------------------------------------------
  //----Mean estimates across clusters------------------------------------------
  //----------------------------------------------------------------------------
  
   theta_hat  = J(1,D,0)                                                        //Initial vector to store mean of estimates over groups
   for (i=1; i <= D; i++) {
     S_temp         = S[.,i]                                                    //Temp vector of estimates for the ith covariate
	 S_temp         = select(S_temp, S_temp[.,1])                               //Selecting only non-zero estimates as otherwise there are not identified
	 theta_hat[.,i] = mean(S_temp)                                              //Mean using only identified estimates
   }
   
   //---------------------------------------------------------------------------
   //----Pvalues for the null of no effect--------------------------------------
   //---------------------------------------------------------------------------
   
   G          = runiform(Q,P)                                                   //
   G          = 2:*(G :<= 0.5) :- 1                                             //Random signs changes for each group
   
   //----Pvalue for individual coefficients-------------------------------------
   
   pval        = J(1,D,0)                                                       //Null matrix for pvalues of estimates
   for (i=1; i <= D; i++) {
     if ((ind[1,i],rep_ind[1,i]) == (1,1)) {
	   pval[.,i]   = pval(S[.,i],0,G)                                           //
     }
   }
   
   //----Pvalue for joint test--------------------------------------------------
   
   theta_joint   = mean(S_joint)                                                //Mean estimate over groups where all parameters are identified
   if ((noconstant,margins_s)==("" , "")) {
     V          = (S_joint[.,1..(D_joint-1)]'*S_joint[.,1..(D_joint-1)])        //
	 TS_joint   = theta_joint[1,1..(D_joint-1)]*cholinv(V)*                     ///
	              theta_joint[1,1..(D_joint-1)]'                                //Joint Wald test without constant
   }
   else {
     V          = S_joint'*S_joint                                              //
	 TS_joint   = theta_joint[1,.]*cholinv(V)*theta_joint[1,.]'                 //
   } 
   TS_joint_p  = J(P,1,0)                                                       //Null matrix for values of sign changes joint TS
   for (i=1; i <= P; i++) {
     g          = G[.,i]                                                        //{-1,1}^q for random sign changes
     S_temp     = g:*S                                                          //transforming the estimates with these sign changes
	 S_p        = select(S_temp, ind_joint[1,.])                                //Selecting only variables that are not omitted
	 S_p        = select(S_p, select_joint[.,1])                                //Selecting only groups where all parameters are identified
	 theta_p    = mean(S_p)                                                     //Mean of estimates over groups over sign changes dataset
	 if ((noconstant,margins_s)==("" , "")) {
       V_p             = (S_p[.,1..(D_joint-1)]'*S_p[.,1..(D_joint-1)])         //
	   TS_joint_p[i,1] = theta_p[1,1..(D_joint-1)]*cholinv(V_p)*                ///
	                     theta_p[1,1..(D_joint-1)]'                             //Joint Wald test without constant
     }
     else {
       V_p             = S_p'*S_p                                               //
	   TS_joint_p[i,1] = theta_p[1,.]*cholinv(V_p)*theta_p[1,.]'                //    
     }
   }
   pval_joint   = mean((TS_joint_p :>= TS_joint))                               //P value for joint test excluding constant
   
   //---------------------------------------------------------------------------
   //----CI using test inversion with a bisection algorithm---------------------
   //---------------------------------------------------------------------------
   //printf("Working")
   //displayflush()
   U           = J(1,D,0)                                                       //Null matrix to store upper value of CI
   L           = J(1,D,0)                                                       //Null matrix to store lower value of CI
   for (i=1; i <= D; i++) {
     if ((ind[1,i],rep_ind[1,i]) == (1,1)) {
   
   //----Upper value of Confidence Interval-------------------------------------
       
	   range_s     = start[.,i]                                                 //Grid jumps for bisection algorithm
	   theta_1     = theta_hat[.,i]                                             //Starting val. 
	   theta_2     = theta_hat[.,i] + (2*range_s)                               //First point to the right 
	   theta_0     = theta_2                                                    // 
	   pval_u      = pval(S[.,i],theta_0,G)                                     //pval calculation
	   while (pval_u  >= alpha_s) { 
	     theta_1   = theta_2                                                    //If you don't reject move further to right
	     theta_2   = theta_2 + range_s                                          //                                                       
	     theta_0   = theta_2                                                    //
	     pval_u    = pval(S[.,i],theta_0,G)                                     //
		// pval_u
	   }  
	   while (abs(pval_u - alpha_s)  > tolerance_s) {                             
	     theta_0   = (theta_1 + theta_2)/2                                      //If you reject move to midpoint of last two points                                                     //
         pval_u    = pval(S[.,i],theta_0,G)                                     //
		// pval_u
	     if (pval_u > alpha_s){                                                   
	       theta_1       = theta_0                                              //
	     }
	     else {
	       theta_2       = theta_0                                              //
	     }
	   }
	   U[.,i]      = theta_0                                                    //
	 
   //--Lower bound on Confidence Interval---------------------------------------
   
	   theta_1     = theta_hat[.,i]                                             //
	   theta_2     = theta_hat[.,i] - (2*range_s)                               //Start val. 
	   theta_0     = theta_2                                                    //
	   pval_l      = pval(S[.,i],theta_0,G)                                     //pval calculation                                                                             
	   while (pval_l  >= alpha_s) {                                               
	     theta_1   = theta_2                                                    //If you don't reject move to the left
	     theta_2   = theta_2 - range_s                                          //   
	     theta_0   = theta_2                                                    //
	     pval_l    = pval(S[.,i],theta_0,G)                                     //
	   }      
	   while (abs(pval_l - alpha_s)  > tolerance_s) {	   
	     theta_0   = (theta_1 + theta_2)/2                                      //If you reject move to midpoint of last two points                                                     //
	     pval_l    = pval(S[.,i],theta_0,G)                                     //
	       if (pval_l > alpha_s){                                                 
	         theta_1       = theta_0                                            //
	       }
	       else {
	         theta_2       = theta_0                                            //
	       }
	    }  
	    L[.,i]      = theta_0                                                   //
	 }
	 else {
	 U[.,i] = 0                                                                 //
	 L[.,i] = 0                                                                 //
	 }
   }
   
   //---------------------------------------------------------------------------
   //----Storing results to view in Stata---------------------------------------
   //---------------------------------------------------------------------------
   
   st_numscalar(N_min_s, N_min)                                                 //Storing min obs in a group to be viewed in stata
   st_numscalar(N_max_s, N_max)                                                 //Storing max obs in a group to be viewed in stata
   st_numscalar(q_s, Q)                                                         //Storing no. of groups to be viewed in stata
   st_numscalar(F_stat_s, TS_joint)                                             //Storing F_stat value to be viewed in stata
   st_numscalar(pval_j_s, pval_joint)                                           //Storing pvalue of joint test to view in stata
   st_matrix(pval_s, pval)                                                      //Storing pvalues to view in stata
   st_matrix(b_group_s, S)                                                      //Storing matrix of coefficients to be viewed in stata
   
   //----Producing output table to view in Stata--------------------------------
   
   printf("   \n")
   printf("    {txt}%s {c |}  {txt}%10s                  Number of obs          = %10.0g\n","Cluster var", gvariable_s, N)   
   printf("{hline 16}{c +}{hline 19}           F statistic            = %10.0g\n", TS_joint)
   printf("         Number {c |}  %10.0g                  Prob > F_stat          = %10.0g\n", Q, pval_joint)   
   printf("        Max obs {c |}  %10.0g                  Test statistic         =       Wald\n",  N_max)
   printf("        Min obs {c |}  %10.0g                  Number of sign changes = %10.0g \n", N_min, P)
   printf("   \n")
   printf("{hline 16}{c TT}{hline 65}\n")
   printf("     {txt}%10s {c |}       Coef.        Mean      P.value       [%f%% Conf. Interval] \n", outcome_s,level_s)
   printf("{hline 16}{c +}{hline 65}\n")
   if ((noconstant,margins_s)==("" , "")) {
   for (i=1; i <= (D-1); i++) {
   if (rep_ind[1,i] == 1) {
   if (ind[1,i] == 1) {
   printf("     {txt}%10s {c |} {res} %10.0g   %10.0g   %10.0g    %10.0g   %10.0g\n", name_cov[1,(i)], theta_reg[1,i], theta_hat[1,i], pval[1,i], L[1,i], U[1,i])
   }
   else {
   printf("     {txt}%10s {c |} {res}         {txt}%10s    \n", name_cov[1,(i)], "(omitted)")
   }
   }
   }
   printf("          {txt}%s {c |} {res} %10.0g   %10.0g   %10.0g    %10.0g   %10.0g\n","_cons", theta_reg[1,D], theta_hat[1,D], pval[1,D], L[1,D], U[1,D])
   }
   else {
   for (i=1; i <= D; i++) {
   if (rep_ind[1,i] == 1){
   if (ind[1,i] == 1) {
   printf("     {txt}%10s {c |} {res} %10.0g   %10.0g   %10.0g    %10.0g   %10.0g\n", name_cov[1,(i)], theta_reg[1,i], theta_hat[1,i], pval[1,i], L[1,i], U[1,i])
   }
   else {
   printf("     {txt}%10s {c |} {res}         {txt}%10s    \n", name_cov[1,(i)], "(omitted)")
   }
   }
   }
   }
   printf("{hline 16}{c BT}{hline 65}\n")


}

end

mata:
   //----------------------------------------------------------------------------
   //----Function for calculating pvalue-----------------------------------------
   //----------------------------------------------------------------------------
  
   function pval(S_f,theta_0_f, G_f) {
     S_temp    = S_f                                                             //
     G_temp    = select(G_f, S_temp[.,1])                                        //
     S_temp    = select(S_temp, S_temp[.,1])                                     //
     S_temp    = S_temp :- theta_0_f                                             //
     V_q       = (S_temp :- mean(S_temp))'*(S_temp :- mean(S_temp))              //
     TS_temp   = abs(mean(S_temp))/sqrt(V_q)                                     //
     S_p       = S_temp :* G_temp                                                //
     V_q_p     = (S_p :- mean(S_p))'*(S_p :- mean(S_p))                          //
     V_q_p     = diagonal(V_q_p)                                                 //
     TS_p      = abs(mean(S_p)) :/ sqrt(V_q_p)'                                  //
     pval      = mean((TS_p' :>= TS_temp))                                       //
  
     return(pval)                                                                //
   }

end
