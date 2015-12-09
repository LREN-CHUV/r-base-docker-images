#!/usr/bin/env r
#
# A simple example to install one or more packages from GitHub
#
# Copyright (C) 2014 - 2015  Carl Boettiger and Dirk Eddelbuettel
#
# Released under GPL (>= 2)

##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/utils.r
## 

# Given the name or vector of names, returns a named vector reporting
# whether each exists and is a directory.
dir.exists <- function(x) {
  res <- file.exists(x) & file.info(x)$isdir
  stats::setNames(res, x)
}

compact <- function(x) {
  is_empty <- vapply(x, function(x) length(x) == 0, logical(1))
  x[!is_empty]
}

"%||%" <- function(a, b) if (!is.null(a)) a else b

"%:::%" <- function(p, f) {
  get(f, envir = asNamespace(p))
}

rule <- function(..., pad = "-") {
  if (nargs() == 0) {
    title <- ""
  } else {
    title <- paste0(...)
  }
  width <- getOption("width") - nchar(title) - 1
  message(title, " ", paste(rep(pad, width, collapse = "")))
}

# check whether the specified file ends with newline
ends_with_newline <- function(path) {
  conn <- file(path, open = "rb", raw = TRUE)
  on.exit(close(conn))
  seek(conn, where = -1, origin = "end")
  lastByte <- readBin(conn, "raw", n = 1)
  lastByte == 0x0a
}

render_template <- function(name, data = list()) {
  path <- system.file("templates", name, package = "devtools")
  template <- readLines(path)
  whisker::whisker.render(template, data)
}

is_installed <- function(pkg, version = 0) {
  system.file(package = pkg) != "" && packageVersion(pkg) > version
}

read_dcf <- function(path) {
  fields <- colnames(read.dcf(path))
  as.list(read.dcf(path, keep.white = fields)[1, ])
}

write_dcf <- function(path, desc) {
  desc <- unlist(desc)
  # Add back in continuation characters
  desc <- gsub("\n[ \t]*\n", "\n .\n ", desc, perl = TRUE, useBytes = TRUE)
  desc <- gsub("\n \\.([^\n])", "\n  .\\1", desc, perl = TRUE, useBytes = TRUE)

  text <- paste0(names(desc), ": ", desc, collapse = "\n")

  if (substr(text, nchar(text), 1) != "\n") {
    text <- paste0(text, "\n")
  }

  cat(text, file = path)
}

dots <- function(...) {
  eval(substitute(alist(...)))
}

first_upper <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  x
}

download <- function(path, url, ...) {
  request <- httr::GET(url, ...)
  httr::stop_for_status(request)
  writeBin(httr::content(request, "raw"), path)
  path
}

download_text <- function(url, ...) {
  request <- httr::GET(url, ...)
  httr::stop_for_status(request)
  httr::content(request, "text")
}

last <- function(x) x[length(x)]

# Modified version of utils::file_ext. Instead of always returning the text
# after the last '.', as in "foo.tar.gz" => ".gz", if the text that directly
# precedes the last '.' is ".tar", it will include also, so
# "foo.tar.gz" => ".tar.gz"
file_ext <- function (x) {
    pos <- regexpr("\\.((tar\\.)?[[:alnum:]]+)$", x)
    ifelse(pos > -1L, substring(x, pos + 1L), "")
}

is_bioconductor <- function(x) {
  !is.null(x$biocviews)
}

trim_ws <- function(x) {
  gsub("^[[:space:]]+|[[:space:]]+$", "", x)
}

##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/utils.r
## 


##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/package-env.r
## 

# Create the package environment where exported objects will be copied to
attach_ns <- function(pkg = ".") {
  pkg <- as.package(pkg)
  nsenv <- ns_env(pkg)

  if (is_attached(pkg)) {
    stop("Package ", pkg$package, " is already attached.")
  }

  # This should be similar to attachNamespace
  pkgenv <- attach(NULL, name = pkg_env_name(pkg))
  attr(pkgenv, "path") <- getNamespaceInfo(nsenv, "path")
}

# Invoke namespace load actions. According to the documentation for setLoadActions
# these actions should be called at the end of processing of S4 metadata, after
# dynamically linking any libraries, the call to .onLoad(), if any, and caching
# method and class definitions, but before the namespace is sealed
run_ns_load_actions <- function(pkg = ".") {
  nsenv <- ns_env(pkg)
  actions <- methods::getLoadActions(nsenv)
  for (action in actions)
    action(nsenv)
}

# Copy over the objects from the namespace env to the package env
export_ns <- function(pkg = ".") {
  pkg <- as.package(pkg)
  nsenv <- ns_env(pkg)
  pkgenv <- pkg_env(pkg)
  nsInfo <- parse_ns_file(pkg)

  exports <- getNamespaceExports(nsenv)
  importIntoEnv(pkgenv, exports, nsenv, exports)

  # If lazydata is true, manually copy data objects in $lazydata to package
  # environment
  if (!is.null(pkg$lazydata) &&
      tolower(pkg$lazydata) %in% c("true", "yes")) {
    copy_env(src = nsenv$.__NAMESPACE__.$lazydata, dest = pkgenv)
  }
}


#' Return package environment
#'
#' This is an environment like \code{<package:pkg>}. The package
#' environment contains the exported objects from a package. It is
#' attached, so it is an ancestor of \code{R_GlobalEnv}.
#'
#' When a package is loaded the normal way, using \code{\link{library}},
#' this environment contains only the exported objects from the
#' namespace. However, when loaded with \code{\link{load_all}}, this
#' environment will contain all the objects from the namespace, unless
#' \code{load_all} is used with \code{export_all=FALSE}.
#'
#' If the package is not attached, this function returns \code{NULL}.
#'
#' @param pkg package description, can be path or package name.  See
#'   \code{\link{as.package}} for more information
#' @keywords internal
#' @seealso \code{\link{ns_env}} for the namespace environment that
#'   all the objects (exported and not exported).
#' @seealso \code{\link{imports_env}} for the environment that contains
#'   imported objects for the package.
#' @export
pkg_env <- function(pkg = ".") {
  pkg <- as.package(pkg)
  name <- pkg_env_name(pkg)

  if (!is_attached(pkg)) return(NULL)

  as.environment(name)
}


# Generate name of package environment
# Contains exported objects
pkg_env_name <- function(pkg = ".") {
  pkg <- as.package(pkg)
  paste("package:", pkg$package, sep = "")
}


# Reports whether a package is loaded and attached
is_attached <- function(pkg = ".") {
  pkg_env_name(pkg) %in% search()
}


##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/package-env.r
## 


##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/reload.r
## 

#' Unload and reload package.
#'
#' This attempts to unload and reload a package. If the package is not loaded
#' already, it does nothing. It's not always possible to cleanly unload a
#' package: see the caveats in \code{\link{unload}} for some of the
#' potential failure points. If in doubt, restart R and reload the package
#' with \code{\link{library}}.
#'
#' @param pkg package description, can be path or package name.  See
#'   \code{\link{as.package}} for more information
#' @param quiet if \code{TRUE} suppresses output from this function.
#' @examples
#' \dontrun{
#' # Reload package that is in current directory
#' reload(".")
#'
#' # Reload package that is in ./ggplot2/
#' reload("ggplot2/")
#'
#' # Can use inst() to find the package path
#' # This will reload the installed ggplot2 package
#' reload(inst("ggplot2"))
#' }
#' @export
reload <- function(pkg = ".", quiet = FALSE) {
  pkg <- as.package(pkg)

  if (is_attached(pkg)) {
    if (!quiet) message("Reloading installed ", pkg$package)
    unload(pkg)
    require(pkg$package, character.only = TRUE, quietly = TRUE)
  }
}


##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/reload.r
## 


##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/rtools.r
## 

# Need to check for existence so load_all doesn't override known rtools location
if (!exists("set_rtools_path")) {
  set_rtools_path <- NULL
  get_rtools_path <- NULL
  local({
    rtools_paths <- NULL
    set_rtools_path <<- function(rtools) {
      stopifnot(is.rtools(rtools))
      path <- file.path(rtools$path, version_info[[rtools$version]]$path)

      rtools_paths <<- path
    }
    get_rtools_path <<- function() {
      rtools_paths
    }
  })
}

