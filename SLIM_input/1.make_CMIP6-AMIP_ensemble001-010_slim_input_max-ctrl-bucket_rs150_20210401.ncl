; 2021-04-01 Wenwen Kong
; SLIM input for "slim_cam6_2deg_F2000_max-ctrl-bucket_rs150"
	; bucketdepth: ctrl-bucket with annual maximum assigned to each grid box
	; evap_res: 150 s/m 

begin
path     = "/glade/work/kwenwen/SLIM/data_for_inputs/CMIP6-AMIP_1deg_ensemble001-010_1991to2010clim/"
ensemble = (/"001","002","003","004","005","006","007","008","009","010"/)
ncase    = dimsizes(ensemble)

ntime         = 12
nlat          = 192
nlon          = 288

stretch       = (/ntime,nlat,nlon/)
ndim          = (/1,2/)

do      k     = 0,ncase-1
casename      = "f.e21.FHIST_BGC.f09_f09_mg17.CMIP6-AMIP."+ensemble(k)+".clm2.h0."

; ************************
;         glc_mask
; ************************
print("---------------------------------")
print("......Creating 'glc_mask'......")
f_PCT_GLACIER = addfile(path+"surfdata_0.9x1.25_78pfts_CMIP6_simyr1850_c170824_PCT_GLACIER.nc","r")
glc_mask      = f_PCT_GLACIER->PCT_GLACIER
glc_mask      = where(glc_mask.ge.50,1,0)
nc_glc_mask   = conform_dims(stretch, glc_mask, ndim)

nc_glc_mask!0            = "time"
nc_glc_mask&time         = ispan(1,ntime,1)
nc_glc_mask!1            = "lsmlat"
nc_glc_mask&lsmlat       = glc_mask&lsmlat
nc_glc_mask&lsmlat@units = glc_mask&lsmlat@units
nc_glc_mask!2            = "lsmlon"
nc_glc_mask&lsmlon       = glc_mask&lsmlon 
nc_glc_mask&lsmlon@units = glc_mask&lsmlon@units
nc_glc_mask@long_name    = "Mask marking gridcells which should be treated as glaciers/ice sheets"
nc_glc_mask@units        = "unitless"
printMinMax(nc_glc_mask,1)
print("......Creating 'glc_mask'......DONE")
print("")

; ************************
;       albedo 
; ************************
print("---------------------------------")
print("......Creating albedo......")
print("")
f_FSRND       = addfile(path+casename+"FSRND.1991-2010.monclim.nc","r")
f_FSDSND      = addfile(path+casename+"FSDSND.1991-2010.monclim.nc","r")
f_FSRNI       = addfile(path+casename+"FSRNI.1991-2010.monclim.nc","r")
f_FSDSNI      = addfile(path+casename+"FSDSNI.1991-2010.monclim.nc","r")
f_FSRVD       = addfile(path+casename+"FSRVD.1991-2010.monclim.nc","r")
f_FSDSVD      = addfile(path+casename+"FSDSVD.1991-2010.monclim.nc","r")
f_FSRVI       = addfile(path+casename+"FSRVI.1991-2010.monclim.nc","r")
f_FSDSVI      = addfile(path+casename+"FSDSVI.1991-2010.monclim.nc","r")

alb_nd        = dim_avg_n_Wrap(f_FSRND->FSRND,0)/dim_avg_n_Wrap(f_FSDSND->FSDSND,0)
alb_nf        = dim_avg_n_Wrap(f_FSRNI->FSRNI,0)/dim_avg_n_Wrap(f_FSDSNI->FSDSNI,0)
alb_vd        = dim_avg_n_Wrap(f_FSRVD->FSRVD,0)/dim_avg_n_Wrap(f_FSDSVD->FSDSVD,0)
alb_vf        = dim_avg_n_Wrap(f_FSRVI->FSRVI,0)/dim_avg_n_Wrap(f_FSDSVI->FSDSVI,0)
copy_VarCoords(glc_mask,alb_nd)
copy_VarCoords(glc_mask,alb_vd)
copy_VarCoords(glc_mask,alb_nf)
copy_VarCoords(glc_mask,alb_vf)
alb_nd@long_name = "Near-infrared direct albedo"
alb_nf@long_name = "Near-infrared diffuse albedo"
alb_vd@long_name = "Visible direct albedo"
alb_vf@long_name = "Visible diffuse albedo"

