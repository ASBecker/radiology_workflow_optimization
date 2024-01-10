email_body <- function(df) {
  if(df$Reason == "Temporary Change to FF - Pending Incoming Materials") {
    temp_msg <- " while an Image Coordinator is working with your office to obtain additional information needed to complete the read"
  } else {
    temp_msg <- ""
  }
  if(all(df$Reason == "No reason indicated")) df %<>% select(-Reason)
  paste0(
  '
<html>
<head>
<meta charset="utf-8"> <!-- utf-8 works for most cases -->
<meta name="viewport" content="width=device-width"> <!-- Forcing initial-scale shouldn`t be necessary -->
<meta http-equiv="X-UA-Compatible" content="IE=edge"> <!-- Use the latest (edge) version of IE rendering engine -->
<meta name="x-apple-disable-message-reformatting">  <!-- Disable auto-scale in iOS 10 Mail entirely -->
<meta name="format-detection" content="telephone=no,address=no,email=no,date=no,url=no"> <!-- Tell iOS not to automatically link certain text strings. -->
<meta name="color-scheme" content="light">
<meta name="supported-color-schemes" content="light">
<!-- What it does: Makes background images in 72ppi Outlook render at correct size. -->
<!--[if gte mso 9]>
<xml>
<o:OfficeDocumentSettings>
<o:AllowPNG/>
<o:PixelsPerInch>96</o:PixelsPerInch>
</o:OfficeDocumentSettings>
</xml>
<![endif]-->
<title>$if(title-prefix)$$title-prefix$ - $endif$$pagetitle$</title>
<style>
body {
font-family: Helvetica, sans-serif;
font-size: 14px;
}
.content {
background-color: white;
}
.content .message-block {
margin-bottom: 24px;
}
.header .message-block, .footer message-block {
margin-bottom: 12px;
}
img {
max-width: 100%;
}
@media only screen and (max-width: 767px) {
.container {
width: 100%;
}
.articles, .articles tr, .articles td {
display: block;
width: 100%;
}
.article {
margin-bottom: 24px;
}
}
</style>
</head>
<body style="background-color:#f6f6f6;font-family:Helvetica, sans-serif;color:#222;margin:0;padding:0;">
  <table width="85%" align="center" class="container"
style="max-width:1000px;">
    <tr>
      <td style="padding:24px;">
        <table width="100%" class="content" style="background-color:white;">
          <tr>
            <td style="padding:12px;"><h2>Automatic Notification: Submitted radiology exam will not be read</h2>
<p>An internal report cannot be issued for the following outside radiology examinations submitted for read. The images will be available on PACS but no report generated', temp_msg, ', as per institutional policy.</p>
<p>For any questions, please file a IT support ticket and reference the Accession number and MRN.</p>
<p>Please do not reply to this e-mail, it has been sent from an unattended mailbox. </p>',
knitr::kable(df, format = "html"),
sprintf('</td>
          </tr>
        </table>
        <div class="footer" style="font-family:Helvetica, sans-serif;color:#999999;font-size:8px;font-weight:normal;margin:24px 0 0 0;text-align:center;"><p>E-mail generated %s</p>
</div>
      </td>
    </tr>
  </table>
</body>', Sys.time())
  )
}

email_body_filmlib <- function(df) {
  paste0(
    '
<html>
<head>
<meta charset="utf-8"> <!-- utf-8 works for most cases -->
<meta name="viewport" content="width=device-width"> <!-- Forcing initial-scale shouldn`t be necessary -->
<meta http-equiv="X-UA-Compatible" content="IE=edge"> <!-- Use the latest (edge) version of IE rendering engine -->
<meta name="x-apple-disable-message-reformatting">  <!-- Disable auto-scale in iOS 10 Mail entirely -->
<meta name="format-detection" content="telephone=no,address=no,email=no,date=no,url=no"> <!-- Tell iOS not to automatically link certain text strings. -->
<meta name="color-scheme" content="light">
<meta name="supported-color-schemes" content="light">
<!-- What it does: Makes background images in 72ppi Outlook render at correct size. -->
<!--[if gte mso 9]>
<xml>
<o:OfficeDocumentSettings>
<o:AllowPNG/>
<o:PixelsPerInch>96</o:PixelsPerInch>
</o:OfficeDocumentSettings>
</xml>
<![endif]-->
<title>$if(title-prefix)$$title-prefix$ - $endif$$pagetitle$</title>
<style>
body {
font-family: Helvetica, sans-serif;
font-size: 14px;
}
.content {
background-color: white;
}
.content .message-block {
margin-bottom: 24px;
}
.header .message-block, .footer message-block {
margin-bottom: 12px;
}
img {
max-width: 100%;
}
@media only screen and (max-width: 767px) {
.container {
width: 100%;
}
.articles, .articles tr, .articles td {
display: block;
width: 100%;
}
.article {
margin-bottom: 24px;
}
}
</style>
</head>
<body style="background-color:#f6f6f6;font-family:Helvetica, sans-serif;color:#222;margin:0;padding:0;">
  <table width="85%" align="center" class="container"
style="max-width:1000px;">
    <tr>
      <td style="padding:24px;">
        <table width="100%" class="content" style="background-color:white;">
          <tr>
            <td style="padding:12px;"><h2>‼️Missing E-Mail Notification‼️</h2>
<p>The following exams have been converted to ForFile, without a contact address in the system.</p>
<p>Please inform the treating physician/team that no radiology report will be issued for the following exams.</p>
<p>Do not reply to this e-mail, it has been sent from an unattended mailbox. </p>',
knitr::kable(df, format = "html"),
sprintf('</td>
          </tr>
        </table>
        <div class="footer" style="font-family:Helvetica, sans-serif;color:#999999;font-size:8px;font-weight:normal;margin:24px 0 0 0;text-align:center;"><p>E-mail generated %s</p>
</div>
      </td>
    </tr>
  </table>
</body>', Sys.time())
  )
}