#' Find rtools.
#'
#' To build binary packages on windows, Rtools (found at
#' \url{http://cran.r-project.org/bin/windows/Rtools/}) needs to be on
#' the path. The default installation process does not add it, so this
#' script finds it (looking first on the path, then in the registry).
#' It also checks that the version of rtools matches the version of R.
#'
#' @section Acknowledgements:
#'   This code borrows heavily from RStudio's code for finding rtools.
#'   Thanks JJ!
#' @param debug if \code{TRUE} prints a lot of additional information to
#'   help in debugging.
#' @return Either a visible \code{TRUE} if rtools is found, or an invisible
#'   \code{FALSE} with a diagnostic \code{\link{message}}.
#'   As a side-effect the internal package variable \code{rtools_path} is
#'   updated to the paths to rtools binaries.
#' @keywords internal
#' @export
find_rtools <- function(debug = FALSE) {
  # Non-windows users don't need rtools
  if (.Platform$OS.type != "windows") return(TRUE)


  # First try the path
  from_path <- scan_path_for_rtools(debug)
  if (is_compatible(from_path)) {
    set_rtools_path(from_path)
    return(TRUE)
  }

  if (!is.null(from_path)) {
    # Installed
    if (is.null(from_path$version)) {
      # but not from rtools
      if (debug) "gcc and ls on path, assuming set up is correct\n"
      return(TRUE)
    } else {
    # Installed, but not compatible
      message("WARNING: Rtools ", from_path$version, " found on the path",
        " at ", from_path$path, " is not compatible with R ", getRversion(), ".\n\n",
        "Please download and install ", rtools_needed(), " from ", rtools_url,
        ", remove the incompatible version from your PATH, then run find_rtools().")
      return(invisible(FALSE))
    }
  }

  # Not on path, so try registry
  registry_candidates <- scan_registry_for_rtools(debug)

  if (length(registry_candidates) == 0) {
    # Not on path or in registry, so not installled
    message("WARNING: Rtools is required to build R packages, but is not ",
      "currently installed.\n\n",
      "Please download and install ", rtools_needed(), " from ", rtools_url,
      " and then run find_rtools().")
    return(invisible(FALSE))
  }

  from_registry <- Find(is_compatible, registry_candidates, right = TRUE)
  if (is.null(from_registry)) {
    # In registry, but not compatible.
    versions <- vapply(registry_candidates, function(x) x$version, character(1))
    message("WARNING: Rtools is required to build R packages, but no version ",
      "of Rtools compatible with R ", getRversion(), " was found. ",
      "(Only the following incompatible version(s) of Rtools were found:",
      paste(versions, collapse = ","), ")\n\n",
      "Please download and install ", rtools_needed(), " from ", rtools_url,
      " and then run find_rtools().")
    return(invisible(FALSE))
  }

  installed_ver <- installed_version(from_registry$path, debug = debug)
  if (is.null(installed_ver)) {
    # Previously installed version now deleted
    message("WARNING: Rtools is required to build R packages, but the ",
      "version of Rtools previously installed in ", from_registry$path,
      " has been deleted.\n\n",
      "Please download and install ", rtools_needed(), " from ", rtools_url,
      " and then run find_rtools().")
    return(invisible(FALSE))
  }

  if (installed_ver != from_registry$version) {
    # Installed version doesn't match registry version
    message("WARNING: Rtools is required to build R packages, but no version ",
      "of Rtools compatible with R ", getRversion(), " was found. ",
      "Rtools ", from_registry$version, " was previously installed in ",
      from_registry$path, " but now that directory contains Rtools ",
      installed_ver, ".\n\n",
      "Please download and install ", rtools_needed(), " from ", rtools_url,
      " and then run find_rtools().")
    return(invisible(FALSE))
  }

  # Otherwise it must be ok :)
  set_rtools_path(from_registry)
  TRUE
}

scan_path_for_rtools <- function(debug = FALSE) {
  if (debug) cat("Scanning path...\n")

  # First look for ls and gcc
  ls_path <- Sys.which("ls")
  if (ls_path == "") return(NULL)
  if (debug) cat("ls :", ls_path, "\n")

  gcc_path <- Sys.which("gcc")
  if (gcc_path == "") return(NULL)
  if (debug) cat("gcc:", gcc_path, "\n")

  # We have a candidate installPath
  install_path <- dirname(dirname(ls_path))
  install_path2 <- dirname(dirname(dirname(gcc_path)))
  if (tolower(install_path2) != tolower(install_path)) return(NULL)

  version <- installed_version(install_path, debug = debug)
  if (debug) cat("Version:", version, "\n")

  rtools(install_path, version)
}

scan_registry_for_rtools <- function(debug = FALSE) {
  if (debug) cat("Scanning registry...\n")

  keys <- NULL
  try(keys <- utils::readRegistry("SOFTWARE\\R-core\\Rtools",
    hive = "HCU", view = "32-bit", maxdepth = 2), silent = TRUE)
  if (is.null(keys))
    try(keys <- utils::readRegistry("SOFTWARE\\R-core\\Rtools",
      hive = "HLM", view = "32-bit", maxdepth = 2), silent = TRUE)
  if (is.null(keys)) return(NULL)

  rts <- vector("list", length(keys))

  for(i in seq_along(keys)) {
    version <- names(keys)[[i]]
    key <- keys[[version]]
    if (!is.list(key) || is.null(key$InstallPath)) next;
    install_path <- normalizePath(key$InstallPath,
      mustWork = FALSE, winslash = "/")

    if (debug) cat("Found", install_path, "for", version, "\n")
    rts[[i]] <- rtools(install_path, version)
  }

  Filter(Negate(is.null), rts)
}

installed_version <- function(path, debug) {
  if (!file.exists(file.path(path, "Rtools.txt"))) return(NULL)

  # Find the version path
  version_path <- file.path(path, "VERSION.txt")
  if (debug) {
    cat("VERSION.txt\n")
    cat(readLines(version_path), "\n")
  }
  if (!file.exists(version_path)) return(NULL)

  # Rtools is in the path -- now crack the VERSION file
  contents <- NULL
  try(contents <- readLines(version_path), silent = TRUE)
  if (is.null(contents)) return(NULL)

  # Extract the version
  contents <- gsub("^\\s+|\\s+$", "", contents)
  version_re <- "Rtools version (\\d\\.\\d+)\\.[0-9.]+$"

  if (!grepl(version_re, contents)) return(NULL)

  m <- regexec(version_re, contents)
  regmatches(contents, m)[[1]][2]
}

is_compatible <- function(rtools) {
  if (is.null(rtools)) return(FALSE)
  if (is.null(rtools$version)) return(FALSE)

  stopifnot(is.rtools(rtools))
  info <- version_info[[rtools$version]]
  if (is.null(info)) return(FALSE)

  r_version <- getRversion()
  r_version >= info$version_min && r_version <= info$version_max
}

rtools <- function(path, version) {
  structure(list(version = version, path = path), class = "rtools")
}
is.rtools <- function(x) inherits(x, "rtools")

# Rtools metadata --------------------------------------------------------------
rtools_url <- "http://cran.r-project.org/bin/windows/Rtools/"
version_info <- list(
  "2.11" = list(
    version_min = "2.10.0",
    version_max = "2.11.1",
    path = c("bin", "perl/bin", "MinGW/bin")
  ),
  "2.12" = list(
    version_min = "2.12.0",
    version_max = "2.12.2",
    path = c("bin", "perl/bin", "MinGW/bin", "MinGW64/bin")
  ),
  "2.13" = list(
    version_min = "2.13.0",
    version_max = "2.13.2",
    path = c("bin", "MinGW/bin", "MinGW64/bin")
  ),
  "2.14" = list(
    version_min = "2.13.0",
    version_max = "2.14.2",
    path = c("bin", "MinGW/bin", "MinGW64/bin")
  ),
  "2.15" = list(
    version_min = "2.14.2",
    version_max = "2.15.1",
    path = c("bin", "gcc-4.6.3/bin")
  ),
  "2.16" = list(
    version_min = "2.15.2",
    version_max = "3.0.0",
    path = c("bin", "gcc-4.6.3/bin")
  ),
  "3.0" = list(
    version_min = "2.15.2",
    version_max = "3.0.99",
    path = c("bin", "gcc-4.6.3/bin")
  ),
  "3.1" = list(
    version_min = "3.0.0",
    version_max = "3.1.99",
    path = c("bin", "gcc-4.6.3/bin")
  ),
  "3.2" = list(
    version_min = "3.1.0",
    version_max = "3.2.99",
    path = c("bin", "gcc-4.6.3/bin")
  ),
  "3.3" = list(
    version_min = "3.2.0",
    version_max = "3.3.99",
    path = c("bin", "gcc-4.6.3/bin")
  )
)

