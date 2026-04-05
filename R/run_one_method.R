## =====================================================
## run_one_method.R
## Run ONE method in a fresh R session (crash-isolated)
## Args:
##   1) job_rds: path to an .rds containing bulk/method/meta
## =====================================================

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) stop("Usage: Rscript run_one_method.R <job_rds>")

job_rds <- args[1]
job <- readRDS(job_rds)

setwd(job$project_dir %||% "/project")
options(stringsAsFactors = FALSE)
options(warn = 1)

`%||%` <- function(a, b) if (!is.null(a)) a else b

## --- hard single-core ---
disable_parallel_global <- function(nthreads = 1) {
  options(
    mc.cores = nthreads,
    parallelly.maxWorkers.localhost = nthreads,
    parallelly.maxWorkers = nthreads
  )
  Sys.unsetenv("_R_CHECK_LIMIT_CORES_")
  Sys.setenv("_R_CHECK_LIMIT_CORES_" = "false")
  Sys.setenv(
    OMP_NUM_THREADS = as.character(nthreads),
    OPENBLAS_NUM_THREADS = as.character(nthreads),
    MKL_NUM_THREADS = as.character(nthreads),
    NUMEXPR_NUM_THREADS = as.character(nthreads),
    VECLIB_MAXIMUM_THREADS = as.character(nthreads),
    RCPP_PARALLEL_NUM_THREADS = as.character(nthreads),
    R_FUTURE_FORK_ENABLE = "false",
    R_PARALLELLY_FORK_ENABLE = "false",
    `_R_CHECK_LIMIT_CORES_` = "false"
  )
  if (requireNamespace("future", quietly = TRUE)) future::plan(future::sequential)
  if (requireNamespace("BiocParallel", quietly = TRUE)) {
    BiocParallel::register(BiocParallel::SerialParam(), default = TRUE)
  }
  if (requireNamespace("foreach", quietly = TRUE)) foreach::registerDoSEQ()
  if (requireNamespace("RhpcBLASctl", quietly = TRUE)) {
    RhpcBLASctl::blas_set_num_threads(nthreads)
    RhpcBLASctl::omp_set_num_threads(nthreads)
  }
  invisible(TRUE)
}
disable_parallel_global(1)

## --- load your framework ---
source("load_methods.R", local = .GlobalEnv)
load_deconv_methods(path = "deconv_function")
source("method_registry.R", local = .GlobalEnv)
source("run_deconv.R", local = .GlobalEnv)

disable_parallel_global(1)

## --- run exactly one method ---
message("=== [SUBPROC] Running method: ", job$method, " ===")
run_deconv(
  bulk      = job$bulk,
  tissue    = job$tissue,
  sex       = job$sex,
  method    = job$method,
  bulk_name = job$bulk_name,
  out_base  = job$out_base
)

message("=== [SUBPROC] Done: ", job$method, " ===")
