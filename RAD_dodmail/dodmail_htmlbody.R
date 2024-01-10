make_body <- function(dod_am, dod_pm, dod_late) {
  if(dod_pm == dod_late) {
    late_block <- glue::glue("<p>DOD pm (1-close): {dod_pm}</p>")
  } else {
    late_block <- late_block <- glue::glue("<p>DOD pm (1-6): {dod_pm}</p> <p>LATE (6-close): {dod_late}</p>")
  }
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
            <td style="padding:12px;"><h2>DOD schedule today</h2>',
            glue::glue('<p>Please find the DOD schedule below:</p>
<p>DOD am (8-1): {dod_am}</p> 
{late_block}
</td>
   </tr>
     </table>
        <div class="footer" style="font-family:Helvetica, sans-serif;color:#999999;font-size:8px;font-weight:normal;margin:24px 0 0 0;text-align:center;"><p>Radiology - Analytics Service</p></div>
      </td>
    </tr>
  </table>
</body>'
  ))
}

make_body_regional <- function(dod_early, dod_am, dod_pm, dod_late) {
  if(dod_late == "<mark>Missing entry, check QGenda</mark>") dod_late <- dod_pm
  if(dod_pm == dod_late) {
    late_block <- glue::glue("<p>DOD pm (1-7): {dod_pm}</p>")
  } else {
    late_block <- late_block <- glue::glue("<p>DOD mid-pm (1-4): {dod_pm}</p> <p>LATE (4-7): {dod_late}</p>")
  }
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
            <td style="padding:12px;"><h2>DOD schedule today</h2>',
glue::glue('<p>Please find the DOD schedule below:</p>
{ifelse(is.na(dod_early), paste0(""), paste0("<p>DOD early: ", dod_early, "</p>"))}
<p>DOD am (8-1): {dod_am}</p> 
{late_block}
</td>
   </tr>
     </table>
        <div class="footer" style="font-family:Helvetica, sans-serif;color:#999999;font-size:8px;font-weight:normal;margin:24px 0 0 0;text-align:center;"><p>Radiology - Analytics Service</p></div>
      </td>
    </tr>
  </table>
</body>'
))
}