rtools_needed <- function() {
  r_version <- getRversion()

  for(i in rev(seq_along(version_info))) {
    version <- names(version_info)[i]
    info <- version_info[[i]]
    ok <- r_version >= info$version_min && r_version <= info$version_max
    if (ok) return(paste("Rtools", version))
  }
  "the appropriate version of Rtools"
}

##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/rtools.r
## 


##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/R.r
## 

# R("-e 'str(as.list(Sys.getenv()))' --slave")
R <- function(options, path = tempdir(), env_vars = NULL, ...) {
  options <- paste(
    "--no-site-file", "--no-environ", "--no-save", "--no-restore",
    options)
  r_path <- file.path(R.home("bin"), "R")

  # If rtools has been detected, add it to the path only when running R...
  if (!is.null(get_rtools_path())) {
    old <- add_path(get_rtools_path(), 0)
    on.exit(set_path(old))
  }

  withr::with_dir(path, system_check(r_path, options, c(r_profile(),
                                               r_env_vars(), env_vars), ...))
}

#' Run R CMD xxx from within R
#'
#' @param cmd one of the R tools available from the R CMD interface.
#' @param options a charater vector of options to pass to the command
#' @param path the directory to run the command in.
#' @param env_vars environment variables to set before running the command.
#' @param ... additional arguments passed to \code{\link{system_check}}
#' @return \code{TRUE} if the command succeeds, throws an error if the command
#' fails.
#' @export
RCMD <- function(cmd, options, path = tempdir(), env_vars = NULL, ...) {
  options <- paste(options, collapse = " ")
  R(paste("CMD", cmd, options), path = path, env_vars = env_vars, ...)
}

#' Environment variables to set when calling R
#'
#' Devtools sets a number of environmental variables to ensure consistent
#' between the current R session and the new session, and to ensure that
#' everything behaves the same across systems. It also suppresses a common
#' warning on windows, and sets \code{NOT_CRAN} so you can tell that your
#' code is not running on CRAN. If \code{NOT_CRAN} has been set externally, it
#' is not overwritten.
#'
#' @keywords internal
#' @return a named character vector
#' @export
r_env_vars <- function() {
  vars <- c(
    "R_LIBS" = paste(.libPaths(), collapse = .Platform$path.sep),
    "CYGWIN" = "nodosfilewarning",
    # When R CMD check runs tests, it sets R_TESTS. When the tests
    # themselves run R CMD xxxx, as is the case with the tests in
    # devtools, having R_TESTS set causes errors because it confuses
    # the R subprocesses. Un-setting it here avoids those problems.
    "R_TESTS" = "",
    "R_BROWSER" = "false",
    "R_PDFVIEWER" = "false",
    "TAR" = auto_tar())

  if (is.na(Sys.getenv("NOT_CRAN", unset = NA))) {
    vars[["NOT_CRAN"]] <- "true"
  }

  vars
}

# Create a temporary .Rprofile based on the current "repos" option
# and return a named vector that corresponds to environment variables
# that need to be set to use this .Rprofile
r_profile <- function() {
  tmp_user_profile <- file.path(tempdir(), "Rprofile-devtools")
  tmp_user_profile_con <- file(tmp_user_profile, "w")
  on.exit(close(tmp_user_profile_con), add = TRUE)
  writeLines("options(repos =", tmp_user_profile_con)
  dput(getOption("repos"), tmp_user_profile_con)
  writeLines(")", tmp_user_profile_con)

  c(R_PROFILE_USER = tmp_user_profile)
}

# Determine the best setting for the TAR environmental variable
# This is needed for R <= 2.15.2 to use internal tar. Later versions don't need
# this workaround, and they use R_BUILD_TAR instead of TAR, so this has no
# effect on them.
auto_tar <- function() {
  tar <- Sys.getenv("TAR", unset = NA)
  if (!is.na(tar)) return(tar)

  windows <- .Platform$OS.type == "windows"
  no_rtools <- is.null(get_rtools_path())
  if (windows && no_rtools) "internal" else ""
}



##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/R.r
## 


##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/cran.r
## 

available_packages <- memoise::memoise(function(repos, type) {
  suppressWarnings(available.packages(contrib.url(repos, type), type = type))
})

package_url <- function(package, repos,
                        available = available_packages(repos, "source")) {
  ok <- (available[, "Package"] == package)
  ok <- ok & !is.na(ok)

  if (!any(ok)) {
    return(list(name = NA_character_, url = NA_character_))
  }

  vers <- package_version(available[ok, "Version"])
  keep <- vers == max(vers)
  keep[duplicated(keep)] <- FALSE
  ok[ok][!keep] <- FALSE

  name <- paste(package, "_", available[ok, "Version"], ".tar.gz", sep = "")
  url <- file.path(available[ok, "Repository"], name)

  list(name = name, url = url)
}


# Return the version of a package on CRAN (or other repository)
# @param package The name of the package.
# @param available A matrix of information about packages.
cran_pkg_version <- function(package, available = available.packages()) {

  idx <- available[, "Package"] == package
  if(any(idx)) {
    as.package_version(available[package, "Version"])
  } else {
    NULL
  }
}

##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/cran.r
## 


##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/parse-deps.r
## 

#' Parse package dependency strings.
#'
#' @param string to parse. Should look like \code{"R (>= 3.0), ggplot2"} etc.
#' @return list of two character vectors: \code{name} package names,
#'   and \code{version} package versions. If version is not specified,
#'   it will be stored as NA.
#' @keywords internal
#' @export
#' @examples
#' parse_deps("httr (< 2.1),\nRCurl (>= 3)")
#' # only package dependencies are returned
#' parse_deps("utils (== 2.12.1),\ntools,\nR (>= 2.10),\nmemoise")
parse_deps <- function(string) {
  if (is.null(string)) return()
  stopifnot(is.character(string), length(string) == 1)
  if (grepl("^\\s*$", string)) return()

  pieces <- strsplit(string, ",")[[1]]

  # Get the names
  names <- gsub("\\s*\\(.*?\\)", "", pieces)
  names <- gsub("^\\s+|\\s+$", "", names)

  # Get the versions and comparison operators
  versions_str <- pieces
  have_version <- grepl("\\(.*\\)", versions_str)
  versions_str[!have_version] <- NA

  compare  <- sub(".*\\((\\S+)\\s+.*\\)", "\\1", versions_str)
  versions <- sub(".*\\(\\S+\\s+(.*)\\)", "\\1", versions_str)

  # Check that non-NA comparison operators are valid
  compare_nna   <- compare[!is.na(compare)]
  compare_valid <- compare_nna %in% c(">", ">=", "==", "<=", "<")
  if(!all(compare_valid)) {
    stop("Invalid comparison operator in dependency: ",
      paste(compare_nna[!compare_valid], collapse = ", "))
  }

  deps <- data.frame(name = names, compare = compare,
    version = versions, stringsAsFactors = FALSE)

  # Remove R dependency
  deps[names != "R", ]
}


#' Check that the version of an imported package satisfies the requirements
#'
#' @param dep_name The name of the package with objects to import
#' @param dep_ver The version of the package
#' @param dep_compare The comparison operator to use to check the version
#' @keywords internal
check_dep_version <- function(dep_name, dep_ver = NA, dep_compare = NA) {
  if (!requireNamespace(dep_name, quietly = TRUE)) {
    stop("Dependency package ", dep_name, " not available.")
  }

  if (xor(is.na(dep_ver), is.na(dep_compare))) {
    stop("dep_ver and dep_compare must be both NA or both non-NA")

  } else if(!is.na(dep_ver) && !is.na(dep_compare)) {

    compare <- match.fun(dep_compare)
    if (!compare(
      as.numeric_version(getNamespaceVersion(dep_name)),
      as.numeric_version(dep_ver))) {

      warning("Need ", dep_name, " ", dep_compare,
        " ", dep_ver,
        " but loaded version is ", getNamespaceVersion(dep_name))
    }
  }
  return(TRUE)
}



##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/parse-deps.r
## 


