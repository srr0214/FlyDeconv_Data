if (!exists(".internal_scRNA_loaded", envir = .GlobalEnv)) {

  message("[INFO] Loading internal scRNA reference data ...")

  load("data/all_tissues_scRNA.RData", envir = .GlobalEnv)

  assign(".internal_scRNA_loaded", TRUE, envir = .GlobalEnv)
}


get_internal_data <- function(tissue, sex, type) {
  
  ## ---------- marker：不分性别 ----------
  if (type %in% c("marker_long", "marker_list")) {
    
    obj_name <- switch(
      type,
      marker_long = paste0(tissue, "_long"),
      marker_list = paste0(tissue, "_list")
    )
    
    if (!exists(obj_name, envir = .GlobalEnv)) {
      stop("Internal data not found: ", obj_name)
    }
    
    return(get(obj_name, envir = .GlobalEnv))
  }
  
  ## ---------- 预留：分性别的数据 ----------
  suffix <- switch(
    sex,
    mix    = "all",
    male   = "male",
    female = "female"
  )
  
  obj_name <- switch(
    type,
    cell_expr     = paste0(tissue, "_cell_", suffix),
    annotation    = paste0(tissue, "_ann_", suffix),
    celltype_expr = paste0(tissue, "_celltype_", suffix),
    stop("Unknown internal data type: ", type)
  )
  
  if (!exists(obj_name, envir = .GlobalEnv)) {
    stop("Internal data not found: ", obj_name)
  }
  
  get(obj_name, envir = .GlobalEnv)
}