; Calculate Greenland albedoes
lat1   = 66
lat2   = 76
lon1   = 315
lon2   = 325
alb_nd_greenland = avg(alb_nd({lat1:lat2},{lon1:lon2}))
alb_nf_greenland = avg(alb_nf({lat1:lat2},{lon1:lon2}))
alb_vd_greenland = avg(alb_vd({lat1:lat2},{lon1:lon2}))
alb_vf_greenland = avg(alb_vf({lat1:lat2},{lon1:lon2}))

; Set snow albedoes to greenland value
; Set missing values to 0.1
; Set glacier regions in ground albedo to greenland value
alb_snd = alb_nd
alb_snd = alb_nd_greenland
alb_snd = where(ismissing(alb_snd), 0.1, alb_snd)
nc_alb_snd           = conform_dims(stretch, alb_snd, ndim)
copy_VarCoords(nc_glc_mask,nc_alb_snd)
nc_alb_snd@long_name = "Near-infrared direct albedo for deep snow"
nc_alb_snd@units     = "unitless"
printMinMax(nc_alb_snd,1)
if any(ismissing(nc_alb_snd)) then
	print("STOP!STOP!STOP!...No missing value is allowed.")
	exit()
end if
print("......alb_snd......DONE")
print("")

alb_svd = alb_vd
alb_svd = alb_vd_greenland
alb_svd = where(ismissing(alb_svd), 0.1, alb_svd)
nc_alb_svd           = conform_dims(stretch, alb_svd, ndim)
copy_VarCoords(nc_glc_mask,nc_alb_svd)
nc_alb_svd@long_name = "Visible direct albedo for deep snow"
nc_alb_svd@units     = "unitless"
printMinMax(nc_alb_svd,1)
if any(ismissing(nc_alb_svd)) then
        print("STOP!STOP!STOP!...No missing value is allowed.")
	exit()
end if
print("......alb_svd......DONE")
print("")

alb_snf = alb_nf
alb_snf = alb_nf_greenland
alb_snf = where(ismissing(alb_snf), 0.1, alb_snf)
nc_alb_snf           = conform_dims(stretch, alb_snf, ndim)
copy_VarCoords(nc_glc_mask,nc_alb_snf)
nc_alb_snf@long_name = "Near-infrared diffuse albedo for deep snow"
nc_alb_snf@units     = "unitless"
printMinMax(nc_alb_snf,1)
if any(ismissing(nc_alb_snf)) then
        print("STOP!STOP!STOP!...No missing value is allowed.")
	exit()
end if
print("......alb_snf......DONE")
print("")

alb_svf = alb_vf
alb_svf = alb_vf_greenland
alb_svf = where(ismissing(alb_svf), 0.1, alb_svf)
nc_alb_svf           = conform_dims(stretch, alb_svf, ndim)
copy_VarCoords(nc_glc_mask,nc_alb_svf)
nc_alb_svf@long_name = "Vislble diffuse albedo for deep snow"
nc_alb_svf@units     = "unitless"
printMinMax(nc_alb_svf,1)
if any(ismissing(nc_alb_svf)) then
        print("STOP!STOP!STOP!...No missing value is allowed.")
	exit()
end if
print("......alb_svf......DONE")
print("")

alb_gnd = alb_nd
alb_gnd = where(glc_mask.eq.1,alb_nd_greenland,alb_gnd)
alb_gnd = where(ismissing(alb_gnd), 0.1, alb_gnd)
nc_alb_gnd           = conform_dims(stretch, alb_gnd, ndim)
copy_VarCoords(nc_glc_mask,nc_alb_gnd)
nc_alb_gnd@long_name = "Near-infrared direct albedo for bare ground"
nc_alb_gnd@units     = "unitless"
printMinMax(nc_alb_gnd,1)
if any(ismissing(nc_alb_gnd)) then
        print("STOP!STOP!STOP!...No missing value is allowed.")
	exit()
end if
print("......alb_gnd......DONE")
print("")