##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/deps.r
## 

#' Find all dependencies of a CRAN or dev package.
#'
#' Find all the dependencies of a package and determine whether they are ahead
#' or behind CRAN. A \code{print()} method identifies mismatches (if any)
#' between local and CRAN versions of each dependent package; an
#' \code{update()} method installs outdated or missing packages from CRAN.
#'
#' @param pkg A character vector of package names. If missing, defaults to
#'   the name of the package in the current directory.
#' @param dependencies Which dependencies do you want to check?
#'   Can be a character vector (selecting from "Depends", "Imports",
#'    "LinkingTo", "Suggests", or "Enhances"), or a logical vector.
#'
#'   \code{TRUE} is shorthand for "Depends", "Imports", "LinkingTo" and
#'   "Suggests". \code{NA} is shorthand for "Depends", "Imports" and "LinkingTo"
#'   and is the default. \code{FALSE} is shorthand for no dependencies (i.e.
#'   just check this package, not its dependencies).
#' @param quiet If \code{TRUE}, suppress output.
#' @param upgrade If \code{TRUE}, also upgrade any of out date dependencies.
#' @param repos A character vector giving repositories to use.
#' @param type Type of package to \code{update}.  If "both", will switch
#'   automatically to "binary" to avoid interactive prompts during package
#'   installation.
#'
#' @param object A \code{package_deps} object.
#' @param ... Additional arguments passed to \code{\link{install.packages}}.
#'
#' @return
#'
#' A \code{data.frame} with columns:
#'
#' \tabular{ll}{
#' \code{package} \tab The dependent package's name,\cr
#' \code{installed} \tab The currently installed version,\cr
#' \code{available} \tab The version available on CRAN,\cr
#' \code{diff} \tab An integer denoting whether the locally installed version
#'   of the package is newer (1), the same (0) or older (-1) than the version
#'   currently available on CRAN.\cr
#' }
#'
#' @export
#' @examples
#' \dontrun{
#' package_deps("devtools")
#' # Use update to update any out-of-date dependencies
#' update(package_deps("devtools"))
#' }
package_deps <- function(pkg, dependencies = NA, repos = getOption("repos"),
                         type = getOption("pkgType")) {
  if (identical(type, "both")) {
    type <- "binary"
  }

  if (length(repos) == 0)
    repos <- character()

  repos[repos == "@CRAN@"] <- "http://cran.rstudio.com"
  cran <- available_packages(repos, type)

  if (missing(pkg)) {
    pkg <- as.package(".")$package
  }
  deps <- sort(find_deps(pkg, cran, top_dep = dependencies))

  # Remove base packages
  inst <- installed.packages()
  base <- unname(inst[inst[, "Priority"] %in% c("base", "recommended"), "Package"])
  deps <- setdiff(deps, base)

  inst_ver <- unname(inst[, "Version"][match(deps, rownames(inst))])
  cran_ver <- unname(cran[, "Version"][match(deps, rownames(cran))])
  diff <- compare_versions(inst_ver, cran_ver)

  structure(
    data.frame(
      package = deps,
      installed = inst_ver,
      available = cran_ver,
      diff = diff,
      stringsAsFactors = FALSE
    ),
    class = c("package_deps", "data.frame"),
    repos = repos,
    type = type
  )
}

#' @export
#' @rdname package_deps
dev_package_deps <- function(pkg = ".", dependencies = NA,
                             repos = getOption("repos"),
                             type = getOption("pkgType")) {
  pkg <- as.package(pkg)
  install_dev_remotes(pkg)

  dependencies <- tolower(standardise_dep(dependencies))
  dependencies <- intersect(dependencies, names(pkg))

  parsed <- lapply(pkg[tolower(dependencies)], parse_deps)
  deps <- unlist(lapply(parsed, `[[`, "name"), use.names = FALSE)

  if (is_bioconductor(pkg)) {
    bioc_repos <- BiocInstaller::biocinstallRepos()

    missing_repos <- setdiff(names(bioc_repos), names(repos))

    if (length(missing_repos) > 0)
      repos[missing_repos] <- bioc_repos[missing_repos]
  }

  package_deps(deps, repos = repos, type = type)
}

compare_versions <- function(a, b) {
  stopifnot(length(a) == length(b))

  compare_var <- function(x, y) {
    if (is.na(y)) return(2L)
    if (is.na(x)) return(-2L)

    x <- package_version(x)
    y <- package_version(y)

    if (x < y) {
      -1L
    } else if (x > y) {
      1L
    } else {
      0L
    }
  }

  vapply(seq_along(a), function(i) compare_var(a[[i]], b[[i]]), integer(1))
}

install_dev_remotes <- function(pkg, ...) {
  pkg <- as.package(pkg)

  if (!has_dev_remotes(pkg)) {
    return()
  }

  types <- dev_remote_type(pkg[["remotes"]])

  lapply(types, function(type) type$fun(type$repository, ...))
}

# Parse the remotes field split into pieces and get install_ functions for each
# remote type
dev_remote_type <- function(remotes = "") {

  if (!nchar(remotes)) {
    return()
  }

  dev_packages <- trim_ws(unlist(strsplit(remotes, ",[[:space:]]*")))

  parse_one <- function(x) {
    pieces <- strsplit(x, "::", fixed = TRUE)[[1]]

    if (length(pieces) == 1) {
      type <- "github"
      repo <- pieces
    } else if (length(pieces) == 2) {
      type <- pieces[1]
      repo <- pieces[2]
    } else {
      stop("Malformed remote specification '", x, "'", call. = FALSE)
    }
    tryCatch(
      fun <- get(x = paste0("install_", tolower(type)),
        envir = asNamespace("devtools"),
        mode = "function",
        inherits = FALSE),
      error = function(e) {
        stop("Malformed remote specification '", x, "'", call. = FALSE)
      })
    list(repository = repo, type = type, fun = fun)
  }

  lapply(dev_packages, parse_one)
}

has_dev_remotes <- function(pkg) {
  pkg <- as.package(pkg)

  !is.null(pkg[["remotes"]])
}


#' @export
print.package_deps <- function(x, show_ok = FALSE, ...) {
  class(x) <- "data.frame"

  ahead <- x$diff > 0L
  behind <- x$diff < 0L
  same_ver <- x$diff == 0L

  x$diff <- NULL
  x[] <- lapply(x, format)

  if (any(behind)) {
    cat("Needs update -----------------------------\n")
    print(x[behind, , drop = FALSE], row.names = FALSE, right = FALSE)
  }

  if (any(ahead)) {
    cat("Not on CRAN ----------------------------\n")
    print(x[ahead, , drop = FALSE], row.names = FALSE, right = FALSE)
  }

  if (show_ok && any(same_ver)) {
    cat("OK ---------------------------------------\n")
    print(x[same_ver, , drop = FALSE], row.names = FALSE, right = FALSE)
  }
}

#' @export
#' @rdname package_deps
#' @importFrom stats update
update.package_deps <- function(object, ..., quiet = FALSE, upgrade = TRUE) {
  ahead <- object$package[object$diff == 2L]
  if (length(ahead) > 0 && !quiet) {
    message("Skipping ", length(ahead), " packages not available: ",
      paste(ahead, collapse = ", "))
  }

  missing <- object$package[object$diff == 1L]
  if (length(missing) > 0 && !quiet) {
    message("Skipping ", length(missing), " packages ahead of CRAN: ",
      paste(missing, collapse = ", "))
  }

  if (upgrade) {
    behind <- object$package[object$diff < 0L]
  } else {
    behind <- object$package[is.na(object$available)]
  }
  if (length(behind) > 0L) {
    install_packages(behind, repos = attr(object, "repos"),
      type = attr(object, "type"), ...)
  }

}

install_packages <- function(pkgs, repos = getOption("repos"),
                             type = getOption("pkgType"), ...,
                             dependencies = FALSE, quiet = NULL) {
  if (identical(type, "both"))
    type <- "binary"
  if (is.null(quiet))
    quiet <- !identical(type, "source")

  message("Installing ", length(pkgs), " packages: ",
    paste(pkgs, collapse = ", "))
  utils::install.packages(pkgs, repos = repos, type = type, ...,
    dependencies = dependencies, quiet = quiet)
}

