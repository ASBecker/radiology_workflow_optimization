library(shiny)
library(shinyjs)
library(tidyverse)
library(magrittr)
library(tidyr)
library(lubridate)
library(stringi)
library(httr)
library(XML)
library(xml2)
library(knitr)
library(ignyt)
library(kableExtra)

# Perform authentication on start -----------------------------------

auth_req <- dictation_sys_auth()

if (status_code(auth_req) != 200) stop("Could not connect to Dictation System API")

con <- analytics_sql_con()

# Custom functions --------------------------------------------------------

pdate <- function(d) {
  d %>%
    ymd_hms(tz = "America/New_York") %>%
    as.character()
}

xml_auditdf <- function(report_xml, pacs_trail, datawarehouse_vars) {
  if (!is.character(report_xml)) {
    if (typeof(report_xml) == "list") {
      xml_list <- xmlToList(xmlParse(report_xml))

      report <- xml_list$OriginalReport$ContentRTF %>%
        str_split(coll("{\\xml}")) %>%
        .[[1]] %>%
        .[2] %>%
        read_xml()

      if (report %>% xml_find_all("//name") %>% xml_text() %>% stri_cmp_eq("LIP") %>% any()) {
        chr_vec <- report %>%
          xml_children() %>%
          xml_children() %>%
          xml_children() %>%
          xml_text()
        ix_dt <- chr_vec %>%
          stri_cmp_eq("DATE") %>%
          which() %>%
          sum(1)
        ix_tm <- chr_vec %>%
          stri_cmp_eq("TIME") %>%
          which() %>%
          sum(1)
        ix_rad <- chr_vec %>%
          stri_cmp_eq("DOCTOR") %>%
          which() %>%
          sum(1)
        ix_ref <- chr_vec %>%
          stri_cmp_eq("LIP") %>%
          which() %>%
          sum(1)

        phone_datetime <- paste0(chr_vec[ix_dt], " ", chr_vec[ix_tm])
        phone_callers <- paste(chr_vec[ix_rad], " &#8594; ", chr_vec[ix_ref])
      } else {
        phone_datetime <- NA
        phone_callers <- NA
      }
    } else {
      xml_list <- list()
    }
    out_df <- tibble(
      Status = c(
        "Order: Entered", "Order: Released",
        "Scheduling: Entered at",
        "Exam: Scheduled date/time", "Exam: Pt. arrived", "Exam: Begin", "Exam: Finished",
        "PACS*: First imgs. available", "PACS*: Last imgs arrived", "PACS*: Last verified",
        "Ignyt: Assigned at [to]",
        "Ignyt: Manually reassigned at [by]",
        "&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; new reader:",
        "&#9997; Report: Drafted",
        "Report: Phone call with prelim. findings",
        "&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; who called who:",
        "&#10004; Report: Prelim",
        "Report: Last modified",
        "&#128231; ER: Prelim. report notification",
        "&#9989; Report: Finalized",
        "&#128231; ER: Final report notification",
        "&#128231; ER: Attending notified:",
        "Reading Resident/Fellow:",
        "Signing Attending:"
      ),
      Timestamp = c(
        datawarehouse_vars$OMS_ENTER_DT %>% pdate(),
        datawarehouse_vars$OMS_RELEASE_DT %>% pdate(),
        datawarehouse_vars$ris_create_dt,
        datawarehouse_vars$ris_scheduled_dt,
        datawarehouse_vars$ris_pt_arrival_dt,
        datawarehouse_vars$ris_exam_start_dt,
        datawarehouse_vars$ris_exam_end_dt,
        xml_list$Orders$Order$Procedures$Procedure$EndDate %>% pdate(),
        xml_list$Orders$Order$CustomFields$CustomField$SetDate %>% pdate(),
        xml_list$OriginalReport$CreateDate %>% pdate(),
        datawarehouse_vars$ignyt_timestamp %>% replace_na("Not assigned"),
        datawarehouse_vars$reassignment_dttm,
        {
          if (!is.na(datawarehouse_vars$new_reader)) paste(" &#8594; ", datawarehouse_vars$new_reader) else NA
        },
        datawarehouse_vars$draft_timestamp %>%
          pdate() %>%
          {
            if (is.na(.)) if_else(is.na(datawarehouse_vars$ignyt_timestamp), "Not drafted", "No draft timestamp recorded") else .
          },
        phone_datetime,
        phone_callers,
        datawarehouse_vars$OMS_PRELIM_RESULTS_DT %>% pdate() %>% replace_na("No prelim. report date recorded"),
        xml_list$OriginalReport$LastModifiedDate %>% pdate(),
        datawarehouse_vars$prelim_email_timestamp,
        datawarehouse_vars$OMS_FINAL_RESULTS_DT %>% pdate(),
        datawarehouse_vars$final_email_timestamp,
        datawarehouse_vars$ERAttendingFullName,
        datawarehouse_vars$fellow_resident_name,
        datawarehouse_vars$radiologist_name
      )
    ) %>%
      filter(!(is.na(Timestamp) | Timestamp == "NA [NA]"))
  } else {
    out_df <- tibble(
      Status = c(
        "Order: Entered", "Order: Released",
        "Scheduling: Entered at",
        "Exam: Scheduled date/time", "Exam: Pt. arrived", "Exam: Begin", "Exam: Finished",
        "PACS*: First imgs. available", "PACS*: Last imgs arrived", "PACS*: Last verified",
        "Ignyt: Assigned at [to]",
        "Ignyt: Manually reassigned at [by]",
        "&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; new reader:",
        "&#9997; Report: Drafted",
        "&#10004; Report: Prelim",
        "&#128231; ER: Prelim. report notification",
        "&#9989; Report: Finalized",
        "&#128231; ER: Final report notification",
        "&#128231; ER: Attending notified:",
        "Reading Resident/Fellow:",
        "Signing Attending:"
      ),
      Timestamp = c(
        datawarehouse_vars$OMS_ENTER_DT %>% pdate(),
        datawarehouse_vars$OMS_RELEASE_DT %>% pdate(),
        datawarehouse_vars$ris_create_dt,
        datawarehouse_vars$ris_scheduled_dt,
        datawarehouse_vars$ris_pt_arrival_dt,
        datawarehouse_vars$ris_exam_start_dt,
        datawarehouse_vars$ris_exam_end_dt,
        xml_list$Orders$Order$Procedures$Procedure$EndDate %>% pdate(),
        xml_list$Orders$Order$CustomFields$CustomField$SetDate %>% pdate(),
        xml_list$OriginalReport$CreateDate %>% pdate(),
        datawarehouse_vars$ignyt_timestamp %>% replace_na("Not assigned"),
        datawarehouse_vars$reassignment_dttm,
        {
          if (!is.na(datawarehouse_vars$new_reader)) paste(" &#8594; ", datawarehouse_vars$new_reader) else NA
        },
        datawarehouse_vars$draft_timestamp %>%
          pdate() %>%
          {
            if (is.na(.)) if_else(is.na(datawarehouse_vars$ignyt_timestamp), "Not drafted", "No draft timestamp recorded") else .
          },
        datawarehouse_vars$OMS_PRELIM_RESULTS_DT %>% pdate() %>% replace_na("No prelim. report date recorded"),
        datawarehouse_vars$prelim_email_timestamp,
        datawarehouse_vars$OMS_FINAL_RESULTS_DT %>% pdate(),
        datawarehouse_vars$final_email_timestamp,
        datawarehouse_vars$ERAttendingFullName,
        datawarehouse_vars$fellow_resident_name,
        datawarehouse_vars$radiologist_name
      )
    ) %>%
      filter(!(is.na(Timestamp) | Timestamp == "NA [NA]"))
  }
  
  if(stringr::str_detect(datawarehouse_vars$`Exam Description`, "FOREIGN|FORFILE")) {
    out_df[which(out_df$Status == "Scheduling: Entered at"), ]$Status <- "Film library: Images received"
    out_df[which(out_df$Status == "Exam: Begin"), ]$Status <- "Film Library: Images pushed to PACS"
    out_df[which(out_df$Status == "Exam: Finished"), ]$Status <- "RIS: Exam marked as 'Completed'"
    out_df <- out_df[which(!out_df$Status %in% c("Exam: Pt. arrived", "Exam: Scheduled date/time")), ]
    if(ymd_hms(out_df[which(out_df$Status == "Report: Last modified"), ]$Timestamp) > ymd_hms(out_df[which(out_df$Status == "&#9989; Report: Finalized"), ]$Timestamp)) {
      out_df[which(out_df$Status == "Report: Last modified"), ]$Timestamp <- out_df[which(out_df$Status == "&#9989; Report: Finalized"), ]$Timestamp
      out_df[which(out_df$Status == "&#9989; Report: Finalized"), ]$Timestamp <- "Timestamp unavailable. Check PS360/RIS directly or back here in a few hours."
    }
  }
  
  sbind <- purrr::safely(vctrs::vec_rbind)

  cmb_df <- sbind(
    out_df[1:which(out_df$Status == "Exam: Finished" | out_df$Status == "RIS: Exam marked as 'Completed'"), ],
    pacs_trail %>%
      mutate(
        Status = paste("PACS:", Action, " [", `User#1`, "]"),
        dttm = paste0(Date, " ", toupper(Time)),
        Timestamp = as.character(mdy_hms(dttm, tz = "America/New_York"))
      ) %>%
      select(Status, Timestamp),
    out_df[which(out_df$Status == "Exam: Finished" | out_df$Status == "RIS: Exam marked as 'Completed'") + 1:nrow(out_df), ]
  )

  if (is.null(cmb_df$error)) {
    out_df <- cmb_df$result
  }

  out_df %<>% arrange(Timestamp) %>%
    filter(!is.na(Status) & !is.na(Timestamp))
}

