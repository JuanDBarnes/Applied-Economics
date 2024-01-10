local num: list sizeof global(covs)
mat def pvals = J(`num',1,.)

local row = 1
foreach var of global covs {
    qui rdrobust `var' $x
    mat pvals[`row',1] =  e(pv_rb)
    local row = `row'+1
	}
frmttable using "filename", statmat(pvals)