find_deps <- function(pkgs, available = available.packages(), top_dep = TRUE,
                      rec_dep = NA, include_pkgs = TRUE) {
  if (length(pkgs) == 0 || identical(top_dep, FALSE))
    return(character())

  top_dep <- standardise_dep(top_dep)
  rec_dep <- standardise_dep(rec_dep)

  top <- tools::package_dependencies(pkgs, db = available, which = top_dep)
  top_flat <- unlist(top, use.names = FALSE)

  if (length(rec_dep) != 0 && length(top_flat) > 0) {
    rec <- tools::package_dependencies(top_flat, db = available, which = rec_dep,
      recursive = TRUE)
    rec_flat <- unlist(rec, use.names = FALSE)
  } else {
    rec_flat <- character()
  }

  unique(c(if (include_pkgs) pkgs, top_flat, rec_flat))
}


standardise_dep <- function(x) {
  if (identical(x, NA)) {
    c("Depends", "Imports", "LinkingTo")
  } else if (isTRUE(x)) {
    c("Depends", "Imports", "LinkingTo", "Suggests")
  } else if (identical(x, FALSE)) {
    character(0)
  } else if (is.character(x)) {
    x
  } else {
    stop("Dependencies must be a boolean or a character vector", call. = FALSE)
  }
}

#' Update packages that are missing or out-of-date.
#'
#' Works similarly to \code{install.packages()} but doesn't install packages
#' that are already installed, and also upgrades out dated dependencies.
#'
#' @param pkgs Character vector of packages to update.
#' @inheritParams package_deps
#' @seealso \code{\link{package_deps}} to see which packages are out of date/
#'   missing.
#' @export
#' @examples
#' \dontrun{
#' update_packages("ggplot2")
#' update_packages(c("plyr", "ggplot2"))
#' }
update_packages <- function(pkgs, dependencies = NA,
                            repos = getOption("repos"),
                            type = getOption("pkgType")) {
  pkgs <- package_deps(pkgs, repos = repos, type = type)
  update(pkgs)
}


##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/deps.r
## 


##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/has-devel.r
## 

#' Check if you have a development environment installed.
#'
#' Thanks to the suggestion of Simon Urbanek.
#'
#' @return TRUE if your development environment is correctly set up, otherwise
#'   returns an error.
#' @export
#' @examples
#' has_devel()
has_devel <- function() {
  foo_path <- file.path(tempdir(), "foo.c")

  cat("void foo(int *bar) { *bar=1; }\n", file = foo_path)
  on.exit(unlink(foo_path))

  R("CMD SHLIB foo.c", tempdir())
  dylib <- file.path(tempdir(), paste("foo", .Platform$dynlib.ext, sep=''))
  on.exit(unlink(dylib), add = TRUE)

  dll <- dyn.load(dylib)
  on.exit(dyn.unload(dylib), add = TRUE)

  stopifnot(.C(dll$foo, 0L)[[1]] == 1L)
  TRUE
}

check_build_tools <- function(pkg = ".") {
  pkg <- as.package(pkg)
  if (!file.exists(file.path(pkg$path, "src"))) return(TRUE)

  check <- getOption("buildtools.check", NULL)
  if (!is.null(check)) {
    check("Installing R package from source")
  } else {
    # Outside of Rstudio and don't have good heuristic
    TRUE
  }
}

##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/has-devel.r
## 


##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/system.r
## 

#' Run a system command and check if it succeeds.
#'
#' @param cmd the command to run.
#' @param args a vector of command arguments.
#' @param env a named character vector of environment variables.  Will be quoted
#' @param quiet if \code{FALSE}, the command to be run will be echoed.
#' @param ... additional arguments passed to \code{\link[base]{system}}
#' @return \code{TRUE} if the command succeeds, an error will be thrown if the
#' command fails.
#' @export
system_check <- function(cmd, args = character(), env = character(),
                         quiet = FALSE, ...) {
  full <- paste(shQuote(cmd), " ", paste(args, collapse = " "), sep = "")

  if (!quiet) {
    message(wrap_command(full))
    message()
  }

  result <- suppressWarnings(withr::with_envvar(env,
    system(full, intern = quiet, ignore.stderr = quiet, ...)
  ))

  if (quiet) {
    status <- attr(result, "status") %||% 0
  } else {
    status <- result
  }

  if (!identical(as.character(status), "0")) {
    stop("Command failed (", status, ")", call. = FALSE)
  }

  invisible(TRUE)
}


wrap_command <- function(x) {
  lines <- strwrap(x, getOption("width") - 2, exdent = 2)
  continue <- c(rep(" \\", length(lines) - 1), "")
  paste(lines, continue, collapse = "\n")
}

##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/system.r
## 


##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/decompress.r
## 

# Decompress pkg, if needed
source_pkg <- function(path, subdir = NULL, before_install = NULL) {
  if (!file.info(path)$isdir) {
    bundle <- path
    outdir <- tempfile(pattern = "devtools")
    dir.create(outdir)

    path <- decompress(path, outdir)
  } else {
    bundle <- NULL
  }

  pkg_path <- if (is.null(subdir)) path else file.path(path, subdir)

  # Check it's an R package
  if (!file.exists(file.path(pkg_path, "DESCRIPTION"))) {
    stop("Does not appear to be an R package (no DESCRIPTION)", call. = FALSE)
  }

  # Check configure is executable if present
  config_path <- file.path(pkg_path, "configure")
  if (file.exists(config_path)) {
    Sys.chmod(config_path, "777")
  }

  # Call before_install for bundles (if provided)
  if (!is.null(bundle) && !is.null(before_install))
    before_install(bundle, pkg_path)

  pkg_path
}


decompress <- function(src, target) {
  stopifnot(file.exists(src))

  if (grepl("\\.zip$", src)) {
    my_unzip(src, target)
    outdir <- getrootdir(as.vector(utils::unzip(src, list = TRUE)$Name))

  } else if (grepl("\\.tar$", src)) {
    utils::untar(src, exdir = target)
    outdir <- getrootdir(utils::untar(src, list = TRUE))

  } else if (grepl("\\.(tar\\.gz|tgz)$", src)) {
    utils::untar(src, exdir = target, compressed = "gzip")
    outdir <- getrootdir(utils::untar(src, compressed = "gzip", list = TRUE))

  } else if (grepl("\\.(tar\\.bz2|tbz)$", src)) {
    utils::untar(src, exdir = target, compressed = "bzip2")
    outdir <- getrootdir(utils::untar(src, compressed = "bzip2", list = TRUE))

  } else {
    ext <- gsub("^[^.]*\\.", "", src)
    stop("Don't know how to decompress files with extension ", ext,
      call. = FALSE)
  }

  file.path(target, outdir)
}


# Returns everything before the last slash in a filename
# getdir("path/to/file") returns "path/to"
# getdir("path/to/dir/") returns "path/to/dir"
getdir <- function(path)  sub("/[^/]*$", "", path)

# Given a list of files, returns the root (the topmost folder)
# getrootdir(c("path/to/file", "path/to/other/thing")) returns "path/to"
getrootdir <- function(file_list) {
  slashes <- nchar(gsub("[^/]", "", file_list))
  if (min(slashes) == 0) return("")

  getdir(file_list[which.min(slashes)])
}

my_unzip <- function(src, target, unzip = getOption("unzip")) {
  if (unzip == "internal") {
    return(utils::unzip(src, exdir = target))
  }

  args <- paste(
    "-oq", shQuote(src),
    "-d", shQuote(target)
  )

  system_check(unzip, args, quiet = TRUE)
}

##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/decompress.r
## 

##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/git.r
## 

uses_git <- function(path = ".") {
  !is.null(git2r::discover_repository(path))
}

git_sha1 <- function(n = 10, path = ".") {
  r <- git2r::repository(path, discover = TRUE)
  sha <- git2r::commits(r, n = 1)[[1]]@sha # sha of most recent commit
  substr(sha, 1, n)
}

git_uncommitted <- function(path = ".") {
  r <- git2r::repository(path, discover = TRUE)
  st <- vapply(git2r::status(r), length, integer(1))
  any(st != 0)
}

git_sync_status <- function(path = ".") {
  r <- git2r::repository(path, discover = TRUE)

  upstream <- git2r::branch_get_upstream(git2r::head(r))
  # fetch(r, branch_remote_name(upstream))

  c1 <- git2r::commits(r)[[1]]
  c2 <- git2r::lookup(r, git2r::branch_target(upstream))
  ab <- git2r::ahead_behind(c1, c2)

#   if (ab[1] > 0)
#     message(ab[1], " ahead of remote")
#   if (ab[2] > 0)
#     message(ab[2], " behind remote")

  invisible(any(ab != 0))
}

