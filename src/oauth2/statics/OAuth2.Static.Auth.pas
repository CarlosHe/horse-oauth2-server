unit OAuth2.Static.Auth;

interface

const

  OAUTH_HTML_AUTH =

    '<!DOCTYPE html>'#10 +
    '<html lang="en">'#10 +
    '   <head>'#10 +
    '      <title>%APPLICATION_NAME% - Authorize</title>'#10 +
    '      <meta charset="utf-8" />'#10 +
    '      <meta name="viewport" content="minimum-scale=1, initial-scale=1, width=device-width" />'#10 +
    '      <script src="https://unpkg.com/react@latest/umd/react.development.js" crossorigin="anonymous"></script>'#10 +
    '      <script src="https://unpkg.com/react-dom@latest/umd/react-dom.development.js"></script>'#10 +
    '      <script src="https://unpkg.com/@material-ui/core@latest/umd/material-ui.development.js"'#10 +
    '         crossorigin="anonymous"></script>'#10 +
    '      <script src="https://unpkg.com/babel-standalone@latest/babel.min.js" crossorigin="anonymous"></script>'#10 +
    '      <!-- Fonts to support Material Design -->'#10 +
    '      <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:300,400,500,700&display=swap" />'#10 +
    '      <!-- Icons to support Material Design -->'#10 +
    '      <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons" />'#10 +
    '   </head>'#10 +
    '   <body>'#10 +
    '      <div id="root"></div>'#10 +
    '      <script type="text/babel">'#10 +
    ''#10 +
    '         const { useState } = React'#10 +
    ''#10 +
    '         const {'#10 +
    '             colors,'#10 +
    '             CssBaseline,'#10 +
    '             ThemeProvider,'#10 +
    '             Typography,'#10 +
    '             Container,'#10 +
    '             makeStyles,'#10 +
    '             createMuiTheme,'#10 +
    '             Box,'#10 +
    '             SvgIcon,'#10 +
    '             Link,'#10 +
    '             TextField,'#10 +
    '             Avatar,'#10 +
    '             FormControlLabel,'#10 +
    '             Button,'#10 +
    '             Chip,'#10 +
    '         } = MaterialUI;'#10 +
    ''#10 +
    '         // Create a theme instance.'#10 +
    '         const theme = createMuiTheme({'#10 +
    '             palette: {'#10 +
    '                 primary: {'#10 +
    '                     main: "#009688",'#10 +
    '                 },'#10 +
    '                 secondary: {'#10 +
    '                     main: "#263238",'#10 +
    '                 },'#10 +
    '                 error: {'#10 +
    '                     main: colors.red.A400,'#10 +
    '                 },'#10 +
    '                 background: {'#10 +
    '                     default: "#ECEFF1",'#10 +
    '                 },'#10 +
    '             },'#10 +
    '         });'#10 +
    ''#10 +
    '         function LockOutlinedIcon(props) {'#10 +
    '             return ('#10 +
    '                 <SvgIcon {...props}>' +
    '                     <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 ' +
    ' 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.' +
    '9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V' +
    '6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z" />'
    +
    '                 </SvgIcon>' +
    '             );'#10 +
    '         }'#10 +
    ''#10 +
    '         const useStyles = makeStyles(theme => ({'#10 +
    '             paper: {'#10 +
    '                 marginTop: theme.spacing(8),'#10 +
    '                 display: "flex",'#10 +
    '                 flexDirection: "column",'#10 +
    '                 alignItems: "center",'#10 +
    '             },'#10 +
    '             avatar: {'#10 +
    '                 margin: theme.spacing(1),'#10 +
    '                 backgroundColor: theme.palette.secondary.main,'#10 +
    '             },'#10 +
    '             form: {'#10 +
    '                 width: "100%", // Fix IE 11 issue.'#10 +
    '                 marginTop: theme.spacing(1),'#10 +
    '             },'#10 +
    '             submit: {'#10 +
    '                 margin: theme.spacing(2, 0, 2),'#10 +
    '             },'#10 +
    '             scopes_box:{'#10 +
    '                 display: "flex",'#10 +
    '                 padding: theme.spacing(2),'#10 +
    '                 justifyContent: "center",'#10 +
    '                 flexWrap: "wrap",'#10 +
    '                 marginTop: theme.spacing(1),'#10 +
    '                 "& > *": {'#10 +
    '                     margin: theme.spacing(1, 1, 1, 1),'#10 +
    '                 },'#10 +
    '              },'#10 +
    '              scope_text: {'#10 +
    '                 marginTop: theme.spacing(2),'#10 +
    '              }'#10 +
    '         }));'#10 +
    ''#10 +
    '         function Copyright() {'#10 +
    '             return ('#10 +
    '                 <Typography variant="body2" color="textSecondary" align="center">'#10 +
    '                     {"Copyright © "}'#10 +
    '                     <Link color="inherit">'#10 +
    '                         %APPLICATION_NAME%'#10 +
    '                     </Link>{" "}'#10 +
    '                     {new Date().getFullYear()}'#10 +
    '                     {"."}'#10 +
    '                 </Typography>'#10 +
    '             );'#10 +
    '         }'#10 +
    ''#10 +
    '         function App() {'#10 +
    '             const classes = useStyles();'#10 +
    '             return ('#10 +
    '                     <Container component="main" maxWidth="xs">'#10 +
    '                         <CssBaseline />'#10 +
    '                         <div className={classes.paper}>'#10 +
    '                             <Avatar className={classes.avatar}>'#10 +
    '                                 <LockOutlinedIcon />'#10 +
    '                             </Avatar>'#10 +
    '                             <Typography component="h4" variant="h5" align="center" className={classes.authorization_text}>'#10 +
    '                                 <strong>%APP_NAME%</strong> is requesting permission to access your account.'#10 +
    '                             </Typography>'#10 +
    '%SCOPES_FRAGMENT%'#10+
    '                             <form method="post" action="/oauth/read" className={classes.form} noValidate>'#10 +
    '                                 <input type="hidden" autoComplete="false" name="state" value="%STATE%" />'#10 +
    '                                 <input type="hidden" autoComplete="false" name="next" value="%NEXT%" />'#10 +
    '                                 <input type="hidden" autoComplete="false" name="auth_token" value="%AUTH_TOKEN%" />'#10 +
    '                                 <Button'#10 +
    '                                     type="submit"'#10 +
    '                                     fullWidth'#10 +
    '                                     variant="contained"'#10 +
    '                                     color="primary"'#10 +
    '                                     name="__CONFIRM__"'#10 +
    '                                     value="1"'#10 +
    '                                     className={classes.submit}'#10 +
    '                                     >'#10 +
    '                                 Authorize'#10 +
    '                                 </Button>'#10 +
    '                                 <Button'#10 +
    '                                     type="submit"'#10 +
    '                                     fullWidth'#10 +
    '                                     variant="contained"'#10 +
    '                                     color="secondary"'#10 +
    '                                     name="__CANCEL__"'#10 +
    '                                     value="1"'#10 +
    '                                     className={classes.submit}'#10 +
    '                                     >'#10 +
    '                                 Close'#10 +
    '                                 </Button>'#10 +
    '                             </form>'#10 +
    '                         </div>'#10 +
    '                         <Box mt={8}>'#10 +
    '                             <Copyright />'#10 +
    '                         </Box>'#10 +
    '                     </Container>'#10 +
    '             );'#10 +
    '         }'#10 +
    ''#10 +
    '         ReactDOM.render('#10 +
    '             <ThemeProvider theme={theme}>'#10 +
    '                 <CssBaseline />'#10 +
    '                 <App />'#10 +
    '             </ThemeProvider>,'#10 +
    '             document.querySelector("#root"),'#10 +
    '         );'#10 +
    '      </script>'#10 +
    '   </body>'#10 +
    '</html>';

  OAUTH_HTML_AUTH_SCOPE_FRAGMENT =
    '                        <Typography component="h5" variant="h6" align="center" className={classes.scope_text}>'#10 +
    '                            <strong>This application will be able to:</strong>'#10 +
    '                        </Typography>'#10 +
    '                        <Box className={classes.scopes_box}>'#10 +
    '%SCOPES_BOX%'+
    '                        </Box>'#10;

  OAUTH_HTML_AUTH_SCOPE_ITEM =
    '                            <Chip label="%SCOPE_DESCRIPTION%" />'#10;

implementation

end.