datawarehouse_times <- function(accno, con) {
  dm_times <- sql_query(con, sprintf("select 
                                     t1.[Exam Description],
                                     t1.[Accession Number],
                                     t2.OMS_ENTER_DT, t2.OMS_RELEASE_DT, 
                                     t1.[Date Exam Scheduled (Created)] AS ris_create_dt, 
                                     t1.[Scheduled Date] AS ris_scheduled_dt, 
                                     t1.[Arrival Date] AS ris_pt_arrival_dt,
                                     t1.[Begin Date] AS ris_exam_start_dt, 
                                     t1.[Exam Completed] AS ris_exam_end_dt,
                                     t3.draft_timestamp,
                                     t4.ignyt_timestamp,
                                     t4.[User Name],
                                     t5.ERAttendingFullName, 
                                     t2.OMS_PRELIM_RESULTS_DT,
                                     t5.prelim_email_timestamp,
                                     t2.OMS_FINAL_RESULTS_DT,
                                     t1.[Finalized Date],
                                     t5.final_email_timestamp,
                                     t1.[Fellow/Resident] AS fellow_resident_name, 
                                     t1.[Radiologist] AS radiologist_name
                           FROM RISdb t1
                           LEFT JOIN datawarehouse.OMS_DATA t2
                           ON t1.[Accession Number] = t2.OMS_RIS_ACCESSION_ID
                           LEFT JOIN ignyt.log_draft t3
                           ON t1.[Accession Number] = t3.[Accession Number]
                           LEFT JOIN ignyt.log_assigned t4
                           ON t1.[Case ID (Main)] = t4.[Case ID (Main)]
                           LEFT JOIN ignyt.erlog t5
                           ON t1.[Accession Number] = t5.ris_accession_number
                           WHERE t1.[Accession Number] = %s;", accno)) %>%
    mutate(OMS_FINAL_RESULTS_DT = tidyr::replace_na(OMS_FINAL_RESULTS_DT, `Finalized Date`)) %>% 
    select(-`Finalized Date`) %>%
    mutate(ignyt_timestamp = paste0(pdate(ignyt_timestamp), " [", `User Name`, "]"))
  if(nrow(dm_times) > 2) {
    if(length(unique(dm_times$ignyt_timestamp)) > 1) {
      dm_times$ignyt_timestamp <- apply(dm_times[, "ignyt_timestamp"], 2, paste, collapse = "<br \\>")
    }
  }
  dm_times %<>% left_join(
    sql_query(con, sprintf("SELECT accno, timestamp, new_reader, reassigning_user
                FROM ignyt.log_reassignments
                WHERE accno = '%s';", accno)),
      by = c("Accession Number" = "accno")
  ) %>%
    mutate(reassignment_dttm = paste0(mdy_hm(timestamp, tz = "America/New_York"), " [", reassigning_user, "]")) %>%
    distinct(reassignment_dttm, .keep_all = TRUE)
  if (nrow(dm_times) > 1) {
    dm_times$reassignment_dttm <- apply(dm_times[, "reassignment_dttm"], 2, paste, collapse = "<br \\>")
    dm_times$new_reader <- apply(dm_times[, "new_reader"], 2, paste, collapse = "<br \\>")
    dm_times$reassigning_user <- apply(dm_times[, "reassigning_user"], 2, paste, collapse = "<br \\>")
  }
  dm_times %<>% distinct(reassignment_dttm, .keep_all = TRUE) %>%
    mutate_all(as.character)
}

# Shiny -------------------------------------------------------------------

ui <- fluidPage(
  titlePanel("Report Audit Trail for Accession Number"),
  sidebarLayout(
    sidebarPanel(
      useShinyjs(),
      textInput("accno", "Accession Number"),
      actionButton("update", "Search"),
      checkboxInput("query_pacs", HTML("Query PACS <br />(report longer and less legible)"))
    ),
    mainPanel(
      htmlOutput("auditTrail")
    )
  )
)


server <- function(input, output, session) {
  observeEvent(TRUE,
    {
      query <- parseQueryString(session$clientData$url_search)
      if (!is.null(query$accno)) {
        runjs("window.history.replaceState(null, null, window.location.pathname);")
        updateTextInput(session, "accno", value = query[["accno"]])
        delay(1000, click("update"))
      }
    },
    once = TRUE
  )

  observe({
    toggleState("update", !is.null(input$accno) && input$accno != "")
  })

  accno_click <- eventReactive(input$update, {
    input$accno
  })
  
  pacs_click <- eventReactive(input$update, {
    input$query_pacs
  })

  output$auditTrail <- renderText({
    withProgress(message = "Querying data: ", {
      incProgress(.1, detail = "Dictation system")
      report_query <- report_audit_trail(accno_click())
      
      if(pacs_click()) {
        incProgress(.1, detail = "PACS")
        pacs_query <- pacs_audittrail(accno_click())
      } else {
        pacs_query <- data.frame()
      }

      incProgress(.4, detail = "Order data")
      dm_times <- datawarehouse_times(accno_click(), con)

      incProgress(1, detail = "Finished")
    })
    paste0(
      xml_auditdf(report_query, pacs_query, dm_times) %>%
        kable(escape = FALSE) %>%
        kable_styling(
          bootstrap_options = c("striped", "hover", "condensed", "responsive"),
          stripe_index = c(1, 2, 4:7, 11:14)
        ),
      "<p>* These times are taken from the dictation system audit trail (only rough estimates of PACS events)</p>"
    )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