# Retrieve the current running path of the git binary.
# @param git_binary_name The name of the binary depending on the OS.
git_path <- function(git_binary_name = NULL) {
  # Use user supplied path
  if (!is.null(git_binary_name)) {
    if (!file.exists(git_binary_name)) {
      stop("Path ", git_binary_name, " does not exist", .call = FALSE)
    }
    return(git_binary_name)
  }

  # Look on path
  git_path <- Sys.which("git")[[1]]
  if (git_path != "") return(git_path)

  # On Windows, look in common locations
  if (.Platform$OS.type == "windows") {
    look_in <- c(
      "C:/Program Files/Git/bin/git.exe",
      "C:/Program Files (x86)/Git/bin/git.exe"
    )
    found <- file.exists(look_in)
    if (any(found)) return(look_in[found][1])
  }

  stop("Git does not seem to be installed on your system.", call. = FALSE)
}


# GitHub ------------------------------------------------------------------

uses_github <- function(path = ".") {
  if (!uses_git(path))
    return(FALSE)

  r <- git2r::repository(path, discover = TRUE)
  r_remote_urls <- git2r::remote_url(r)

  any(grepl("github", r_remote_urls))
}

github_info <- function(path = ".", remote_name = NULL) {
  if (!uses_github(path))
    return(github_dummy)

  r <- git2r::repository(path, discover = TRUE)
  r_remote_urls <- grep("github", remote_urls(r), value = TRUE)

  if (!is.null(remote_name) && !remote_name %in% names(r_remote_urls))
    stop("no github-related remote named ", remote_name, " found")

  remote_name <- c(remote_name, "origin", names(r_remote_urls))
  x <- r_remote_urls[remote_name]
  x <- x[!is.na(x)][1]

  github_remote_parse(x)
}

github_dummy <- list(username = "<USERNAME>", repo = "<REPO>")

remote_urls <- function(r) {
  remotes <- git2r::remotes(r)
  stats::setNames(git2r::remote_url(r, remotes), remotes)
}

github_remote_parse <- function(x) {
  if (length(x) == 0) return(github_dummy)
  if (!grepl("github", x)) return(github_dummy)

  if (grepl("^https", x)) {
    # https://github.com/hadley/devtools.git
    re <- "github.com/(.*?)/(.*)\\.git"
  } else if (grepl("^git", x)) {
    # git@github.com:hadley/devtools.git
    re <- "github.com:(.*?)/(.*)\\.git"
  } else {
    stop("Unknown GitHub repo format", call. = FALSE)
  }

  m <- regexec(re, x)
  match <- regmatches(x, m)[[1]]
  list(username = match[2], repo = match[3])
}

# Extract the commit hash from a git archive. Git archives include the SHA1
# hash as the comment field of the zip central directory record
# (see https://www.kernel.org/pub/software/scm/git/docs/git-archive.html)
# Since we know it's 40 characters long we seek that many bytes minus 2
# (to confirm the comment is exactly 40 bytes long)
git_extract_sha1 <- function(bundle) {

  # open the bundle for reading
  conn <- file(bundle, open = "rb", raw = TRUE)
  on.exit(close(conn))

  # seek to where the comment length field should be recorded
  seek(conn, where = -0x2a, origin = "end")

  # verify the comment is length 0x28
  len <- readBin(conn, "raw", n = 2)
  if (len[1] == 0x28 && len[2] == 0x00) {
    # read and return the SHA1
    rawToChar(readBin(conn, "raw", n = 0x28))
  } else {
    NULL
  }
}

##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/git.r
## 


##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/package.r
## 

#' Coerce input to a package.
#'
#' Possible specifications of package:
#' \itemize{
#'   \item path
#'   \item package object
#' }
#' @param x object to coerce to a package
#' @param create only relevant if a package structure does not exist yet: if
#'   \code{TRUE}, create a package structure; if \code{NA}, ask the user
#'   (in interactive mode only)
#' @export
#' @keywords internal
as.package <- function(x = NULL, create = NA) {
  if (is.package(x)) return(x)

  x <- check_dir(x)
  load_pkg_description(x, create = create)
}


check_dir <- function(x) {
  if (is.null(x)) {
    stop("Path is null", call. = FALSE)
  }

  # Normalise path and strip trailing slashes
  x <- normalise_path(x)
  x <- package_root(x) %||% x

  if (!file.exists(x)) {
    stop("Can't find directory ", x, call. = FALSE)
  }
  if (!file.info(x)$isdir) {
    stop(x, " is not a directory", call. = FALSE)
  }

  x
}

package_root <- function(path) {
  if (is.package(path)) {
    return(path$path)
  }
  stopifnot(is.character(path))

  has_description <- function(path) {
    file.exists(file.path(path, 'DESCRIPTION'))
  }
  path <- normalizePath(path, mustWork = FALSE)
  while (!has_description(path) && !is_root(path)) {
    path <- dirname(path)
  }

  if (is_root(path)) {
    NULL
  } else {
    path
  }
}

is_root <- function(path) {
  identical(path, dirname(path))
}

normalise_path <- function(x) {
  x <- sub("\\\\+$", "/", x)
  x <- sub("/*$", "", x)
  x
}

# Load package DESCRIPTION into convenient form.
load_pkg_description <- function(path, create) {
  path <- normalizePath(path)
  path_desc <- file.path(path, "DESCRIPTION")

  if (!file.exists(path_desc)) {
    if (is.na(create) && interactive()) {
      message("No package infrastructure found in ", path, ". Create it?")
      create <- (menu(c("Yes", "No")) == 1)
    }

    if (create) {
      setup(path = path)
    } else {
      stop("No description at ", path_desc, call. = FALSE)
    }
  }

  desc <- as.list(read.dcf(path_desc)[1, ])
  names(desc) <- tolower(names(desc))
  desc$path <- path

  structure(desc, class = "package")
}


#' Is the object a package?
#'
#' @keywords internal
#' @export
is.package <- function(x) inherits(x, "package")

# Mockable variant of interactive
interactive <- function() .Primitive("interactive")()



##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/package.r
## 


##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/install.r
## 