alb_gvd = alb_vd
alb_gvd = where(glc_mask.eq.1,alb_vd_greenland,alb_gvd)
alb_gvd = where(ismissing(alb_gvd), 0.1, alb_gvd)
nc_alb_gvd           = conform_dims(stretch, alb_gvd, ndim)
copy_VarCoords(nc_glc_mask,nc_alb_gvd)
nc_alb_gvd@long_name = "Visible direct albedo for bare ground"
nc_alb_gvd@units     = "unitless"
printMinMax(nc_alb_gvd,1)
if any(ismissing(nc_alb_gvd)) then
        print("STOP!STOP!STOP!...No missing value is allowed.")
	exit()
end if
print("......alb_gvd......DONE")
print("")

alb_gnf = alb_nf
alb_gnf = where(glc_mask.eq.1,alb_nf_greenland,alb_gnf)
alb_gnf = where(ismissing(alb_gnf), 0.1, alb_gnf)
nc_alb_gnf           = conform_dims(stretch, alb_gnf, ndim)
copy_VarCoords(nc_glc_mask,nc_alb_gnf)
nc_alb_gnf@long_name = "Near-infrared diffuse albedo for bare ground"
nc_alb_gnf@units     = "unitless"
if any(ismissing(nc_alb_gnf)) then
        print("STOP!STOP!STOP!...No missing value is allowed.")
	exit()
end if
print("......alb_gnf......DONE")
print("")

alb_gvf = alb_vf
alb_gvf = where(glc_mask.eq.1,alb_vf_greenland,alb_gvf)
alb_gvf = where(ismissing(alb_gvf), 0.1, alb_gvf)
nc_alb_gvf        = conform_dims(stretch, alb_gvf, ndim)
copy_VarCoords(nc_glc_mask,nc_alb_gvf)
nc_alb_gvf@long_name = "Visible diffuse albedo for bare ground"
nc_alb_gvf@units     = "unitless"
printMinMax(nc_alb_gvf,1)
if any(ismissing(nc_alb_gvf)) then
        print("STOP!STOP!STOP!...No missing value is allowed.")
	exit()
end if
print("......alb_gvf......DONE")
print("")

; *********************
;    bucketdepth
; *********************
print("---------------------------------")
print("......Creating bucketdepth......")
f_bucket_1 = addfile(path+"f.e21.FHIST_BGC.f09_f09_mg17.CMIP6-AMIP."+ensemble(k)+".clm2.h0.bucketdepth.MillyShmakin2002.19912010.clim.Isla.nc","r")
nc_bucketdepth_1    = f_bucket_1->bucketdepth
nc_bucketdepth_1    = where(ismissing(nc_bucketdepth_1), avg(nc_bucketdepth_1), nc_bucketdepth_1)
copy_VarCoords(nc_glc_mask,nc_bucketdepth_1)
; ----- obtain max
max_bucketdepth  = new((/nlat,nlon/),"float")
do i = 0,nlat-1
do j = 0,nlon-1
max_bucketdepth(i,j) = max(nc_bucketdepth_1(:,i,j))
end do
end do

nc_max_bucketdepth = conform_dims((/ntime,nlat,nlon/),max_bucketdepth,(/1,2/))
copy_VarCoords(nc_glc_mask,nc_max_bucketdepth)

nc_max_bucketdepth@units     = "kg/m2"
nc_max_bucketdepth@long_name = "Bucket capacity"
if any(ismissing(nc_max_bucketdepth)) then
        print("STOP!STOP!STOP!...No missing value is allowed.")
	exit()
end if

nc_bucketdepth = nc_max_bucketdepth
print("......Creating bucketdepth......DONE")
print("")

; *********************
;    emissivity
; *********************
print("---------------------------------")
print("......Creating emissivity......")
nc_emissivity = nc_glc_mask
nc_emissivity = 1
nc_emissivity@long_name = "Surface emissivity for longwave radiation"
nc_emissivity@units     = "unitless"
print("......Creating emissivity......DONE")
print("")

; *********************
;    snowmask
; *********************
print("---------------------------------")
print("......Creating snowmask......")
f_PFT=addfile("/glade/u/home/kwenwen/work/Postdoc_work/SLIM_input/surfdata/PFT_to_MillyShmakin2002a/surfdata_0.9x1.25_78pfts_CMIP6_simyr1850_c170824_to_MillyShmakin2002a.nc","r")
PFT = f_PFT->PCT_NAT_PFT
high_veg = dim_sum_n_Wrap(PFT(0:3,:,:),0)
low_veg  = dim_sum_n_Wrap(PFT(4:6,:,:),0)
snowmask = high_veg
snowmask = 0
snowmask = where(high_veg.gt.low_veg, 100, 40)
nc_snowmask  = conform_dims(stretch, snowmask, ndim)
copy_VarCoords(nc_glc_mask,nc_snowmask)
nc_snowmask@long_name = "Snow-masking depth"
nc_snowmask@units     = "kg/m2"
print("......check snowmask range......")
printMinMax(nc_snowmask,1)
if any(ismissing(nc_snowmask)) then
	print("STOP!STOP!STOP!...No missing value is allowed.")
	exit()
