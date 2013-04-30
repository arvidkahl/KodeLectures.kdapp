# > index.coffee
{MainView} = KodeLectures.Views  

do ->
  
  KD.enableLogs()

  console.log 'Development version of KodeLectures starting...'  

  # Checking for query parameters -> TBI
  
  useFakeQuery = no # yes
  
  if useFakeQuery 
    query = 'kl:arvidkahl:md5'
  else 
    query = 'QUERY HERE'
    
  loader     = new KDView
    cssClass : "kodelectures loading"
    partial  : "Loading KodeLectures..."  
  
  appView.addSubView loader
    
  # Integrity Check before we load the MainView
  
  io = new KodeLectures.Controllers.FileIOController
  console.log "%cIntegrity Check starting.","color:#00bb00;"
  console.time 'Integrity Check'
  io.checkAppIntegrity (err)=>
    console.timeEnd 'Integrity Check'
    
    unless err
      console.log 'Loading MainView'
      
      mainView   = new MainView
        cssClass : "kodelectures"
        ace      : Ace
      
      appView.removeSubView loader
      appView.addSubView mainView
    
      # Forward query join request to app if it exists and is a sessionKey
      if /^kl:[^:]+:[^:]+$/.test query then KD.utils.wait 1000, =>
        mainView.emit 'JoinSessionFromQuery', query
    
    else 
      new KDNotificationView
        title     : 'There is an integrity issue in this app. Please check the console.'
        duration  : 5000
    
      console.log '%cKodeLectures.kdapp: There is an integrity issue in this apps data.', 'font-size:14px;color:red;'
      console.log err