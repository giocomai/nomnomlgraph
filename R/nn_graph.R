#' Create a diagram with `nomnoml` based on edges and nodes
#'
#' Available `association` types to be used in the `edges` data frame:
#'
#' -    association
#' ->   association
#' <->  association
#' -->  dependency
#' <--> dependency
#' -:>  generalization
#' <:-  generalization
#' --:> implementation
#' <:-- implementation
#' +-   composition
#' +->  composition
#' o-   aggregation
#' o->  aggregation
#' --   note
#' -/-  hidden
#'
#' @param nodes A data frame with two columns: `id`, `text`, and an optional
#'   `classifier`.
#' @param edges A data frame with three columns: `from`, `to`, and
#'   `association`.
#' @param output Defaults to "diagram". Valid values are either "diagram" or
#'   "code".
#' @param direction Defaults to "down". Valid values are either "down" or
#'   "right".
#' @param fill Defaults to "#FEFEFF". Values commonly used by `nomnoml` inlcude
#'   "#eee8d5" and "#fdf6e3".
#' @param edgesStyle Defaults to "hard". Valid values are either "hard" or
#'   "rounded". Value is passed to `nomnoml` as "edges".
#'
#' @inheritParams nomnoml::nomnoml
#'
#' @return An object with class `nomnoml` and `htmlwidget`. By default, it the
#'   diagram is printed.
#' @export
#'
#' @examples
#' nodes <- tibble::tribble(
#'   ~id, ~text,
#'   1, "Starting point",
#'   2, "Other starting point",
#'   3, "This is where things merge",
#'   4, "This is where things go"
#' )
#'
#'
#' edges <- tibble::tribble(
#'   ~from, ~to, ~association,
#'   1, 3, "-",
#'   2, 3, "-",
#'   3, 4, "->"
#' )
#'
#' nn_graph(
#'   nodes = nodes,
#'   edges = edges,
#'   fill = "#fdf6e3",
#'   edgesStyle = "rounded",
#'   # font = "Roboto Condensed",
#'   fillArrows = "false",
#'   svg = TRUE
#' )
nn_graph <- function(nodes,
                     edges,
                     output = "diagram",
                     direction = "down",
                     lineWidth = 1,
                     fill = "#FEFEFF",
                     zoom = 4,
                     arrowSize = 1,
                     bendSize = 0.3,
                     gutter = 5,
                     edgeMargin = 0,
                     edgesStyle = "hard",
                     fillArrows = "false",
                     font = "sans",
                     fontSize = 12,
                     leading = 1.25,
                     padding = 8,
                     spacing = 40,
                     stroke = "#33322E",
                     title = "filename",
                     png = NULL,
                     width = NULL,
                     height = NULL,
                     svg = FALSE) {
  if ("classifier" %in% colnames(nodes)) {
    nodes[["classifier"]][is.na(nodes[["classifier"]])] <- ""
  } else {
    nodes[["classifier"]] <- ""
  }

  nodes[["classifier"]] <- dplyr::if_else(condition = nodes[["classifier"]] == "",
    true = "",
    false = stringr::str_c("<", nodes[["classifier"]], ">")
  )

  pre_df <- edges %>%
    dplyr::left_join(
      y = nodes %>%
        dplyr::rename(
          from_text = text,
          from_classifier = classifier
        ),
      by = c("from" = "id")
    ) %>%
    dplyr::left_join(
      y = nodes %>%
        dplyr::rename(
          to_text = text,
          to_classifier = classifier
        ),
      by = c("to" = "id")
    )


  base_nomnoml <- pre_df %>%
    glue::glue_data("[{from_classifier}{from_text}]{association}[{to_classifier}{to_text}]") %>%
    paste(collapse = "\n")

  code_v <- stringr::str_c(c(
    stringr::str_c(
      "#direction: ",
      direction,
      "\n",
      "#edges: ",
      edgesStyle,
      "\n",
      "#lineWidth: ",
      lineWidth,
      "\n",
      "#fill: ",
      fill,
      "\n",
      "#zoom: ",
      zoom,
      "\n",
      "#arrowSize: ",
      arrowSize,
      "\n",
      "#bendSize: ",
      bendSize,
      "\n",
      "#gutter: ",
      gutter,
      "\n",
      "#edgeMargin: ",
      edgeMargin,
      "\n",

      "#fillArrows: ",
      fillArrows,
      "\n",
      "#font: ",
      font,
      "\n",
      "#fontSize: ",
      fontSize,
      "\n",
      "#leading: ",
      leading,
      "\n",
      "#padding: ",
      padding,
      "\n",
      "#spacing: ",
      spacing,
      "\n",
      "#stroke: ",
      stroke,
      "\n",
      "#title: ",
      title,
      "\n"
    ),
    base_nomnoml
  ),
  collapse = "\n"
  )

  if (output == "code") {
    code_v
  } else {
    nomnoml::nomnoml(
      code = code_v,
      png = png,
      width = width,
      height = height,
      svg = svg
    )
  }
}

