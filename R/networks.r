#' Networks metadata.
#'
#' @template otherlimstart
#' @template occ
#' @template identifierargs
#' @export
#'
#' @param data The type of data to get. One or more of: 'contact', 'endpoint',
#'    'identifier', 'tag', 'machineTag', 'comment', 'constituents', or the
#'    special 'all'. Default: `'all'`
#' @param uuid UUID of the data network provider. This must be specified if
#' data is anything other than 'all'. Only 1 can be passed in
#' @param query Query nodes. Only used when `data='all'`. Ignored
#' otherwise.
#'
#' @references <http://www.gbif.org/developer/registry#networks>
#'
#' @examples \dontrun{
#' networks(limit=5)
#' networks(uuid='7ddd1f14-a2b0-4838-95b0-785846f656f3')
#' uuids <- c('7ddd1f14-a2b0-4838-95b0-785846f656f3',
#'   '07b013b4-a2da-47a1-a8ef-df685912fbd6')
#' lapply(uuids, function(x) networks(uuid = x))
#' networks(data='endpoint', uuid='16ab5405-6c94-4189-ac71-16ca3b753df7')
#'
#' # curl options
#' networks(limit=5, curlopts = list(verbose=TRUE))
#' }

networks <- function(data = 'all', uuid = NULL, query = NULL, identifier=NULL,
                     identifierType=NULL, limit=100, start=NULL,
                     curlopts = list()) {

  args <- rgbif_compact(list(q = query, limit = as.integer(limit),
                             offset = start))
  data <- match.arg(data,
                    choices = c(
                      'all', 'contact', 'endpoint', 'identifier',
                      'tag', 'machineTag', 'comment', 'constituents'),
                    several.ok = TRUE)

  # Define function to get data
  getdata <- function(x){
    if (!x == 'all' && is.null(uuid))
      stop('You must specify a uuid if data does not equal "all"')

    url <- if (is.null(uuid)) {
      paste0(gbif_base(), '/network')
    } else {
      if (x == 'all') { sprintf('%s/network/%s', gbif_base(), uuid) } else {
        sprintf('%s/network/%s/%s', gbif_base(), uuid, x)
      }
    }
    res <- gbif_GET(url, args, TRUE, curlopts)
    structure(list(meta = get_meta(res), data = parse_results(res, uuid)))
  }

  # Get data
  if (length(data) == 1) getdata(data) else lapply(data, getdata)
}