#' Install a local development package.
#'
#' Uses \code{R CMD INSTALL} to install the package. Will also try to install
#' dependencies of the package from CRAN, if they're not already installed.
#'
#' By default, installation takes place using the current package directory.
#' If you have compiled code, this means that artefacts of compilation will be
#' created in the \code{src/} directory. If you want to avoid this, you can
#' use \code{local = FALSE} to first build a package bundle and then install
#' it from a temporary directory. This is slower, but keeps the source
#' directory pristine.
#'
#' If the package is loaded, it will be reloaded after installation. This is
#' not always completely possible, see \code{\link{reload}} for caveats.
#'
#' To install a package in a non-default library, use \code{\link{with_libpaths}}.
#'
#' @param pkg package description, can be path or package name.  See
#'   \code{\link{as.package}} for more information
#' @param reload if \code{TRUE} (the default), will automatically reload the
#'   package after installing.
#' @param quick if \code{TRUE} skips docs, multiple-architectures,
#'   demos, and vignettes, to make installation as fast as possible.
#' @param local if \code{FALSE} \code{\link{build}}s the package first:
#'   this ensures that the installation is completely clean, and prevents any
#'   binary artefacts (like \file{.o}, \code{.so}) from appearing in your local
#'   package directory, but is considerably slower, because every compile has
#'   to start from scratch.
#' @param args An optional character vector of additional command line
#'   arguments to be passed to \code{R CMD install}. This defaults to the
#'   value of the option \code{"devtools.install.args"}.
#' @param quiet if \code{TRUE} suppresses output from this function.
#' @param dependencies \code{logical} indicating to also install uninstalled
#'   packages which this \code{pkg} depends on/links to/suggests. See
#'   argument \code{dependencies} of \code{\link{install.packages}}.
#' @param upgrade_dependencies If \code{TRUE}, the default, will also update
#'   any out of date dependencies.
#' @param build_vignettes if \code{TRUE}, will build vignettes. Normally it is
#'   \code{build} that's responsible for creating vignettes; this argument makes
#'   sure vignettes are built even if a build never happens (i.e. because
#'   \code{local = TRUE}).
#' @param keep_source If \code{TRUE} will keep the srcrefs from an installed
#'   package. This is useful for debugging (especially inside of RStudio).
#'   It defaults to the option \code{"keep.source.pkgs"}.
#' @param threads number of concurrent threads to use for installing
#'   dependencies.
#'   It defaults to the option \code{"Ncpus"} or \code{1} if unset.
#' @param ... additional arguments passed to \code{\link{install.packages}}
#'   when installing dependencies. \code{pkg} is installed with
#'   \code{R CMD INSTALL}.
#' @export
#' @family package installation
#' @seealso \code{\link{with_debug}} to install packages with debugging flags
#'   set.
install <- function(pkg = ".", reload = TRUE, quick = FALSE, local = TRUE,
                    args = getOption("devtools.install.args"), quiet = FALSE,
                    dependencies = NA, upgrade_dependencies = TRUE,
                    build_vignettes = FALSE,
                    keep_source = getOption("keep.source.pkgs"),
                    threads = getOption("Ncpus", 1),
                    ...) {

  pkg <- as.package(pkg)
  check_build_tools(pkg)

  if (!quiet) {
    message("Installing ", pkg$package)
  }

  # If building vignettes, make sure we have all suggested packages too.
  if (build_vignettes && missing(dependencies)) {
    dependencies <- TRUE
  }
  install_deps(pkg, dependencies = dependencies, upgrade = upgrade_dependencies,
    threads = threads, ...)

  # Build the package. Only build locally if it doesn't have vignettes
  has_vignettes <- length(tools::pkgVignettes(dir = pkg$path)$docs > 0)
  if (local && !(has_vignettes && build_vignettes)) {
    built_path <- pkg$path
  } else {
    built_path <- build(pkg, tempdir(), vignettes = build_vignettes, quiet = quiet)
    on.exit(unlink(built_path))
  }

  opts <- c(
    paste("--library=", shQuote(.libPaths()[1]), sep = ""),
    if (keep_source) "--with-keep.source",
    "--install-tests"
  )
  if (quick) {
    opts <- c(opts, "--no-docs", "--no-multiarch", "--no-demo")
  }
  opts <- paste(paste(opts, collapse = " "), paste(args, collapse = " "))

  built_path <- normalizePath(built_path, winslash = "/")
  R(paste("CMD INSTALL ", shQuote(built_path), " ", opts, sep = ""),
    quiet = quiet)

  if (reload) {
    reload(pkg, quiet = quiet)
  }
  invisible(TRUE)
}

#' Install package dependencies if needed.
#'
#' @inheritParams install
#' @inheritParams package_deps
#' @param ... additional arguments passed to \code{\link{install.packages}}.
#' @export
#' @examples
#' \dontrun{install_deps(".")}
install_deps <- function(pkg = ".", dependencies = NA,
                         threads = getOption("Ncpus", 1),
                         repos = getOption("repos"),
                         type = getOption("pkgType"),
                         ...,
                         upgrade = TRUE,
                         quiet = FALSE) {

  pkg <- dev_package_deps(pkg, repos = repos, dependencies = dependencies,
    type = type)
  update(pkg, ..., Ncpus = threads, quiet = quiet, upgrade = upgrade)
}

##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/install.r
## 


##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/install-remote.r
## 

#' Install a remote package.
#'
#' This:
#' \enumerate{
#'   \item downloads source bundle
#'   \item decompresses & checks that it's a package
#'   \item adds metadata to DESCRIPTION
#'   \item calls install
#' }
#' @noRd
install_remote <- function(remote, ..., quiet = FALSE) {
  stopifnot(is.remote(remote))

  bundle <- remote_download(remote, quiet = quiet)
  on.exit(unlink(bundle), add = TRUE)

  source <- source_pkg(bundle, subdir = remote$subdir)
  on.exit(unlink(source, recursive = TRUE), add = TRUE)

  add_metadata(source, remote_metadata(remote, bundle, source))

  # Because we've modified DESCRIPTION, its original MD5 value is wrong
  clear_description_md5(source)

  install(source, ..., quiet = quiet)
}

install_remotes <- function(remotes, ...) {
  invisible(vapply(remotes, install_remote, ..., FUN.VALUE = logical(1)))
}

# Add metadata
add_metadata <- function(pkg_path, meta) {
  path <- file.path(pkg_path, "DESCRIPTION")
  desc <- read_dcf(path)

  desc <- modifyList(desc, meta)

  write_dcf(path, desc)
}

# Modify the MD5 file - remove the line for DESCRIPTION
clear_description_md5 <- function(pkg_path) {
  path <- file.path(pkg_path, "MD5")

  if (file.exists(path)) {
    text <- readLines(path)
    text <- text[!grepl(".*\\*DESCRIPTION$", text)]

    writeLines(text, path)
  }
}

remote <- function(type, ...) {
  structure(list(...), class = c(paste0(type, "_remote"), "remote"))
}
is.remote <- function(x) inherits(x, "remote")

remote_download <- function(x, quiet = FALSE) UseMethod("remote_download")
remote_metadata <- function(x, bundle = NULL, source = NULL) UseMethod("remote_metadata")

##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/install-remote.r
## 


##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/github.r
## 

github_auth <- function(token) {
  if (is.null(token)) {
    NULL
  } else {
    httr::authenticate(token, "x-oauth-basic", "basic")
  }
}

github_response <- function(req) {
  text <- httr::content(req, as = "text")
  parsed <- jsonlite::fromJSON(text, simplifyVector = FALSE)

  if (httr::status_code(req) >= 400) {
    errors <- vapply(parsed$errors, `[[`, "message", FUN.VALUE = character(1))

    stop(
      parsed$message, " (", httr::status_code(req), ")\n",
      paste("* ", errors, collapse = "\n"),
      call. = FALSE
    )
  }

  parsed
}

github_GET <- function(path, ..., pat = github_pat()) {
  auth <- github_auth(pat)
  req <- httr::GET("https://api.github.com/", path = path, auth, ...)
  github_response(req)
}

github_POST <- function(path, body, ..., pat = github_pat()) {
  auth <- github_auth(pat)
  req <- httr::POST("https://api.github.com/", path = path, body = body, auth,
    encode = "json", ...)
  github_response(req)
}

github_rate_limit <- function() {
  req <- github_GET("rate_limit")
  core <- req$resources$core

  reset <- as.POSIXct(core$reset, origin = "1970-01-01")
  cat(core$remaining, " / ", core$limit,
    " (Reset ", strftime(reset, "%H:%M:%S"), ")\n", sep = "")
}

github_commit <- function(username, repo, ref = "master") {
  github_GET(file.path("repos", username, repo, "commits", ref))
}

github_tag <- function(username, repo, ref = "master") {
  github_GET(file.path("repos", username, repo, "tags", ref))
}

#' Retrieve Github personal access token.
#'
#' A github personal access token
#' Looks in env var \code{GITHUB_PAT}
#'
#' @keywords internal
#' @export
github_pat <- function() {
  pat <- Sys.getenv('GITHUB_PAT')
  if (identical(pat, "")) return(NULL)

  message("Using github PAT from envvar GITHUB_PAT")
  pat
}

##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/github.r
## 


##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/install-github.r
## 