end if
print("......Creating snowmask......DONE")
print("")

; *********************
;    roughness
; *********************
print("---------------------------------")
print("......Creating roughness......")
glc_hc = 0.01
f_HTOP = addfile(path+casename+"HTOP.1991-2010.monclim.nc","r")
roughness   = dim_avg_n_Wrap(f_HTOP->HTOP,0)
roughness   = where(glc_mask.eq.1,glc_hc,roughness)
roughness   = where(ismissing(roughness),glc_hc,roughness)
roughness   = where(roughness.lt.glc_hc,glc_hc,roughness)
nc_roughness= conform_dims(stretch, roughness, ndim)
copy_VarCoords(nc_glc_mask,nc_roughness)
nc_roughness@long_name = "Vegetation height"
nc_roughness@units     = "m"
print("......Creating roughness......DONE")
print("")

; *********************
;    evap_res
; *********************
print("---------------------------------")
print("......Creating evap_res......")
nc_evap_res = nc_glc_mask
nc_evap_res = 150.
copy_VarCoords(nc_glc_mask,nc_evap_res)
nc_evap_res@long_name = "Evaporative resistance"
nc_evap_res@units     = "s/m"
printMinMax(nc_evap_res,1)
print("......Creating evap_res......DONE")
print("")

; *********************
;    Dust fluxes
; *********************
print("---------------------------------")
print("......Creating dust fluxes......")
f_DSTFLXT = addfile(path+casename+"DSTFLXT.1991-2010.monclim.nc","r")
DSTFLXT   = dim_avg_n_Wrap(f_DSTFLXT->DSTFLXT,0)
flxdst    = -1 * 0.25 * DSTFLXT
nc_l2xavg_Fall_flxdst = conform_dims(stretch, flxdst, ndim)
nc_l2xavg_Fall_flxdst = where(ismissing(nc_l2xavg_Fall_flxdst),avg(flxdst),nc_l2xavg_Fall_flxdst)
copy_VarCoords(nc_glc_mask,nc_l2xavg_Fall_flxdst)
nc_l2xavg_Fall_flxdst@long_name = "Dust flux"
nc_l2xavg_Fall_flxdst1= nc_l2xavg_Fall_flxdst
nc_l2xavg_Fall_flxdst2= nc_l2xavg_Fall_flxdst
nc_l2xavg_Fall_flxdst3= nc_l2xavg_Fall_flxdst
nc_l2xavg_Fall_flxdst4= nc_l2xavg_Fall_flxdst
print("......Creating dust fluxes......DONE")
print("")

; *********************
;    soil_type
; *********************
print("---------------------------------")
print("......Creating soil_type......")
nc_soil_type  = nc_glc_mask
nc_soil_type  = 0
nc_soil_type@long_name  = "Soil type: currently useless"
nc_soil_type@units      = "unitless"
print("......Creating soil_type......DONE")
print("")

; *****************************
;    soil_tk_1d & soil_cv_1d
; *****************************
print("---------------------------------")
print("......Creating soil_tk_1d & soil_cv_1d......")
f_soil_tk_1d = addfile(path+"surfdata_0.9x1.25_78pfts_CMIP6_simyr1850_c170824_soil_tk_f.e21.FHIST_BGC.f09_f09_mg17.CMIP6-AMIP."+ensemble(k)+".nc","r")
f_soil_cv_1d = addfile(path+"surfdata_0.9x1.25_78pfts_CMIP6_simyr1850_c170824_soil_cv_f.e21.FHIST_BGC.f09_f09_mg17.CMIP6-AMIP."+ensemble(k)+".nc","r")
soil_tk_1d   = f_soil_tk_1d->soil_tk_1d
soil_cv_1d   = f_soil_cv_1d->soil_cv_1d
soil_tk_1d   = where(ismissing(soil_tk_1d), 0.1, soil_tk_1d)
soil_cv_1d   = where(ismissing(soil_cv_1d), 0.1, soil_cv_1d)
nc_soil_tk_1d= conform_dims(stretch, soil_tk_1d, ndim)
nc_soil_cv_1d= conform_dims(stretch, soil_cv_1d, ndim)
copy_VarCoords(nc_glc_mask,nc_soil_tk_1d)
copy_VarCoords(nc_glc_mask,nc_soil_cv_1d)
nc_soil_tk_1d@long_name = soil_tk_1d@long_name
nc_soil_tk_1d@units     = soil_tk_1d@units
nc_soil_cv_1d@long_name = soil_cv_1d@long_name
nc_soil_cv_1d@units     = soil_cv_1d@units
print("......Creating soil_tk_1d & soil_cv_1d......DONE")

