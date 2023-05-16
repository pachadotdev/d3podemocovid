#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import d3po
#' @importFrom dplyr filter select group_by mutate
#' @importFrom rlang sym
#' @importFrom lubridate year month
#' @noRd
app_server <- function(input, output, session) {
  selected_date <- reactive({
    input$date
  })

  selected_province <- reactive({
    input$province
  })

  vaccination_coverage_week <- eventReactive(input$date, {
    d3podemocovid::vaccination_coverage %>%
      filter(
        !!sym("week_end") == selected_date(),
        !!sym("pruid") != 1
      ) %>%
      select(id = !!sym("prename"), !!sym("proptotal_atleast1dose"))
  })

  province_coverage <- eventReactive(input$province, {
    d <- d3podemocovid::vaccination_coverage %>%
      filter(!!sym("pruid") != 1, !!sym("prename") == selected_province()) %>%
      select(id = !!sym("prename"), !!sym("week_end"), !!sym("proptotal_atleast1dose"))

    d <- d %>%
      mutate(yearmonth = paste0(year(!!sym("week_end")), month(!!sym("week_end")))) %>%
      group_by(!!sym("yearmonth")) %>%
      filter(!!sym("week_end") == max(!!sym("week_end")))

    # vaccination_coverage %>%
    #   mutate(yearmonth = paste0(year(!!sym("week_end")), month(!!sym("week_end")))) %>%
    #   group_by(!!sym("yearmonth")) %>%
    #   filter(!!sym("week_end") == max(!!sym("week_end"))) %>%
    #   distinct(week_end) %>%
    #   pull(week_end) %>%
    #   paste(collapse = '","')

    return(d)
  })

  output$line <- render_d3po({
    d3po(province_coverage()) %>%
      po_line(
        daes(x = !!sym("week_end"), y = !!sym("proptotal_atleast1dose"), group = !!sym("id"), color = !!sym("id"))
      ) %>%
      po_title(sprintf("Percent of the population who have received at least 1 dose of a COVID-19 vaccine - %s", selected_province()))
  })

  output$geomap <- render_d3po({
    d3po(vaccination_coverage_week()) %>%
      po_geomap(
        daes(
          group = !!sym("id"),
          color = !!sym("proptotal_atleast1dose")
        ),
        map = d3podemocovid::provinces
      ) %>%
      po_title(sprintf("Percent of the population who have received at least 1 dose of a COVID-19 vaccine - %s", selected_date()))
  })
}
