; 2021-04-01
; Get the ensemble mean 

begin
ensemble     = (/"001","002","003","004","005","006","007","008","009","010"/)
ncase        = dimsizes(ensemble)
path         = "/glade/work/kwenwen/SLIM/data_for_inputs/CMIP6-AMIP_1deg_ensemble001-010_1991to2010clim/input4_slim_cam6_2deg_F2000_max-ctrl-bucket_rs150/"
ff           = addfile(path+"slim_fromCMIP6-AMIP-1deg_ensemble001_1991to2010clim_max-ctrl-bucket_rs150_20210401.nc","r")
fo           = addfile(path+"slim_fromCMIP6-AMIP-1deg_ensemble001-010_1991to2010clim_max-ctrl-bucket_rs150_20210401.nc","c")

var_list     = (/"glc_mask",\
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
ntime        = 12
nlat         = 192
nlon         = 288

do     i     = 0,nvar-1
ff_var       = ff->$var_list(i)$
temp         = new((/10,ntime,nlat,nlon/),typeof(ff_var))
	
do     j     = 0,ncase-1
f            = addfile(path+"slim_fromCMIP6-AMIP-1deg_ensemble"+ensemble(j)+"_1991to2010clim_max-ctrl-bucket_rs150_20210401.nc","r")
temp(j,:,:,:) = f->$var_list(i)$
end do

temp_clim    = dim_avg_n_Wrap(temp,0)
copy_VarCoords(ff_var,temp_clim)

fo->$var_list(i)$ = temp_clim
delete(temp)
delete(temp_clim)
end do

fo->time     = ff->time
fo->lsmlat   = ff->lsmlat
fo->lsmlon   = ff->lsmlon

globalAtt          = True
globalAtt@Author   = "Wenwen Kong (wenwenkong@ucla.edu)"
globalAtt@Date_created = systemfunc("date")
globalAtt@Resolution   = "f09_f09_mg17"
globalAtt@Description  = "Forcing file for SLIM (simple land interface model)"
globalAtt@History      = "Modified following Marysa Lague's code"+\
        "No seasonality"+\
        "Retain spatial variation for some variables"
globalAtt@bucketdepth  = "monthly maximum ctrl-bucket: Bucketdepth is calculated by integrating SOILLIQ over the effective root zone depth"
globalAtt@evap_res     = "Evap res cappted at 1000 s/m"
fileattdef(fo,globalAtt)

end