#' Attempts to install a package directly from GitHub.
#'
#' This function is vectorised on \code{repo} so you can install multiple
#' packages in a single command.
#'
#' @param repo Repository address in the format
#'   \code{username/repo[/subdir][@@ref|#pull]}. Alternatively, you can
#'   specify \code{subdir} and/or \code{ref} using the respective parameters
#'   (see below); if both is specified, the values in \code{repo} take
#'   precedence.
#' @param username User name. Deprecated: please include username in the
#'   \code{repo}
#' @param ref Desired git reference. Could be a commit, tag, or branch
#'   name, or a call to \code{\link{github_pull}}. Defaults to \code{"master"}.
#' @param subdir subdirectory within repo that contains the R package.
#' @param auth_token To install from a private repo, generate a personal
#'   access token (PAT) in \url{https://github.com/settings/applications} and
#'   supply to this argument. This is safer than using a password because
#'   you can easily delete a PAT without affecting any others. Defaults to
#'   the \code{GITHUB_PAT} environment variable.
#' @param host GitHub API host to use. Override with your GitHub enterprise
#'   hostname, for example, \code{"github.hostname.com/api/v3"}.
#' @param ... Other arguments passed on to \code{\link{install}}.
#' @details
#' Attempting to install from a source repository that uses submodules
#' raises a warning. Because the zipped sources provided by GitHub do not
#' include submodules, this may lead to unexpected behaviour or compilation
#' failure in source packages. In this case, cloning the repository manually
#' using \code{\link{install_git}} with \code{args="--recursive"} may yield
#' better results.
#' @export
#' @family package installation
#' @seealso \code{\link{github_pull}}
#' @examples
#' \dontrun{
#' install_github("klutometis/roxygen")
#' install_github("wch/ggplot2")
#' install_github(c("rstudio/httpuv", "rstudio/shiny"))
#' install_github(c("hadley/httr@@v0.4", "klutometis/roxygen#142",
#'   "mfrasca/r-logging/pkg"))
#'
#' # Update devtools to the latest version, on Linux and Mac
#' # On Windows, this won't work - see ?build_github_devtools
#' install_github("hadley/devtools")
#'
#' # To install from a private repo, use auth_token with a token
#' # from https://github.com/settings/applications. You only need the
#' # repo scope. Best practice is to save your PAT in env var called
#' # GITHUB_PAT.
#' install_github("hadley/private", auth_token = "abc")
#'
#' }
install_github <- function(repo, username = NULL,
                           ref = "master", subdir = NULL,
                           auth_token = github_pat(),
                           host = "api.github.com", ...) {

  remotes <- lapply(repo, github_remote, username = username, ref = ref,
    subdir = subdir, auth_token = auth_token, host = host)

  install_remotes(remotes, ...)
}

github_remote <- function(repo, username = NULL, ref = NULL, subdir = NULL,
                       auth_token = github_pat(), sha = NULL,
                       host = "api.github.com") {

  meta <- parse_git_repo(repo)
  meta <- github_resolve_ref(meta$ref %||% ref, meta)

  if (is.null(meta$username)) {
    meta$username <- username %||% getOption("github.user") %||%
      stop("Unknown username.")
    warning("Username parameter is deprecated. Please use ",
      username, "/", repo, call. = FALSE)
  }

  remote("github",
    host = host,
    repo = meta$repo,
    subdir = meta$subdir %||% subdir,
    username = meta$username,
    ref = meta$ref,
    sha = sha,
    auth_token = auth_token
  )
}

#' @export
remote_download.github_remote <- function(x, quiet = FALSE) {
  if (!quiet) {
    message("Downloading GitHub repo ", x$username, "/", x$repo, "@", x$ref)
  }

  dest <- tempfile(fileext = paste0(".zip"))
  src_root <- paste0("https://", x$host, "/repos/", x$username, "/", x$repo)
  src <- paste0(src_root, "/zipball/", x$ref)

  if (!is.null(x$auth_token)) {
    auth <- httr::authenticate(
      user = x$auth_token,
      password = "x-oauth-basic",
      type = "basic"
    )
  } else {
    auth <- NULL
  }

  if (github_has_remotes(x, auth))
    warning("GitHub repo contains submodules, may not function as expected!",
      call. = FALSE)

  download(dest, src, auth)
}

github_has_remotes <- function(x, auth = NULL) {
  src_root <- paste0("https://", x$host, "/repos/", x$username, "/", x$repo)
  src_submodules <- paste0(src_root, "/contents/.gitmodules?ref=", x$ref)
  response <- httr::HEAD(src_submodules, , auth)
  identical(httr::status_code(response), 200L)
}

#' @export
remote_metadata.github_remote <- function(x, bundle = NULL, source = NULL) {
  # Determine sha as efficiently as possible
  if (!is.null(x$sha)) {
    # Might be cached already (because re-installing)
    sha <- x$sha
  } else if (!is.null(bundle)) {
    # Might be able to get from zip archive
    sha <- git_extract_sha1(bundle)
  } else {
    # Otherwise can use github api
    sha <- github_commit(x$username, x$repo, x$ref)$sha
  }

  list(
    RemoteType = "github",
    RemoteHost = x$host,
    RemoteRepo = x$repo,
    RemoteUsername = x$username,
    RemoteRef = x$ref,
    RemoteSha = sha,
    RemoteSubdir = x$subdir,
    # Backward compatibility for packrat etc.
    GithubRepo = x$repo,
    GithubUsername = x$username,
    GithubRef = x$ref,
    GithubSHA1 = sha,
    GithubSubdir = x$subdir
  )
}

#' GitHub references
#'
#' Use as \code{ref} parameter to \code{\link{install_github}}.
#' Allows installing a specific pull request or the latest release.
#'
#' @param pull The pull request to install
#' @seealso \code{\link{install_github}}
#' @rdname github_refs
#' @export
github_pull <- function(pull) structure(pull, class = "github_pull")

#' @rdname github_refs
#' @export
github_release <- function() structure(NA_integer_, class = "github_release")

github_resolve_ref <- function(x, params) UseMethod("github_resolve_ref")

#' @export
github_resolve_ref.default <- function(x, params) {
  params$ref <- x
  params
}

#' @export
github_resolve_ref.NULL <- function(x, params) {
  params$ref <- "master"
  params
}

#' @export
github_resolve_ref.github_pull <- function(x, params) {
  # GET /repos/:user/:repo/pulls/:number
  path <- file.path("repos", params$username, params$repo, "pulls", x)
  response <- github_GET(path)

  params$username <- response$head$user$login
  params$ref <- response$head$ref
  params
}

# Retrieve the ref for the latest release
#' @export
github_resolve_ref.github_release <- function(x, params) {
  # GET /repos/:user/:repo/releases
  path <- paste("repos", params$username, params$repo, "releases", sep = "/")
  response <- github_GET(path)
  if (length(response) == 0L)
    stop("No releases found for repo ", params$username, "/", params$repo, ".")

  params$ref <- response[[1L]]$tag_name
  params
}

# Parse concise git repo specification: [username/]repo[/subdir][#pull|@ref|@*release]
# (the *release suffix represents the latest release)
parse_git_repo <- function(path) {
  username_rx <- "(?:([^/]+)/)?"
  repo_rx <- "([^/@#]+)"
  subdir_rx <- "(?:/([^@#]*[^@#/]))?"
  ref_rx <- "(?:@([^*].*))"
  pull_rx <- "(?:#([0-9]+))"
  release_rx <- "(?:@([*]release))"
  ref_or_pull_or_release_rx <- sprintf("(?:%s|%s|%s)?", ref_rx, pull_rx, release_rx)
  github_rx <- sprintf("^(?:%s%s%s%s|(.*))$",
    username_rx, repo_rx, subdir_rx, ref_or_pull_or_release_rx)

  param_names <- c("username", "repo", "subdir", "ref", "pull", "release", "invalid")
  replace <- stats::setNames(sprintf("\\%d", seq_along(param_names)), param_names)
  params <- lapply(replace, function(r) gsub(github_rx, r, path, perl = TRUE))
  if (params$invalid != "")
    stop(sprintf("Invalid git repo: %s", path))
  params <- params[sapply(params, nchar) > 0]

  if (!is.null(params$pull)) {
    params$ref <- github_pull(params$pull)
    params$pull <- NULL
  }

  if (!is.null(params$release)) {
    params$ref <- github_release()
    params$release <- NULL
  }

  params
}

##
## // end of https://raw.githubusercontent.com/hadley/devtools/master/R/install-github.r
## 

## load docopt and devtools from CRAN
suppressMessages(library(docopt))       # we need docopt (>= 0.3) as on CRAN

## configuration for docopt
doc <- "Usage: installGithub.r [-h] [-d DEPS] REPOS...

-d --deps DEPS      Install suggested dependencies as well? [default: NA]
-h --help           show this help text

where REPOS... is one or more GitHub repositories.

Examples:
  installGithub.r RcppCore/RcppEigen

installGithub.r is part of littler which brings 'r' to the command-line.
See http://dirk.eddelbuettel.com/code/littler.html for more information.
"

## docopt parsing
opt <- docopt(doc)
if (opt$deps == "TRUE" || opt$deps == "FALSE") {
    opt$deps <- as.logical(opt$deps)
} else if (opt$deps == "NA") {
    opt$deps <- NA
}

invisible(sapply(opt$REPOS, function(r) install_github(r, dependencies = opt$deps)))
