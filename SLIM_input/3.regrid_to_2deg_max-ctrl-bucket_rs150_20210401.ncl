; 2021-04-01
; Regrid the 1deg ensemble mean of SLIM input to 2-deg

begin
; target resolution
ff_path  = "/glade/work/kwenwen/SLIM/data_for_inputs/CMIP6-AMIP_2deg_ensemble001_1991to2010clim/"
ff       = addfile(ff_path+"slim_fromCMIP6-AMIP-2deg_ensemble001_1991to2010clim_rs100_20201110.nc","r")
xo       = ff->lsmlon
yo       = ff->lsmlat

path     = "/glade/work/kwenwen/SLIM/data_for_inputs/CMIP6-AMIP_1deg_ensemble001-010_1991to2010clim/input4_slim_cam6_2deg_F2000_max-ctrl-bucket_rs150/"
fi       = addfile(path+"slim_fromCMIP6-AMIP-1deg_ensemble001-010_1991to2010clim_max-ctrl-bucket_rs150_20210401.nc","r")
xi       = fi->lsmlon
yi       = fi->lsmlat
fo       = addfile(path+"slim2deg_fromCMIP6-AMIP-1deg_ensemble001-010_1991to2010clim_max-ctrl-bucket_rs150.nc","c")

var_list = (/"glc_mask",\
	     "alb_gvd",\
	     "alb_svd",\
	     "alb_gnd",\
	     "alb_snd",\
	     "alb_gvf",\
	     "alb_svf",\
	     "alb_gnf",\
	     "alb_snf",\
	     "bucketdepth",\
	     "emissivity",\
	     "snowmask",\
	     "roughness",\
	     "evap_res",\
	     "l2xavg_Fall_flxdst1",\
	     "l2xavg_Fall_flxdst2",\
	     "l2xavg_Fall_flxdst3",\
	     "l2xavg_Fall_flxdst4",\
	     "soil_type",\
	     "soil_tk_1d",\
	     "soil_cv_1d",\
	     "glc_tk_1d",\
	     "glc_cv_1d"/)
nvar         = dimsizes(var_list)

fiCyclicX    = True
foOption     = 0

do     i     = 0,nvar-1
fi_var       = fi->$var_list(i)$
ff_var       = ff->$var_list(i)$
temp         = linint2_Wrap(xi, yi, fi_var, fiCyclicX, xo, yo, foOption)
copy_VarCoords(ff_var,temp)

fo->$var_list(i)$ = temp
delete(fi_var)
delete(ff_var)
delete(temp)
end do

fo->time     = ff->time
fo->lsmlat   = ff->lsmlat
fo->lsmlon   = ff->lsmlon

globalAtt         = True
globalAtt@History = "Regridded from slim_fromCMIP6-AMIP-1deg_ensemble001-010_1991to2010clim_max-ctrl-bucket_rs150_20210401.nc"

fileattdef(fo,globalAtt)
end
