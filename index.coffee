# > index.coffee
{MainView} = KodeLectures.Views  

do ->
  
  KD.enableLogs()

  console.log 'Development version of KodeLectures starting...'  

  loader     = new KDView
    cssClass : "kodelectures loading"
    partial  : "Loading KodeLectures..."  
  
  appView.addSubView loader
    
  require ["ace/ace"], (Ace)=>
    
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
      
      else 
        new KDNotificationView
          title     : 'There is an integrity issue in this app. Please check the console.'
          duration  : 5000
      
        console.log '%cKodeLectures.kdapp: There is an integrity issue in this apps data.', 'font-size:14px;color:red;'
        console.log err