; ****************************
;    glc_tk_1d & glc_cv_1d
; ****************************
print("---------------------------------")
print("......Creating glc_tk_1d & glc_cv_1d......")
; Directly use values from table 2.7 of CLM5 tech note
nc_glc_tk_1d = nc_glc_mask
nc_glc_cv_1d = nc_glc_mask
nc_glc_tk_1d = 2.29  
nc_glc_cv_1d = 2.11727*1e6
nc_glc_tk_1d@units = soil_tk_1d@units
nc_glc_cv_1d@units = soil_cv_1d@units
nc_glc_tk_1d@long_name = "Thermal conductivity of ice"
nc_glc_cv_1d@long_name = "Heat capacity of ice"
print("......Creating glc_tk_1d & glc_cv_1d......DONE")
print("")

; ****************************
;    SLIM input
; ****************************
print("---------------------------------")
print("......Putting all variables to a single netcdf......")
fo_path      = "/glade/work/kwenwen/SLIM/data_for_inputs/CMIP6-AMIP_1deg_ensemble001-010_1991to2010clim/input4_slim_cam6_2deg_F2000_max-ctrl-bucket_rs150/"
fo           = addfile(fo_path+"slim_fromCMIP6-AMIP-1deg_ensemble"+ensemble(k)+"_1991to2010clim_max-ctrl-bucket_rs150_20210401.nc","c")

fo->glc_mask = nc_glc_mask

fo->alb_gvd  = nc_alb_gvd

fo->alb_svd  = nc_alb_svd

fo->alb_gnd  = nc_alb_gnd

fo->alb_snd  = nc_alb_snd

fo->alb_gvf  = nc_alb_gvf

fo->alb_svf  = nc_alb_svf

fo->alb_gnf  = nc_alb_gnf

fo->alb_snf  = nc_alb_snf

fo->bucketdepth = nc_bucketdepth 

fo->emissivity  = nc_emissivity

fo->snowmask    = nc_snowmask

fo->roughness   = nc_roughness

fo->evap_res    = nc_evap_res

fo->l2xavg_Fall_flxdst1 = nc_l2xavg_Fall_flxdst1

fo->l2xavg_Fall_flxdst2 = nc_l2xavg_Fall_flxdst2

fo->l2xavg_Fall_flxdst3 = nc_l2xavg_Fall_flxdst3

fo->l2xavg_Fall_flxdst4 = nc_l2xavg_Fall_flxdst4

fo->soil_type = nc_soil_type

fo->soil_tk_1d= nc_soil_tk_1d

fo->soil_cv_1d= nc_soil_cv_1d

fo->glc_tk_1d = nc_glc_tk_1d

fo->glc_cv_1d = nc_glc_cv_1d

print("......Add global attributes......")

globalAtt          = True
globalAtt@Author   = "Wenwen Kong (wenwenkong@ucla.edu)"
globalAtt@Date_created = systemfunc("date")
globalAtt@Resolution   = "f09_f09_mg17"
globalAtt@Description  = "Forcing file for SLIM (simple land interface model)"
globalAtt@History      = "Modified following Marysa Lague's code"+\
	"No seasonality"+\
	"Retain spatial variation" 
globalAtt@bucketdepth  = "max-ctrl-bucket (Bucketdepth is calculated by integrating SOILLIQ over the effective root zone depth)"
globalAtt@evap_res     = "Evap res = 150s/m"
fileattdef(fo,globalAtt)

print("------ Congrats! ------")
print("......You've created a SLIM input forcing file......")	
end do
end  
