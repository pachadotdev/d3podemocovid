#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinydashboard
#' @import d3po
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    dashboardPage(
      dashboardHeader(title = "D3po covid demo"),
      dashboardSidebar(
        collapsed = FALSE,
        selectInput(
          inputId = "date",
          label = "Select date",
          choices = c("2020-12-26","2021-01-30","2021-02-27","2021-03-27","2021-04-24","2021-05-29","2021-06-26","2021-07-31","2021-08-28","2021-09-25","2021-10-30","2021-11-27","2021-12-25","2022-01-30","2022-02-27","2022-03-27","2022-04-24","2022-05-22","2022-06-19","2022-07-17","2022-08-14","2022-09-11","2022-10-09","2022-11-06","2022-12-04","2023-01-29","2023-02-26","2023-03-26","2023-04-23"),
          selected = "2023-04-23"
        ),
        selectInput(
          inputId = "province",
          label = "Select province",
          choices = c("Alberta","British Columbia","Manitoba","New Brunswick","Newfoundland and Labrador","Northwest Territories",
            "Nova Scotia","Nunavut","Ontario","Prince Edward Island","Quebec","Saskatchewan","Yukon"),
          selected = "Ontario"
        )
      ),
      dashboardBody(
        tags$head(tags$style(HTML(".content-wrapper { overflow: auto; }"))),
        col_6(d3po_output("line", height = "650px")),
        col_6(d3po_output("geomap", height = "650px"))
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "d3podemocovid"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
